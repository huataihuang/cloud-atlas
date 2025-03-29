.. _ipmi_sensor_fan_speed:

================================
IPMI sensor和风扇转速
================================

我所使用的二手 :ref:`hpe_dl360_gen9` 服务器，作为机架型服务器，风扇的噪音通常比个人电脑要大很多。所以作为个人使用，我一直想改造成 :ref:`server_fanless` 。

虽然通过硬件手段，强制拆除风扇( :ref:`hpe_dl360_gen9_without_fan` )是一种方法。但是，硬件调整灵活性较差(万一又需要风扇究极呢?)，所以我尝试本文的 ``IPMI`` 控制风扇速度来实现静音服务器(甚至关闭风扇运转)。

IPMI sensor
===============

``ipmitool`` 提供了一个命令 ``sensor`` 可以用来直接检查服务器传感器，包括温度和风扇(转速等)都是通过这个命令获取:

.. literalinclude:: ipmi_sensor_fan_speed/ipmi_sensor
   :caption: 不带任何参数 ``ipmitool sensor`` 可以输出服务器所有传感器状态

.. literalinclude:: ipmi_sensor_fan_speed/ipmi_sensor_output
   :caption: ``ipmitool sensor`` 输出我的 :ref:`hpe_dl360_gen9` 服务器传感器信息
   :emphasize-lines: 4,5,40-42

从传感器输出中能够看到很多信息，例如输出内容高亮部分可以看到服务器CPU温度，以及 ``Fan 1`` (1号风扇)的转速和工作状态

- 一些输出信息解释(输出中的英文术语):

.. csv-table:: ``ipmitool sensor`` 输出信息中英文术语解释(非精确)
   :file: ipmi_sensor_fan_speed/ipmi_sensor_output.csv
   :widths: 30, 70
   :header-rows: 1

这里的温度传感、风扇状态等 可以通过 :ref:`ipmi_exporter` 实现 :ref:`grafana` 监控采集，可以帮助观察服务器状态

风扇转速控制
===============

风扇转速控制似乎没有很清晰易懂的配置命令，从网上资料来看，是通过 ``ipmitool raw`` 底层命令来实现控制的。貌似各大主流服务器厂商的设置方法相似，但是困难在于各厂商设置的配置位参数不同(很难找到参考资料)

- 首先切换风扇控制模式，从自动控制转为人工配置(manually configurable)，这里的参数值是 ``0x1`` 表示人工配置，要恢复自动模式则是设置为 ``0x0`` :

对于 DELL 服务器:

.. literalinclude:: ipmi_sensor_fan_speed/ipmi_fan_dell
   :caption: DELL服务器的风扇设置

对于 supermicro 服务器:

.. literalinclude:: ipmi_sensor_fan_speed/ipmi_fan_supermicro
   :caption: Supermicro服务器的风扇设置

.. note::

   很不幸，我还没有找到HP的控制风扇的ipmitool命令，貌似网上资料是通过iLo来控制的。实在不行，我就用 :ref:`hp_ilo` 来实现了

参考
======

- `How to adjust fan speed with IPMI command? <https://www.asrockrack.com/support/faq.asp?id=63>`_
- `Controlling Server Fan Speed With ipmitool <https://www.defaultroot.com/index.php/2021/02/25/controlling-server-fan-speed-with-ipmitool/>`_
- `Dell Fan Control Commands <https://gist.github.com/slykar/f90ad596b18d5ab1eb1c66b2ccf51c54>`_
- `Fan Speeds on SuperMicro System via IPMI <https://serverfault.com/questions/662526/fan-speeds-on-supermicro-system-via-ipmi>`_
- `Dell PowerEdge fan control with ipmitool - individual fan speeds <https://www.reddit.com/r/homelab/comments/t9pa13/dell_poweredge_fan_control_with_ipmitool/>`_
- `HP DL385p g8 - Fan Control HELP <https://forums.servethehome.com/index.php?threads/hp-dl385p-g8-fan-control-help.39803/>`_
