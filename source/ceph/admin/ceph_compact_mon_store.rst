.. _ceph_compact_mon_store:

======================
压缩Ceph监控服务存储
======================

长期运行的Ceph存储，会发现 ``/var/lib/ceph/mon/ceph-`hostname`/store.db/`` 目录下存储了大量的 ``.sst`` 文件以及 ``.log`` 文件，占用大量磁盘空间，可能会触发 :ref:`warn_mon_disk_low` 。此时我们可以通过压缩mon存储容量来缩减磁盘占用::

   ceph tell mon.<HOST_NAME> compact

例如::

   ceph tell mon.z-b-data-1 compact

此外，我们可以配置 Ceph mon 进程在启动时进行压缩，即配置 ``[mon]`` 段落如下::

   [mon]
   mon_compact_on_start = true

然后重启 ``ceph-mon`` 服务::

   systemctl restart ceph-mon@z-b-data-1


参考
======

- `Ceph Compacting the monitor store <https://access.redhat.com/documentation/en-us/red_hat_ceph_storage/4/html-single/troubleshooting_guide/index#compacting-the-monitor-store_diag>`_
