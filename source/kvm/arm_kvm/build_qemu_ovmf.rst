.. _build_qemu_ovmf:

=======================
编译QEMU+OVMF(ARM架构)
=======================

源代码编译QEMU
======================

- 安装编译依赖::

   pacman -S ninja

- 执行以下方法下载编译::

   tar xvJf qemu-7.1.0.tar.xz
   cd qemu-7.1.0
   ./configure
   make -j8   #按照主机CPU核心数设置编译并发

源代码编译OVMF
=====================

:ref:`ovmf` 提供了虚拟机的UEFI支持，可以在虚拟机中实现硬件直通(CPU/PCI)，对于ARM架构的服务器支持有重要意义。在 :ref:`asahi_linux` 的arch linux for ARM仓库没有提供 UEFI/EDK2 软件包 ``ovmf-aarch64`` ，所以这里也从源代码编译

.. note::

   `EDK2 Nightly Build <https://retrage.github.io/edk2-nightly/>`_ 提供了编译好的EDK2，非官方的OVMF(各种平台)

``ovmf-aarch6`` 软件包提供BIOS是 ``/usr/share/ovmf/AARCH64/QEMU_EFI.fd`` 

- 安装编译工具::

   pacman -S make gcc binutils acpica nasm

.. note::

   安装 ``iasl`` 实际安装是 ``acpica`` (替代了iasl)，这个软件包是ACPI工具

   在aarch64架构上没有提供 ``nasm`` ，这个软件包是 80x86 assembler

   详情参考 `edk2-aarch64 <https://archlinux.org/packages/extra/any/edk2-aarch64/>`_

- 下载源代码::

   git clone git@github.com:tianocore/edk2.git
   cd edk2
   git submodule update --init

- ``edksetup`` 脚本会准备编译环境::

   source edksetup.sh

这里似乎有个报错::

   bash: /home/huatai/docs/github.com/tianocore/edk2-master/BaseTools/BuildEnv: No such file or directory

我采用以下方法绕过::

   cd ..
   ln -s edk2 edk2-master
   cd edk2
   source edksetup.sh

此时在 ``Conf`` 目录下会生成 ``target.txt`` 可以编辑你需要编译的UEIF镜像目标平台

举例:

X64平台:

.. literalinclude:: build_qemu_ovmf/target.txt_x64
   :language: bash
   :caption: 编译x64的UEFI镜像，用于OVMF，使用GCC5

AARCH64平台:

.. literalinclude:: build_qemu_ovmf/target.txt_aarch64
   :language: bash
   :caption: 编译ARM 64位的UEFI镜像，用于OVMF，使用GCC5

- 编译 BaseTools (只需要执行一次)::

   make -C BaseTools

- 如果已经配置过 ``Conf/target.txt`` ，则直接执行::

   build

如果没有配置 ``Conf/target.txt`` 则可以命令行传递编译参数:

对于x64 qemu，使用::

   build -t GCC5 -a X64 -p OvmfPkg/OvmfPkgX64.dsc

则编译后firmware卷位于 ``Build/OvmfX64/DEBUG_GCC5/FV``

对于aarch64 firmware，使用::

   build -t GCC5 -a AARCH64 -p ArmVirtPkg/ArmVirtQemu.dsc

则编译后firmware位于 ``Build/ArmVirtQemu-AARCH64/DEBUG_GCC5/FV``

- Qemu希望 aarch64 的 firmware 是 64M ，所以firmware镜像不能直接使用，需要一些填充来创建可以用于 pflash 的镜像::

   cd Build/ArmVirtQemu-AARCH64/DEBUG_GCC5/FV
   dd of="QEMU_EFI-pflash.raw" if="/dev/zero" bs=1M count=64
   dd of="QEMU_EFI-pflash.raw" if="QEMU_EFI.fd" conv=notrunc
   dd of="QEMU_VARS-pflash.raw" if="/dev/zero" bs=1M count=64
   dd of="QEMU_VARS-pflash.raw" if="QEMU_VARS.fd" conv=notrunc

编译选项
----------

.. note::

   这段比较复杂，对于深入研究安全启动有必要了解。我实际没有实践

有许多编译时选项，通常使用 ``-D NAME`` 或 ``-D NAME=TRUE`` 启用。 可以使用 ``-D NAME=FALSE`` 关闭默认启用的选项。 可用选项在构建命令引用的 ``*.dsc`` 文件中定义，所以一个功能完整的镜像构建可能类似如下::

   build -t GCC5 -a X64 -p OvmfPkg/OvmfPkgX64.dsc \
       -D FD_SIZE_4MB \
       -D NETWORK_IP6_ENABLE \
       -D NETWORK_HTTP_BOOT_ENABLE \
       -D NETWORK_TLS_ENABLE \
       -D TPM2_ENABLE 

安全启动支持(在x64上)需要SMM模式。在没有SMM的情况下，没有什么可以阻止用户操作系统绕过固件直接写入闪存，因此受保护的 UEFI 变量实际上并未受到保护。此外，挂起(S3)支持仅在固件的某些部分(特别是PEI，详见下文)以32位模式运行时才与启用的SMM 一起使用。 所以安全启动变体必须这样编译::

   build -t GCC5 -a IA32 -a X64 -p OvmfPkg/OvmfPkgIa32X64.dsc \
       -D FD_SIZE_4MB \
       -D SECURE_BOOT_ENABLE \
       -D SMM_REQUIRE \
       [ ... add network + tpm + other options as needed ... ]

``D_SIZE_4MB`` 参数选项创建更大的固件映像，大小为 4MB 而不是 2MB（默认），为代码和变量提供更多空间。 RHEL/CentOS 构建使用它。由于历史原因，Fedora 构建的大小为 2MB。

如果需要32位firmware，采用以下方法::

   build -t GCC5 -a ARM -p ArmVirtPkg/ArmVirtQemu.dsc
   build -t GCC5 -a IA32 -p OvmfPkg/OvmfPkgIa32.dsc

编译后的输出结果位于 ``Build/ArmVirtQemu-ARM/DEBUG_GCC5/FV`` 和 ``Build/OvmfIa32/DEBUG_GCC5/FV``

引导新的firmware构建
=====================

x86 firmware build会创建3各不同镜像:

- ``OVMF_VARS.fd`` : 这是持久化的UEFI变量的firmware卷，即firmware存储所有配置(引导条目和引导顺序、安全引导密钥等)。通常这个文件用作空变量存储的模板，每个VM都有自己的私有副本。例如 :ref:`libvirt` 将文件存储在 ``/var/lib/libvirt/qemu/nvram`` 中。

- ``OVMF_CODE.fd`` : 带有代码的firmware卷。将它和 ``VARS`` 分开可以:

  - 确保轻松更新固件
  - 允许将只读代码映射到guest操作系统

= ``OVMF.fd`` : 是包含 ``CODE`` 和 ``VARS`` 的一体化镜像。这样就可以使用 ``-bios`` 参数直接作为ROM加载。但是有2个缺点:

  - ``UEFI`` 变量不是持久的
  - 不适用于 ``SMM_REQUIRE=TRUE`` 构建

``qemu`` 将 pflash 存储作为快设备处理，所以必须创建用于firmware镜像的块设备文件文件::

   CODE=${WORKSPACE}/Build/OvmfX64/DEBUG_GCC5/FV/OVMF_CODE.fd
   VARS=${WORKSPACE}/Build/OvmfX64/DEBUG_GCC5/FV/OVMF_VARS.fd
   qemu-system-x86_64 \
     -blockdev node-name=code,driver=file,filename=${CODE},read-only=on \
     -blockdev node-name=vars,driver=file,filename=${VARS},snapshot=on \
     -machine q35,pflash0=code,pflash1=vars \
     [ ... ]

以下是ARM版本(也就是上文使用 ``dd`` 创建的填充文件::

   CODE=${WORKSPACE}/Build/ArmVirtQemu-AARCH64/DEBUG_GCC5/FV/QEMU_EFI-pflash.raw
   VARS=${WORKSPACE}/Build/ArmVirtQemu-AARCH64/DEBUG_GCC5/FV/QEMU_VARS-pflash.raw
   qemu-system-aarch64 \
     -blockdev node-name=code,driver=file,filename=${CODE},read-only=on \
     -blockdev node-name=vars,driver=file,filename=${VARS},snapshot=on \
     -machine virt,pflash0=code,pflash1=vars \
     [ ... ]

源代码结构
=============

``edk2`` 核心仓库包含一系列软件包，每个软件包都有自己的顶级目录，以下是一些重要目录:

- ``OvmfPkg`` : x64相关代码以及特定的虚拟化代码，如virtio驱动
- ``ArmVirtPkg`` : ARM特定代码
- ``MdePkg, MdeModulePkg`` ： 主要核心代码，如PCI支持，USB至此和，通用服务和驱动等等
- ``PcAtChipsetPkg`` : Intel架构的驱动和库
- ``ArmPkg, ArmPlatformPkg`` : ARM架构支持代码
- ``CryptoPkg, NetworkPkg, FatPkg, CpuPkg, ...`` : 加密支持(使用openssl，网络支持(包括网络启动),FAT文件系统驱动等等

使用OVMF
==============

在 :ref:`libvirt` 启动VM时传递参数 ``--boot uefi`` 可启动OVMF，举例::

   virt-install --name centos8 --ram=2048 --vcpus=1 --cpu host --hvm --disk path=/var/lib/libvirt/images/centos8-vm1,size=10 --location /home/ostechnix/centos8.iso --network bridge=br0 --graphics vnc --boot uefi

参考 `edk2-aarch64 <https://archlinux.org/packages/extra/any/edk2-aarch64/>`_ 软件包文件目录，应该有::

   usr/share/edk2/aarch64/QEMU_CODE.fd
   usr/share/edk2/aarch64/QEMU_EFI.fd
   usr/share/edk2/aarch64/QEMU_VARS.fd

所以使用如下复制方法::

   mkdir -p /usr/share/edk2/aarch64
   cp QEMU_EFI-pflash.raw /usr/share/edk2/aarch64/QEMU_CODE.fd
   cp QEMU_VARS-pflash.raw /usr/share/edk2/aarch64/QEMU_VARS.fd

参考
======

- `edk2 quickstart for virtualization <https://www.kraxel.org/blog/2022/05/edk2-virt-quickstart/>`_ 这篇文档非常详细，特别是编译的步骤，包括ARM64。本文的编译OVMF参考该文档
- `ubuntu wiki: OVMF <https://wiki.ubuntu.com/UEFI/OVMF>`_
- `How to run OVMF <https://github.com/tianocore/tianocore.github.io/wiki/How-to-run-OVMF>`_
- `QEMU Build instructions <https://www.qemu.org/download/#source>`_
- `Setup: Linux host, QEMU vm, arm64 kernel <https://android.googlesource.com/platform/external/syzkaller/+/HEAD/docs/linux/setup_linux-host_qemu-vm_arm64-kernel.md>`_ 手工启动QEMU vm(ARM)
- `arch linux arm aarch64 + ovmf uefi + qemu <https://xnand.netlify.app/2019/10/03/armv8-qemu-efi-aarch64.html>`_
- `How to build OVMF <https://github.com/tianocore/tianocore.github.io/wiki/How-to-build-OVMF>`_ 不过这个文档没有很详细的关于ARM64架构的说明
