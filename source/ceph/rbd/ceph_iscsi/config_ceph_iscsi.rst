.. _config_ceph_iscsi:

=======================
配置Ceph iSCSI网关
=======================

完成 :ref:`install_ceph_iscsi` 可以配置 :ref:`ceph_rbd` 块设备映射iSCSI

创建 ``rbd`` 存储池
====================

- ``gwcli`` 需要一个名为 ``rbd`` 的存储池，这样就能够用来存储有关 iSCSI 配置的元数据，首先检查是否存在这个存储池::

   ceph osd lspools

这里显示::

   1 .mgr
   2 libvirt-pool

其中 ``libvirt-pool`` 是我在实践 :ref:`mobile_cloud_ceph_rbd_libvirt` 创建用于libvirt的RBD存储池，但是实际没有使用(原因是 :ref:`arch_linux` ARM没有提供RBD驱动)。当时通过WEB管理界面创建的OSD存储池 ``libvirt-pool`` 已经验证并调整  ``pg_num = 32`` (ceph.conf)

执行以下命令创建名为 ``rbd`` 的存储池:

.. literalinclude:: config_ceph_iscsi/create_rbd_pool_named_rbd
   :language: bash
   :caption: 创建名为 rbd 的存储池

.. note::

   这里我发现奇怪的问题，即使 ``/etc/ceph/ceph.conf`` 已经配置了::

      osd pool default pg num = 32
      osd pool default pgp num = 32

   参数是按照WEB管理界面操作完成，但是依然执行命令报错::

      Error ERANGE: 'pgp_num' must be greater than 0 and lower or equal than 'pg_num', which in this case is 1

   目前暂时采用WEB管理界面创建存储池，待后续排查

完成后再次检查 ``ceph osd lspools`` 可以看到名为 ``rbd`` 的存储池:

.. literalinclude:: config_ceph_iscsi/ceph_osd_lspools_output
   :language: bash
   :caption: 创建名为 rbd 的存储池
   :emphasize-lines: 3

- 在每个 iSCSI 网关节点(我的实践案例采用 ``a-b-data-2`` 和 ``a-b-data-3`` )，创建 ``/etc/ceph/iscsi-gateway.cfg`` 配置文件:

.. literalinclude:: config_ceph_iscsi/iscsi-gateway.cfg
   :language: bash
   :caption: 创建 /etc/ceph/iscsi-gateway.cfg

.. note::

   测试环境没有配置安全认证，后续有机会再搞。生产环境务必配置

.. note::

   ``trusted_ip_list`` 是每个iSCSI网关上的IP地址列表，用于管理操作，如 target 创建，LUN导出等。IP可以与将用于iSCSI数据的IP相同，例如READ/WRITE 命令到/从 RBD 映像，但建议使用单独的 IP。

- 在每个iSCSI网关节点，激活和启动API服务:

.. literalinclude:: config_ceph_iscsi/enable_start_rbd_target_gw_api
   :language: bash
   :caption: 在每个Ceph iSCSI节点上激活并启动API服务

这里我遇到启动 ``rbd-target-gw`` 服务的错误::

   Dec 18 23:38:54 a-b-data-2.dev.cloud-atlas.io systemd[1]: rbd-target-gw.service: Scheduled restart job, restart counter is at 3.
   Dec 18 23:38:54 a-b-data-2.dev.cloud-atlas.io systemd[1]: Stopped rbd-target-gw.service - Setup system to export rbd images through LIO.
   Dec 18 23:38:54 a-b-data-2.dev.cloud-atlas.io systemd[1]: rbd-target-gw.service: Start request repeated too quickly.
   Dec 18 23:38:54 a-b-data-2.dev.cloud-atlas.io systemd[1]: rbd-target-gw.service: Failed with result 'exit-code'.
   Dec 18 23:38:54 a-b-data-2.dev.cloud-atlas.io systemd[1]: Failed to start rbd-target-gw.service - Setup system to export rbd images through LIO.

启动 ``rbd-target-gw`` 非常重要，后续 ``gwcli`` 都依赖API网关完成

我尝试重启了操作系统，发现重启后 ``rbd-target-gw`` / ``rbd-target-api`` 启动正常。看来是有相关性依赖

配置target
===============

待续

参考
=======

- `Ceph Block Device » Ceph Block Device 3rd Party Integration » Ceph iSCSI Gateway » iSCSI Targets » Configuring the iSCSI Target using the Command Line Interface <https://docs.ceph.com/en/latest/rbd/iscsi-target-cli/>`_
