.. _osx-kvm:

==============
OSX-KVM
==============

OSX-KVM 是目前虚拟化运行macOS非常方便成熟的方案。

准备工作
=========

我是采用 :ref:`amd_mi50_flash_vbios` 将 :ref:`amd_mi50` 改造成 ``V420 Pro`` ，安装在 :ref:`dell_t5820` 上来构建黑苹果。另外，购买了一块BCM94360CD千兆双频5G台式机无线网卡(原生免驱)，以实现AirDrop、HandOff(接力)、iMessage 和 Continuity(连续互通)。

操作系统采用 :ref:`ubuntu_linux` 26.04 LTS。

开启 CPU 虚拟化与 IOMMU
------------------------

- 修改 ``/etc/default/grub`` :

.. literalinclude:: osx-kvm/grub
   :caption: ``/etc/default/grub``

然后更新GRUB并重启系统:

.. literalinclude:: osx-kvm/update-grub
   :caption: 更新GRUB并重启

确认PCI设备ID并进行VFIO隔离
----------------------------

- 检查AMD显卡Vendor/Device ID

.. literalinclude:: osx-kvm/lspci_amd
   :caption: 检查AMD显卡Vendor/Device ID

输出显示

.. literalinclude:: osx-kvm/lspci_amd_output
   :caption: AMD显卡Vendor/Device ID显示

注意，这里显示的AMD显卡信息有6行，分别代表了2块 :ref:`amd_mi50` 计算卡:

  - ``1002:14a0`` 和 ``1002:14a1`` 不是额外的显卡，而是 MI50 显卡内部自带的 PCIe Bridge（PCIe 桥接芯片）。因为 MI50（Vega 20 架构）内部采用了多层拓扑结构，PCIe 信号会先经过显卡板载的 Bridge 芯片，再连接到真正的 Vega 20 核心（ ``1002:66a0`` ）。
  - ``17:00.0 / 18:00.0`` : 第一块 MI50 内部的 PCIe 桥接节点
  - ``b3:00.0 / b4:00.0`` : 第二块 MI50 内部的 PCIe 桥接节点

在配置 vfio.conf 时，只需要填真正的 GPU 核心 Device ID（ ``1002:66a0`` ）。内部的 PCIe 桥接芯片无需（也不应该）绑定给 vfio-pci，Linux 内核与 PCIe 驱动层会自动处理桥接设备。

- 检查BCM94360CD (Wi-Fi 与 Bluetooth)

.. literalinclude:: osx-kvm/lspci_broadcom
   :caption: 检查BCM94360CD (Wi-Fi)

输出显示

.. literalinclude:: osx-kvm/lspci_broadcom_output
   :caption: 检查BCM94360CD (Wi-Fi)

注意: BCM94360CD 的蓝牙是通过网卡上的转接线插在主板 USB 针脚上的，通常显示为 USB 设备（如 05ac:828d）

.. literalinclude:: osx-kvm/lsusb
   :caption: 检查USB查看蓝牙接口

配置VFIO绑定
-------------

- 将上述设备隔离给 ``vfio-pci`` ，即配置 ``/etc/modprobe.d/vfio.conf``

.. literalinclude:: osx-kvm/vfio.conf
   :caption: 配置vfio.conf绑定ID

.. warning::

   由于两块 AMD MI50 的 GPU 核心 Device ID 完全相同(都是 ``1002:66a0`` )，所以上述使用 ``ids`` 配置的 ``vfio.conf`` 会导致两块显卡同时输出给虚拟机使用。

   如果要分别输出，例如一块给虚拟机，一块给物理主机，则不能使用 ``vfio.conf`` 的 ``ids`` ，而是要交给 :ref:`qemu` / :ref:`libvirt` 管理。后续我将采用 :ref:`libvirt_hooks_qemu_gpu` 方式来动态为虚拟机动态注册并绑定vfio-pci。

- 防止宿主机主显卡驱动抢占:

.. literalinclude:: osx-kvm/blacklist.conf
   :caption: 配置物理主机屏蔽掉GPU卡

.. warning::

   这里配置 ``blacklist.conf`` 是仅适合AMD GPU完全用于虚拟机的情况，如果该GPU还要同时给Host主机使用，则不可使用。对于需要在虚拟机和Host主机之间切换GPU，应该采用 :ref:`libvirt_hooks_qemu_gpu`

更新 initramfs 并重启:

.. literalinclude:: osx-kvm/initramfs
   :caption: 更新 initramfs 并重启

重启后执行 ``lspci -nnk -s 0000:19:00.0`` ，确认 Kernel driver in use: 显示为 vfio-pci 即代表隔离成功 **不过，我这里实践发现不行，还是显示为 amdgpu** 这说明host主机没有屏蔽掉vfio，我之前实践 :ref:`ovmf_gpu_nvme` ，是需要配置内核参数屏蔽掉: ``配置/etc/default/grub加载vfio-pci.ids来隔离PCI直通设备``

.. note::

   考虑到后续还是要采用 :ref:`libvirt_hooks_qemu_gpu` ，以便能够更好动态使用GPU。我在实践和记录这这段内容之后，调整了方法，将上述固定配置 ``vfio`` 改造成 :ref:`libvirt_hooks_qemu_gpu` 以便能够在日常中灵活切换。

OSX-KVM搭建 macOS 虚拟机环境
=============================

- 克隆项目与安装基础依赖

.. literalinclude:: osx-kvm/osx-kvm
   :caption: 下载osx-kvm以及安装基础依赖

.. note::

   精简安装参考 :ref:`ubuntu_deploy_kvm`

- 设置调优kvm:

.. literalinclude:: osx-kvm/kvm
   :caption: 设置当前服务器kvm以及调优

持久化配置:

.. literalinclude:: osx-kvm/kvm_config
   :caption: 持久化kvm配置

- 将用户添加到 ``kvm`` 和 ``libvirt`` 组:

.. literalinclude:: osx-kvm/usermod
   :caption: 当前用户添加组

- 重新登录，然后执行:

.. literalinclude:: osx-kvm/fetch
   :caption: 下载

必须看到下载验证成功:

.. literalinclude:: osx-kvm/fetch_output
   :caption: 下载成功
   :emphasize-lines: 11,21

有时候网络抖动会导致镜像下载中断，此时校验失败会提示 ``Image verification failed. (Invalid chunk 1 size: expected 10485760, read 1048576)`` ，则清理缓存重新下载:

.. literalinclude:: osx-kvm/fetch_clean
   :caption: 清理失败的下载

- 转换下载的 ``BaseSystem.dmg`` 文件成为 ``BaseSystem.img`` :

.. literalinclude:: osx-kvm/dmg2img
   :caption: 转换dmg文件

- 启动安装:

.. literalinclude:: osx-kvm/boot
   :caption: 启动安装

.. note::

   这里可以看出安装的脚本是默认你在桌面环境运行的，所以会启动qemu时附加 :ref:`alsa` 库要求以及 ``gtk`` 要求。不过，我是在纯字符终端的无头安装模式，所以参考gemini建议做一些调整，以便能够从字符模式完成这个安装过程。

   待续...

参考
======

- gemini
- `Github: kholia/osx-kvm <https://github.com/kholia/osx-kvm>`_
