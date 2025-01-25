.. _run_debian_in_qemu:

==========================
在QEMU中运行debian
==========================

我在 :ref:`lfs` 的构建目标之一就是 :ref:`lfs_virtualization` ，目标是用最精简的系统来运行虚拟化集群。不借助复杂的包装工具(例如 :ref:`libvirt` )，仅使用 QEMU 来实现虚拟化:

- 更为深入理解Linux虚拟化的底层技术
- 使用有限的组件运行起全功能的Linux虚拟化
- 为后续构建更为复杂的 :ref:`lfs_k8s` 提供基础

本文实践将在不同的软硬件环境中完成，并且会不断完善



参考
======

- `QEMU and HVF <https://gist.github.com/aserhat/91c1d5633d395d45dc8e5ab12c6b4767>`_ 非常好的分享
- `Install QEMU on OSX <https://gist.github.com/Jatapiaro/6a7c769a07911adc629e1604729d4c7a>`_
