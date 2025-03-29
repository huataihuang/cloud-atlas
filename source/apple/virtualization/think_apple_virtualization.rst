.. _think_apple_virtualization:

=======================================
Apple的Virtualization framework思考
=======================================

虚拟化技术对比
================

在macOS(iOS)上，有以下几个技术流派:

- :ref:`virtualbox` : 非常古老但仍然在持续开发的跨平台虚拟化技术，我记得是Sun公司收购的一家开源虚拟化公司，后来随Sun一起被Oracle收购，不过始终保持开源。我使用不多，因为主要 :ref:`kvm` 更适合云计算。
- :ref:`vmware_fusion` 和 `Parallels <https://www.parallels.com/>`_ : 商业虚拟化软件，都非常著名，使用非常简便，缺点是需要不断升级才能适配(允许)在新版本macOS上运行。VMware Fusion现在已经免费，但Parallels依然收费(且昂贵)。
- 基于 :ref:`qemu` 技术的开源虚拟机 :ref:`utm` : 由于采用了全能的QEMU，utm可以说能够在 macOS / iOS 系统上运行任何操作系统。但是带来的缺点是虚拟化开销很大，我尝试在第一代iPad Pro上使用UTM安装Linux缓慢到让我崩溃，所以我还是放弃了。
- 基于从 :ref:`bhyve` 移植过来的 :ref:`xhyve` : 早期的macOS开源项目，类似于 :ref:`kvm` ，但是现在看起来随着 :ref:`apple_virtualization` 发展， ``xhybe`` 已经停止开发了，我感觉在闭源的 macOS/iOS 上，这块开源极难推进，无法得到苹果生态的支持
- 最后就是现在Apple公司持续在开发演进的 :ref:`apple_virtualization` ，实际上甚至不需要安装任何虚拟机软件，在XCode中通过简单的代码调用就能够运行虚拟机，并且是原生虚拟化性能是最佳的。目前可以看到能够发挥 :ref:`apple_virtualization` 性能的开源虚拟机软件是 :ref:`lima` 和 :ref:`tart` :

  - :ref:`tart` 是纯使用 :ref:`apple_virtualization` 的开源软件，并且只支持 Apple Silicon 架构，也就是说理论上它是最轻量级(代码量少)最快速的(专注单一架构)。缺点是必须有最新的ARM架构的Apple设备
  - :ref:`lima` 是全能型虚拟化软件，也就是既支持 :ref:`apple_virtualization` 又支持 :ref:`qemu` :

    - 优点:

      - 所有的Apple设备都能运行，不管是Intel架构还是ARM架构，都能够运行各种操作系统，能支持VZ( :ref:`apple_virtualization` )就用VZ，不能支持VZ就还是用传统的 :ref:`qemu` 
      - 如果你只运行 Linux 并且专注于容器，那么 :ref:`lima` 几乎就是最好的选择

    - 缺点:

      - 官方只支持Linux，虽然通过qemu也能运行 :ref:`freebsd` 甚至我觉得以qemu这样全能的虚拟软件运行 :ref:`windows` 或者 :ref:`macos` 也不是不行，但是这和裸运行QEMU已经没有区别，完全无法利用Lima定义开发的环境
      - 实践发现没有很好支持USB设备(只能通过QEMU手工处理)

选择
======

选择哪个虚拟化技术取决于你的物理设备和需要运行的虚拟机操作系统:

- 如果你使用最新的 ``Apple Silicon`` 硬件，并且只想运行 :ref:`linux` 或 :ref:`macos` ，那么恭喜你，你可以基于Apple最新最受支持的 :ref:`apple_virtualization` 框架的多种虚拟化软件: :ref:`tart` / :ref:`utm` / :ref:`lima`

  - 如果需要同时使用 :ref:`linux` 和 :ref:`macos` 虚拟机，那么选择 :ref:`tart`
  - 如果只运行 :ref:`linux` 虚拟机，那么选择 :ref:`lima` > :ref:`tart` > :ref:`utm`

    - 底层技术都是使用 :ref:`apple_virtualization` 所以性能和稳定性没有太大区别
    - :ref:`lima` 优势在于其项目目标是就是 Linux ，专注于便捷使用并且容器化运行(CNCF孵化项目)，所以和Host主机结合完美，可以非常容易融合本地目录共享，后续使用 :ref:`colima` 或者运行 :ref:`kubernetes` 有社区很好的扩展支持
    - :ref:`tart` 优势在于其目标只有 :ref:`apple_virtualization` ，抛弃了旧版本Intel架构支持，所以轻装上阵，几乎就是最新Mac硬件和软件的结合体，对单纯运行Linux/macOS虚拟机十分便捷友好
    - :ref:`utm` 最初核心是 :ref:`qemu` ，逐步扩展支持了 :ref:`apple_virtualization` 所以官方目前说明对 :ref:`apple_virtualization` 支持有限测试不充分

- 如果你依然在使用古早的 Intel 硬件 Mac设备，那么选择就比较有限或者说得非常仔细地平衡选择:

  - 如果需要运行 :ref:`macos` 虚拟机，那么很不幸没得选: :ref:`tart` / :ref:`utm` 都不支持Intel硬件的macOS虚拟机， :ref:`lima` 更是只能运行linux。不过， **天无绝人之路** 你还是可以选择:

    - 使用商业但免费的 :ref:`vmware_macos_on_macos` (我验证使用Apple开发者网站提供的Xcode示例项目手工 :ref:`run_macos_in_apple_virtualization` 无法在Intel架构硬件上运行，卒!)

  - 如果只运行 :ref:`linux` 虚拟机，那么选择 :ref:`lima` > :ref:`utm`

    - 在符合条件的硬件和软件环境下， :ref:`lima` 默认启用VZ虚拟化，专注于Linux虚拟化使得Lima社区发展专注而迅速，并且得到CNCF支持后，后续作为容器化运行底座，会有较好的发展前景，也适合后端技术磨练。
    - :ref:`utm` 在交互界面上非常友好， :ref:`qemu` 极大拓展了各种操作系统支持，并且有精心开发的GUI管理界面使得UTM更接近传统的虚拟化桌面软件。
    - 两者底层技术几乎一致，区别主要在于社区发展方向

  - 如果想要运行不同操作系统，特别是倾向于 :ref:`windows` 虚拟化，那么 :ref:`utm` 可能是唯一选择(另一个 :ref:`virtualbox` 发展停滞所以并不推荐)

    - 核心基于 :ref:`qemu` 能够完美运行各种Windows版本，并且集成提供了开源驱动来加速Windows运行

.. note::

   目前实践以及社区开源实现都验证了， :ref:`apple_virtualization` 正在逐步抛弃Intel架构支持，无法实现原生虚拟化运行 :ref:`macos` ，现在仅仅能够原生运行 :ref:`linux` 虚拟机。总之，硬件不升级的话选择会越来越狭窄。

我的选择
==========

没有完美的唯一，所以我还是根据自己的需要进行组合选择:

- 使用 :ref:`lima` 作为主力虚拟化:

  - 由于目前我没有Apple Silicon硬件，所以要采用 :ref:`apple_virtualization` ``VZ`` 虚拟化引擎，采用 :ref:`lima` 不仅能够充分发挥我现有硬件的性能，而且也方便进一步实践和学习 :ref:`kubernetes` / :ref:`docker` (采用 :ref:`colima` )
  - 少量场景，例如需要使用外接USB设备和运行 :ref:`freebsd` ，则在 :ref:`lima` 中指定 :ref:`qemu` 引擎来完成，性能损失大一些，但是还能接受

- :ref:`vmware_fusion` 作为辅助虚拟化

  - 采用 :ref:`vmware_macos_on_macos` 完成一些实践学习

- :ref:`utm` 作为辅助虚拟化:

  - 由于我很少使用 :ref:`windows` ，所以 :ref:`utm` 支持多种Windows系统的优势对我而言不重要
  - 但是UTM可以在 :ref:`ios` 上运行 :ref:`linux` 虚拟机，对于我的开发运维工作可能是一个利器，有待后续实践

- 后续如果入手了 :ref:`mac_mini_2024` ，则采用 :ref:`tart` 替代 :ref:`vmware_fusion` 来运行 :ref:`macos` ，实现性能最优化

参考
======

- `Apple developer Documentation: Virtualization <https://developer.apple.com/documentation/virtualization>`_
