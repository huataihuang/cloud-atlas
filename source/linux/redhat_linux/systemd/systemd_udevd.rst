.. _systemd_udevd:

======================
systemd-udevd
======================

在使用 :ref:`systemd` 的主机上， :ref:`udev` 操作由 ``systemd-udevd`` 守护进程管理，可以通过 ``systemd`` 方式使用以下命令检查 ``udev`` 守护进程状态::

   systemctl status systemd-udevd

输出信息类似::

   ● systemd-udevd.service - udev Kernel Device Manager
        Loaded: loaded (/lib/systemd/system/systemd-udevd.service; static; vendor preset: enabled)
        Active: active (running) since Thu 2022-05-26 12:42:45 CST; 2 weeks 6 days ago
   TriggeredBy: ● systemd-udevd-control.socket
                ● systemd-udevd-kernel.socket
          Docs: man:systemd-udevd.service(8)
                man:udev(7)
      Main PID: 1614651 (systemd-udevd)
        Status: "Processing with 112 children at max"
         Tasks: 2
        Memory: 55.9M
        CGroup: /system.slice/systemd-udevd.service
                ├─1614651 /lib/systemd/systemd-udevd
                └─1834149 /lib/systemd/systemd-udevd
   May 26 12:42:45 zcloud systemd[1]: Starting udev Kernel Device Manager...
   May 26 12:42:45 zcloud systemd[1]: Started udev Kernel Device Manager.

``systemd-udevd`` 监听内核 ``uevents`` ，对于每个事件， ``systemd-udevd`` 会执行匹配上的udev规则中指定的指令。详细配置方法参考 :ref:`udev` 。

``systemd-udevd`` 守护进程的特性可以通过 ``udev.conf`` 配置，可以指定命令参数，环境变量以及内核命令行，或者使用 ``udevadm`` 动态修改。

参考
=====

- `在 Linux 使用 systemd-udevd 管理你的接入硬件 <https://linux.cn/article-13691-1.html>`_ : `Managing your attached hardware on Linux with systemd-udevd <https://opensource.com/article/20/2/linux-systemd-udevd>`_ 中文翻译，便于学习
- `systemd-udevd.service(8) <https://man.archlinux.org/man/systemd-udevd.service.8>`_
