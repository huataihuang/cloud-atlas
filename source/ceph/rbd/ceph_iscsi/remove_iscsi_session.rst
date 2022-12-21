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



参考
=======

- `Remove ISCSI sessions using the Linux command line <https://helpdesk.kaseya.com/hc/en-gb/articles/4407512021521-Remove-ISCSI-sessions-using-the-Linux-command-line>`_
- `How to delete iscsi target from initiator ( CentOS / RHEL 7  ) Linux <https://www.golinuxcloud.com/delete-remove-inactive-iscsi-target-rhel-7-linux/>`_
