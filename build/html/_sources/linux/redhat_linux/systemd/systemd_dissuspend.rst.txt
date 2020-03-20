.. _systemd_dissuspend:

=========================
systemd禁止笔记本suspend
=========================

我在 :ref:`ubuntu_server` 和 :ref:`ubuntu_on_mbp` 实践中，都是采用笔记本电脑作为服务器运行。但是笔记本默认情况下，合上屏幕就会休眠 ，而作为服务器希望使用运行，在屏幕关闭的时候不出现suspend，否则会导致主机网路断开无法访问。

禁用屏幕关闭时suspend
========================

* 编辑 ``/etc/systemd/logind.conf`` 配置::

   #HandleLidSwitch=suspend
   HandleLidSwitch=ignore
   #HandleLidSwitchExternalPower=suspend
   HandleLidSwitchExternalPower=ignore
   #HandleLidSwitchDocked=ignore #这行设置是默认的

* 然后重新加载 ``logind.conf`` 配置以便生效::

   systemctl restart systemd-logind

* 在 ``logind.conf`` 的man中有如下相关信息：

``HandlePowerKey=, HandleSuspendKey=, HandleHibernateKey=, HandleLidSwitch=``  控制了logind如何处理系统电源管理和睡眠键以及屏幕开阖时候触发的动作，例如系统电源关闭或者suspend。设置值可以是 ``ignore`` ， ``poweroff`` ， ``reboot`` ， ``halt`` ， ``kexec`` ， ``suspend`` ， ``hybrid-sleep`` 和  ``lock`` 。如果设置了 ``ignore`` ，就不会处理任何这些键。如果设置 ``lock`` 则会锁定屏幕。只有输入设备具有 ``power-switch`` udev标签才会监视键盘和屏幕开阖事件。默认设置::

   HandlePowerKey=poweroff
   HandleSuspendKey=suspend
   HandleLidSwitch=suspend
   HandleHibernateKey=hibernate

对于外接屏幕的笔记本，合上屏幕以后，还可以设置屏幕关闭，这样可以进一步减少能源消耗，也降低笔记本温度。方法是使用 ``vbetool`` 工具::

   sudo vbetool dpms off

建议采用如下方法，这样即使关闭屏幕，只要按下 ``Enter`` 键就可以恢复::

   sudo sh -c 'vbetool dpms off; read ans; vbetool dpms on'

# 参考

* `How to disable auto suspend when I close laptop lid? <https://unix.stackexchange.com/questions/52643/how-to-disable-auto-suspend-when-i-close-laptop-lid>`_
