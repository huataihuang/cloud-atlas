.. _osd_slow_ops_warning_after_ceph_down:

=======================================
Ceph硬关机重启后OSD出现"slow ops"报错
=======================================

我的 :ref:`priv_cloud_infra` 中部署的 :ref:`zdata_ceph` 采用了3台 :ref:`ovmf` 虚拟机，但是我在一次物理服务器重启前，快速执行了 ``virsh shutdown XXX`` 连续关闭了3台虚拟机。这次 ``virsh shutdown`` 命令执行间隔极短，也就是说3台Ceph虚拟机几乎同时关闭。由于没有在虚拟机内部的操作系统执行shutdown，这种虚拟机 shutdown 可能不是干净的关机方法，我发现重启服务器之后，3个虚拟机虽然正常启动，但是使用ceph存储的其他虚拟机启动会 ``paused`` 住::

    Id   Name         State
   ----------------------------
    1    z-b-data-2   running
    2    z-b-data-3   running
    3    z-b-data-1   running
    4    z-k8s-m-1    paused

在Ceph虚拟机集群中检查 ``ceph -s`` 可以看到告警::

     cluster:
       id:     0e6c8b6f-0d32-4cdb-a45d-85f8c7997c17
       health: HEALTH_WARN
               Reduced data availability: 33 pgs inactive, 33 pgs peering
               5 slow ops, oldest one blocked for 1925 sec, daemons [osd.1,osd.2] have slow ops.
   
     services:
       mon: 3 daemons, quorum z-b-data-1,z-b-data-2,z-b-data-3 (age 11m)
       mgr: z-b-data-1(active, since 32m)
       osd: 3 osds: 3 up (since 31m), 3 in (since 4w)
   
     data:
       pools:   2 pools, 33 pgs
       objects: 44.79k objects, 174 GiB
       usage:   517 GiB used, 880 GiB / 1.4 TiB avail
       pgs:     100.000% pgs not active
                33 peering

这显示OSD存在异常

检查 ``dmesg -T`` 输出也有一个提示信息::

   [Tue Jan 10 00:41:47 2023] systemd[1]: /lib/systemd/system/ceph-volume@.service:8: Unit configured to use KillMode=none. This is unsafe, as it disables systemd's process lifecycle management for the service. Please update your service to use a safer KillMode=, such as 'mixed' or 'control-group'. Support for KillMode=none is deprecated and will eventually be removed.

看来ceph进程关闭需要改进?
