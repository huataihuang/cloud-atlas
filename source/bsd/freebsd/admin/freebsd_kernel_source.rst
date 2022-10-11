.. _freebsd_kernel_source:

===================
FreeBSD内核源代码
===================

可以直接从发行版网站下载源代码包，类似 :ref:`freebsd_wine` 中安装 ``lib32`` 的方法::

   fetch -arRo /tmp/ https://download.freebsd.org/ftp/releases/amd64/13.1-RELEASE/src.txz
   tar -xpf /tmp/src.txz -C /

然后更新::

   freebsd-update fetch install


