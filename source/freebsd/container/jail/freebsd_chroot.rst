.. _freebsd_chroot:

==================
FreeBSD chroot
==================

在 :ref:`linux_jail` 中，要运行在Linux环境，是需要执行一步 ``chroot`` 的:

.. literalinclude:: linux_jail_archive/jexec_chroot
   :caption: ``jexec`` 结合 ``chroot`` 将访问 :ref:`debian` 系统Linux二进制兼容

在日常工作中，也可能需要通过这种 ``chroot`` 方式来修复磁盘中的FreeBSD:

.. literalinclude:: freebsd_chroot/chroot
   :caption: chroot进入FreeBSD环境

参考
=====

- `HowTo Chroot to BSD <https://unix.stackexchange.com/questions/109810/howto-chroot-to-bsd>`_
