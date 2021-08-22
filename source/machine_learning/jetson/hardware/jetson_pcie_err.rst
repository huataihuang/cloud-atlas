.. _jetson_pcie_err:

============================
Jetson Nano PCIe Buss Error
============================

意外发现Jetson Nano文件系统只读::

   -bash: cannot create temp file for here-document: Read-only file system

.. note::

   这个文件系统只读有可能是我通过dd复制TF卡，把原先旧卡中某些缺陷带入到新卡？我现在重新用新卡完整通过L4T重新安装，再继续观察。

检查系统日志中有PCIe错误:

.. literalinclude:: jetson_pcie_err/dmesg_pcie_bus_error.txt
   :lines: 475-482

上述报错看起来和PCIe Bus相关::

   [五 8月 20 08:40:47 2021] pcieport 0000:00:01.0: AER: Corrected error received: id=0010
   [五 8月 20 08:40:47 2021] pcieport 0000:00:01.0: PCIe Bus Error: severity=Corrected, type=Physical Layer, id=0008(Receiver ID)
   [五 8月 20 08:40:47 2021] pcieport 0000:00:01.0:   device [10de:0fae] error status/mask=00000001/00002000
   [五 8月 20 08:40:47 2021] pcieport 0000:00:01.0:    [ 0] Receiver Error         (First)

- 检查处理器温度::

   paste <(cat /sys/class/thermal/thermal_zone*/type) <(cat /sys/class/thermal/thermal_zone*/temp) | column -s $'\t' -t | sed 's/\(.\)..$/.\1°C/'

输出显示::

   AO-therm         41.5°C
   CPU-therm        34.0°C
   GPU-therm        31.0°C
   PLL-therm        31.5°C
   PMIC-Die         100.0°C
   thermal-fan-est  33.0°C
   iwlwifi          39.0°C

上述 ``PCIe Bus Error: severity=Corrected, type=Physical Layer, id=0008(Receiver ID)`` 报错在 askubuntu `PCIe Bus Error: severity=Corrected, type=Physical Layer, id=00e5(Receiver ID) <https://askubuntu.com/questions/863150/pcie-bus-error-severity-corrected-type-physical-layer-id-00e5receiver-id>`_ 有一个解释：

PCIe活跃状态电源管理(PCIe Active State Power Management)是将链路转换成低电能状态，在Jetson Nano的Ubuntu使用的内核版本较低，转换电能状态时会导致设备触发一些错误。

在内核启动参数中添加 ``pcie_aspm=off`` 可以使这种错误消息不再出现，但是这也会增加电能消耗，因为实际上主机这是关闭了节能功能。

修改启动参数
============

- 检查当前内核运行参数::

   cat /proc/cmdline

当前显示如下:

.. literalinclude:: jetson_pcie_err/cmdline_origin

在Jetson Nano的配置文件 ``/boot/extlinux/extlinux.conf`` 可以看到:

.. literalinclude:: jetson_pcie_err/extlinux.conf_origin

默认情况下，会从 CBoot 获取 bootargs ，所以这里可以替换和修改启动参数，所以我增加上 ``pcie_aspm=off`` :

.. literalinclude:: jetson_pcie_err/extlinux.conf

- 修改后，重启系统，再检查 ``cat /proc/cmdline`` 可以看到内核参数后添加了 ``pcie_aspm=off`` 参数:

.. literalinclude:: jetson_pcie_err/cmdline

实践经验
============

从之前验证来看，使用 ``pcie_aspm=off`` 确实可以消除内核报错，并且印象中好像很少再出现文件系统只读问题。对比之下，我最近一次重装jetson系统，没有添加这个内核参数，则非常容易出现文件系统只读以及上述内核报错。

参考
=======

- `PCIe Bus Error: severity=Corrected, type=Physical Layer, id=00e5(Receiver ID) <https://askubuntu.com/questions/863150/pcie-bus-error-severity-corrected-type-physical-layer-id-00e5receiver-id>`_
- `NVIDIA U-Boot Customization <https://docs.nvidia.com/jetson/l4t/index.html#page/Tegra%20Linux%20Driver%20Package%20Development%20Guide/uboot_guide.html>`_
- `Where can I change default cmdline/cbootargs and other questions regarding jetson nano boot process. <https://forums.developer.nvidia.com/t/where-can-i-change-default-cmdline-cbootargs-and-other-questions-regarding-jetson-nano-boot-process/82087>`_
