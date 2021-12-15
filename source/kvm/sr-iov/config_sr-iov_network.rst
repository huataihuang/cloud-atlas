.. _config_sr-iov_network:

======================
配置SR-IOV网络虚拟化
======================

.. note::

   对于高速 40Gbps Intel服务器网卡，需要在guest虚拟机使用 :ref:`linux_dpdk` 才能充分发挥性能!

   请参考 `Frequently Asked Questions for SR-IOV on Intel Ethernet Server Adapters <https://www.intel.com/content/www/us/en/support/articles/000005722/ethernet-products.html>`_ 说明获得不同以太网卡对SR-IOV的支持功能

实践环境
==========

我的实践是在 :ref:`hpe_dl360_gen9` 上，采用配套Intel 4x 千兆网卡，主控芯片是 ``I350 Gigabit Network Connection (rev 01)`` 。根据 `Intel Ethernet Server Adapter I350: Product Brief <https://www.intel.com/content/www/us/en/products/docs/network-io/ethernet/10-25-40-gigabit-adapters/ethernet-i350-server-adapter-brief.html>`_ :

- Support for PCI-SIG SR-IOV specification: Up to 8 Virtual Functions per Port
- 对于4网口网卡: 可支持32个Virtual Functions(VF)

`Intel Ethernet Controller I350 <https://www.intel.com/content/www/us/en/products/details/ethernet/gigabit-controllers/i350-controllers/downloads.html>`_ 提供了相关驱动和软件下载，建议更新firmwware

SR-IOV概述
==============

SR-IOV提供了将单一物理PCI资源( ``PF`` )切分成虚拟PCI功能( ``VF`` )，以便注入(inject)VM提供高性能。对于网卡VF，数据流是绕过物理服务器的网络堆栈来实现 ``北向-南向`` 网络高性能。

有多种方式可以将一个 SR-IOV 网卡 VF 注入一个KVM虚拟机:

- 作为一个SR-IOV VF PCI passthrough设备
- 使用 ``macvtap`` 作为一个SR-IOV VF 网卡
- 使用一个网卡的 KVM虚拟网络池 ( ``KVM virtual netowrk pool for adapters`` ) 作为一个SR-IOV VF网卡

准备
========

- 内核增加 ``intel_iommu=on`` 和 ``iommu=pt`` 参数，编辑 ``/etc/default/grbu`` 配置( :ref:`ovmf` )::

   GRUB_CMDLINE_LINUX_DEFAULT="intel_iommu=on iommu=pt vfio-pci.ids=144d:a80a,10de:1b39"

然后执行重建grub::

   sudo update-grub

- 重启系统::

   sudo shutdown -r now

- 检查网卡 - 我的 :ref:`hpe_dl360_gen9` 主板板载4口千兆网卡(Broadcom NetXtreme BCM5719 Gigabit Ethernet PCIe (rev 01)) ，另外独立安装了4口千兆网卡(Intel I350 Gigabit Network Connection (rev 01))，所以系统显示为8个以太网设备::

   ifconfig -a | grep eno

显示::

   eno1: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
   eno2: flags=4098<BROADCAST,MULTICAST>  mtu 1500
   eno3: flags=4098<BROADCAST,MULTICAST>  mtu 1500
   eno4: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
   eno49: flags=4098<BROADCAST,MULTICAST>  mtu 1500
   eno50: flags=4098<BROADCAST,MULTICAST>  mtu 1500
   eno51: flags=4098<BROADCAST,MULTICAST>  mtu 1500
   eno52: flags=4098<BROADCAST,MULTICAST>  mtu 1500

其中:

  - ``eno1 ~ eno4`` 是 Broadcom BCM5719
  - ``eno49 ~ eno52`` 是 Intel I350

本文实践采用 ``Intel I350`` 的4口千兆网卡，驱动信息可以通过 ``ethtool`` 查看::

   ethtool -i eno49

显示::

   driver: igb
   version: 5.6.0-k
   firmware-version: 1.61, 0x80000daa, 1.949.0
   expansion-rom-version:
   bus-info: 0000:04:00.0
   supports-statistics: yes
   supports-test: yes
   supports-eeprom-access: yes
   supports-register-dump: yes
   supports-priv-flags: yes

VF配置
---------

- ``/sys/class/net/<device name>/device/sriov_numvfs`` 参数设置了 SR-IOV 网络设备VF数量，例如 ``eno49`` 默认设置::

   cat /sys/class/net/eno49/device/sriov_numvfs

输出是::

   0

表示当前尚未有VF

- 设置PF对应的VF4 个(最高支持7，也就是 ``PF+VF`` 最大值是 ``8`` )::

   echo 4 | sudo tee /sys/class/net/eno49/device/sriov_numvfs

此时执行 ``ifconfig -a | grep eno49`` 会看到增加了4个VF::

   eno49: flags=4098<BROADCAST,MULTICAST>  mtu 1500
   eno49v0: flags=4098<BROADCAST,MULTICAST>  mtu 1500
   eno49v1: flags=4098<BROADCAST,MULTICAST>  mtu 1500
   eno49v2: flags=4098<BROADCAST,MULTICAST>  mtu 1500
   eno49v3: flags=4098<BROADCAST,MULTICAST>  mtu 1500

- 注意，这个 ``sriov_numvfs`` 参数是随着  ``igbvf`` 内核模块加载的，一旦加载就不能直接修改成其他 ``非0`` 参数。例如，刚设置完4个VF，如果马上修改该参数会报错::

   echo 6 | sudo tee /sys/class/net/eno49/device/sriov_numvfs
   
提示错误::

   tee: /sys/class/net/eno49/device/sriov_numvfs: Device or resource busy
   
- 观察内核模块可以看到::

   $ lsmod | grep igb
   igbvf                  49152  0
   igb                   221184  0
   dca                    16384  2 igb,ioatdma
   i2c_algo_bit           16384  3 igb,mgag200,nouveau

- 如果我们要修改VF数量，需要将 ``sriov_numvfs`` 重置为 ``0`` ，然后重新配置这个参数::

   echo 0 | sudo tee /sys/class/net/eno49/device/sriov_numvfs

此时检查 ``ifconfig -a | grep eno49`` 就只看到一个设备::

   eno49: flags=4098<BROADCAST,MULTICAST>  mtu 1500

.. note::

   另一种重置方法是卸载 ``igbvf`` 和 ``igb`` 内核模块::

      sudo rmmod igbvf
      sudo rmmod igb

   卸载 ``igb`` 内核模块必须是该 ``Intel i350`` 网卡没有使用情况下才能卸载，卸载后 ``eno49 - eno51`` 设备会消失。

   然后再次加载 ``igb`` 内核模块::

      sudo modprobe igb

   此时，  ``/sys/class/net/eno49/device/sriov_numvfs`` 参数会重置为 ``0`` ，也就可以调整VF数量了

- ``Intel i350`` 对应支持 VF 最大数量可以从 ``sriov_totalvfs`` 查看::

   cat /sys/class/net/eno49/device/sriov_totalvfs

输出是::

   7

表示最高可以调整 ``sriov_numvfs`` 是 ``7``

- 在重置 ``sriov_numvfs`` 为 ``0`` 之后，就可以再次调整VF数量::

   echo 7 | sudo tee /sys/class/net/eno49/device/sriov_numvfs

- 完成后再次检查::

   ifconfig -a | grep eno49

可以看到一共有 ``8`` 个 ``eno49`` 相关网卡::

   eno49: flags=4098<BROADCAST,MULTICAST>  mtu 1500
   eno49v0: flags=4098<BROADCAST,MULTICAST>  mtu 1500
   eno49v1: flags=4098<BROADCAST,MULTICAST>  mtu 1500
   eno49v2: flags=4098<BROADCAST,MULTICAST>  mtu 1500
   eno49v3: flags=4098<BROADCAST,MULTICAST>  mtu 1500
   eno49v4: flags=4098<BROADCAST,MULTICAST>  mtu 1500
   eno49v5: flags=4098<BROADCAST,MULTICAST>  mtu 1500
   eno49v6: flags=4098<BROADCAST,MULTICAST>  mtu 1500

.. note::

   Linux Kernel version 3.8.x 及以上版本可以通过上述调整 ``sriov_numvfs`` 方法动态调整VF数量。但是，对于 3.7.x 或更低版本，则不能动态调整，而是要在加载内核模块时传递参数::

      modprobe idb max_vfs=4,4

参考
=====

- `Configure SR-IOV Network Virtual Functions in Linux KVM <https://www.intel.com/content/www/us/en/developer/articles/technical/configure-sr-iov-network-virtual-functions-in-linux-kvm.html>`_
- `SR-IOV Configuration Guide Intel Ethernet CNA X710 & XL710 on Red Hat Enterprise Linux 7 <file:///Users/huatai/Downloads/xl710-sr-iov-config-guide-gbe-linux-brief.pdf>`_
