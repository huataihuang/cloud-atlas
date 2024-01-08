.. _udev_startup:

===============
udev快速起步
===============

- 完成 ``/etc/udev/rules.d/`` 目录下规则配置修改后，可以重启操作系统或或者通过以下命令使得 ``udev`` 重新加载规则:

.. literalinclude:: udev_startup/udev_reload-rules
   :caption: ``udevadm`` 控制重新加载 ``udev`` 规则

参考
=======

- `An introduction to Udev: The Linux subsystem for managing device events <https://opensource.com/article/18/11/udev>`_
- `Beginners Guide to Udev in Linux <https://www.thegeekdiary.com/beginners-guide-to-udev-in-linux/>`_
- `archlinux wiki: udev <https://wiki.archlinux.org/title/udev>`_
- `SUSE Administration Guide: Dynamic Kernel Device Management with udev <https://documentation.suse.com/sles/15-SP1/html/SLES-all/cha-udev.html>`_
