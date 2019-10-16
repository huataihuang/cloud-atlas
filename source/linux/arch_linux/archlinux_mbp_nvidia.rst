.. _archlinux_mbp_nvidia:

=====================================
Arch Linux环境MacBook Pro Nvidia显卡
=====================================

我的笔记本MacBook 是 2013年底版本，属于 MacBook Pro 11,x 系列。从 ``dmidecode`` 可以看到::

   System Information
        Manufacturer: Apple Inc.
        Product Name: MacBookPro11,3

Nvidia显卡
=============

- 检查显卡::

   lspci -k | grep -A 2 -E "(VGA|3D)"

输出::

   01:00.0 VGA compatible controller: NVIDIA Corporation GK107M [GeForce GT 750M Mac Edition] (rev a1)
    Subsystem: Apple Inc. GK107M [GeForce GT 750M Mac Edition]
        Kernel driver in use: nouveau

当前是开源驱动 ``nouveau`` ，性能较差。

对于 GeForce 600-900 以及 Quadro/Tesla/Tegra K系列显卡，或者更新的显卡(2010-2019年)，安装 ``nvidia`` 或 ``nvidia-lts`` 驱动包::

   sudo pacman -S nvidia

安装完成后需要重启系统，因为 ``nvidia`` 软件包包含屏蔽 ``nouveau`` 模块配置，所以需要重启。

参考
========

- `Arch Linux社区文档 - MacBookPro11,x <https://wiki.archlinux.org/index.php/MacBookPro11,x>`_
- `Arch Linux社区文档 - NVIDIA <https://wiki.archlinux.org/index.php/NVIDIA>`_

