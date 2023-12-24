.. _control_hpe_lio_fan_speed:

===================================
通过HPE iLO控制风扇转速
===================================

我最初尝试采用标准的 :ref:`ipmi` 方式来控制 :ref:`hpe_dl360_gen9` 风扇转速，目的是实现 :ref:`server_fanless` 。不过，HPE服务器的 ``ipmi`` 资料非常匮乏，我找不到 :ref:`ipmi_sensor_fan_speed` 的HPE服务器配置方法( ``ipmitool raw`` 参数各个厂商不统一，没有资料无法配置 )。

从网上资料来看，HPE服务器的风扇控制是通过 :ref:`hp_ilo` 实现的，只是实现方法非常曲折

.. note::

   我暂时还没有时间精力来尝试实践，这里只做资料汇总。过几天再搞...

脚本控制
=========

`HOW TO CONTROL HPE ILO FAN SPEED (ILO 4, GEN 8~9) <https://forums.unraid.net/topic/141249-how-to-control-hpe-ilo-fan-speed-ilo-4-gen-8~9/>`_ 提供了一个封装脚本，通过 iLO 的SSH密钥方式来登陆 iLO 进行设置(其实就是 ssh 执行 iLO 命令)。脚本非常简单，但是可以看出设置方法。结合iLO手册，我觉得应该很容易完成。

.. note::

   简单看了一下脚本，iLO设置看起来非常简单的命令。也就是 :ref:`ssh` 远程执行，使用密钥认证可以非常方便完成。

.. literalinclude:: control_hpe_lio_fan_speed/ilo_fan_speed.sh
   :language: bash
   :caption: 通过iLO远程命令调整服务器风扇转速

命令行
========

`Silence of the fans pt 2: HP iLO 4 2.73 now with the fan hack! <https://www.reddit.com/r/homelab/comments/hix44v/silence_of_the_fans_pt_2_hp_ilo_4_273_now_with/>`_ 提供了简单的命令方法，也是ssh到iLO通过简单命令设置

`HP-ILO-Fan-Control (GitHub项目) <https://github.com/That-Guy-Jack/HP-ILO-Fan-Control>`_ 结合 `ilo4_unlock (Silence of the Fans) (GitHub项目) <https://github.com/kendallgoto/ilo4_unlock>`_ 来控制风扇

WEB设置
=========

`ilo-fans-controller (GitHub项目) <https://github.com/alex3025/ilo-fans-controller>`_ 提供了通过WEB服务器(php)方式来设置iLO(包装)，使用更为简便。

参考
=====

- `Silence of the fans pt 2: HP iLO 4 2.73 now with the fan hack! <https://www.reddit.com/r/homelab/comments/hix44v/silence_of_the_fans_pt_2_hp_ilo_4_273_now_with/>`_  介绍ilo控制fan的资料，可以作为起步
- `HOW TO CONTROL HPE ILO FAN SPEED (ILO 4, GEN 8~9) <https://forums.unraid.net/topic/141249-how-to-control-hpe-ilo-fan-speed-ilo-4-gen-8~9/>`_
- `Silence of the fans pt 2: HP iLO 4 2.73 now with the fan hack! <https://www.reddit.com/r/homelab/comments/hix44v/silence_of_the_fans_pt_2_hp_ilo_4_273_now_with/>`_
- `ilo-fans-controller (GitHub项目) <https://github.com/alex3025/ilo-fans-controller>`_
