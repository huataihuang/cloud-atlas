.. _bhyve_pci_passthru_startup:

===============================
bhyve PCI Passthrough快速起步
===============================

我在构建 :ref:`bsd_cloud_bhyve` 时，需要构建一个 :ref:`machine_learning` 工作环境:

- 将 :ref:`nvidia_gpu` 和 :ref:`amd_gpu` 通过 :ref:`iommu` 技术实现PCI Passthrough 给 Linux bhybe 虚拟机
- 模拟出不同的GPU分布集群(单机多卡，多机多卡)

在FreeBSD中bhyve支持将host主机上的CPI设备透传给虚拟机使用:

- CPU必须支持Intel :ref:`iommu` (也称为 ``VT-d`` )
- PCI设备(和驱动)支持 ``MSI/MSI-x`` 中断

通过搜索ACPI表的DMAR表可以获知是否支持Host VT-d:

.. literalinclude:: bhyve_pci_passthru_startup/acpidump
   :caption: DMAR表

在我的组装台式机上可以看到如下输出:

.. literalinclude:: bhyve_pci_passthru_startup/acpidump_output
   :caption: DMAR表输出

通过 ``pciconf`` 可以查看PCI卡的 ``MSI/MSI-x`` 支持:

.. literalinclude:: bhyve_pci_passthru_startup/pciconf
   :caption: 通过 ``pciconf`` 查看PCI卡的 ``MSI/MSI-x`` 支持

在我的组装台式机上可以看到如下输出:

.. literalinclude:: bhyve_pci_passthru_startup/pciconf_output
   :caption: 通过 ``pciconf`` 查看PCI卡的 ``MSI/MSI-x`` 支持

配置
=====

- 确保 ``vmm.ko`` 在 ``/boot/loader.conf`` 配置中设置:

.. literalinclude:: ../bhyve_startup/loader.conf
   :caption: 配置启动时加载模块 ``vmm.ko`` (已经在 :ref:`bhyve_startup` 设置)
   :emphasize-lines: 1

- 使用 ``pciconf -vl`` 检查需要pass through 设备的 ``bus/slot/function`` :

.. literalinclude:: bhyve_pci_passthru_startup/pciconf_vl
   :caption: 通过 ``pciconf`` 获取设备信息

我需要传递的设备是 :ref:`amd_radeon_instinct_mi50` :

.. literalinclude:: bhyve_pci_passthru_startup/pciconf_vl_output
   :caption: 通过 ``pciconf`` 获取设备信息
   :emphasize-lines: 10-13

这里根据输出 ``vgapci0@pci0:4:0:0`` 可以知道这个 :ref:`amd_radeon_instinct_mi50` 的 ``bus/slot/function`` 值为 ``4/0/0``

- 在操作系统启动时，需要对Host主机屏蔽掉需要直通的PCI设备，这个设置时通过 ``pptdevs`` 参数完成的，如果有多个设备需要屏蔽，则使用空格来分隔设备列表:

.. literalinclude:: bhyve_pci_passthru_startup/pptdevs
   :caption: 设置屏蔽的直通的PCI设备( ``/boot/loader.conf`` )

注意，每行 ``pptdevs`` 只支持最多 ``128`` 个字符，所以如果有更多的直通设备需要配置的画，可以使用 ``pptdevN`` 来设置，例如 ``pptdevs2``

- 重启操作系统，再次检查 ``pciconf -vl`` 就会看到原先设备 ``vgapci0`` 变成了 ``ppt`` (这里看到的是 ``ppt0@pci0:4:0:0`` )类似如下:

.. literalinclude:: bhyve_pci_passthru_startup/pciconf_vl_output_ppt
   :caption: 重启系统后检查 ``pptdevs`` 设备的开头会变成 ``ppt``
   :emphasize-lines: 1

- 现在就在虚拟机中使用这个设备了，添加 ``-s 7,passthru,4/0/0`` 类似如下:

.. literalinclude:: bhyve_pci_passthru_startup/fedora_vm
   :caption: 设置 fedora 虚拟机使用这个passthru设备

异常排查
===========

-s 7,passthru,4/0/0 \

- 必须向 ``bhyveload`` 和 ``bhyve`` 传递 ``-S`` 参数来 wire guest memory，否则启动会报错:

.. literalinclude:: bhyve_pci_passthru_startup/wire_memory
   :caption: 如果 ``bhyve`` 没有使用 ``-S`` 参数会报错

- 添加了 ``-S`` 运行参数后，提示报错:

.. literalinclude:: bhyve_pci_passthru_startup/setup_memory
   :caption: 提示setup memory错误    

参考 `bhyve PCI pass-through to Linux guest <https://lists.freebsd.org/pipermail/freebsd-virtualization/2015-December/003979.html>`_ 提示: 不仅需要给 ``bhyve`` 传递 ``-S`` 参数，还需要给 ``grub-bhyve`` 传递 ``-S`` 参数

待续...

参考
=======

- `FreeBSD wiki: bhyve PCI Passthrough <https://wiki.freebsd.org/bhyve/pci_passthru>`_
