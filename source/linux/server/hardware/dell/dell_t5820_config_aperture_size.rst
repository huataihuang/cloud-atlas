.. _dell_t5820_config_aperture_size:

=================================
配置Dell T5820 Aperture Size变量
=================================

我在尝试通过 :ref:`amd_mi50_change_vbios_bar_size` 来解决 :ref:`dell_t5820` 不支持resize BAR，也就是不能够支持大规格BAR，遇到手工修订VBIOS的困难无法解决。从另一个角度来说，既然 :ref:`amd_mi50` 无法修订BAR size，那么从主机BIOS角度来说，其实可以通过忽略GPU上报BAR size来解决。这个思路是在gemini提示后，google到 :ref:`gentoo_linux` Wiki中的一篇 `User:0xdc/Drafts/Configure Intel GPU Aperture Size via hidden UEFI settings <https://wiki.gentoo.org/wiki/User:0xdc/Drafts/Configure_Intel_GPU_Aperture_Size_via_hidden_UEFI_settings>`_ 触发的

.. warnging::

   实际上我搞错了概念，我以为调整 :ref:`dell_t5820` 的BIOS中 ``Aperture Size`` 能够忽略掉 :ref:`amd_mi50` 这种计算卡要求大规格BAR的请求，实际上搞错了 ``Aperture Size`` 和 ``ReBAR`` 的对应关系:

   ``ReBAR`` 是PCIe规范中新的协商机制，通过动态协商要求主板BIOS分配连续的大BAR的地址空间。但是如果BIOS由于主板总线布局、控制器(nvme,网卡)占位，导致在64为空间找不到连续的32GB区域，或者对齐计数器(通常最大只支持到256MB或512MB的对齐步进)溢出，就会分配失败。

   由于 :ref:`dell_t5820` 主板BIOS不支持 ``reBAR`` 协议，导致无法响应和 :ref:`amd_mi50` 协商BAR，这就会导致启动时挂起。这个问题通过修订BIOS的 ``Aperture Size`` 是无法解决的。我最初以为修订 ``Aperture Size`` 能够写死BIOS的BAR大小忽略GPU的请求，是理解错误的!

   要解决Dell T5820能够使用 :ref:`amd_mi50` 或 :ref:`tesla_a2` 这样的数据中心计算卡，需要采用 :ref:`amd_mi50_change_vbios_bar_size` (但是我实践失败) ，或者采用 :ref:`dell_t5820_rebaruefi` 为BIOS注入reBAR功能。

下载BIOS
===========

我使用的 :ref:`dell_t5820` 在官方网站可以下载到最新的 `Dell T5820 BIOS 2.48.0 <https://www.dell.com/support/home/en-uk/drivers/driversdetails?driverid=6y45v&oscode=biosa&productcode=precision-5820-workstation>`_ 

下载到的是一个 ``Precision_5820_2.48.0.exe`` ，Dell使用PFS封装了BIOS bin文件，需要使用社区开发的 `platomav/BIOSUtilities <https://github.com/platomav/BIOSUtilities>`_ 来处理BIOS文件

在这个 `platomav/BIOSUtilities <https://github.com/platomav/BIOSUtilities>`_ 的Python工具中 ``dell_pfs_extract.py`` 可以用来提取Dell的bios文件

.. literalinclude:: dell_t5820_config_aperture_size/extract_bios
   :caption: 执行下载的bios执行文件提取出所需的.bin文件

.. note::

   另一种获取BIOS文件的方式是直接从主机芯片中抠出当前的固件，也就是使用 ``Intel CSME System Tools`` 来获取主板现成包含所有变量状态的固件镜像。 ``Intel CSME System Tools`` 需要从github上找，例如 `CE1CECL/IntelCSTools <https://github.com/CE1CECL/IntelCSTools>`_

   需要注意CSME工具是有对应处理器系列的要求的，T5820搭载Xeon W-2100系列处理器对应CSME v11，搭载Xeon W-2200斜裂处理器对应CSME v12

   另外，Intel 官方提供的 `Intel CSME Version Detection Tool <https://www.intel.com/content/www/us/en/download/19392/intel-converged-security-and-management-engine-version-detection-tool-intel-csmevdt.html>`_ 是一个安全检测工具，用于检测当前的ME固件版本是否有漏洞，它并没有读写(Dump/Flash)固件的功能。对于要读取BIOS的操作，应该使用前述的 **Intel CSME System Tools** 工具中提供的 ``Flash Programming Tool(FPT)``

不过，实践发现使用 ``dell_pfs_extract.py`` 提取文件还是失败了，gemini提示是Dell可能在文件中加入了额外的混淆，所以改为 ``binwalk`` 来处理

.. literalinclude:: dell_t5820_config_aperture_size/binwalk
   :caption: 安装binwalk来提取.bin文件

使用 ``binwalk`` 执行后输出信息:

.. literalinclude:: dell_t5820_config_aperture_size/binwalk_output
   :caption: 安装binwalk来提取.bin文件

此时在 ``_[0].extracted`` 目录下有:

.. literalinclude:: dell_t5820_config_aperture_size/binwalk_files
   :caption: 通过binwalk获得的文件

这里 ``210`` 很可能就是被压缩过的PFS固件载荷，接下来用 ``UEFITool`` 来验证

.. warning::

   从下载的Dell官方BIOS执行文件中，我尝试提取.bin失败，所以最终我采用了其他手段

UEFITool
============

UEFITool是一个遵循UEFI平台接口规范的firmware镜像查看和编辑器。

按照Gentoo Linux Wiki `User:0xdc/Drafts/Configure Intel GPU Aperture Size via hidden UEFI settings <https://wiki.gentoo.org/wiki/User:0xdc/Drafts/Configure_Intel_GPU_Aperture_Size_via_hidden_UEFI_settings>`_ 是从源代码编译。不过， `LongSoft/UEFITool <https://github.com/LongSoft/UEFITool/>`_ 官方release也提供了针对不同平台编译好的执行程序，可以直接下载使用。

.. literalinclude:: dell_t5820_config_aperture_size/uefitool
   :caption: 下载和运行UEFITool

.. note::

   UEFITool是一个图形化程序，例如在Linux环境下运行需要Qt环境，所以对于我的远程Linux字符终端服务器过于沉重。所以我最后改为在Windows平台运行以方便使用。

将前面解开的 ``210`` 在 ``UEFITool`` 中打开，如果能够打开则说明前面使用 ``dell_pfs_extract.py`` 或 ``binwalk`` 是正确获取了PFS载荷，如果失败，则说明前面的步骤没有成功，需要寻找其他方法来获取PFS载荷。

如果一切顺利的话， 按照Gentoo Linux Wiki `User:0xdc/Drafts/Configure Intel GPU Aperture Size via hidden UEFI settings <https://wiki.gentoo.org/wiki/User:0xdc/Drafts/Configure_Intel_GPU_Aperture_Size_via_hidden_UEFI_settings>`_ 就能够从官方的 ``bios.bin`` 中搜索到内容是 ``Aperture Size`` 的内容，就可以将这部分导出为 ``section.bin`` ，让后续的 ``ifextract`` 工具(该工具能将二进制文件内容解析转换成人能够读取的变量设置)来处理解析 

.. warngin::

   很不幸，我的实践验证前面采用的 ``binwalk`` 方法没有正确提取出PFS载荷，在UEFITools中无法使用该文件

Intel CSME System Tools(失败)
================================

由于我前面尝试 ``dell_pfs_extract.py`` 和 ``binwalk`` 来提取PFS载荷失败，所以我改为尝试Intel提供的主板BIOS提取工具 ``Intel CSME System Tools`` ，从 `CE1CECL/IntelCSTools <https://github.com/CE1CECL/IntelCSTools>`_ 下载 CSME System Tools :strike:`v12` **v14** (针对 :ref:`dell_t5820` 使用的Xeon W-2200系列处理器，我实践下来需要使用v14):

- 下载以后找寻LINUX64版本的 ``fpt`` ，有点奇怪的目录 :strike:`CSME System Tools v12 r38/Flash Programming Tool/LINUX64` ，将该目录下程序 ``FPT`` 设置为可执行，然后执行

.. literalinclude:: dell_t5820_config_aperture_size/fpt
   :caption: 执行 ``fpt`` 来提取BIOS

这里我遇到一个报错，提示版本不兼容:

.. literalinclude:: dell_t5820_config_aperture_size/fpt_unsupport
   :caption: 版本不兼容报错
   :emphasize-lines: 5

这里提示是因为 "后期出货的 W-2200 系列或 BIOS 更新后，底层驱动逻辑更接近 Comet Lake"

按照 gemini 提示，使用最兼容CometLake V Series的 v14.0.x 系列: ``CSME System Tools v14.0.20+ r20``

但是依然报错:

.. literalinclude:: dell_t5820_config_aperture_size/fpt_unsupport_again
   :caption: 版本不兼容报错依旧
   :emphasize-lines: 3

但是执行依然报错，gemini提示是: Dell 在 T5820 的固件中做了相当深入的定制，导致 Intel 官方的 FPT 工具即使版本号对标也无法识别其 PCH（南桥）特征。这种情况在高性能工作站上并不罕见，因为它们的 PCH ID 往往被归类为“Server/WS”级别，而非普通的消费级 Comet Lake。

flashrom(失败)
=================

gemini提示可以使用社区的 ``flashrom`` 工具，不依赖Intel的工具链，是直接通过内核驱动尝试访问SPI总线:

.. literalinclude:: dell_t5820_config_aperture_size/flashrom
   :caption: 尝试flashrom

但是也没有成功，显示不支持该平台

UEFI BIOS Updater (UBU)(失败)
=================================

gemini提示采用 ``UEFI BIOS Updater (UBU)`` 这个工具从 `Win-Raid Forum: [Tool Guide+News] “UEFI BIOS Updater” (UBU) <https://winraid.level1techs.com/t/tool-guide-news-uefi-bios-updater-ubu/30357>`_ 可以找到最新版本是 2024年11月发布的 ``UEFI BIOS Updater v1.80 B1`` ，(注册论坛后?)可以在该页面置顶贴找到 "SoniX’s MEGA folder" 提供的下载

.. note::

   UBU（UEFI BIOS Updater）本身并不具备解析 BIOS 二进制结构的能力，它本质上是一个由 批处理脚本（.bat） 编写的自动化流水线，负责调用各种专业小工具来完成复杂的任务。

将之前从Dell官方网站下载的 ``Precision_5820_2.48.0.exe`` 放到 UBU 的根目录下，然后右键以管理员权限运行 ``UBU.cmd`` 然后选择 ``Precision_5820_2.48.0.exe`` 进行扫描

很不幸，扫描后提示 ``Unknown platform BIOS`` ，看来也没有成功

如果成功的话，则会在当前目录下生成一个正确的 ``bios.bin`` 文件，这个文件就能够用UEFITool处理扫描，见上文(我没有成功)

IFRExtractor
================

`LongSoft/Universal-IFR-Extractor <https://github.com/LongSoft/Universal-IFR-Extractor>`_ 现在已经停止开发，官方改为使用Rust开发的 `LongSoft/IFRExtractor-RS <https://github.com/LongSoft/IFRExtractor-RS>`_ 可以直接下载release提供的二进制执行软件。

.. literalinclude:: dell_t5820_config_aperture_size/ifrextract
   :caption: 使用 ``ifrextract`` 将bios解析成文本

根据解析得到的 ``setup.txt`` 能够找到每个 ``Aperture Size`` 规格对用的BIOS偏移地址，后续就能够有针对性设置指定值

.. warning::

   由于我前面的尝试都失败了，实际上这步我没有进行，改为后续的盲猜尝试

modGRUBshell
===============

.. note::

   理论上我应该在前面通过 UEFITool + IFRExtrator 获得准确的每个Apecture Size的编译位置才能进行这一步。但是我实际上前面尝试都失败了，看来Dell的BIOS是加密非标准兼容机的格式，使用各种工具都无法处理。我最终采用盲猜方式来完成本段实践。

setup_var.efi
================

.. note::

   我发现gemini给的指导实际上是错误的，导致我走了一个弯路: gemini 以为 ``setup_var.efi`` 和之前的 ``modGRUBshell`` 是相同的工具的重写版本，所以给了一个旧版的操作方法(通过efibootmgr来启动setup_var.efi)实际上无法启动。

   正确的方法应该是启动一个 ``uefi shell`` ，在 ``uefi shell`` 中运行这个 ``setup_var.efi`` 独立命令

`datasone/setup_var.efi <https://github.com/datasone/setup_var.efi>`_ 提供了一个 **UEFI Command Line Tool for Reading/Writing UEFI Variables** 可以修订UEFI的变量值，这个工具对于我的 :ref:`dell_t5820` 来说，可能可以修复Apecture Size

Gemini提示根据 T5820 历史版本（2.1.0 到 2.20.0）固件库比对出的三个最可能的偏移量:

- 0x5C2 (最常见)
- 0x5C6
- 0x632

需要挨个尝试...

U盘启动方法:实践失败
---------------------

.. warning::

   这段我搞错了，gemini指导我去直接启动 ``setup_var.efi`` 是错误的，应该启动一个 ``uefi shell`` 再运行这个工具。

   **这段保留仅仅是为了记录我的错误以便更理解这些工具的使用方法**

- 首先从 `datasone/setup_var.efi <https://github.com/datasone/setup_var.efi>`_ 下载 ``setup_var.efi``

- 格式化U盘，将U盘格式化成 FAT32

.. literalinclude:: dell_t5820_config_aperture_size/fat32
   :caption: 将U盘分区格式化成FATA32

- 挂载分区:

.. literalinclude:: dell_t5820_config_aperture_size/mount
   :caption: 挂载分区

- 创建EFI结构并复制引导文件:

.. literalinclude:: dell_t5820_config_aperture_size/cp
   :caption: 构建EFI

- 将U盘插入 :ref:`dell_t5820` 然后启动主机，在启动时按下 ``F12`` 选择从UEFI启动从U盘启动

.. warning::

   我遇到一个问题，我的 :ref:`dell_t5820` 似乎禁止从外部U盘启动UEFI，虽然我已经安装gemini提示做了BIOS调整:

   - ``UEFI Boot Path Security`` 设置为 ``Never``
   - ``SMM Security Mitigation`` 设置为 ``Disabled`` (这个参数开启会导致无法修改变量)
   - ``Secure Boot Enable`` 设置为 ``Disabled``

- 执行(这里仅记录，因为从U盘启动没有成功）

.. literalinclude:: dell_t5820_config_aperture_size/run
   :caption: 执行 ``setup_var``

注入硬盘引导方法(efibootmgr):实践失败
-----------------------------------------

.. warning::

   这段gemini指导的方法也是错误的，但是启动的efi方法可以作为后续参考

由于上述从U盘启动UEFI可以触发了 :ref:`dell_t5820` 的安全限制，所以改为将 ``setup_var.efi`` 复制到硬盘的EFI分区中来运行:

.. literalinclude:: dell_t5820_config_aperture_size/disk_uefi
   :caption: 将 ``setup_var.efi`` 复制到硬盘的EFI分区

使用 efibootmgr 注册启动项:

.. literalinclude:: dell_t5820_config_aperture_size/efibootmgr
   :caption: 使用 ``efibootmgr`` 注册启动项目

这个命令执行会输出：

.. literalinclude:: dell_t5820_config_aperture_size/efibootmgr_output
   :caption: 使用 ``efibootmgr`` 注册启动项目的输出信息
   :emphasize-lines: 6

由于上述步骤是注册从硬盘启动的EFI，所以可以绕过 :ref:`dell_t5820` 的安全限制

重启系统，按 ``F12`` ，选择 ``BIOS_MOD_TOOL`` 运行

但是T5820启动后执行了 ``Pre-boot System Performance Check`` 后提示 ``Hardware scan complete with no issues. No bootable devices were found! Possible causes could be a corrupt OS image or a boot device is not enabled in BIOS setup. `` ，然后只提供了一个 ``Shutdown按钮``

gemini提示( **事后排查发现gemini的解释是错的** ):

- ``No bootable devices were found`` ：说明 Dell 的固件已经扫描了你的 EFI 分区，但它拒绝承认 ``setup_var.efi`` 是一个有效的引导文件
- ``Pre-boot System Performance Check`` : 这说明 BIOS 在尝试加载该文件时触发了自检
- **关机原因** ：这不是因为安全拦截，而是因为该 ``.efi`` 文件可能与 T5820 这种基于 ``Intel Scalable (Xeon W)`` 架构的底层 EFI 运行时环境（Runtime Services）不兼容，导致固件加载器在 PE 头部校验或入口函数执行时直接崩溃，随后 BIOS 逻辑认为没有可用的引导设备，只能引导你关机。 **这个解释存疑**

注入硬盘引导方法(grub):实践失败
----------------------------------

.. warning::

   这段gemini指导实践下来行不通，原因是 ``setup_var.efi`` 是一个独立的UEFI shell中执行的工具，而不是efi启动盘。

   这里保留只是为了今后参考知道自己错在哪里!

由于上述 ``efibootmgr`` 执行 ``setup_var.efi`` 失败，改为采用先启动GRUB，然后在grub中执行efi命令: 因为 GRUB 是由 Ubuntu 正确签名并被 BIOS 信任的，它已经获得了执行权限，所以能够执行自定义的 ``efi`` 指令

- 修改 ``/etc/default/grub`` 设置启动时显示GRUB菜单并提供10秒钟超时以便选择输入命令 ``c`` :

.. literalinclude:: dell_t5820_config_aperture_size/grub
   :caption: 修改 ``/etc/default/grub`` 配置

- 更新grub:

.. literalinclude:: dell_t5820_config_aperture_size/update-grub
   :caption: 更新grub

- 然后在GRUB启动菜单中按下 ``c`` 来进入GRUB命令行，输入:

.. literalinclude:: dell_t5820_config_aperture_size/boot
   :caption: 在GRUB命令行输入

这里我遇到了报错:

.. literalinclude:: dell_t5820_config_aperture_size/boot_error
   :caption: 启动报错

gemini提示上述错误( **这段解释是gemini强行挽尊** ): 是因为GRUB 试图加载这个文件，但 EFI 固件在校验该文件的 PE 头部时发现其不符合 T5820 这种工作站级别主板的严格内存对齐或签名要求。由于 T5820 是 Xeon 平台，它的 EFI 实现非常保守。所以gemini建议我采用OpenCore 社区维护的、极其稳定的 ``modGRUBShell.efi`` （也叫 ``ControlMsrE2.efi`` 的变体）

通过UEFI shell运行setup_var.efi
----------------------------------

仔细阅读了setup_var.efi的README，了解到这个工具实际是在UEFI shell中执行的独立程序(我应该早点看README)，这样思路就改成应该先启动一个完整的UEFI shell，然后在 ``shell>`` 中运行这个变量设置程序 ``setup_var.efi`` 

从 `pbatard/UEFI-Shell <https://github.com/pbatard/UEFI-Shell>`_ 下载最新版本的UEFI shell，这个UEFI shell是从EDK2 源码编译的目前社区里最标准、兼容性最好的 UEFI Shell 二进制分发版。

之前遇到的 ``r = 2`` 报错是因为 ``setup_var.efi`` 运行需要一个SHELL环境。这个 shell.efi 会提供完整的指令集（如 map, ls, cd），它能像一个微型操作系统一样，为 ``setup_var.efi`` 提供必要的运行支撑。

- 将下载的 ``shellx64.efi`` 同样复制到 ``/boot/efi/EFI/tools`` 目录

.. literalinclude:: dell_t5820_config_aperture_size/shell.efi
   :caption: 复制 ``shell.efi``

- 为了避免每次都手工去输入繁杂的GRUB命令，将 ``shell.efi`` 集成到GRUB菜单中，编辑 ``/etc/grub.d/40_custom`` :

.. literalinclude:: dell_t5820_config_aperture_size/40_custom
   :caption: 配置 ``/etc/grub.d/40_custom`` 将shell.efi集成到GRUB菜单
   :emphasize-lines: 6-11

- 然后更新GRUB并重启:

.. literalinclude:: dell_t5820_config_aperture_size/update-grub
   :caption: 更新grub

- 重启后选择进入UEFI shell后，首先执行 ``map -r`` ，可以看到系统中的各个分区，按照分区前面的标号进入分区，例如 ``FS1:`` 回车以后，执行 ``ls`` 看有没有看到工具。不行就换一个分区

- 进入工具目录:

.. literalinclude:: dell_t5820_config_aperture_size/cd
   :caption: 进入工具目录

- ``setup_var.efi`` 运行的命令方法比较奇特，我看了一会儿README明白了大概的使用方法:

.. literalinclude:: dell_t5820_config_aperture_size/setup_var.efi
   :caption: 简单的读取和设置方法

.. note::

   实践到这一步，我已经了解了如何通过 ``setup_var.efi`` 调整UEFI模式的BIOS参数，也算实践有所收获。

   不过，这次实践没有解决在 :ref:`dell_t5820` 上安装 :ref:`amd_mi50` 的启动问题，原因我在本文开头做了说明总结。

参考
=======

- `User:0xdc/Drafts/Configure Intel GPU Aperture Size via hidden UEFI settings <https://wiki.gentoo.org/wiki/User:0xdc/Drafts/Configure_Intel_GPU_Aperture_Size_via_hidden_UEFI_settings>`_ Gentoo Linux提供了调整主板BIOS隐藏的UEIF设置来强制设置Aperture Size
