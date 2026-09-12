.. _swaylock_swayidle:

=============================
swaylock+swayidle锁屏和休眠
=============================

在 Alpine Linux 极简环境下，配合 swaylock（锁屏工具）与 swayidle（空闲事件监听守护进程），可以非常高效地实现超时自动锁屏、关闭显示器（DPMS）以及休眠。

- 安装

.. literalinclude:: swaylock_swayidle/install
   :caption: 安装swaylock 和 swayidle

- 配置sway自动触发 ``~/.config/sway/config`` :

.. literalinclude:: swaylock_swayidle/config
   :caption: 配置触发

.. note::

   - 300 秒 (5 分钟)：无操作自动调用 swaylock 锁屏（全屏黑色 #1a1b26 背景）。
   - 600 秒 (10 分钟)：通过 Sway 的 DPMS 机制关闭 MacBook 屏幕背光（完全熄屏省电）。
   - 恢复操作 (resume)：移动鼠标或按任意键时，自动重新点亮屏幕。
   - 900 秒 (15 分钟)：自动触发 Suspend 到内存。
   - before-sleep：在手动合盖休眠或系统自动休眠前，强制先触发 swaylock，确保唤醒后不会露屏。

.. note::

   ``swayidle`` 会作为守护进程运行在 Sway 会话中，监听用户操作（键盘/鼠标输入）。

- 快捷键锁屏:

.. literalinclude:: swaylock_swayidle/lock
   :caption: 快捷键锁屏(借鉴macOS)

.. note::

   - ``Control+Mod4+q`` ：即组合键 ``Ctrl + Super/Command + Q``
   - ``-f`` （daemonize）：告诉 swaylock 在后台运行并立刻锁屏，避免卡顿。
   - ``-c 1a1b26`` ：设置锁屏背景色为深色(可以替换为自定义的颜色十六进制码，或使用 ``-i /path/to/image`` 指定壁纸图片)

参考
=====

- gemini
