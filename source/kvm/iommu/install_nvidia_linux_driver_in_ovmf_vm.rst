.. _install_nvidia_linux_driver_in_ovmf_vm:

=====================================
在OVMF虚拟机中安装NVIDIA Linux驱动
=====================================

我在完成了 :ref:`ovmf_gpu_nvme` 配置之后，原本以为在passthough的OVMF虚拟机内部，对NVIDIA GPU的驱动安装会像在物理主机上 :ref:`install_nvidia_linux_driver` 一样轻松。毕竟，理论上说，直通进虚拟机的NVIDIA GPU卡不就是虚拟机独占的一块物理GPU卡么。

然而，实践并没有像预想的那么顺利...

.. note::

   由于我之前已经在物理主机安装(演练)过一遍 :ref:`install_nvidia_linux_driver` ，所以采用相同方法在 :ref:`ovmf_gpu_nvme` 的虚拟机 ``z-k8s-n-1`` 安装 NVIDIA CUDA 驱动

:ref:`install_nvidia_linux_driver`
=====================================

- 根据不同发行版在 `NVIDIA CUDA Toolkit repo 下载 <https://developer.nvidia.com/cuda-downloads>`_ 选择对应的 :ref:`cuda_repo` ，例如我的 :ref:`priv_cloud_infra` 采用了 Ubuntu 22.04 LTS，所以执行如下步骤在系统中添加仓库:

.. literalinclude:: ../../machine_learning/cuda/install_nvidia_cuda/cuda_toolkit_ubuntu_repo
   :language: bash
   :caption: 在Ubuntu 22.04操作系统添加NVIDIA官方软件仓库配置

- 安装 NVIDIA CUDA 驱动:

.. literalinclude:: ../../machine_learning/hardware/nvidia_gpu/install_nvidia_linux_driver/cuda_driver_debian_ubuntu_repo_install
   :language: bash
   :caption: 使用NVIDIA官方软件仓库安装CUDA驱动

这里安装过程提示不能支持 Secure Boot::

   Building initial module for 5.15.0-57-generic
   Can't load /var/lib/shim-signed/mok/.rnd into RNG
   40A7F3E73E7F0000:error:12000079:random number generator:RAND_load_file:Cannot open file:../crypto/rand/randfile.c:106:Filename=/var/lib/shim-signed/mok/.rnd
   ...
   Secure Boot not enabled on this system.
   Done.

- 重启操作系统，检查驱动安装::

   nvidia-smi

我以为一切顺利结束，然而...

.. _nvidia_pci_passthrough_via_ovmf_pci_realloc:

NVIDIA passthrough via ovmf需要Host主机内核参数 ``pci=realloc``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

在虚拟机内部 :ref:`install_nvidia_linux_driver` 遇到异常，设备没有初始化成功，从 ``dmesg -T`` 看到:

.. literalinclude:: install_nvidia_linux_driver_in_ovmf_vm/dmesg_nvidia_pci_io_region_invalid
   :language: bash
   :caption: 虚拟机NVIDIA设备初始化失败，显示PCI I/O region错误
   :emphasize-lines: 5,6

这个问题在 `PCI passthrough via OVMF/Examples <https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF/Examples>`_ 找到案例，案例中建议物理主机内核参数需要增加 ``pci=realloc`` ，否则就会导致类似错误::

   NVRM: This PCI I/O region assigned to your NVIDIA device is invalid: NVRM: BAR1 is 0M @ 0x0 (PCI:0000:0a:00.0)

所以修订 :ref:`ovmf_gpu_nvme` 物理主机内核参数添加 ``pci=realloc`` 并重启物理主机

不过，我在物理主机内核参数配置了 ``pci=realloc`` 依然没有解决这个问题，虚拟机内部依然同样错误。

在NVIDIA论坛中 `NVRM: This PCI I/O region assigned to your NVIDIA device is invalid #229899 <https://forums.developer.nvidia.com/t/nvrm-this-pci-i-o-region-assigned-to-your-nvidia-device-is-invalid/229899>`_ 提到如果 ``pci=realloc`` 不生效可以尝试 ``pci=realloc=off`` 。

正在迷惘的时候，参考 `NVRM: This PCI I/O region assigned to your NVIDIA device is invalid #81645 <https://forums.developer.nvidia.com/t/nvrm-this-pci-i-o-region-assigned-to-your-nvidia-device-is-invalid/81645>`_ ，原来这个问题就是我在 :ref:`dl360_gen9_large_bar_memory` 曾经解决过的，当时发现BIOS自检报错:

.. literalinclude:: ../../linux/server/hardware/hpe/dl360_gen9_large_bar_memory/bios_option_ard_config_err
   :caption: NVIDIA Tesla P10计算卡安装后启动BIOS自检报错信息

通过 :ref:`hpe_server_pcie_64bit_bar_support` 解决，所以在物理服务器上 :ref:`install_nvidia_linux_driver` 就没有遇到 ``PCI I/O region assigned to your NVIDIA device is invalid`` 这样的错误。

这个 ``PCI I/O region`` 资源分配问题是常见的，表示pci设备所需的内存窗口大小和区域(BAR)最初是由BIOS分配，但是有时候不正确或不兼容，参数 ``pci=realloc`` 使内核能够更改区域。

结合 `Nvidia drivers for Tesla V100 PCIe 32Gb failing to load <https://forum.proxmox.com/threads/nvidia-drivers-for-tesla-v100-pcie-32gb-failing-to-load.118292/>`_ 和上文的几个参考文档，我逐渐想清楚了:

- 对于NVIDIA GPU，物理主机的BIOS需要激活 :ref:`hpe_server_pcie_64bit_bar_support` 来支持正确的pci设备所需的内存窗口大小和区域(BAR)
- 如果BIOS比较古老不支持上述 ``64-Bit Addressing`` 或者 ``Large BAR`` 配置，则可以通过物理服务器的Linux操作系统内核参数 ``pci=realloc`` 来由内核更改PCI设备内存窗口和区域(BAR)
- 实际上我已经在 :ref:`hpe_dl360_gen9` 完成了 :ref:`dl360_bios_upgrade` ，并通过 激活 :ref:`hpe_server_pcie_64bit_bar_support` 支持，所以没有必要配置物理主机内核参数 ``pci=realloc`` (两者目的是相同的)。这也是为何在物理主机上添加了内核参数 ``pci=realloc`` 前后效果相同的原因。

需要注意的是，上述配置都是在物理服务器上完成，但是这样依然不能使得虚拟机正确

.. note::

   **虚拟机配置** : 反复尝试后我发现 ``其实需要同时满足2个条件`` （见下文)   

- 虚拟机qemu通过传递 ``-global q35-pcihost.pci-hole64-size=2048G`` 可以分配更大的PCI内存窗口( `HGX A100 VM passthrough issues on Ubuntu 20.04 <https://forums.developer.nvidia.com/t/hgx-a100-vm-passthrough-issues-on-ubuntu-20-04/183099>`_ )，对于libvirt配置方法，我参考 `qemuxml2xmlout-pcihole64-gib.xml <https://github.com/snabbco/libvirt/blob/master/tests/qemuxml2xmloutdata/qemuxml2xmlout-pcihole64-gib.xml>`_ 

执行 ``virsh edit z-k8s-n-1`` 

找到::

   <controller type='pci' index='0' model='pcie-root'/>

修改成::

   <controller type='pci' index='0' model='pcie-root'>
       <pcihole64 unit='KiB'>2147483648</pcihole64>
   </controller> 

然后启动虚拟机后检查 ``qemu`` 参数就可以看到 ``-global q35-pcihost.pci-hole64-size=2147483648K``

不过，此时虚拟机内部依然报错 (还需要下面一步)

- 虚拟机内核还是要添加 ``pci=realloc`` 才能彻底解决NVIDIA的 ``PCI I/O region`` 错误问题

  - 单纯在虚拟机内核上配置 ``pci=realloc`` 是不够的(目前我的物理主机还开启着 ``pci=realloc`` ，等有时间我关闭物理主机内核 ``pci=realloc`` 验证一下我的猜想)

在虚拟机内部修改 ``/etc/default/grub`` 添加参数 ``pci=realloc`` :

.. literalinclude:: install_nvidia_linux_driver_in_ovmf_vm/grub
   :caption: 修订 ``/etc/default/grub`` 添加 ``pci=realloc`` 参数
   :emphasize-lines: 2

然后执行::

   update-grub

再重启一次虚拟机

WOW，终于虚拟机内部不再出现NVIDIA相关报错，并且执行 ``nvidia-smi`` 可以正确看到

.. literalinclude:: install_nvidia_linux_driver_in_ovmf_vm/ovmf_passthrough_nvidia-smi_output
   :caption: 虚拟机正确配置NVIDIA后执行nvidia-smi输出信息

参考
========

- `NVIDIA Cloud Native Documentation: Installation Guide >> containerd <https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html#containerd>`_
