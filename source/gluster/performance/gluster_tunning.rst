.. _gluster_tunning:

===================
GlusterFS性能优化
===================

对比
=====

软件版本都是 GlusterFS 11 ，区别是操作系统和内核

CentOS7.2服务端/SuSE15.5客户端
--------------------------------

在 :ref:`deploy_centos7_suse15_suse12_gluster11` 后，我简单测试了一下写入性能，选择了客户端上的 ``/usr`` 目录(1.9GB，大约6.24w文件)复制到GlusterFS卷::

   # time cp -R /usr/ /data/backup

   real    2m57.236s
   user    0m0.773s
   sys     0m4.131s

可以看到效率不高

此外，复制时，客户端 ``glusterfs`` 进程的CPU使用率大约 1.4 个cpu core

再次部署了一个集群，区别是服务器端内核从 ``3.10`` 升级到 ``4.19`` ，此时启用了 ``xfs`` 的 v5版本(支持CRC)，同样复制 ``/usr`` 目录，略微快一点点::

   # time cp -r /usr /data/backup

   real    2m48.185s
   user    0m0.846s
   sys     0m4.515s

CentOS7.2服务端/SuSE12.5客户端
--------------------------------

再次部署 :ref:`deploy_centos7_suse15_suse12_gluster11` ，同样复制客户端 ``/usr`` 目录(1.9GB，大约6.24w文件)复制到GlusterFS卷::

   # time cp -R /usr/ /data/backup

   real    4m9.248s
   user    0m1.146s
   sys     0m8.926s

删除文件::

   # time rm -rf /data/backup/usr

   real    1m58.413s
   user    0m0.227s
   sys     0m1.779s

初步结论
---------

操作系统对GlusterFS性能的影响较大，明显看到客户端从 SuSE 12 (kernel 4.12) 升级到 SuSE 15 (kernel 5.14)，大约能够获得 30% 的性能提升。推测操作系统的内核默认参数也有一些优化，所以推荐采用新版本操作系统。

优化思路
==========

参考
=====

- `performance and sizing guide (Redh Hat Gluster Storage on QCT servers) <https://go.qct.io/wp-content/uploads/2018/08/Reference-Architecture-QCT-and-Red-Hat-Gluster-Storage-Performance-and-Sizing-Guide.pdf>`_
