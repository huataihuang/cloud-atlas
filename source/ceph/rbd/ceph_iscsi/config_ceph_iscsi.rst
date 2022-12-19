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

``gwcli`` 可以创建和配置 iSCSI target 以及 RBD images,并且提供了跨网关复制配置的能力。虽然底层的工具如 ``targetcli`` 和 ``rbd`` 也能完成相应工作，但是只能用于本地处理，所以不要直接使用底层工具，而应该采用上层的 ``gwcli`` 。

- 在一个Ceph iSCSI网关节点，启动 Ceph iSCSI弯管命令，进行交互操作::

   gwcli

.. note::

   此时会进入一个类似文件系统的层次结构，你可以简单执行 ``ls`` 命令，可以看到结合了底层 ``iSCSI target`` 和 ``rdb`` 的树状结构::

      /> ls /
      o- / ................................................................... [...]
        o- cluster ................................................... [Clusters: 1]
        | o- ceph ...................................................... [HEALTH_OK]
        |   o- pools .................................................... [Pools: 3]
        |   | o- .mgr ............ [(x3), Commit: 0.00Y/46368320K (0%), Used: 1356K]
        |   | o- libvirt-pool ...... [(x3), Commit: 0.00Y/46368320K (0%), Used: 12K]
        |   | o- rbd ............... [(x3), Commit: 0.00Y/46368320K (0%), Used: 12K]
        |   o- topology .......................................... [OSDs: 3,MONs: 3]
        o- disks ................................................. [0.00Y, Disks: 0]
        o- iscsi-targets ......................... [DiscoveryAuth: None, Targets: 0]

- 进入 ``iscsi-targets`` 创建一个名为 ``iqn.2022-12.io.cloud-atlas.iscsi-gw:iscsi-igw`` :

.. literalinclude:: config_ceph_iscsi/gwcli_create_iscai_target
   :language: bash
   :caption: 创建名为 iqn.2022-12.io.cloud-atlas.iscsi-gw:iscsi-igw 的iSCSI target

- 创建iSCSI网关，这里IP地址是用于读写命令的，可以和 ``trusted_ip_list`` 一致，不过建议使用独立IP:

.. literalinclude:: config_ceph_iscsi/gwcli_create_iscai_gateways
   :language: bash
   :caption: 创建iSCSI网关

.. note::

   请注意我第一次执行添加命令 ``create a-b-data-2 192.168.8.205 skipchecks=true`` 提示错误::

      The first gateway defined must be the local machine

   参考 `Bug 1979449 - iSCSI: Getting the error "The first gateway defined must be the local machine" while adding gateways <https://bugzilla.redhat.com/show_bug.cgi?id=1979449>`_ 原因是 ``ceph-iscsi`` 使用FQDN来验证主机名是否匹配。所以我第二次改为完整域名就能够添加gateway。

.. note::

   对于非 RHEL/CentOS 操作系统或者使用上游开源ceph-iscsi代码或者使用ceph-iscsi-test内核，则需要使用 ``skipchecks=true`` 参数，这样可以避免校验Red Hat内核和检查rpm包。

- 添加RBD镜像，位于 ``rbd`` ，大小就采用Ceph整个Bluestore磁盘大小(因为我磁盘空间有限，所以整个分配给虚拟机使用), 即名为 ``vm_images`` 大小 55G:

.. literalinclude:: config_ceph_iscsi/gwcli_create_rbd_image
   :language: bash
   :caption: 创建RBD磁盘镜像

.. note::

   回过头看，之前文档中提到创建Ceph存储池命名为 ``rbd`` ，我感觉实际命名可以采用其他名字。考虑到我之前创建过 ``livirt-pool`` 存储池，所以我这里改为创建在存储池 ``libvirt-pool`` 下。

   磁盘创建的规格可以超过实际物理磁盘容量，例如我的OSD磁盘只有46.6G(物理磁盘分区)，但是创建 ``rbd image`` 可以创建上百G甚至更多。实际使用时才会消耗磁盘空间，具体可以等逻辑磁盘写满就可以动态添加底层物理磁盘扩容。

- 创建一个 initator 名为 ``iqn.1989-06.io.cloud-atlas:libvirt-client`` 客户端，并且配置intiator的CHAP名字和密码，然后再把创建的RBD镜像磁盘添加给用户:

.. literalinclude:: config_ceph_iscsi/gwcli_create_initator_client
   :language: bash
   :caption: 创建名为 iqn.1989-06.io.cloud-atlas:libvirt-client 的iSCSI initator客户端命名

.. note::

   这里的CHAP username和password必须配置，否则target会拒绝任何登陆

   username必须是8个字符或以上; password必须是12个字符或以上

添加iSCSI网关到Ceph管理Dashboard
=====================================

配置好 Ceph iSCSI网关之后，在Dashboard上还是看不到新的网关，此时需要通过::

   ceph dashboard iscsi-gateway-list
   # Gateway URL format for a new gateway: <scheme>://<username>:<password>@<host>[:port]
   ceph dashboard iscsi-gateway-add -i <file-containing-gateway-url> [<gateway_name>]
   ceph dashboard iscsi-gateway-rm <gateway_name>

举例，创建一个 ``iscsi-gw`` 配置文件内容就是(按照 /etc/ceph/iscsi-gateway.cfg )::

   http://admin:mypassword@192.168.8.205:5001

然后执行以下命令添加iSCSI网关管理配置到Dashboard::

   ceph dashboard iscsi-gateway-add -i iscsi-gw iscsi-gw-1

这里有一个问题，就是我错误配置了iSCSI GW的IP地址，但是我发现添加以后无法删除，因为删除时候会去访问错误的GW的IP地址，一直超时...暂时没有想出解决方法，似乎要清理垃圾数据(是flask后端提供的API服务，应该有什么地方记录数据，所以需要手工更新配置)

参考
=======

- `Ceph Block Device » Ceph Block Device 3rd Party Integration » Ceph iSCSI Gateway » iSCSI Targets » Configuring the iSCSI Target using the Command Line Interface <https://docs.ceph.com/en/latest/rbd/iscsi-target-cli/>`_
