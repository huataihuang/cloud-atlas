.. _docker_kernel_cgroup_mem_swap:

======================================
Docker内核支持cgroup内存和 swap限制
======================================

在 :ref:`alpine_docker` 执行 ``docker info`` 时候，默认会看到如下警告信息::

   WARNING: No memory limit support
   WARNING: No swap limit support

上述报错参考 `Your kernel does not support cgroup swap limit capabilities <https://docs.docker.com/engine/install/linux-postinstall/#your-kernel-does-not-support-cgroup-swap-limit-capabilities>`_ ，通常出现在 Ubuntu 或 Debian系统上，而基于RPM的系统已经默认激活了上述功能。

如果不需要上述能力，则可以忽略报错。也可以在Ubuntu或Debian系统上启用上述功能限制。

内存和swap记账功能会消耗大约1%的可用内存以及总体10%的性能降低，即使Docker没有运行

- 配置 ``/etc/default/grub`` ，添加 ``GRUB_CMDLINE_LINUX`` 行内容添加如下2个键值对::

   GRUB_CMDLINE_LINUX="cgroup_enable=memory swapaccount=1"

- 更新GRUB::

   sudo update-grub

然后重启系统可以消除上述报错警告。

alpine修订方法
==================

对于树莓派上运行 :ref:`alpine_linux` ，则没有使用 Grub 或 extlinux，则直接修订 ``/boot/cmdline.txt`` 在最后添加::

   cgroup_enable=memory cgroup_memory=1 swapaccount=1

但是很奇怪，我系统重启以后发现内核参数并没有上述添加内容，也没有解决 ``docker info`` 输出告警信息

参考
========

- `Your kernel does not support cgroup swap limit capabilities <https://docs.docker.com/engine/install/linux-postinstall/#your-kernel-does-not-support-cgroup-swap-limit-capabilities>`_
- `Pi Image docker info warnings - No kernel memory limit support #303 <https://github.com/me-box/databox/issues/303>`_
