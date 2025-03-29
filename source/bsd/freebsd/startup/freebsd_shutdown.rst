.. _freebsd_shutdown:

===============
FreeBSD关机
===============

当从Linux转换到FreeBSD平台，你会发现原先在Linux平台上关机命令 ``shutdown -h now`` 只是把FreeBSD进入halt模式，电源并没有切断。

原来在FreeBSD上，应该使用 ``-p`` 参数::

   shutdown -p now

参考
======

- `FreeBSD 101 Hacks: Shutdown <https://nanxiao.gitbooks.io/freebsd-101-hacks/content/posts/shutdown.html>`_
