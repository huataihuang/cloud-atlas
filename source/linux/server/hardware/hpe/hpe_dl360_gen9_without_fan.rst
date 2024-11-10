.. _hpe_dl360_gen9_without_fan:

===============================
HPE DL360 gen9无风扇模式工作
===============================

.. warning::

   本文只是我的一个构想，但是我最终决定不实现这个无风扇方案:

   - 机架式服务器内部空间非常紧凑，散热不佳，如果没有服务器内部通风流动会导致积热死机
   - 为机架式服务器设置的GPU计算卡都是被动散热，本身没有风扇，完全依赖机架式服务器内部风扇鼓动的流动风散热，所以关闭风扇会导致GPU卡无法工作

   所以我考虑改进方案为: :ref:`control_hpe_lio_fan_speed`

在构建 :ref:`think_server_fanless` ，需要在我的 :ref:`hpe_dl360_gen9` 配置BIOS，关闭风扇告警，以便能够无风扇启动运行

参考
=====

- `How to Enable or Disable Fan Installation Requirements Messaging? <https://support.hpe.com/hpesc/public/docDisplay?docId=sf000046351en_us&docLocale=en_US>`_
