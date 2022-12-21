.. _remove_iscsi_session:

==========================
从系统删除iSCSI会话
==========================

在完成 :ref:`ceph_iscsi_initator` 配置后，我发现执行 :ref:`mobile_cloud_ceph_iscsi_libvirt` 会始终提示错误:

.. literalinclude:: ../../deploy/install_mobile_cloud_ceph/mobile_cloud_ceph_iscsi_libvirt/virsh_pool_start_error
   :language: bash
   :caption: libvirt启动iSCSI pool报错，显示已经存在iSCSI会话

最初我以为只要退出上次测试 :ref:`ceph_iscsi_initator` 创建的会话就可以了，所以执行:

.. literalinclude:: ceph_iscsi_initator/iscsiadm_logout
   :language: bash
   :caption: iscsiadm退出target登陆

然后再次启动libvirt的iSCSI pool:

.. literalinclude:: ../../deploy/install_mobile_cloud_ceph/mobile_cloud_ceph_iscsi_libvirt/virsh_pool_start
   :language: xml
   :caption: 使用virsh pool-start启动images_iscsi存储池

但是报错依旧

看起来清理之前存在的iSCSI session可能是解决方法

清理iSCSI会话
================

- 如果iSCSI磁盘已经挂载，则需要先卸载，例如::

   umount /clusterfs

- 检查当前会话:

.. literalinclude:: ceph_iscsi_initator/iscsiadm_session_show
   :language: bash
   :caption: iscsiadm检查当前会话

此时可以看到::

   tcp: [23] 192.168.8.205:3260,1 iqn.2022-12.io.cloud-atlas.iscsi-gw:iscsi-igw (non-flash)

- 从iSCSI target登出:

.. literalinclude:: ceph_iscsi_initator/iscsiadm_logout
   :language: bash
   :caption: iscsiadm退出target登陆

提示信息::

   Logging out of session [sid: 23, target: iqn.2022-12.io.cloud-atlas.iscsi-gw:iscsi-igw, portal: 192.168.8.205,3260]
   Logout of [sid: 23, target: iqn.2022-12.io.cloud-atlas.iscsi-gw:iscsi-igw, portal: 192.168.8.205,3260] successful.

- 再次检查当前会话:

.. literalinclude:: ceph_iscsi_initator/iscsiadm_session_show
   :language: bash
   :caption: iscsiadm检查当前会话

此时就看到没有活跃会话了::

   iscsiadm: No active sessions.

- 删除删除节点:

.. literalinclude:: ceph_iscsi_initator/iscsiadm_delete_node
   :language: bash
   :caption: iscsiadm删除节点(iqn)

此时 ``/etc/iscsi/nodes`` 目录下对应节点目录会删除

- 如果需要可以删除iSCSI discovery数据库的targets记录:

.. literalinclude:: ceph_iscsi_initator/iscsiadm_delete_discoverydb_target
   :language: bash
   :caption: iscsiadm删除discovery数据的target记录

然后可以重新尝试 :ref:`mobile_cloud_ceph_iscsi_libvirt`

参考
=======

- `Remove ISCSI sessions using the Linux command line <https://helpdesk.kaseya.com/hc/en-gb/articles/4407512021521-Remove-ISCSI-sessions-using-the-Linux-command-line>`_
- `How to delete iscsi target from initiator ( CentOS / RHEL 7  ) Linux <https://www.golinuxcloud.com/delete-remove-inactive-iscsi-target-rhel-7-linux/>`_
