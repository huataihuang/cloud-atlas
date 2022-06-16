.. _fix_android_boot_loop:

==========================
修复Android不断重启
==========================

我的 :ref:`pixel_3` 在一次忘记充电消耗完电能，我将手机充电后意外发现，手机开机后不断重启无法正常进入之前在 :ref:`lineageos_19.1_pixel_3` 系统。

这个问题通常需要首先尝试冷关机和冷启动，即完全清理缓存进行启动:

- 同时按下 ``电源键`` 和 ``音量降低键`` ，保持按下状态 20 秒，然后放开手指，此时手机会进行一次冷启动

  - 在我的修复案例中，按住 ``电源键`` 和 ``音量降低键`` 20秒期间，手机依然不断重启
  - 但是当我放开手指最后一次重启是冷启动
  - 等待一些时间，这次冷启动没有再出现循环启动，正常出现了 ``LineageOS`` 的标志并启动进入系统

.. note::

   同时按下 ``电源键`` 和 ``音量降低键`` 的冷启动通常会清理内存，一般能够修复一些设备启动问题

此外，同时按住 ``电源键`` 和 ``音量降低键`` 启动时不释放会进入 ``recovery`` 模式，此时可以通过音量键选择菜单，其中包括了 ``Wipe data/factory reset`` 功能。这个reset功能可以初始化手机设备，清理掉可能存在问题的数据，这是尝试前述冷重启不成功的补救方法啊，但是会导致数据丢失，慎用!

参考
======

- `Fix Android Stuck in a Reboot Loop <https://techcult.com/fix-android-stuck-in-a-reboot-loop/>`_
- `Steps to Try When Android is Stuck in a Reboot Loop <https://www.technipages.com/android-stuck-reboot-loop>`_
