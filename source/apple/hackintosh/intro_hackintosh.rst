.. _intro_hackintosh:

========================
Hackintosh(黑苹果)简介
========================

我的想法
==========

我从2011年开始使用第一台 :ref:`mba11_late_2010` ，几乎都是将macOS作为自己的工作客户端。特别是在阿里能够选择配置苹果笔记本，从x86到Apple Silicon架构的MacBook，能用原生系统，所以一直都没有想要自己折腾Hackintosh(黑苹果)。

不过， :ref:`whats_past_is_prologue` ，失业之后再折腾新设备不太经济，我现在专注于深入挖掘自己已经投入大量资金和时间的二手设备 :ref:`hpe_dl380_gen9` 和 :ref:`dell_t5820` ，以及自己组装的台式机和 :ref:`raspberry_pi` 。

但是，我发现一个问题，现有手头最好的能够使用的苹果设备是 **十三年前** 购买的 :ref:`mbp15_late_2013` ，已经老到无法安装最新的macOS，甚至连很多主流软件都无法在旧版macOS上运行了。这带来了很多不便。

.. note::

   由于2025年和2026年出现了内存、存储芯片荒，原本春季可能上市的M5 mac mini也迟迟没有推出，等到9月份虽然M6 mac mini终于推出，但是价格也比原本预期高很多，实在剁不下手了。有可能要到2027甚至2028年才有合适价位的设备可以购买。

那么怎么让旧设备继续"发光发热"呢？

经过一番折腾，我终于 :ref:`oclp_macos` 。没错，终于能够让 **十三年前** :ref:`mbp15_late_2013` 爬起来再战三百回合。

但是， :ref:`mbp15_late_2013` 内置的 :ref:`nvidia_gpu` 驱动已经被macOS废弃，通过 ``OCLP`` 强行注入驱动带来很多奇怪的异常，特别是现代网页的复杂 :ref:`javascript` 常常触发驱动异常，导致系统假死没有响应。

考虑到我后期移动工作可能会采用更低端轻便的 :ref:`mba11_late_2010` (我是多想不开要自我折磨)，我就想如何充分利用服务器硬件来实现一个云端macOS/Windows环境，用于开发和日常使用:

- 所有的重负载计算和图形渲染都由服务器CPU/GPU承担
- 通过 :ref:`sunshine` / :ref:`moonlight` 推流实现本地轻量级显示和操作
- 任何时候都能够回到一致的工作桌面，永不停机的工作环境

这里有一个巧妙的workaround，原本在 :ref:`mbp15_late_2013` 上通过 ``OCLP`` 注入NVIDIA驱动，在组件 Hackintosh(黑苹果) 就可以选择最兼容macOS的 :ref:`amd_gpu` 来绕过驱动异常问题，按照gemini推测，即使采用入门级的 :ref:`amd_rx580` 也能带来很大的性能提升。

构想的方案
===============

:ref:`dell_t5820` 作为典型的企业级工作站，其底层硬件( :ref:`xeon_w` 我实际使用 :ref:`xeon_w-2225` )在黑苹果社区有非常成熟的模拟方案。

- 最高可模拟的 macOS 版本：macOS 15 (Sequoia)

  - 模拟身份: 可以在 ``OpenCore`` 中将其 ``SMBIOS`` 仿冒为 ``MacPro7,1`` (即 **2019款 Mac Pro** )，因为真实的MacPro7.1本身就是使用Intel Xeon W-32xx 处理器(与T5820使用的W-21xx/22xx同属Skylake-X/Cascade Lake-X架构)，所以指令集和PCIe通道映射高度一致。
  - Xcode 兼容性： macOS 15 完全能够运行 Xcode 16，能够满足 2026/2027 年绝大多数 iOS 18 / iOS 19/20 的开发与编译需求。

显卡选择: :ref:`amd_mi50`
---------------------------

我最初选择 :ref:`amd_rx580` 想通过一个低成本硬件来体验黑苹果(当时还没有解决 :ref:`dell_t5820_gpu` 问题)，但是很不幸的是，二手矿卡导致T5820的电源背板电流击穿，我当时误判为主板故障，花了700元重新购买了 :ref:`dell_t5820_mainboard` 。

不过，新购买的主板是二代主板，能够更稳定支持大负载先看， :ref:`amd_mi50` 在完成 :ref:`amd_mi50_flash_vbios` 刷入Pro V420 VBIOS之后，具备了 EFI Image (GOP)，已验证能够点亮。所以我能够充分使用我的双 :ref:`amd_mi50` 来实现我的梦想。

不足之处
----------------

我的 :ref:`dell_t5820` 的处理器是 :ref:`xeon_w-2225` (4核8线程，基频4.1GHz / 睿频4.6GHz) ，是非常古老的 **基于 14nm 的 Skylake/Cascade Lake** 微架构，单核性能较低，在 :ref:`x-plane` 和 :ref:`ms_flight_simulator` 这种只能以较低帧数运行。X-Plane 12 的物理引擎（计算空气流过塞斯纳 172 机翼的每一颗粒子效果）全部压在 CPU 的核心 0 上，即使GPU( :ref:`amd_mi50` 非常空闲)，CPU仍然会高负载报警。在复杂大机场（如首都机场、洛杉矶机场）、多云雨天气、或者开启大量 AI 密集交通时，帧率可能会被 **限制在 25 ~ 35 帧左右** 。

再次构思的方案
=================

实际上我折腾 :ref:`c246_mi50_hackintosh` 花了好几天时间，一点点拼凑出 ``config.plist`` ，而最后居然还没有成功。这使得我非常沮丧...

gemini提示我“觉得极度折腾是非常正常的，因为手写 OpenCore 的 config.plist 相当于用汇编语言去适配一台电脑的底座 BIOS”。而现在绝大多数黑苹果玩家和 KVM 虚拟机玩家，采用的都是以下几种大幅降低门槛的"快捷方式":

- 现成 EFI 库(“抄作业”模式): 黑苹果社区（GitHub、Tonymacx86、远景论坛、Geekbench 数据库）有极其庞大的开源生态。

  - 物理机：对于常见的主板（如华硕/微星/技嘉的常规型号，甚至 Dell T5820 这类经典工作站），GitHub 上通常有现成的开源仓库（比如搜索 Dell-T5820-Hackintosh-EFI）。
  - **自动化生成工具（OCAT）** : 现在很少有人用 ProperTree 逐行敲代码，大家普遍使用 OpenCore AuxiliaryTools (OCAT) 这种图形化工具，直接输入 CPU 架构（如 Coffee Lake / Cascade Lake），软件就会自动套用官方最佳实践模板，一键生成正确的 Config。

- KVM 虚拟机黑苹果(“降维打击”模式): 在 KVM 下装黑苹果，再也不需要去理会物理主板那些折磨人的 BIOS 缺陷、复杂的 ACPI 补丁、声卡网卡 Inject、甚至是讨厌的 MMIO 内存映射冲突了。

  - **统一的虚拟硬件环境** ：KVM 建立了一个标准的“虚拟 Mac”。QEMU 模拟出来的主板和芯片组结构对 macOS 来说是极其标准的。
  - **成熟的一键开箱工具** : 在 Linux 下，社区早已将 OpenCore 的 KVM 镜像打磨得极为成熟。

    - OSX-KVM
    - macOS-Simple-KVM
    - docker-osx

.. csv-table:: OSX-KVM等虚拟机黑苹果技术对比
   :file: intro_hackintosh/kvm_hackintosh.csv
   :widths: 10,30,30,30
   :header-rows: 1

``OSX-KVM`` 是目前KVM 虚拟黑苹果领域最地道、最成熟的项目。提供纯净的 QEMU 启动脚本以及一键生成 XML 配置文件（方便导入 Virt-Manager 图形界面管理）:

  - PCIe 硬件直通原生友好：基于标准的 Libvirt/Qemu 架构
  - CPU/内存性能: 提供了针对 Intel Xeon/Core 的最佳 qemu 参数（如 CPU topology、host-passthrough、hugepages 大页内存支持）
  - OpenCore 镜像维护及时

``Docker-OSX`` 将 QEMU/KVM 打包进了 Docker 容器中，主要目的是实现“一键启动 macOS”，广泛应用于自动测试、安全逆向以及 CI/CD 流水线:

  - 如果只是想临时用一下 macOS，甚至不需要外接显示器，只要本地有 Docker，一条命令就能把 macOS 跑起来。
  - 不太适合做GPU 直通的工作站。把物理 PCIe 设备透传进 Docker 容器，再由容器内的 QEMU 接管，网络、权限和 VFIO 设备的挂载配置会变得比纯 Libvirt 繁琐得多，极易掉坑。

**根据gemini对比技术方案，我后续将尝试通过虚拟机来运行黑苹果，以降低构建精力消耗**

参考
=======

- `wikipedia: Hackintosh <https://zh.wikipedia.org/wiki/Hackintosh>`_
- gemini
