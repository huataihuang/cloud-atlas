.. _sway_dwt:

==========================================================
Sway环境输入时禁止触摸板(DWT, Disable-while-typing)
==========================================================

输入时禁用触摸板
=====================

我在使用sway时有一个困扰，就是终端输入文字时，手掌经常触碰到Mabook宽大的TouchPad导致鼠标漂移和窗口失焦。解决的方法是在输入时暂时禁用触控板。

在Sway( :ref:`wayland` )环境下，所有的输入设备都是由底层的 ``libinput`` 驱动直接管理的，在 ``libinput`` 中内置了 **输入时禁止出口板** (DWT, Disable-while-typing) 功能。

.. literalinclude:: sway_dwt/config
   :caption: 控制touchpad

上述配置可以完全仿照出macOS触控盘使用习惯，非常推荐。

结合 :ref:`bt-keyboard-switcher`
=====================================

我现在使用 :ref:`bt-keyboard-switcher` 来实现 :ref:`mba11_late_2010` 能够通过蓝牙来模拟键盘为 :ref:`ipad_mini5` 和 :ref:`iphone12_mini` 提供输入，这就产生了一个问题，当键盘切换到作为 :ref:`ipad_mini5` 和 :ref:`iphone12_mini` 的蓝牙键盘模拟时，本地的 :ref:`sway` 系统就接收不到键盘输入，此时会导致光标因为TouchPad误触而漂移。

解决的方法主要有2个:

快捷键禁用TouchPad
--------------------------

最简单是在sway中绑定快捷键，在准备去iPad打字前"一键禁用"触控板，回来以后再一键开启:

- 修改 ``~/.config/sway/config`` 加入:

.. literalinclude:: sway_dwt/config_disable_touchpad
   :caption: 在sway配置中加入切换激活触控板配置

这样通过 ``$mod+Shift+t`` 就能切换触摸板激活

自动联动
----------------

.. note::

   这段我还没有测试验证，待后续尝试，先记录gemini的建议

