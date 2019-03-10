.. _ubuntu_lts_hwe:

================================
Ubuntu LTS Enablement Stacks
================================

Ubuntu LTS enablement（也称为 HWE 或 Hardware Enablement）stacks为Ubuntu LTS版本提供了较新的内核以及X支持。这些enablement stacks可以手工安装。

Ubuntu 18.04.2 以及更新的版本在Desktop版本提供了一个保持更新的内核以及X对战。服务器架构则默认采用GA内核，并提供了可选的增强内核。

安装HWE软件栈
==============

安装HWE软件栈非常简单：

- Desktop版本安装HWE::

   sudo apt install --install-recommends linux-generic-hwe-18.04 xserver-xorg-hwe-18.04

- Server版本安装HWE::

   sudo apt-get install --install-recommends linux-generic-hwe-18.04

.. note::

   在Ubuntu 18.04 LTS上安装了HWE之后，可以看到内核版本从原先的 4.15.x 系列更改成了 4.18.x 系列，和当前的 Ubuntu 18.10 发行版相当。

   Ubuntu 18.04 LTS也可以安装 ``xserver-xorg-hwe-18.04`` 。

   实际安装了HWE之后，Ubuntu LTS版本和最新的Stable版本差别不大(内核和Xorg)。

参考
=========

- `LTS Enablement Stacks <https://wiki.ubuntu.com/Kernel/LTSEnablementStack>`_
