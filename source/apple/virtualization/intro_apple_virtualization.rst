.. _intro_apple_virtualization:

=======================================
Apple的Virtualization framework简介
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
  - :ref:`lima` 是全能型虚拟化软件，也就是既支持 :ref:`apple_virtualization` 又支持 :ref:`qemu` 。这样好处是所有的Apple设备都能运行，不管是Intel架构还是ARM架构，都能够运行各种操作系统，能支持VZ( :ref:`apple_virtualization` )就用VZ，不能支持VZ就还是用传统的 :ref:`qemu` 。缺点可能是软件比较庞杂，为了支持多架构和跨平台，软件比较沉重且容易出现各种问题。不过 :ref:`lima` 发展非常迅速，得到了很多商业公司支持，目前是很多开源虚拟化、容器化软件的核心。

我的看法(技术角度):

- :ref:`lima` 目前可能是比较成熟的全面的方案，支持的硬件架构完整，对于目前我还没有Apple Silicon硬件的情况下，可能是唯一的选择

  - 不过限制在于Lima项目的目标是运行Linux容器，所以实际上主要就是运行Linux虚拟机，对其他操作系统支持很弱(可能能够运行 :ref:`freebsd` ，但看来无法运行 :ref:`macos` )

- :ref:`tart` 是一个有发展潜力的专注方案: 只支持 Apple Silicon + Apple Virtualization

  - 特定应用范围限制在纯Apple生态，这是缺点但也是优点
  - 既能够运行 :ref:`linux` 又能够 :ref:`macos` ，这对于纯Apple生态是非常突出的优势，至少比 :ref:`lima` 多具备了支持macOS
  - 随着Apple逐渐抛弃Intel架构，对于 :ref:`tart` 来说会发展越来越好，没有历史包袱，专注于 :ref:`apple_virtualization` 可以站在巨人的肩膀上发展更快

- 如果不需要图形桌面，并且也不想有虚拟化消耗，那么 :ref:`darwin-containers` 是一个选择，虽然目前这个开源项目还非常早期，使用起来难度很高(困难)

参考
======

- `Apple developer Documentation: Virtualization <https://developer.apple.com/documentation/virtualization>`_
