.. _jetson_pcie_err:

============================
Jetson Nano PCIe Buss Error
============================

意外发现Jetson Nano文件系统只读::

   -bash: cannot create temp file for here-document: Read-only file system

.. note::

   这个文件系统只读有可能是我通过dd复制TF卡，把原先旧卡中某些缺陷带入到新卡？我现在重新用新卡完整通过L4T重新安装，再继续观察。

检查系统日志中有PCIe错误:

.. literalinclude:: dmesg_pcie_bus_error.txt
   :lines: 475-482

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



参考
=======

- `PCIe Bus Error: severity=Corrected, type=Physical Layer, id=00e5(Receiver ID) <https://askubuntu.com/questions/863150/pcie-bus-error-severity-corrected-type-physical-layer-id-00e5receiver-id>`_
