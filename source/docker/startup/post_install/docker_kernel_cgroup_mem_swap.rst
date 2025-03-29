.. _docker_kernel_cgroup_mem_swap:

======================================
Docker内核支持cgroup内存和 swap限制
======================================

在 :ref:`alpine_docker` 执行 ``docker info`` 时候，默认会看到如下警告信息:

.. literalinclude:: docker_kernel_cgroup_mem_swap/docker_info_memory_swap_error
   :caption: ``docker info`` 显示不支持内存和swap限制的警告

上述报错参考 `Your kernel does not support cgroup swap limit capabilities <https://docs.docker.com/engine/install/linux-postinstall/#your-kernel-does-not-support-cgroup-swap-limit-capabilities>`_ ，通常出现在 Ubuntu 或 Debian系统上，而基于RPM的系统已经默认激活了上述功能。

如果不需要上述能力，则可以忽略报错。也可以在Ubuntu或Debian系统上启用上述功能限制。

内存和swap记账功能会消耗大约1%的可用内存以及总体10%的性能降低，即使Docker没有运行

- 配置 ``/etc/default/grub`` ，添加 ``GRUB_CMDLINE_LINUX`` 行内容添加如下2个键值对，然后执行 ``update-grub`` 更新  :ref:`ubuntu_grub` 之后重启系统生效:

.. literalinclude:: docker_kernel_cgroup_mem_swap/grub
   :caption: 配置 ``/etc/default/grub`` ，添加 ``GRUB_CMDLINE_LINUX`` 行内容

alpine修订方法
==================

对于树莓派上运行 :ref:`alpine_linux` 或 :ref:`raspberry_pi_os` ，则没有使用 Grub 或 extlinux，则直接修订 ``/boot/firmware/cmdline.txt`` 在最后添加:

.. literalinclude:: docker_kernel_cgroup_mem_swap/cmdline
   :caption: 树莓派修订 ``/boot/firmware/cmdline.txt`` 激活cgroup内存和swap限制

参考
========

- `Your kernel does not support cgroup swap limit capabilities <https://docs.docker.com/engine/install/linux-postinstall/#your-kernel-does-not-support-cgroup-swap-limit-capabilities>`_
- `Pi Image docker info warnings - No kernel memory limit support #303 <https://github.com/me-box/databox/issues/303>`_
