.. _ubuntu_on_thinkpad_x220:

===========================
ThinkPad X220上运行Ubuntu
===========================

安装
=========

我主要的云计算模拟集群部署在 :ref:`ubuntu_on_mbp` 系统中（主机命名为 ``xcloud`` ），在 ThinkPad X220上部署云计算模拟主要是作为补充，则主机名命名为 ``zcloud`` 。

安装方式同样按照 :ref:`base_os` ，详细的安装如下：

- :ref:`ubuntu_server`
- :ref:`ubuntu_desktop`

.. note::

   ThinkPad X220 硬件性能较差，并且CPU处理器 :ref:`intel_core_i5_2410m` 支持虚拟化特性有限（不支持 :ref:`intel_vmcs` 加速）所以不适合运行嵌套虚拟化技术，相对而言就不能部署OpenStack模拟集群。不过， :ref:`docker` 和 :ref:`kubernetes` 技术不需要依赖KVM虚拟化，虽然不能模拟大规模OpenStack集群，但是，可以通过Kubernetes集群来实践容器集群技术，并且可以和 ``xcloud`` 互为补充。

安装过程和 :ref:`ubuntu_on_mbp` 相同，这里只简单记录，并补充一些特定的设置。

.. note::

   ThinkPad X220笔记本（物理主机）上安装的Host操作系统，我命名为 ``zcloud`` ，后续文档中可能会引用这个Host主机名。

ThinkPad硬件设备对Linux兼容性较好，安装完Ubuntu Server操作系统后，无需安装特定驱动升级。笔记本显卡和无线网卡驱动已经默认包含在Ubuntu发行版中，所以可以直接使用系统。

安装后升级系统
=================

初次安装完操作系统，请务必先做系统更新，确保所有软件都保持最新::

   sudo apt update
   sudo apt upgrade

设置无线网络
==============

ThinkPad X220笔记本无线网卡 ``Intel Corporation Centrino Advanced-N 6205 [Taylor Peak] (rev 34)`` 默认已经被Ubuntu发行版支持，所以只需要添加无线网卡配置就可以使用。

配置方法请参考 :ref:`set_ubuntu_wifi` 完成，和MacBook Pro设置方法相同（除了不需要安装专用驱动）。

配置
=========

ThinkPad X220配置Ubuntu方法和MacBook Pro基本相同，所以请参考 :ref:`studio_ubuntu_setup` 完成。

请参考 :ref:`reduce_laptop_overheat` 设置电源管理。
