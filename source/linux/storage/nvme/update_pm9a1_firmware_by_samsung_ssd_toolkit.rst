.. _update_pm9a1_firmware_by_samsung_ssd_toolkit:

============================================================
使用Samsung SSD Toolkit for Data center更新PM9A1 firmware
============================================================

`三星半导体官方工具下载 <https://semiconductor.samsung.com/consumer-storage/support/tools/>`_ 提供 Samsung SSD Toolkit for Data center ，可以看到版本有两个: 2.1 和 3.0，分别提供Windows和Linux版本

非常奇特的是，只有使用 2.1 版本执行命令 ``Samsung_SSD_DC_Toolkit_for_Windows_V2.1.exe -L`` 能够列出主机中安装的 :ref:`samsung_pm9a1` ，使用更新的3.0版本反而无法显示，应该是新版本屏蔽掉了无OEM厂商标记的零售版 ``00B00`` 。

.. note::

   Samsung SSD Toolkit for Data center 这个工具手册和命令帮助非常含糊，执行提示让人难以定位原因，感觉这个工具是 :ref:`nvme-cli` 的一个包装程序，但是设计和开发得非常糟糕，完全是给厂商内部使用的半成品。

   我最终放弃使用 Samsung SSD Toolkit for Data center !!!
