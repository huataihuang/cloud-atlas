.. _fail_create_container_cannot_allocate_memory:

===================================================
内存分配错误无法创建容器异常排查
===================================================

最近 :ref:`helm3_prometheus_grafana` 完成生产环境的监控部署，在一次 :ref:`update_prometheus_config_k8s` 意外发现需要更新的pod没有正常替换( 原本是准备 :ref:`kube-prometheus-stack_persistent_volume` )。检查pods状态:

.. literalinclude:: fail_create_container_cannot_allocate_memory/ContainerCreating_fail
   :caption: 创建pod失败，卡在容器创建步骤
   :emphasize-lines: 3,6

检查容器创建失败原因:

.. literalinclude:: fail_create_container_cannot_allocate_memory/check_ContainerCreating_fail
   :caption: 检查创建pod失败原因
   :emphasize-lines: 6,13

可以看到两个替换pods的容器创建失败都是由于内存分配失败导致 ``cannot allocate memory``

由于正在走 :ref:`kube-prometheus-stack_persistent_volume` ，一旦切换就会出现 :ref:`grafana` 数据丢失，需要从备份中恢复，所以断开时间较长。非常巧，这个卡住并不影响 :ref:`prometheus_configuration` 更新，只是容器不能重建导致状态一直显示不正常，虽然一切功能运行正常。

模仿 ``kubernetes`` 的 ``events`` 中内容手工创建cgroup目录确实报错::

   # mkdir /sys/fs/cgroup/memory/kubepods/besteffort/podeb6abc31-be1d-46a3-b93e-4230893ac649
   mkdir: cannot create directory ‘/sys/fs/cgroup/memory/kubepods/besteffort/podeb6abc31-be1d-46a3-b93e-4230893ac649’: Cannot allocate memory

但是非常奇怪的是，通过 ``top`` 观察可以看到系统内存充足::

   Tasks: 365 total,   1 running, 364 sleeping,   0 stopped,   0 zombie
   %Cpu(s):  0.9 us,  0.2 sy,  0.0 ni, 98.8 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st
   KiB Mem : 25982569+total, 19016694+free, 10491360 used, 59167380 buff/cache
   KiB Swap:        0 total,        0 free,        0 used. 24839529+avail Mem
   
     PID USER      PR  NI    VIRT    RES    SHR S  %CPU %MEM     TIME+ COMMAND
   21993 admin     20   0   42.7g   4.9g   1.4g S  23.6  2.0   4510:43 prometheus
   ...

检查 slab ::

   # ls /sys/kernel/slab | wc -l
   182210

检查 ``slabtop`` :

.. literalinclude:: fail_create_container_cannot_allocate_memory/slabtop
   :language: bash
   :caption: 检查 ``lsabtop``

解决方法
===========

`Kubernetes Cannot Allocate Memory | Solutions Revealed. <https://bobcares.com/blog/kubernetes-cannot-allocate-memory/>`_ 提供了相关信息和解决方案:

- 上述报错是因为 ``cgroup memory allocation`` 无法分配
- 内核 ``3.10.0-1062.4.1`` 或更新版本解决了 ``slab`` 泄漏问题，这个 ``slab leak`` 会导致 ``kmem control group`` 奔溃(不过，也有讨论提到高于 ``3.10.0-1160.36.2.el7.x86 64`` 还是存在问题)

我的服务器内核版本确实是 ``3.10.0-1160.83.1.el7.x86_64`` ，看起来确实存在这个 ``slab leak`` 问题

解决方法有两个:

方法一
~~~~~~~~

- 配置内核参数 ``cgroup.memory=nokmem`` (修订 ``/etc/default/grub`` 的 ``GRUB_CMDLINE_LINUX`` 行配置)

- 修改grub并重启::

   grub2-mkconfig -o /boot/grub2/grub.cfg
   reboot

方法二
~~~~~~~~

升级内核

我检查了我的服务器，当前操作系统版本::

   # cat /etc/redhat-release
   CentOS Linux release 7.9.2009 (Core)

但是如果不做大版本升级，则内核版本升级也只有 ``3.10.0-1160.88.1.el7`` : 已检查 mirrors.163.com ，CentOS 7.9.2009 已经是最高的7系列版本，从仓库能够找到的最新内核版本也只有 ``3.10.0-1160.88.1.el7`` ，这已经是 2023年3月8日的更新版本

Red Hat官方解决方案
=====================

根据Red Hat官方知识库 `The kmem enabled memory cgroup cannot be fully released unless all associated kmem_cache are "destroyed" <https://access.redhat.com/solutions/5785961>`_ 提供的解决方案:

- 如果你的工作负载环境经常遇到这个问题，则建议升级到 RHEL 8.1 版本，内核补丁已经修复了这个问题
- 对于RHEL7系统(RHEL 7.7及更高版本)，需要在内核命令行参数添加 ``cgroup.memory=nokmem`` 来禁止内核内存记账功能( **disable the kernel memory accounting** )
- 目前RedHat内部私有bug修复补丁正在调研 `BZ#1925619 <https://bugzilla.redhat.com/show_bug.cgi?id=1925619>`_ (需要注意RHEL7已经进入Maintenance phase II, RedHat不保证这个bug一定修复)

根因
~~~~~~~

在分层记账(hierarchical accounting)的上下文(context)中，根据 ``mm/memcontrol.c`` 中的逻辑，只有在所有未决的内核内存记账(关联的slab对象)被删除以后，内存控制的cgroup才会被正确删除。即一旦页面被释放，并且相应的 ``kmem_cache`` (slab) 被笑会。此时，分配给每个内存控制的 cgroup ( ``memcg-ID`` )的唯一标识符在最后一次引用技术下乡时从 "私有IDR" (private IDR)中删除。所以，确实有可能在正常运行时消耗掉整个IDR。此时遇到 ``mkdir`` 返回 ``-ENOMEM`` (或无法分配内存)，即使同一层次结构中的
``cgroup`` 数量表明依然有可用空间(以创建额外的内存控制cgroup)。

这个问题的已知/适当补丁解决方案是将 ``kmem`` 记账移动/重新设置为父内存cgroup(RHEL 8.1补丁)；但是RHEL7缺乏先决的几个补丁来修改内存记账基础架构，以便能够重新设置内存记账，所以这个补丁不太可能移植到RHEL 7。

我的修复
~~~~~~~~~~

我参考Red Hat官方方法: 首先升级CentOS 7.9操作系统(但是由于生产限制不能升级到8.1版本)，然后修改内核参数添加 ``cgroup.memory=nokmem`` 关闭内存记账功能，并重启服务器

参考
======

- `Kubernetes Cannot Allocate Memory | Solutions Revealed. <https://bobcares.com/blog/kubernetes-cannot-allocate-memory/>`_
- `K8s - Slab memory leakage <https://1week.tistory.com/24>`_
- `The kmem enabled memory cgroup cannot be fully released unless all associated kmem_cache are "destroyed" <https://access.redhat.com/solutions/5785961>`_
