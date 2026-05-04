.. _upgrade_ubuntu_26.04:

==========================
升级到Ubuntu 26.04 LTS
==========================

26.04版本说明
=============

以下是我关注的特性:

- 内核 GA generic stack 从 6.8 升级到 7.0

  - 默认启用crash dump
  - 新调度系统 ``sched_ext`` 提供了 :ref:`ebpf` 程序调度机制

- :ref:`systemd` 从255升级到259

  - **移除** 了 :ref:`cgroup` v1 支持
  - 默认挂载使用 tmpfs 作为 ``/tmp`` 目录`

- 使用 :ref:`dracut` 作为默认initial ramdisk架构，替代了 ``initramfs-tools``

  - dracut使用systemd来 initial ramdisk
  - dracut现在支持蓝牙和NVMe-oF(NVMEpress over Fabrics)

- 26.04已经具备了 :ref:`nvidia_container_toolkit` ，我检查了NVIDIA官网提供的 :ref:`nvidia_gpu` 已经提供了驱动可用于 :ref:`tesla_a2` 的最新 :ref:`cuda` 13.2

  - 已支持NVIDIA Dynamic Boost(根据负载动态支持CPU和GPU的能耗)，在游戏时能提升GPU更多电能以增强性能

- 26.04已经添加了 :ref;`rocm` 7.1.0 已测试支持 MI-100 (gfx908) (官方文档未显示支持 :ref:`amd_mi50` 待实际验证)

- 支持最新Intel集成和独立的GPU(感觉支持的图形特性较多)

  - 支持Intel Core Ultra Xe2 和 Xe3
  - 支持Intel Arc 5: B570 和 B580
  - 支持Intel Arc Pro: B50, B60, B70
  - 提升了GPU和CPU的渲染性能(Intel Embree support)
  - 完全硬件加速视频解码: AVC, JPEG, HEVC, AV1
  
- 支持 :ref:`raspberry_pi` 基于minimal image (desktop-minimal取代了desktop，可以削减默认安装的应用程序)，如果要在升级以后移除掉 ``ubuntu-desktop`` meta-package遗留的应用，可以通过如下命令

.. literalinclude:: upgrade_ubuntu_26.04/purge_ubuntu-desktop
   :caption: 移除ubuntu-desktop遗留应用

release-upgrade
=================

2026年4月23日Ubuntu 26.04 LTS发布，不过，根据各方信息了解，通常需要到 26.04.01 版本发布时才会提供 release-upgrade 功能，我准备等待数周等待 26.04.01 再做release升级...

.. literalinclude:: upgrade_ubuntu_26.04/meta-release
   :caption: 检查是否支持更新

当返回值是1时候才表明支持 release-upgrade

参考
=======

- `How to upgrade your Ubuntu release <https://ubuntu.com/server/docs/how-to/software/upgrade-your-release/>`_
- `26.04 LTS: Summary for LTS users <https://documentation.ubuntu.com/release-notes/26.04/summary-for-lts-users/>`_
- `Upgrade Server from 25.10 to 26.04 LTS  <https://discourse.ubuntu.com/t/upgrade-server-from-25-10-to-26-04-lts/80884>`_
- `How to upgrade to Ubuntu 26.04 ?? best way <https://www.reddit.com/r/Ubuntu/comments/1sxmr2b/how_to_upgrade_to_ubuntu_2604_best_way/>`_
- `Ubuntu 24.04 to 26.04 LTS upgrade is not available in the Ubuntu Software Updater <https://askubuntu.com/questions/1566029/ubuntu-24-04-to-26-04-lts-upgrade-is-not-available-in-the-ubuntu-software-update>`_
