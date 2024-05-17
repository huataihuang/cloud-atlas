.. _vmware_fusion:

==============================
Studio环境中的VMware Fusion
==============================

虽然 :ref:`kvm_docker_in_studio` 可以模拟集群部署，但是经常出差，偶尔也遇到无法远程访问测试主机，就需要在个人笔记本上构建一个虚拟化平台。由于我个人笔记本使用的是macOS，选择的虚拟化技术主要有：

- VMware
- VirtulBox
- :ref:`xhyve`

.. note::

   VirtualBox是跨平台的桌面虚拟化技术，在服务器领域使用较少，所以我一般不使用。

   我比较倾向使用类似KVM的 :ref:`xhyve` 技术，但是目前在macOS平台还不成熟，使用有较多限制和缺陷。

   目前我准备采用VMware，原因是在软件促销时购买了licence，加上VMware确实非常便利且性能优越。

.. note::

   好消息!!!

   2024年5月，VMware宣布 **对于个人用户** `VMware Fusion Pro: Now Available Free for Personal Use <https://blogs.vmware.com/teamfusion/2024/05/fusion-pro-now-available-free-for-personal-use.html>`_ ；并且 `VMware Workstation Pro: Now Available Free for Personal Use <https://blogs.vmware.com/workstation/2024/05/vmware-workstation-pro-now-available-free-for-personal-use.html>`_ :

   - 个人用户版本 VMware Fusion Pro / VMware Workstation Pro 和订阅版本完全一致，唯一区别是免费版本会显示“本产品仅供个人使用”
   - 预计作为虚拟化巨头， `VMware 将其 Workstation Pro 和 Fusion Pro 产品免费提供给个人使用 <https://www.solidot.org/story?sid=78167>`_ 将扩大其影响力，并和广泛用于云计算的开源的 :ref:`kvm` 竞争

.. note::

   根据 `VMware Fusion Pro: Now Available Free for Personal Use <https://blogs.vmware.com/teamfusion/2024/05/fusion-pro-now-available-free-for-personal-use.html>`_ 说明，用户需要升级到 13.5.2 之后才能使用VMware提供的免费个人版本。

   不过，由于我现在使用的笔记本 :ref:`mba13_early_2014` 过于古老，使用的Big Sur 11.7.10 过于古老，所以暂时无法实践。等后续我使用较好的硬件再做尝试...

VMware Fusion
===============

VMware Fusion基于 Intel 的 macOS操作系统运行的虚拟机系统，通过将物理硬件映射到虚拟机的资源，使得虚拟机具有自己的处理器、内存、磁盘和I/O设备。VMware Fusion 有Pro版本，提供了更适合模拟集群的高级特性：

- 支持软链接Clone，可以大大节约磁盘占用
- 创建高级自定义网络连接配置
- 设置带宽、数据包丢失和虚拟网络适配器的延迟，以模拟各种网络环境 (这是一个非常方便的模拟测试功能)
- 使用 Rest API
- 启用 UEFI 安全引导

VMware Fusion Player
----------------------

对于个人使用，VMware提供了一个简化版本的免费license，称为 VMware Fusion Player。

我在升级macOS版本到到最新的Big Sur 11.1 版本之后，就无法使用原先购买的VMware Fusion Pro 11.x ，所以升级到 VMware Fusion 12。不过，由于目前较少使用macOS上的VMware，所以考虑个人使用要求不高，就改为在安装时申请一个个人使用的免费license。使用个人license安装的VMware Fusion，是Player版本，功能简化，不过对于运行单机少量虚拟机也足够。

Fusion 12
-------------

2020年底推出的Fusion 12适配了最新的macOS 11.1 Big Sur，不过启动虚拟机时候会提示::

   You are running this virtual machine with side channel mitigations enabled.

   Side channel mitigations provide enhanced security but also lower performance.

   To disable mitigations, change the side channel mitigations setting in the advanced panel of the virtual machine settings.
   
   Refer to VMware KB article 79832 at https://kb.vmware.com/s/article/79832 for more details.

这个问题可在虚拟机关闭状态下，选择菜单 ``Virtual Machine > Settings > Advanced`` 然后选择 ``Disable Side Channel Mitigations``

.. figure::  ../../_static/apple/vmware/disable_side_channel_mitigations.png
   :scale: 70

VMware Fusion克隆虚拟机
=========================

和 :ref:`clone_vm` 类似，在VMware Fusion中，不仅支持快速clone虚拟机，而且借助macOS的 :ref:`apfs` 可以实现秒速复制，即 ``copy-on-write`` ，可以极大节约磁盘空间消耗。

.. note::

   复制VMware虚拟机是进行虚拟机备份的最根本方法，详细的备份虚拟机，请参考 `备份VMware虚拟机 <https://github.com/huataihuang/cloud-atlas-draft/blob/master/virtual/vmware/backup_vmware_vm>`_ 。

- 关闭虚拟机
- 找到虚拟机捆绑包：捆绑包是一系列文件组成的包，包括虚拟机的磁盘（数据）和配置文件。默认虚拟机捆绑包位于 ``Macintosh HD/Users/User_name/Virtual Machines`` - `在 VMware Fusion 中查找虚拟机捆绑包 (1007599) <https://kb.vmware.com/s/article/1007599?lang=zh_CN>`_
- 按住 ``option`` 键拖放捆绑包，表示复制文件，这样macOS就会复制捆绑包奥。
- 使用VMware Fusion打开这个新虚拟机，此时Fusion会询问是否已经移动或复制该虚拟机。请选择 ``已复制该虚拟机``
  
.. note::

   选择 ``已移动该虚拟机`` ，则表示该虚拟机从新位置启动同一个虚拟机，所有设置不便。如果选择 ``已复制该虚拟机`` ，将生成新的 UUID 和 MAC 地址，这可导致 Windows 需要重新激活，还可能会导致出现网络问题。

安装VMware Tools
==================

VMware Tools是用于增强虚拟机的Guest操作系统性能并改进虚拟机管理的使用程序套件。推荐采用YUM安装发行版提供的vmware tools工具::

   yum install open-vm-tools

.. note::

   如果Linux发行版不是基于RPM，使用自定义内核，或者是不提供RPM安装程序的ESX(i) 4.1/5.x，则采用编译方式安装。详细请参考 `VMware Tools <https://github.com/huataihuang/cloud-atlas-draft/blob/master/virtual/vmware/install_vmware_tool_in_centos_guest.md>`_ 

   安装了VMware Tools之后，可以设置Host主机文件目录共享给Guest。

macOS虚拟化的限制
==================

其实我最需要的虚拟化技术是SR-IOV (退而求其次则使用 PCI passthrough)，即通过VT-d技术使得虚拟机能够直接访问笔记本硬件，特别是AMD Randeon Pro 555X GPU，这样就能够在虚拟机内部 :ref:`build_tensorflow` ，验证和学习 :ref:`machine_learning` 。

但是很不幸，我Google发现，问题在macOS上：PCI passthrough需要硬件和软件同时支持，虽然现代的Mac硬件上支持VT-d，但是在macOS操作系统并不支持IOMMU，这样就不能把PCI设备（包括GPU）直接给虚拟机使用。解决的方法是在MacBook上安装Linux或Windows，这样才能实现虚拟机操作系统使用GPU。( `VM: Mac OSX Host, Windows Guest: Use VT-d so that the fast GPU is available for the VM? <https://superuser.com/questions/917296/vm-mac-osx-host-windows-guest-use-vt-d-so-that-the-fast-gpu-is-available-for>`_ ) ( 不仅VMware无法实现PCI passthrough， :ref:`xhyve` 也可能因为同样原因无法实现 `Device Passthrough ( Most notably, GPU ) #108 <https://github.com/machyve/xhyve/issues/108>`_ )

.. note::

   IOMMU是 `Intel VT-d <http://www.linux-kvm.org/page/How_to_assign_devices_with_VT-d_in_KVM>`_ 和 AMD IOV技术的通用名，类似PCI passthrough，但是需要注意两者是有区别的：
   
   - IOMMU（例如Intel VT-d技术）的实现 `SR-IOV <https://blog.scottlowe.org/2009/12/02/what-is-sr-iov/>`_ 中，保留了所有虚拟化指令，被虚拟化的硬件设备是知道自己被虚拟化了，并且能够把硬件(PF)分割成多个设别(VF)分别提供给不同的虚拟机。
   - PCI passthrough比SR-IOV速度更快，但是硬件设备不分割，而是整个提供给一台虚拟机使用，此时甚至连物理主机也不能使用设备。比较常用的是在物理服务器上运行的数据库虚拟机，可以连接到FiberChannel SAN设备上。

   参考: `What is IOMMU and will it improve my VM performance? <https://askubuntu.com/questions/85776/what-is-iommu-and-will-it-improve-my-vm-performance>`_

.. note::

   由于这个限制，我考虑在最新的macOS 10.15 发布之后，重新规划安装macOS+Linux实现双启动，以便在个人笔记本上构建完整的虚拟化系统。敬请期待!

快捷键隐藏VMware窗口
======================


参考 `Is it possible to run VMware Fusion in the background to hide the windows and icons it produces? <https://apple.stackexchange.com/questions/68928/is-it-possible-to-run-vmware-fusion-in-the-background-to-hide-the-windows-and-ic/68941>`_

在VMware Fusion窗口启动虚拟机之后，同时按下 ``Command+Option+Shift+Esc`` 可以关闭VMware窗口并且保持虚拟机在后台运行。非常赞的方法！

参考
======

- 请参考我的一些笔记 `cloud-atlas-draft: wmware <https://github.com/huataihuang/cloud-atlas-draft/tree/master/virtual/vmware>`_
