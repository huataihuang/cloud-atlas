.. _lxqt_slock:

=============================
LXQt环境使用轻量级锁屏slock
=============================

锁屏程序选择
=============

- 如果使用 ``LightDM`` 作为显示管理器(display manager)，则可以直接使用 ``light-locker`` ，这是最简单方法
- LXQt 使用 ``xdg-utils`` 提供的 ``xdg-screensaver`` ，但是这个 ``xdg-screensaver`` 实际上只能依赖使用 ``XScreenSaver`` 和 ``xautolock``

  - ``XScreenSaver`` 比较沉重，需要安装占用80MB空间，我感觉为了一个简单的锁屏功能不值得

- 我在 :ref:`xfce_startup` 中选择了轻量级的 ``slock`` ，通过快捷键触发可以快速锁屏。同样我也想在LXQt中使用这个程序，但是需要做一些调整配置

xdg-utils-slock
=====================

:ref:`archlinux_aur` 提供了补丁过的 ``xdg-utils-slock`` 可以让LXQt感知到这个锁屏程序，也就是能够无缝集成到 LXQt

.. note::

   但是为了这个简单的锁屏功能，还是需要安装大约34MB软件

Lock on suspend
======================

可以创建一个 ``slock@.service`` 服务在系统idle时候自动锁屏:

- ``/etc/systemd/system/slock@.service`` :

.. literalinclude:: lxqt_slock/slock@.service
   :language: bash
   :caption: slock@.service 按用户配置suspend时候锁屏

然后按用户(huatai)激活::

   systemctl enable slock@huatai.service

.. note::

   目前我还没有解决 :ref:`asahi_linux` 的suspend，所以暂时没有实践，待后续尝试

Openbox组合键启用slock
========================

其实我只需要一个简单的锁屏功能，通过 :ref:`openbox_keybind` 触发命令，所以修订 ``~/.config/openbox/rc.xml`` 添加一段 ``keybind`` :

.. literalinclude:: lxqt_slock/openbox_rc_slock.xml
   :language: xml
   :caption: 结合Openbox的keybind激活slock，配置 ~/.config/openbox/rx.xml 添加这段配置

然后执行一次 ``openbox --reconfigure`` 后就可以使用 ``ctrl+win+l`` 触发锁屏

参考
=====

- `arch linux: LXQt <https://wiki.archlinux.org/title/LXQt>`_
