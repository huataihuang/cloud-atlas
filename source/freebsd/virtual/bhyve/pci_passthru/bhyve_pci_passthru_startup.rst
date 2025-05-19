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

.. note::

   如果 ``DMAR`` 输出内容是空白，则表明不支持 ``Intel VT-d`` ，例如Intel Atom处理器在这项检查输出就是空白的( `Not working with pci passthru <https://github.com/pr1ntf/iohyve/issues/166>`_ )

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

我需要传递的设备是 :ref:`amd_radeon_instinct_mi50` (和 :ref:`tesla_p10` ) :

.. literalinclude:: bhyve_pci_passthru_startup/pciconf_vl_output
   :caption: 通过 ``pciconf`` 获取设备信息
   :emphasize-lines: 2-6,16-19

这里根据输出 ``vgapci0@pci0:4:0:0`` 可以知道这个 :ref:`amd_radeon_instinct_mi50` 的 ``bus/slot/function`` 值为 ``4/0/0`` (以及 :ref:`tesla_p10` 为 ``1/0/0`` )

- 在操作系统启动时，需要对Host主机屏蔽掉需要直通的PCI设备，这个设置时通过 ``pptdevs`` 参数完成的，如果有多个设备需要屏蔽，则使用空格来分隔设备列表:

.. literalinclude:: bhyve_pci_passthru_startup/pptdevs
   :caption: 设置屏蔽的直通的PCI设备( ``/boot/loader.conf`` ) 这里仅屏蔽 :ref:`amd_radeon_instinct_mi50`

如果屏蔽上述2个设备( ref:`amd_radeon_instinct_mi50` 和 :ref:`tesla_p10` )，则写成:

.. literalinclude:: bhyve_pci_passthru_startup/pptdevs_2
   :caption: 设置屏蔽的直通的PCI设备( ``/boot/loader.conf`` ) 这里同时屏蔽 :ref:`amd_radeon_instinct_mi50` :ref:`tesla_p10`

注意，每行 ``pptdevs`` 只支持最多 ``128`` 个字符，所以如果有更多的直通设备需要配置的画，可以使用 ``pptdevN`` 来设置，例如 ``pptdevs2``

- 重启操作系统，再次检查 ``pciconf -vl`` 就会看到原先设备 ``vgapci0`` 变成了 ``ppt`` (这里看到的是 ``ppt0@pci0:1:0:0`` 和 ``ppt0@pci0:4:0:0`` )类似如下:

.. literalinclude:: bhyve_pci_passthru_startup/pciconf_vl_output_ppt
   :caption: 重启系统后检查 ``pptdevs`` 设备的开头会变成 ``ppt``
   :emphasize-lines: 2,8

- 现在就在虚拟机中使用这个设备了，添加 ``-s 7,passthru,1/0/0`` (假设这里使用 :ref:`tesla_p10` ) 类似如下:

.. literalinclude:: bhyve_pci_passthru_startup/fedora_vm
   :caption: 设置 fedora 虚拟机使用这个passthru设备

异常排查
===========

当我使用了 ``-s 7,passthru,1/0/0`` 出现 ``passthru requires guest memory to be wired`` 报错

- 必须向 ``bhyveload`` 和 ``bhyve`` 传递 ``-S`` 参数来 ``wire guest memory`` ，否则启动会报错:

.. literalinclude:: bhyve_pci_passthru_startup/wire_memory
   :caption: 如果 ``bhyve`` 没有使用 ``-S`` 参数会报错

- 添加了 ``-S`` 运行参数后，提示报错:

.. literalinclude:: bhyve_pci_passthru_startup/setup_memory
   :caption: 提示setup memory错误    

参考 `bhyve PCI pass-through to Linux guest <https://lists.freebsd.org/pipermail/freebsd-virtualization/2015-December/003979.html>`_ 提示: 不仅需要给 ``bhyve`` 传递 ``-S`` 参数，还需要给 ``grub-bhyve`` 传递 ``-S`` 参数

这个问题有点难搞，我发现只要添加 ``-S`` 参数来实现 ``wire guest memory`` 就会提示

.. literalinclude:: bhyve_pci_passthru_startup/setup_memory
   :caption: 提示setup memory错误    

如果此时还调整虚拟机的内存大小，例如原先是 ``2G`` 改成 ``8G`` ，则同样报 ``setup memory`` 错误，但是错误码却是 ``22`` :

.. literalinclude:: bhyve_pci_passthru_startup/setup_memory_22
   :caption: 提示setup memory错误    

该怎么改进这个配置呢？我对比了 `Using bhyve on FreeBSD <https://jjasghar.github.io/blog/2019/06/03/using-bhyve-on-freebsd/>`_ 大致明白了思路:

- 修订 ``/etc/remote`` 添加一个针对虚拟机的控制台访问配置，这样就可以不使用VNC而直接使用字符终端
- 为虚拟机创建一个 ``device.map`` 文件来指示 ``grub-bhyve`` ，并且可以通过 ``grub-bhyve`` 来设置虚拟机的内存和传递参数(例如需要传递 ``-S`` 参数来wrap内存

解决
------

- 创建远程终端配置，即修订 ``/etc/remote`` :

.. literalinclude:: ../bhyve_vm_console/remote
   :caption: 创建终端配置

- 创建针对每个虚拟机的 ``device.map`` 文件，以 ``<vm_name>.map`` 命名，存放在 ``/zroot/vms/<vm_name>`` 目录下:

.. literalinclude:: ../bhyve_vm_console/fedroa.map
   :caption: 为 ``fedora`` 虚拟机创建 ``/zroot/vms/fedora/fedora.map``

参考
=======

- `FreeBSD wiki: bhyve PCI Passthrough <https://wiki.freebsd.org/bhyve/pci_passthru>`_
