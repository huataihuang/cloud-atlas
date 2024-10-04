.. _pi_4_pwm_fan:

====================
树莓派4 PWM风扇
====================

无风扇铜散热器
=================

由于我最初买到的PWM风扇质量不佳(高速时啸叫)，所以我尝试采用无风扇纯铜散热风扇:

执行 ``stress`` 测试:

.. literalinclude:: pi_5_active_cooler/stress
   :language: bash
   :caption: 安装 ``stress`` 工具模拟压力

- 室温大约25度
- 待机时温度53度，主频 600 Hz
- 高负载温度达到74度，主屏1.8 GHz

对比 :ref:`pi_5_active_cooler` 测试，看起来最好需要有一个主动风扇



参考
======

- `Connecting A PWM Fan To A Raspberry Pi <https://www.the-diy-life.com/connecting-a-pwm-fan-to-a-raspberry-pi/>`_
- `Using Raspberry Pi to Control a PWM Fan and Monitor its Speed  <https://blog.driftking.tw/en/2019/11/Using-Raspberry-Pi-to-Control-a-PWM-Fan-and-Monitor-its-Speed/>`_ 台湾网友blog，也同时提供了中文版 `利用 Raspberry Pi 控制 PWM 風扇及轉速偵測 <https://blog.driftking.tw/2019/11/Using-Raspberry-Pi-to-Control-a-PWM-Fan-and-Monitor-its-Speed/>`_
- `树莓派4b：PWM调速风扇+DIY亚克力板外壳的定制降温方案 <https://blog.csdn.net/w1999623/article/details/124375665>`_
- `Raspberry Pi Forum: PWM cooling fan control <https://forums.raspberrypi.com/viewtopic.php?t=354125>`_
