.. _vmware_macos_init:

=============================
VMware运行macOS虚拟机初始化
=============================

使用 :ref:`vmware_fusion` 安装 macOS ``Sequoia 15.2`` :

- 虚拟机硬件配置:

  - 2个CPU core
  - 4GB内存
  - 80GB虚拟硬盘

我没有想到 macOS 能够在 2c4g 的虚拟机中运行起来，不过显然macOS对这样的硬件规格自动做了一些简化，例如看不到桌面的墙纸(只看到一个灰色背景)

初始设置
=========

- 我在macOS操作系统初始设置时创建了一个 ``admin`` 账号(第一个创建账号默认给予管理主机的权限)
- 设置 ``System Settings >> Sharing`` 开启 ``Remote Login`` ，这样可以通过 :ref:`ssh` 登陆主机进行管理也为后续做 :ref:`darwin-jail` 做准备
- 修订 ``/etc/sudoers`` ，设置允许 ``admin`` 组用户无需密码sudo:

.. literalinclude:: vmware_macos_init/sudoers
   :caption: 允许 ``admin`` 组无需密码sudo
   :emphasize-lines: 4

- 安装 ``Xcode Command Line Tools`` :

.. literalinclude:: vmware_macos_init/install_xcode_command_line_tools
   :caption: 安装 ``Xcode Command Line Tools`` (需要在图形界面中的终端执行命令)

- 修订VMware虚拟机配置，优化存储性能:

  - 将虚拟机配置调整为 ``2c6g`` ，增加一些内存可以让虚拟机运行更流畅
  - 调整虚拟磁盘类型，由默认 ``SATA`` 调整为 ``NVMe`` (必要时可以修改成 ``Pre-allocate disk space`` 来进一步优化)
  - 在Advanced配置中

    - 激活 ``Hard disk buffering`` 为 ``Enabled``
    - 激活 ``Disalbe Side Channel Mitigations`` (重要，VMware提示不选择会导致虚拟机性能下降)

.. note::

   VMware虚拟机磁盘优化配置可能很重要，至少我发现没有做优化之前 :ref:`darwin-jail` 刚开始执行同步数据就发生 hang 死现象，优化以后至少能够完整完成 :ref:`darwin-jail`

.. warning::

   我在使用VMware Fusion 13.5.2 最新版本时发现，虚拟机网络极度缓慢，甚至一旦复制流量稍大立即挂起，导致无法完成 :ref:`homebrew` 安装。而且也无法通过网络将打包的 ``jail`` 目录复制出虚拟机。

   总之，非常折腾，我最后是通过外接USB移动硬盘(切换连接到虚拟机和物理主机)，通过移动硬盘复制方式将打包文件复制出来。

- 建议先完成 :ref:`homebrew_init` ，这样能够复制必要的工具
- 制作 :ref:`darwin-jail`

.. note::

   此时得到的是一个非常基本的macOS系统，所以如果要完善工作，还需要安装 :ref:`homebrew` 中的必要工具
