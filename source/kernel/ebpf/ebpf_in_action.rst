.. _ebpf_in_action:

===================
ebpf实践
===================

在了解了 :ref:`ebpf_arch` 之后，可以做一些实践来获得感性认识，进一步了解eBPF的强大能力。

随着 eBPF 生态系统的发展，现在用于开发 eBPF 程序的工具链也越来越多，通常可以采用:

- 基于 bcc 的开发: bcc 提供了 eBPF 的开发，前端使用 Python API，后端 eBPF 程序的 C 实现。 它简单易用，但性能较差。
- 基于libebpf-bootstrap开发: libebpf-bootstrap提供方便的脚手架
- 基于内核源码开发: 内核源码开发门槛较高，也与底层eBPF原理相关性较高(本文案例)

准备
=====

- 操作系统环境采用 :ref:`ubuntu_linux` ，内核版本 5.4.0 ，我采用 :ref:`priv_cloud_infra` 环境的KVM虚拟机 ``z-udev`` ::

   $ uname -a
   Linux z-udev 5.4.0-125-generic #141-Ubuntu SMP Wed Aug 10 13:42:03 UTC 2022 x86_64 x86_64 x86_64 GNU/Linux

- 安装必要的依赖:

.. literalinclude:: ebpf_in_action/ubuntu_install_dev_env_for_ebpf
   :language: bash
   :caption: 安装开发eBPF的软件工具链

- 在Ubuntu Linux环境安装内核源代码， :ref:`apt` 安装非常方便:

.. literalinclude:: ebpf_in_action/ubuntu_install_kernel_source
   :language: bash
   :caption: Ubuntu Linux安装内核源代码

源代码被安装到 ``/usr/src`` 目录::

   huatai@z-udev:/usr/src$ ls -lh
   total 24K
   drwxr-xr-x 24 root root 4.0K Apr  1 07:13 linux-headers-5.4.0-107
   drwxr-xr-x  7 root root 4.0K Apr  1 07:13 linux-headers-5.4.0-107-generic
   drwxr-xr-x 24 root root 4.0K May 21 23:13 linux-headers-5.4.0-110
   drwxr-xr-x  7 root root 4.0K May 21 23:13 linux-headers-5.4.0-110-generic
   drwxr-xr-x 24 root root 4.0K Sep  7 08:21 linux-headers-5.4.0-125
   drwxr-xr-x  7 root root 4.0K Sep  7 08:21 linux-headers-5.4.0-125-generic
   drwxr-xr-x  4 root root   75 Sep  7 08:32 linux-source-5.4.0
   lrwxrwxrwx  1 root root   45 Aug 10 16:17 linux-source-5.4.0.tar.bz2 -> linux-source-5.4.0/linux-source-5.4.0.tar.bz2
   huatai@z-udev:/usr/src$ sudo tar -jxvf linux-source-5.4.0.tar.bz2
   huatai@z-udev:/usr/src$ cd linux-source-5.4.0





参考
======

- `Introduction to eBPF <https://houmin.cc/posts/2c811c2c/>`_ !  **向原著者致敬**
