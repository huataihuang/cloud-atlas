.. _add_ceph_mds:

==================
Ceph集群添加MDS
==================

现在部署 ``ceph-mds`` 服务，对外提供POSIX兼容元数据

- 在 ``z-b-data-1`` 上执行::

   cluster=ceph
   id=z-b-data-1
   sudo mkdir -p /var/lib/ceph/mds/${cluster}-${id}

- 创建keyring::

   sudo ceph-authtool --create-keyring /var/lib/ceph/mds/${cluster}-${id}/keyring --gen-key -n mds.${id}
   sudo chown -R ceph:ceph /var/lib/ceph/mds/${cluster}-${id}

- 导入keyring和设置caps::

   sudo ceph auth add mds.${id} osd "allow rwx" mds "allow *" mon "allow profile mds" -i /var/lib/ceph/mds/${cluster}-${id}/keyring

- 启动服务::

   sudo systemctl start ceph-mds@${id}
   sudo systemctl status ceph-mds@${id}

可以看到::

    ● ceph-mds@z-b-data-1.service - Ceph metadata server daemon
         Loaded: loaded (/lib/systemd/system/ceph-mds@.service; disabled; vendor preset: enabled)
         Active: active (running) since Sun 2021-12-05 17:42:46 CST; 5s ago
       Main PID: 4700 (ceph-mds)
          Tasks: 15
         Memory: 10.4M
         CGroup: /system.slice/system-ceph\x2dmds.slice/ceph-mds@z-b-data-1.service
                 └─4700 /usr/bin/ceph-mds -f --cluster ceph --id z-b-data-1 --setuser ceph --setgroup ceph
    
    Dec 05 17:42:46 z-b-data-1 systemd[1]: Started Ceph metadata server daemon.
    Dec 05 17:42:46 z-b-data-1 ceph-mds[4700]: starting mds.z-b-data-1 at 

- 检查集群状态::

   sudo ceph -s

显示::

   cluster:
     id:     0e6c8b6f-0d32-4cdb-a45d-85f8c7997c17
     health: HEALTH_OK
    
   services:
     mon: 3 daemons, quorum z-b-data-1,z-b-data-2,z-b-data-3 (age 19h)
     mgr: z-b-data-1(active, since 2d)
     mds:  1 up:standby
     osd: 3 osds: 3 up (since 18h), 3 in (since 18h)
    
   data:
     pools:   1 pools, 1 pgs
     objects: 3 objects, 0 B
     usage:   3.0 GiB used, 1.4 TiB / 1.4 TiB avail
     pgs:     1 active+clean

添加另外2个MDS
====================

- 修改每个服务器上 ``/etc/ceph/ceph.conf`` 配置，添加::

   [mds.z-b-data-1]
   host = 192.168.6.204
   
   [mds.z-b-data-2]
   host = 192.168.6.205
   
   [mds.z-b-data-3]
   host = 192.168.6.206

然后重启每个服务器上 ``ceph-mon`` ::

   sudo systemctl restart ceph-mon@`hostname`

- 在 ``z-b-data-2`` 和 ``z-b-data-3`` 上执行以下命令将 ``z-b-data-1`` 主机上 keyring 复制过来(这里举例是 ``z-b-data-2`` )::

   cluster=ceph
   id=z-b-data-2

   sudo mkdir /var/lib/ceph/mds/${cluster}-${id}
   sudo ceph-authtool --create-keyring /var/lib/ceph/mds/${cluster}-${id}/keyring --gen-key -n mds.${id}
   sudo chown -R ceph:ceph /var/lib/ceph/mds/${cluster}-${id}

- 导入keyring和设置caps::

   sudo ceph auth add mds.${id} osd "allow rwx" mds "allow *" mon "allow profile mds" -i /var/lib/ceph/mds/${cluster}-${id}/keyring

- 启动服务器::

   sudo systemctl start ceph-mds@${id}
   sudo systemctl enable ceph-mds@${id}

同样在 ``z-b-data-3`` 上完成上述操作

MDS检查
==========

最后完成，执行状态检查::

   sudo ceph -s

可以看到状态::

   cluster:
     id:     0e6c8b6f-0d32-4cdb-a45d-85f8c7997c17
     health: HEALTH_OK
    
   services:
     mon: 3 daemons, quorum z-b-data-1,z-b-data-2,z-b-data-3 (age 21m)
     mgr: z-b-data-1(active, since 29m)
     mds:  3 up:standby
     osd: 3 osds: 3 up (since 21m), 3 in (since 23h)
    
   data:
     pools:   1 pools, 1 pgs
     objects: 3 objects, 0 B
     usage:   3.0 GiB used, 1.4 TiB / 1.4 TiB avail
     pgs:     1 active+clean

上述状态中 ``services`` ::

   mds:  3 up:standby

根据 `Ceph文档MDS STATES <https://docs.ceph.com/en/latest/cephfs/mds-states/>`_ 

- 检查文件系统::

   sudo ceph fs dump

显示::

   dumped fsmap epoch 11
   e11
   enable_multiple, ever_enabled_multiple: 0,0
   compat: compat={},rocompat={},incompat={1=base v0.20,2=client writeable ranges,3=default file layouts on dirs,4=dir inode in separate object,5=mds uses versioned encoding,6=dirfrag is stored in omap,8=no anchor table,9=file layout v2,10=snaprealm v2}
   legacy client fscid: -1
   
   No filesystems configured
   Standby daemons:
   
   [mds.z-b-data-1{-1:94320} state up:standby seq 1 addr [v2:192.168.6.204:6810/3515377620,v1:192.168.6.204:6811/3515377620]]
   [mds.z-b-data-2{-1:104110} state up:standby seq 1 addr [v2:192.168.6.205:6808/1674656387,v1:192.168.6.205:6809/1674656387]]
   [mds.z-b-data-3{-1:114122} state up:standby seq 2 addr [v2:192.168.6.206:6808/3637086204,v1:192.168.6.206:6809/3637086204]]

参考
=========

- `CEPH by hand <http://www.hep.ph.ic.ac.uk/~dbauer/cloud/iris/ceph.html>`_
