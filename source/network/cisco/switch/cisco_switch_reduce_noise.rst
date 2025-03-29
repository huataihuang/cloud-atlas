.. _cisco_switch_reduce_noise:

================
Cisco交换机降噪
================

我购买的二手 :ref:`ws-c4948-s` 有一个困扰，就是风扇噪音较大，持续工作时(非开机自检过程)的噪音甚至比我的二手 :ref:`hpe_dl360_gen9` 更高些。

降低交换机噪音的手段，找了一下主要有:

- 更换旧滚轴风扇(因为陈旧的风扇带来更多噪音，特别是接近报废时)
- 将风扇完全替换成无风扇组件: 有些人会改造设备，采用散热面积更大的散热器，实现无风扇散热
- 通过软件控制风扇转速，降低风扇噪音
- 可能升级firmware能够改善风扇转速

.. note::

   对于个人使用的服务器和交换机设备，有没有可能完全改造成无风扇模式？

目前我初步考虑软件方式来实现:

- 检查温度::

   sh env. temp.

- 检查电源::

   show power

参考
=====

- `华为交换机Case Study: Fan Noise Is Loud <https://support.huawei.com/enterprise/en/doc/EDOC1000060766/daa14da9/case-study-fan-noise-is-loud>`_ 

华为交换机提供了查看和设置风扇转速的命令:

.. literalinclude:: cisco_switch_reduce_noise/huawei_switch_fan
   :caption: 华为交换机检查和设置风扇转速，升级风扇软件
