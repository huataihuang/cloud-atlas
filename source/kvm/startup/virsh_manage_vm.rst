.. _virsh_manage_vm:

====================
virsh管理虚拟机
====================

在 :ref:`create_vm` 之后，我们可以通过 ``virsh`` 管理虚拟机的生命周期:

.. note::

   本文案例以虚拟机 ``z-b-data-1`` 为案例

启动虚拟机
=============

- 最简单的启动虚拟机命令只需要虚拟机名字，例如启动 ``z-b-data-1`` ::

   virsh start z-b-data-1

在上述 ``start`` 命令之后，可以添加一些有用参数:

  - ``--console`` 启动虚拟机之后，连接到虚拟机的控制台
  - ``--paused`` 启动虚拟机进入暂停状态
  - ``-autodestroy`` 当virsh断开连接后自动销毁虚拟机
  - ``--bypass-cache`` 这个参数结合 ``managedsave`` 使用
  - ``--force-boot`` 放弃任何 ``managedsave`` 选项并导致全新启动

.. _vm_autostart:

配置虚拟机自动启动
======================

- ``virsh`` 提供了 ``autostart`` 命令设置虚拟机自动启动属性，也就是在操作系统启动时自动虚拟机。例如 :ref:`priv_cloud_infra` 中 ``z-b-data-1`` / ``z-b-data-2`` / ``z-b-data-3`` 是部署所有虚拟机镜像存储的 :ref:`ceph` 分布式存储，需要首先在物理服务器启动时自动启动，以便提供其他虚拟机启动时加载镜像::

   virsh autostart z-b-data-1

如果要关闭自动启动，则添加一个 ``--disable`` 参数::

   virsh autostart --disable z-b-data-1

重启虚拟机
=============

- ``virsh`` 重启虚拟机命令 ``reboot`` ，并且提供了 ``--mode modename`` 参数::

   virsh reboot z-b-data-1

保存虚拟机运行状态
====================

``virsh save`` 命令可以将一个运行的虚拟机的虚拟内存当前状态保存到一个指定文件，之后就可以通过 ``virsh restore`` 恢复运行。这个命令有些类似 ``virsh suspend`` 命令，区别在于 ``suspend`` 是暂停在物理主机的内存中，所以如果服务器重启就不能恢复虚拟机的当前状态；而 ``save`` 是把虚拟机内存状态保存到磁盘文件，所以即使物理主机重启，也可以通过对应的 ``restore`` 命令从磁盘文件恢复。

.. note::

   ``virsh save`` 是保存虚拟机的快照( ``snapshot`` )

- ``virsh save`` 保存虚拟机状态::

   virsh save [--bypass-cache] domain file [--xml string] [--running] [--paused] [--verbose]

举例::

   virsh save --bypass-cache z-dev z-dev.save

提示信息::

   Domain z-dev saved to z-dev.save

一旦保存了虚拟机内存状态到磁盘文件，则虚拟机立即关闭

- 对应我们可以恢复保存的虚拟机::

   virsh restore z-dev.save

提示信息::

   Domain restored from z-dev.save

.. note::

   保存 :ref:`iommu` 方式pass-through PCI设备的 ``z-b-data-1`` 虚拟机是报错的::

       virsh save z-b-data-1 z-b-data-1.save

   提示错误::

      error: Failed to save domain z-b-data-1 to z-b-data-1.save
      error: Requested operation is not valid: domain has assigned non-USB host devices

   原因是 libvirt 冻结虚拟机时，虚拟机内部是不知道这个冻结操作，也就无法处理GPU设备的内存内容。解决的方法是采用 :ref:`virsh_dompmsuspend` 结合 :ref:`qemu_guest_agent` 实现vram内存处理才能保存PCIe设备直通的虚拟机状态保存。

suspend 和 resume 虚拟机
=========================

``virsh suspend`` 和 ``virsh resume`` 命令可用来挂起和解冻指定的虚拟机::

   virsh suspend z-dev
   virsh resume z-dev

重命名虚拟机
===============

``virsh domrename`` 可以重命名虚拟机，例如我改变虚拟机用途，用于构建第二个 :ref:`kubernetes` 集群 :ref:`y-k8s` ::

   virsh domrename z-k8s-n-6 y-k8s-m-1

参考
=======

- `STARTING, RESUMING, AND RESTORING A VIRTUAL MACHINE <https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/virtualization_deployment_and_administration_guide/sect-starting_suspending_resuming_saving_and_restoring_a_guest_virtual_machine-starting_a_defined_domain>`_
- `KVM: Autostart a Domain / VM Command <https://www.cyberciti.biz/faq/rhel-centos-linux-kvm-virtualization-start-virtual-machine-guest/>`_
