.. _live_patch_with_ebpf_lsm:

==========================================
使用eBPF LSM热修复Linux内核漏洞(学习笔记)
==========================================

:ref:`lsm` 是一个用于在Linux内核实现安全策略和强制性访问控制的基于hook的框架。直到最近，Linux用户实现安全策略只有连两种方式:

- 配置一个现有的LSM模块，例如AppArmor 或 SELinux
- 编写一个定制的内核模块

Linux 5.7引入了第三种方式: :ref:`prog_lsm` 

LSM BPF允许开发者编写简单的策略而无需配置或加载一个内核模块。LSM BPF编程可以在加载时验证，并且在调用路径上访问到LSM hook时候执行。



参考
=======

- `Live-patching security vulnerabilities inside the Linux kernel with eBPF Linux Security Module <https://blog.cloudflare.com/live-patch-security-vulnerabilities-with-ebpf-lsm/>`_ 学习LSM的参考， `CFC4N的博客 <https://www.cnxct.com>`_ 对原文做了翻译 `使用eBPF LSM热修复Linux内核漏洞 <https://www.cnxct.com/linux-kernel-hotfix-with-ebpf-lsm/>`_ ，我想对LSM和eBPF有一个初步学习，所以准备参考

- `LSM BPF Programs <https://docs.kernel.org/bpf/prog_lsm.html>`_ Kernel官方提供了一个BPF开发指南
