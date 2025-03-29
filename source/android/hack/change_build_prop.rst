.. _change_build_prop:

===================
修改build.prop文件
===================

网上有很多关于修改 ``build.prop`` 来调优Android的建议，例如 `15 Best Android Build.Prop Tweaks You Must Try (2019 Updated) <https://thedroidguru.com/15-best-android-build-prop-tweaks-must-try-2017/>`_ 。

不过，存在最大的困难是，Android的安全策略限制 ``/system`` 分区是只读不可修改的。

参考 `How to edit build prop with magisk? <https://forum.xda-developers.com/apps/magisk/how-to-edit-build-prop-magisk-t3588599>`_ 可以使用命令::

   /data/magisk/resetprop build.prop.item value

这个操作命令 ``resetprop`` 需要安装模块

参考
======

- `15 Best Android Build.Prop Tweaks You Must Try (2019 Updated) <https://thedroidguru.com/15-best-android-build-prop-tweaks-must-try-2017/>`_
