.. _gluster_tunning:

===================
GlusterFS性能优化
===================

说明
=====

在 :ref:`deploy_centos7_suse15_gluster11` 后，我简单测试了一下写入性能，选择了客户端上的 ``/usr`` 目录(1.9GB，大约6.24w文件)复制到GlusterFS卷::

   # time cp -R /usr/ /data/backup

   real    2m57.236s
   user    0m0.773s
   sys     0m4.131s

可以看到效率不高

此外，复制时，客户端 ``glusterfs`` 进程的CPU使用率大约 1.4 个cpu core

优化思路
==========

参考
=====

- `performance and sizing guide (Redh Hat Gluster Storage on QCT servers) <https://go.qct.io/wp-content/uploads/2018/08/Reference-Architecture-QCT-and-Red-Hat-Gluster-Storage-Performance-and-Sizing-Guide.pdf>`_
