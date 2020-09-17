.. _jetson_pcie_err:

============================
Jetson Nano PCIe Buss Error
============================

意外发现Jetson Nano文件系统只读::

   -bash: cannot create temp file for here-document: Read-only file system

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
