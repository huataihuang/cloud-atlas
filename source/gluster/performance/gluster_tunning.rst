.. _gluster_tunning:

===================
GlusterFS性能优化
===================

对比
=====

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

再次部署 :ref:`deploy_centos7_suse15_suse12_gluster11` ，同样复制客户端 ``/usr`` 目录(4.3GB，大约12w文件)复制到GlusterFS卷::

   # time cp -R /usr/ /data/backup

   real    4m9.248s
   user    0m1.146s
   sys     0m8.926s

删除文件::

   # time rm -rf /data/backup/usr

   real    1m58.413s
   user    0m0.227s
   sys     0m1.779s

CentOS7.2服务端/SuSE12.5客户端(软RAID)
-----------------------------------------

改进部署 :ref:`deploy_centos7_gluster11_lvm_mdadm_raid10` ，同样复制客户端 ``/usr`` 目录(4.3GB，大约12w文件)复制到GlusterFS卷::

   # time cp -R /usr/ /mqha/foreignexmuamqha/
   
   real    3m35.887s
   user    0m1.137s
   sys     0m7.584s

可以看到性能略有提升，耗时降低了 25%

删除文件::

   # time rm -rf /mqha/foreignexmuamqha/usr
   
   real    1m48.089s
   user    0m0.450s
   sys     0m2.209s

总体来说，采用 :ref:`linux_software_raid` 构建大容量磁盘(同时降低了brick数量)对于性能似乎有所提高。我感觉可能还是客户端的分发性能没有优化，无法充分利用多bricks的优势，反而被客户端瓶颈拖累了...

优化思路
==========

参考
=====

- `performance and sizing guide (Redh Hat Gluster Storage on QCT servers) <https://go.qct.io/wp-content/uploads/2018/08/Reference-Architecture-QCT-and-Red-Hat-Gluster-Storage-Performance-and-Sizing-Guide.pdf>`_
