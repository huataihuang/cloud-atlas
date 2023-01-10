.. _config_sr-iov_network:

======================
配置SR-IOV网络虚拟化
======================

.. note::

   对于高速 40Gbps Intel服务器网卡，需要在guest虚拟机使用 :ref:`dpdk` 才能充分发挥性能!

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

.. note::

   ``iommu=pt`` 参数 非常关键，虽然文档中仅说明这个参数影响性能，但是我实践发现，如果不激活这个参数，则虽然调整 ``/sys/class/net/eno49/device/sriov_numvfs`` 参数能够看到 ``eno49v0`` 到 ``eno49v6`` 多个eth设备，但是使用 ``lspci`` 却无法看到对应的 ``Ethernet Controller Virtual Function`` ，所以这个内核参数一定要激活。

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

- 此时检查 ``lspci`` 会看到增加了对应的 ``Ethernet Controller Virtual Function`` 设备::

   sudo lspci | grep -i eth | grep -i i350

显示::

   04:00.0 Ethernet controller: Intel Corporation I350 Gigabit Network Connection (rev 01)
   04:00.1 Ethernet controller: Intel Corporation I350 Gigabit Network Connection (rev 01)
   04:00.2 Ethernet controller: Intel Corporation I350 Gigabit Network Connection (rev 01)
   04:00.3 Ethernet controller: Intel Corporation I350 Gigabit Network Connection (rev 01)
   04:10.0 Ethernet controller: Intel Corporation I350 Ethernet Controller Virtual Function (rev 01)
   04:10.4 Ethernet controller: Intel Corporation I350 Ethernet Controller Virtual Function (rev 01)
   04:11.0 Ethernet controller: Intel Corporation I350 Ethernet Controller Virtual Function (rev 01)
   04:11.4 Ethernet controller: Intel Corporation I350 Ethernet Controller Virtual Function (rev 01)
   04:12.0 Ethernet controller: Intel Corporation I350 Ethernet Controller Virtual Function (rev 01)
   04:12.4 Ethernet controller: Intel Corporation I350 Ethernet Controller Virtual Function (rev 01)
   04:13.0 Ethernet controller: Intel Corporation I350 Ethernet Controller Virtual Function (rev 01)

VM注入VF设备
==============

和 :ref:`ovmf` 中向VM注入 PCIe 设备(NVMe 或 GPU) 一样，根据 ``lspci`` 输出的 VF 设备的ID 的 3个数字字段分别对应了 ``bus=  slot= function=`` ，配置一个 ``eno49vf0.xml`` 来对应::

   04:10.0 Ethernet controller: Intel Corporation I350 Ethernet Controller Virtual Function (rev 01)

.. literalinclude:: config_sr-iov_network/eno49vf0.xml
   :language: xml
   :linenos:
   :caption: 注入 04:10.0 PCI设备到VM内部

- 执行设备注入命令::

   virsh attach-device z-iommu eno49vf0.xml --config

- 检查虚拟机 ``z-iommu`` ::

   virsh dumpxml z-iommu

可以看到::

   ...
    <hostdev mode='subsystem' type='pci' managed='yes'>
      <source>
        <address domain='0x0000' bus='0x04' slot='0x10' function='0x0'/>
      </source>
      <address type='pci' domain='0x0000' bus='0x08' slot='0x00' function='0x0'/>
    </hostdev>
   ...

- 登陆 ``z-iommu`` 虚拟机，执行 ``ifconfig`` 可以看新增加了一个网卡设备::

   enp8s0: flags=4099<UP,BROADCAST,MULTICAST>  mtu 1500
           ether 1a:47:5d:9d:13:8d  txqueuelen 1000  (Ethernet)
           RX packets 0  bytes 0 (0.0 B)
           RX errors 0  dropped 0  overruns 0  frame 0
           TX packets 0  bytes 0 (0.0 B)
           TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

- 通过 ``ethtool`` 可以看到这个设备是一个 VF ::

   ethtool -i enp8s0

输出::

   driver: igbvf
   version: 5.15.6-200.fc35.x86_64
   firmware-version:
   expansion-rom-version:
   bus-info: 0000:08:00.0
   supports-statistics: yes
   supports-test: yes
   supports-eeprom-access: no
   supports-register-dump: yes
   supports-priv-flags: no

- 接下来就可以在虚拟机中使用这个 SR-IOV 的 VF 设备，性能测试后续补充

启动时激活VF以及固定MAC地址
============================

上述实践步骤完整展示了如何构建VF并注入虚拟机的方法，不过也有一些细节可以改进:

- 在启动时如何自动激活VF

有多中方法可以实现，比较简单的方法是采用传统的 ``/etc/rc.d/rc.local`` 脚本

.. literalinclude:: config_sr-iov_network/set_vf.sh
   :language: bash
   :linenos:
   :caption: 启动执行脚本激活VF及配置固定MAC

不过，现代操作系统已经采用更为巧妙的 :ref:`udev` 来实现设配配置，结合到 :ref:`libvirt_network_pool_sr-iov` 可以灵活配置。

下一步
============

可以看到，如果通过这种查询 VF 的 pci id，然后编写设备XML文件，逐个添加到虚拟机中，存在以下不足:

- 从PF通过SR-IOV虚拟化出来的VF设备众多，手工编写XML即使有脚本协助也非常繁琐
- 每个注入虚拟机的VF设备都需要查询PCI id，非常容易出错
- 难以确保不出现冲突

实际上， :ref:`libvirt` 提供了一个非常巧妙管理VF的方法 :ref:`libvirt_network_pool_sr-iov`

参考
=====

- `Configure SR-IOV Network Virtual Functions in Linux KVM <https://www.intel.com/content/www/us/en/developer/articles/technical/configure-sr-iov-network-virtual-functions-in-linux-kvm.html>`_
- `SR-IOV Configuration Guide Intel Ethernet CNA X710 & XL710 on Red Hat Enterprise Linux 7 <https://usermanual.wiki/Pdf/xl710sriovconfigguidegbelinuxbrief.51018661/view>`_
