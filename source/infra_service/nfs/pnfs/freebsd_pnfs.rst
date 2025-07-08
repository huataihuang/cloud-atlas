.. _freebsd_pnfs:

======================
FreeBSD pNFS
======================

FreeBSD实现了 NFS v4.1 和 v4.2 pNFS，所以是很好的构建高性能NAS的平台。我规划在 :ref:`vnet_thin_jail` 环境中模拟构建一个pNFS系统:

.. note::

   Linux内核支持了pNFS client，但是似乎没有原生的pNFS server? 需要第三方 :ref:`nfs-ganesha` 实现pNFS

参考
=======

- `Deploying pNFS file sharing with FreeBSD <https://klarasystems.com/articles/deploying-pnfs-file-sharing-with-freebsd/>`_
- `FreeBSD Manual Pages: pNFS <https://man.freebsd.org/cgi/man.cgi?query=pnfs>`_
- Linux系统的pNFS可以参考 `linux-nfs.org PNFS Development <http://wiki.linux-nfs.org/wiki/index.php?title=PNFS_Development&oldid=5561>`_
