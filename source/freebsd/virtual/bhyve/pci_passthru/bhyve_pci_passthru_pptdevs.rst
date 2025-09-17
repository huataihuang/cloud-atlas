.. _bhyve_pci_passthru_pptdevs:

============================================
bhyve PCI Passthrough ``pptdevs`` 经验教训
============================================

问题
=====

这个问题困扰了我一段时间:

最初我以为我的 :ref:`nasse_c246` BIOS存在bug，因为当时我恰好调整了一下BIOS的配置并重启了主机，然后看到FreeBSD的之前配置的 :ref:`bhyve_startup` 的网桥(桥接了4个物理 ``igc`` 网卡以及3个 ``tap`` 虚拟网卡) 突然混乱不生效了:

.. literalinclude:: ../bhyve_startup/rc.conf
   :caption: 在 ``/etc/rc.conf`` 中配置网桥桥接物理网卡和虚拟网卡

表现为:

- 系统启动后只识别出 ``igc0`` 和 ``igc1`` ，另外两个 ``igc2`` 和 ``igc3`` 不翼而飞
- 虚拟交换机 ``igc0bridge`` 没有分配IP地址

这样导致每次启动FreeBSD服务器都要我使用键盘和屏幕来手工配置IP地址连接网络，非常不方便

排查
======

我最初以为是BIOS的bug(主板硬件不稳定)导致主机重启以后无法识别物理网卡，这也是因为当时我正好修改BIOS凑巧出现了遇到了这个异常。而且，我在折腾BIOS的配置，偶然发现又正常识别出4个 ``igc`` 网卡(恢复正常)，就轻率判断为硬件问题。

然而，这次在配置 :ref:`bhyve_nvidia_gpu_passthru_freebsd_15` 再次突然发生这样的情况，使得我非常抓狂，正好在测试PCI passthru时多次调整BIOS，然而我却不知道什么触发了问题。

我甚至想到是不是FreeBSD的网卡驱动是否有配置加载模块时需要传递参数？那么Linux是否正常呢？

通过Ubuntu启动安装U盘看到，Linux是识别出4个网卡的，这说明FreeBSD存在问题，BIOS是正常的。

- 再次启动到FreeBSD系统，我尝试 ``pciconf -lv`` 检查PCI设备，突然发现原来系统是识别出了4个PCI以太网设备的:

.. literalinclude:: bhyve_pci_passthru_pptdevs/pciconf
   :caption: 执行 ``pciconf -lv`` 可以看到4个网卡设备，why?

那为何 ``ifconfig`` 只看到 ``igc0`` 和 ``igc1`` ?

我突然意识到问题了，是我在 :ref:`bhyve_pci_passthru_startup` 以及 :ref:`bhyve_nvidia_gpu_passthru` 等实践中，多次尝试PCI Passthru GPU设备，所以多次修改 ``/boot/loader.conf`` 来从Host上屏蔽掉某些需要Passthru给虚拟机的GPU设备，例如:

.. literalinclude:: bhyve_pci_passthru_pptdevs/loader.conf
   :caption: 配置 ``/boot/loader.conf`` 屏蔽掉Host主机上的GPU设备

而此时启动的主机中 ``2/0/0`` 和 ``3/0/0`` 对应的不是GPU设备(我拆卸掉了GPU卡)，而是主板上集成的以太网设备

原因分析
=========

- 当我在 :ref:`nasse_c246` BIOS 中配置 :ref:`pcie_bifurcation` ，拆分一条PCIe x16 为 ``x8x4x4`` 之后，安装的 :ref:`tesla_p4` 或 :ref:`tesla_p10` ID显示为 ``1/0/0``
- 当我将BIOS恢复为出厂默认配置(也就是关闭 :ref:`pcie_bifurcation` )，此时安装的 :ref:`tesla_p4` 和 :ref:`tesla_p10` 的ID会是识别成 ``2/0/0`` 或 ``3/0/0``
- 为了简化配置，我同时将 ``1/0/0 2/0/0 3/0/0`` 从HOST主机屏蔽掉(见上文 ``/boot/loader.conf`` 配置)

然而，当我拆掉了主机上安装的GPU设备，重启系统后，原先对应GPU的ID ``2/0/0`` 和 ``3/0/0`` 现在被自动对应到主板的2个以太网设备上，这导致了两个以太网卡被自动从Host上屏蔽无法访问。

.. warning::

   当Host主机上的PCIe设备更改时，原先系统识别的PCIe IDs会动态变化，这会导致 ``/boot/loader.conf`` 原先配置的 ``pptdevs`` 误屏蔽掉错误的设备!!!

   **我甚至可能误屏蔽了一块nvme存储(捂脸)** 导致 :ref:`freebsd_zfs_stripe` 无法使用，当时没有想到这个可能还折腾好久重建了ZFS，悲剧啊悲剧
