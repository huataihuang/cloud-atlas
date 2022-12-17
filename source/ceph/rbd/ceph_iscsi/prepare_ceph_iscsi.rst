.. _prepare_ceph_iscsi:

======================
安装Ceph iSCSI的准备
======================

Ceph iSCSI网关要求
====================

强烈建议在Ceph iSCSI网关解决方案中采用至少部署2到4个iSCSI网关节点，以提供高可用。

.. note::

   由于iSCSI网关需要实现RBD镜像映射，所以会消耗大量内存，内存使用量取决于需要映射的RBD镜像数量。需要监控iSCSI网关的内存负载并配备充足的内存硬件。

- 对于iSCSI网关没有特备的Ceph Monitors 或 OSDs选项，但是非常重要的是 ``默认检测OSD的心跳间隔需要降低`` 以减少iSCSI initiator超时可能性。修改 ``/etc/ceph/${CLUSTER}.conf`` 配置:

.. literalinclude:: prepare_ceph_iscsi/ceph.conf
   :language: bash
   :caption: /etc/ceph/ceph.conf 修订OSD心跳参数，降低间隔值减少iSCSI initiator启动超时可能性

- 从一个Ceph Monitor (ceph-mon)节点(例如 ``a-b-data-1`` )更新运行状态:

命令语法:

   ceph tell <daemon_type>.<id> config set <parameter_name> <new_value>

实际操作命令:

.. literalinclude:: prepare_ceph_iscsi/ceph_update_osd_heartbeat_config
   :language: bash
   :caption: 选择一个ceph-mon节点发起更新监控OSD心跳运行配置的状态，降低间隔值减少iSCSI initiator启动超时可能性

完成配置后，可以检查配置::

   ceph config show osd.0

可以看到::

   NAME                                             VALUE                                      SOURCE    OVERRIDES  IGNORES
   auth_client_required                             cephx                                      file
   auth_cluster_required                            cephx                                      file
   auth_service_required                            cephx                                      file
   daemonize                                        false                                      override
   keyring                                          $osd_data/keyring                          default
   leveldb_log                                                                                 default
   mon_host                                         192.168.8.204,192.168.8.205,192.168.8.206  file
   mon_initial_members                              a-b-data-1,a-b-data-2,a-b-data-3           file
   no_config_file                                   false                                      override
   osd_crush_chooseleaf_type                        1                                          file
   osd_delete_sleep                                 0.000000                                   override
   osd_delete_sleep_hdd                             0.000000                                   override
   osd_delete_sleep_hybrid                          0.000000                                   override
   osd_delete_sleep_ssd                             0.000000                                   override
   osd_heartbeat_grace                              20                                         override
   osd_journal_size                                 1024                                       file
   ...

- 在每个OSD节点 上更新运行状态:

.. literalinclude:: prepare_ceph_iscsi/ceph_update_osd_daemon_heartbeat_running_state
   :language: bash
   :caption: 在每个ceph-osd节点发起更新OSD服务进程心跳运行状态，降低间隔值减少iSCSI initiator启动超时可能性

参考
=======

- `Ceph Block Device » Ceph Block Device 3rd Party Integration » Ceph iSCSI Gateway <https://docs.ceph.com/en/quincy/rbd/iscsi-overview/>`_
- `Manual ceph-iscsi Installation <https://docs.ceph.com/en/latest/rbd/iscsi-target-cli-manual-install/>`_
