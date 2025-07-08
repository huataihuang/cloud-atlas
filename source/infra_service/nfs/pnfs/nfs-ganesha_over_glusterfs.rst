.. _nfs-ganesha_over_glusterfs:

============================
NFS-Ganesha over GlusterFS
============================

``NFS-Ganesha`` 是一个支持NFSv3,v4,v4.1以及pNFS的NFS协议用户空间文件服务器。 ``NFS-Ganesha`` 提供了一个FUSE兼容的文件系统抽象层(File System Abstraction Layer,FSAL)允许文件系统开发者通过插件将自己的存储机制加入，并且可以从任何NFS客户端访问存储文件系统。由于 ``NFS-Ganesha`` 是通过自己的FSAL访问FUSE文件系统而无需在内核进行数据复制，所以相应提高了响应性能。

.. note::

   待实践

参考
==============

- `Configuring NFS-Ganesha over GlusterFS <https://docs.gluster.org/en/v3/Administrator%20Guide/NFS-Ganesha%20GlusterFS%20Integration/>`_
