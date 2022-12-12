.. _mobile_cloud_ceph_mon:

============================
移动云计算Ceph部署ceph-mon
============================

监控引导(monitor bootstrapping)
==================================

引导启动一个监控器（理论上就是Ceph存储集群）需要一系列要求：

- 唯一标识符(Unique Identifier)：对于每个集群 ``fsid`` 是唯一标识符，这个命名有些类似 ``filesystem id`` ，这是因为早期Ceph存储集群主要用于Ceph文件系统。Ceph现在支持原生接口，块设备以及对象存储网关接口等等，所以 ``fsid`` 现在显得有些取名不当(misnomer)。
- 集群名称(Cluster Name)：Ceph集群有一个集群名字，命名集群名时候需要使用没有空格的字符串。默认Ceph集群名是 ``ceph`` ，显然，对于不同用途的多个Ceph集群，起一个明确易懂的集群名非常重要。例如在 `multisite configuration <http://docs.ceph.com/docs/master/radosgw/multisite/#multisite>`_ 配置模式，可以通过集群名 ``us-west`` 和 ``us-east`` 来表示集群的地理位置，相应的指定Ceph集群配置可以使用集群名，例如 ``ceph.conf`` , ``us-west.conf`` ， ``us-east.conf`` 等等。命令行可以指定集群，例如 ``ceph --cluster {cluster-name}`` 。
- 监控名(Monitor Name)：在集群中的每个监控实例都有一个唯一命名。根据经验，Ceph监控名通常是主机名（建议每个host主机只配置一个Ceph监控，并且不要混合部署Ceph OSD服务和Ceph Monitor）。通过 ``hostname -s`` 可以获得主机的简短主机名。
- 监控映射(Monitor Map)：启动引导初始化监控需要生成一个监控映射。这个监控映射需要 ``fsid`` 以及集群名字，以及至少一个主机名和它的IP地址。（注：这表示每个监控对应一个集群，即对应一个 ``fsid`` ）
- 监控密钥环(Monitor Keyring)：监控进程相互之间通过一个安全密钥加密通讯。你必须生成一个用于监控安全的密钥环并在引导启动时提供给初始化监控。
- 管理员密钥环(Administrator Keyring)：为了使用ceph命令行工具，需要具备一个 ``client.admin`` 用户，所以必须生成一个管理员用户和密钥环，并且必须将 ``client.admin`` 用户添加到监控密钥环。

建议创建Ceph配置文件包含 ``fsid`` 以及 mon 的 ``initial`` 成员和 mom 的 ``host`` 设置。

.. warning::

   之前的实践中， :ref:`install_ceph_manual_zdata` 步骤 :ref:`add_ceph_osds_zdata` 没有解决自定义Ceph集群名的添加OSDs问题。

   :strike:`现在我重新部署Ceph再次探索自定义 Ceph 集群名，以便后续部署更多集群进行管理。`

   这次还是采用了默认 ``ceph`` 作为集群名

.. note::

   Ceph默认部署集群名字就是 ``ceph`` ，需要注意，很多工具和配置文件都是以集群名字作为配置文件名，例如 ``/etc/ceph/adata.conf`` 表示 ``adata`` 集群，对应的集群访问证书是 ``/etc/ceph/adata.client.admin.keyring`` 。在官方文档中，很多使用 ``name`` 来指代集群名字。

   本次部署还是回归 ``ceph`` 常规命名集群名

- 在每个服务器节点上准备环境变量:

.. literalinclude:: ceph_env
   :language: bash
   :caption: 在每个服务器节点上准备环境变量

部署monitor
================

- 登陆到monitor节点，初始工作在 ``$HOST_1`` ( ``a-b-data-1`` )节点，所以 ``ssh a-b-data-1``

- 由于我们已经安装了ceph软件，所以安装程序已经创建了 ``/etc/ceph`` 目录

.. note::

   如果集群清理，例如 ``ceph-deploy purgedata {node-name}`` 或者 ``ceph-deploy purge {node-name}`` 则部署工具可能会移除 ``/etc/ceph`` 目录。

- 生成一个unique ID，用于fsid::

   cat /proc/sys/kernel/random/uuid

输出::

   598dc69c-5b43-4a3b-91b8-f36fc403bcc5

.. note::

   上述 ``uuid`` 用于 ``fsid`` ，也就是前文环境变量 ``FSID``

.. note::

   也可以使用 ``uuidgen`` 工具来生成uuid，这个工具包含在 ``util-linux`` 软件包中（ 参考 `uuidgen - create a new UUID value <http://manpages.ubuntu.com/manpages/xenial/man1/uuidgen.1.html>`_ ）

- 创建Ceph配置文件 这里我部署 :ref:`mobile_cloud_infra` 由于是采用默认集群名 ``ceph`` ，所以配置文件就是 ``/etc/ceph.conf``  - 配置文件的命名规则是 ``{cluster_name}.conf`` 参考 :ref:`install_ceph_manual_zdata` 中探索

- 执行以下脚本生成初始 ``/etc/ceph/ceph.conf`` 配置文件:

.. literalinclude:: mobile_cloud_ceph_mon/create_ceph_mon_bootstrap_config
   :language: bash
   :caption: 生成Ceph集群起始ceph-mon配置文件 /etc/ceph/ceph.conf 的脚本: create_ceph_mon_bootstrap_config

解析:

===============================================  ===========================
配置                                             说明
===============================================  ===========================
fsid = {UUID}                                    设置Ceph的唯一ID
mon initial members = {hostname}[,{hostname}]    初始化monitor(s)主机名
mon host = {ip-address}[,{ip-address}]           初始化monitor(s)的主机IP
osd pool default size = {n}                      设置存储池中对象的副本数量
osd pool default min size = {n}                  设置降级状态下对象的副本数
===============================================  ===========================

- 创建集群的keyring和monitor密钥:

.. literalinclude:: mobile_cloud_ceph_mon/create_ceph_mon_keyring
   :language: bash
   :caption: 生成Ceph集群的 ${CLUSTER}.mon.keyring

.. note::

   注意这里创建的 ``keyring`` 名字是 ``{CLUSTER}.mon.keyring``

提示::

   creating /tmp/ceph.mon.keyring

- 生成管理员keyring，生成 ``client.admin`` 用户并添加用户到keyring:

.. literalinclude:: mobile_cloud_ceph_mon/create_ceph_client_admin_keyring
   :language: bash
   :caption: 生成Ceph集群的 ${CLUSTER}.client.admin.keyring

提示::

   creating /etc/ceph/ceph.client.admin.keyring

.. warning::

   这里 ``/etc/ceph/${CLUSTER}.client.admin.keyring`` 是和集群名 ``ceph`` 对应的，所以如果创建其他集群管理，例如对 ``zdata`` 集群管理，则这个keyring名字必须是 ``/etc/ceph/zdata.client.admin.keyring``

- 生成 ``bootstrap-osd`` keyring(命名应该也是和集群名相关，是 ``${CLUSTER}.keyring`` )，生成 ``client.bootstrap-osd`` 用户并添加用户到keyring:

.. literalinclude:: mobile_cloud_ceph_mon/create_ceph_bootstrap_osd_keyring
   :language: bash
   :caption: 生成Ceph集群的bootstrap-osd keyring并将用户加入这个keyring

提示::

   creating /var/lib/ceph/bootstrap-osd/ceph.keyring

- 将生成的key添加到 ``${CLUSTER}.mon.keyring`` ( ``ceph.mon.keyring`` )，并且修改这个keyring的owner为 ``ceph`` :

.. literalinclude:: mobile_cloud_ceph_mon/add_key_to_mon_keyring
   :language: bash
   :caption: 将Ceph集群的admin keyring 和 bootstrap-osd keyring添加到 mon.keyring

提示::

   importing contents of /etc/ceph/ceph.client.admin.keyring into /tmp/ceph.mon.keyring
   importing contents of /var/lib/ceph/bootstrap-osd/ceph.keyring into /tmp/ceph.mon.keyring

- 使用主机名、主机IP和FSID生成一个监控映射，保存为 ``/tmp/monmap`` :

.. literalinclude:: mobile_cloud_ceph_mon/create_monmap
   :language: bash
   :caption: 将Ceph集群的主机名、主机IP和FSID生成一个监控映射 /tmp/monmap

提示信息::

   monmaptool: monmap file /tmp/monmap
   setting min_mon_release = octopus
   monmaptool: set fsid to 598dc69c-5b43-4a3b-91b8-f36fc403bcc5
   monmaptool: writing epoch 0 to /tmp/monmap (1 monitors)

- 创建一个监控主机到默认数据目录:

.. literalinclude:: mobile_cloud_ceph_mon/create_mon_dir
   :language: bash
   :caption: 将Ceph集群监控主机的默认数据目录

- 发布监控服务的monitor的map和keyring:

.. literalinclude:: mobile_cloud_ceph_mon/ceph_mon_mkfs
   :language: bash
   :caption: 发布监控服务monitor的map和keyring(创建数据目录下数据)

- ``如果使用自定义集群名，则非常重要`` : 配置 ``systemd`` 启动集群的环境变量，修订 ``/etc/default/ceph`` 添加:

.. literalinclude:: mobile_cloud_ceph_mon/default_ceph
   :language: bash
   :caption: 将Ceph集群名(特别是自定义名)写入到启动环境变量文件 /etc/default/ceph

.. warning::

   这个步骤非常重要，因为 ``ceph-mon@<hostname>`` 启动 ``ceph-mon`` 服务会读取 ``/etc/default/ceph`` 中环境变量，如果没有配置 ``CLUSTER`` 环境变量，就会尝试启动名字为 ``ceph`` 的集群。所以如果要配置一个非默认名字的集群，一定要配置 ``CLUSTER`` 环境变量，否则启动会失败。

   不过，我这次尝试失败: :ref:`mobile_cloud_ceph_mon_adata_fail`

- 启动monitor(s)

通常发行版使用 ``systemctl`` 启动监控:

.. literalinclude:: mobile_cloud_ceph_mon/start_ceph
   :language: bash
   :caption: 启动ceph-mon服务

- 验证monitor运行::

   sudo ceph -s

如果正常，会看到如下输出::

   cluster:
     id:     598dc69c-5b43-4a3b-91b8-f36fc403bcc5
     health: HEALTH_WARN
             mon is allowing insecure global_id reclaim
             1 monitors have not enabled msgr2
  
   services:
     mon: 1 daemons, quorum a-b-data-1 (age 30s)
     mgr: no daemons active
     osd: 0 osds: 0 up, 0 in
  
   data:
     pools:   0 pools, 0 pgs
     objects: 0 objects, 0 B
     usage:   0 B used, 0 B / 0 B avail
     pgs:

消除 ``HEALTH_WARN`` (暂时跳过)
==================================

.. warning::

   本步骤暂时跳过，原因见 :ref:`disable_insecure_global_id_reclaim` 出现的问题

- 消除 ``HEALTH_WARN`` 参考 :ref:`solve_install_ceph_mon_health_warn` 执行以下命令::

   sudo ceph config set mon auth_allow_insecure_global_id_reclaim false
   sudo ceph mon enable-msgr2

最终完成后，执行::

   sudo ceph -s

输出以下信息::

   cluster:
     id:     598dc69c-5b43-4a3b-91b8-f36fc403bcc5
     health: HEALTH_OK
  
   services:
     mon: 1 daemons, quorum a-b-data-1 (age 14s)
     mgr: no daemons active
     osd: 0 osds: 0 up, 0 in
  
   data:
     pools:   0 pools, 0 pgs
     objects: 0 objects, 0 B
     usage:   0 B used, 0 B / 0 B avail
     pgs:

整合脚本快速完成
==================

按照上述步骤一步步完成可以看到，整个步骤都在 ``$HOST_1`` ( ``a-b-data-1`` )上完成，实际上可以整合成一个脚本快速完成:

.. literalinclude:: mobile_cloud_ceph_mon/host_1_ceph_mon.sh
   :language: bash
   :caption: 在节点1上完成ceph-mon部署脚本 host_1_ceph_mon.sh

下一步
========

- :ref:`mobile_cloud_ceph_mgr`

参考
======

- `Ceph document: Installation Ceph >> Installation(Manual) >> Manual Deployment #MONITOR BOOTSTRAPPING <https://docs.ceph.com/en/latest/install/manual-deployment/#monitor-bootstrapping>`_
