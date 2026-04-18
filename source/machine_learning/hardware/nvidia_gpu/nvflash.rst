.. _nvflash:

===============
nvflash
===============

``nvflash`` 是NVIDIA显卡底层的固件闪存工具，直接与显卡上的 **EEPROM (电可擦除可编程只读存储器)** 通信。

``nvflash`` 并不通过操作系统的驱动层(如 NVIDIA Driver)来读写数据，而是通过 **PCIe总线** 直接访问GPU的配置空间:

- **SPI总线通讯** : GPU芯片内部集成了一个SPI控制器，它连接着主板上的BIOS芯片。 ``nvflash`` 发送指令给GPU，命令GPU代理写入BIOS芯片
- **跳过保护机制** : ``nvflash`` 能够通过特定命令(如 ``--protectoff`` )来解除芯片到写保护，或者通过强制参数( ``-6`` )忽略SSID和Device ID的不匹配
- **内存镜像映射** : 在刷写过程中， ``nvflash`` 会将ROM文件载入内存，进行校验(checksum)计算，确认无误后再按块(block)写入EEPROM

我之所以需要使用 ``nvflash`` 是因为我在 :ref:`dell_t5820_gpu` 时发现我购买的二手 :ref:`dell_t5820` 无法使用数据中心的GPU运算卡，很有可能是因为T5820工作站不支持 ``reBAR`` (虽然2017年之后很多兼容机都已经支持)，导致只能使用面向工作站的显卡而不支持面向服务器的GOU计算卡(需要申请巨大的BAR，如16GB或32GB)。

为了能够验证或者说解决 :ref:`dell_t5820` 上使用 :ref:`tesla_a2` 启动问题，我尝试调整 A2 的gpu模式，调整为 ``graphics`` 模式来使用传统的 "Small BAR"。

.. warning::

   在使用 ``nvflash`` 之前，必须首先备份

下载nvflash
=============

`TechPowerUP提供了NVIDIA NVFlash下载 <https://www.techpowerup.com/download/nvidia-nvflash/>`_ 

- 通过解压缩并复制进行安装:

.. literalinclude:: nvflash/install
   :caption: 安装nvflash

我在使用前先用 ``nvidia-smi`` 查看一下当前 :ref:`tesla_a2` 的工作模式: 当前是 ``Compute`` 模式

.. literalinclude:: nvflash/nvidia-smi_compute
   :caption: 可以看到当前是Compute模式
   :emphasize-lines: 6

使用准备
============

在使用 ``nvflash`` 之前需要先禁止NVIDIA内核模块(关键)

.. literalinclude:: nvflash/modprobe-r
   :caption: 禁止驱动

这里可能有模块无法移出，需要查看原因，例如我遇到:

.. literalinclude:: nvflash/modprobe-r_error
   :caption: 移除模块报错

原因是移除命令对模块的顺序是有依赖关系的，通过 ``lsmod | grep nvidia_uvm`` 可以看到 ``nvidia_uvm`` 似乎已经没有依赖使用它的模块

.. literalinclude:: nvflash/mod_depend
   :caption: 显示nvidia_uvm的依赖

这确实是一个麻烦，没法移除模块？

由于可以看到 ``nvidia_uvm`` 还有 **2** 个引用，但是不是模块依赖，这表明是用户态进程在使用

所以要使用 ``lsof`` 来检查

.. literalinclude:: nvflash/lsof
   :caption: 检查哪个用户进程在使用nvidia模块

输出如下，显示有一个 ``dcgm-exporter`` 进程在使用nvidia设备:

.. literalinclude:: nvflash/lsof_output
   :caption: ``dcgm-exporter`` 进程在使用nvidia设备

我是因为 :ref:`ollama_nvidia_a2_gpu_docker` 中包含了 ``dcgm-exporter`` ，所以停止容器来解决这个模块移除问题

使用
=======

- 首先列出所有NVIDIA显卡及索引

.. literalinclude:: nvflash/list
   :caption: 列出NVIDIA显卡

显示有一个设备:

.. literalinclude:: nvflash/list_output
   :caption: 列出NVIDIA显卡显示输出
   :emphasize-lines: 5

- 备份固件:

.. literalinclude:: nvflash/save
   :caption: 保存ROM

报错:

.. literalinclude:: nvflash/save_error
   :caption: 保存ROM报错

奇怪，为何要求重启系统才能运行工具？

暂时屏蔽nvidia模块
---------------------

- 先配置 ``blacklist-nvidia.conf`` 配置屏蔽掉自动加载nvidia模块，以便运行 ``nvflash``

.. literalinclude:: nvflash/blacklist-nvidia.conf
   :language: bash
   :caption: 配置 /etc/modprobe.d/blacklist-nvidia.conf

- 更新内核initramfs映像: 很多现代发行版（如 Ubuntu 24.04/26.04）会将显卡驱动打包进 initramfs（引导阶段的微型根文件系统）。如果你不执行这一步，内核在系统正式挂载根目录之前，可能已经从 initramfs 里把驱动加载了。

.. literalinclude:: nvflash/initramfs
   :caption: 更新initramfs

- 修改 GRUB 引导参数（双重保险）: 为了防止某些服务（如 gdm 或 cuda 运行库）尝试按需加载模块,编辑 ``/etc/default/grub`` 修订 ``GRUB_CMDLINE_LINUX_DEFAULT`` 添加 ``rd.driver.blacklist=nvidia modprobe.blacklist=nvidia`` :

.. literalinclude:: nvflash/grub
   :caption: 修订 /etc/default/grub

然后执行 ``sudo update-grub`` 更新grub，然后重启操作系统并验证

.. literalinclude:: nvflash/check
   :caption: 重启操作系统进行检查

重启以后检查确实已经没有任何 ``nvidia`` 模块加载，但是我发现报错依旧:

.. literalinclude:: nvflash/save_error
   :caption: 保存ROM 依然报错

更换主机
----------

我怀疑是我的兼容主机主板的问题(根据gemini提示有可能是PCIe的休眠或电源模式导致A2的GPU核心休眠)，所以我换到 :ref:`hpe_dl380_gen9` 上再次执行。果然，更换到标准服务上，使用这块数据中心计算卡 :ref:`tesla_a2` 就顺利了很多:

.. literalinclude:: nvflash/list
   :caption: 列出NVIDIA显卡

显示:

.. literalinclude:: nvflash/list_output_dl380
   :caption: 在DL380 gen9上看到的A2
   :emphasize-lines: 5

而且执行ROM备份也成功了:

.. literalinclude:: nvflash/save_a2_rom
   :caption: 保存A2的ROM

输出显示

.. literalinclude:: nvflash/save_a2_rom_output
   :caption: 保存A2的ROM时显示输出
   :emphasize-lines: 16,24

这里输出信息有点奇怪:

  - ``UEFI Version: No Version Found or Out-dated (  )`` 显示没有找到版本，A2 的原厂固件里可能没有包含有效的 UEFI GOP 驱动。
  - ``GPU Mode : N/A`` 实际上表明A2不支持GPU模式切换(见下文尝试切换失败)

- 在尝试切换图形模式之前，我先检查一下A2的BAR size，执行 ``lspci -vvv -s 0b:00.0`` 查看A2卡详情:

.. literalinclude:: nvflash/lspci_vvv
   :caption: 执行 ``lspci -vvv -s 0b:00.0`` 查看A2卡详情
   :emphasize-lines: 10

可以看到BAR size是16G

- 尝试切换graphics模式:

.. literalinclude:: nvflash/gpumode
   :caption: 切换graphics模式
   :emphasize-lines: 10,15

这里输入 ``y`` 执行，但是发现 :ref:`tesla_a2` 不支持graphics模式

 gemini建议我使用 GOPUpd 来处理备份出来的 ``origin_a2.rom`` ，注入针对NVIDIA Ampere 架构的 GOP模块，这样就能为 :ref:`tesla_a2` 添加亮机的能力。

 不过，我考虑到A2不会用在 :ref:`dell_t5820` 上，我准备还是采用 :ref:`amd_mi50` 来进行这个GOP注入和BAR size修订。

参考
======

- 本文实践主要在gemini指导下完成，原理部分摘自gemini
