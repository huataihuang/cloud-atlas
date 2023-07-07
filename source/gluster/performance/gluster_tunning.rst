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

再次部署了一个集群，区别是服务器端内核从 ``3.10`` 升级到 ``4.19`` ，此时启用了 ``xfs`` 的 v5版本(支持CRC)，同样复制 ``/usr`` 目录，略微快一点点::

   # time cp -r /usr /mqha/supergwmuamqha/

   real    2m48.185s
   user    0m0.846s
   sys     0m4.515s

优化思路
==========

参考
=====

- `performance and sizing guide (Redh Hat Gluster Storage on QCT servers) <https://go.qct.io/wp-content/uploads/2018/08/Reference-Architecture-QCT-and-Red-Hat-Gluster-Storage-Performance-and-Sizing-Guide.pdf>`_
