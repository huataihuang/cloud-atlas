.. _vmware_macos_on_macos:

===========================
VMware在macOS中运行macOS
===========================

从recovery分区安装macOS
==========================

安装了VMware Fusion之后，提供了选择安装模式( ``Select th Installation Method`` ):

- 选择 ``Install macOS from the recovery partition`` :

.. figure:: ../../_static/apple/vmware/vmware_install_macos_from_recovery.png

.. figure:: ../../_static/apple/vmware/vmware_install_macos_from_recovery-1.png

.. warning::

   从Recovery分区安装macOS似乎存在问题，我观察了很久没有任何网络流量、磁盘IO和CPU消耗，感觉存在bug (VMware Fusion 13.2)

   从 `Installing OS X from recovery partition fails <https://community.broadcom.com/vmware-cloud-foundation/communities/community-home/digestviewer/viewthread?MessageKey=35265828-9774-4e21-92f6-3a53697ae8e3>`_ 似乎确实不容易成功，所以我放弃这个方法。

从U盘或镜像安装macOS
========================

我的实践遇到了比较奇怪的问题，当我选择从安装介质安装macOS时，创建虚拟机总是失败。但是后来我尝试了一次 ``customize VM`` ，则一路顺利，但是最后提示
