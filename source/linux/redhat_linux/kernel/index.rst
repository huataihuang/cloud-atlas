.. _rhel_kernel:

=====================================
RHEL(Red Hat Enterprise Linux)内核
=====================================

RHEL(Red Hat Enterprise Linux)官方手册提供了系统的内核管理、监控和更新的指南，可以作为 :ref:`kernel` 的生产实践补充。

- `Red Hat Enterprise Linux 7 Kernel Administration Guide <https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/kernel_administration_guide/index>`_ 提供了全面的RedHat服务器内核模块和升级补丁等工作
- `Red Hat Enterprise Linux 8.0 管理监控和更新内核 <https://access.redhat.com/documentation/zh-cn/red_hat_enterprise_linux/8/html/managing_monitoring_and_updating_the_kernel/index>`_ 中文版Red Hat Enterpruse Linux8内核维护手册，和之前RHEL7手册有所修订，并且提供了中文版方便学习参考

我个人断断续续学习参考过RHEL 7的Kernel Administration Guide，不过随着RHEL快速发展进入9系列，RHEL 8已经逐渐成为主流运行系统，所以非常有必要系统学习RHEL 8的内核管理。并且中文版手册，也方便学习参考

.. toctree::
   :maxdepth: 1

   kdump_guide/index
   grubby.rst
   zram.rst

.. only::  subproject and html

   Indices
   =======

   * :ref:`genindex`
