.. _install_ceph_mon:

=========================
安装 ceph-mon
=========================

.. note::

   2021年10月我购买了 :ref:`hpe_dl360_gen9` 构建 :ref:`priv_cloud_infra` ，底层数据存储层采用Ceph实现。为了完整控制部署并了解Ceph组件安装，采用本文手工部署Ceph方式安装。本文在原先 :ref:`install_ceph_manual_zdata` 基础上重新开始。

   部署采用3个 :ref:`ovmf` 虚拟机，通过 :ref:`iommu` 方式 pass-through :ref:`samsung_pm9a1` :ref:`nvme` 存储。也就是一共有3个 :ref:`kvm` 虚拟机来完成Ceph集群部署:

   - ``z-b-data-1`` (192.168.6.204)
   - ``z-b-data-2`` (192.168.6.205)
   - ``z-b-data-3`` (192.168.6.206)

   操作系统采用 :ref:`ubuntu_linux` 20.04.3 LTS

获取Ceph软件
=============

最简易获取软件的方法还是采用发行版的软件仓库，例如 ``apt`` (Debian/Ubuntu) 或 ``yum`` (RHEL/CentOS) ，如果使用非 ``deb`` 或 ``rpm`` 的软件包管理，则可以使用官方提供的tar包安装二进制可执行程序。

.. note::

   在多台服务器上同时操作，可以使用 :ref:`pssh`

安装Ceph软件
==============

.. note::

   为了能够完整了解Ceph集群部署过程，本文档没有使用 ``ceph-deploy`` 和 ``ceph-adm`` 工具，而是采用手工通过APT包管理工具进行部署。

- 安装Ceph软件包（在每个节点上执行）::

   sudo apt update && sudo apt install ceph ceph-mds

.. note::

   `INSTALL CEPH STORAGE CLUSTER <https://docs.ceph.com/en/pacific/install/install-storage-cluster/>`_ 提供了 APT 和 YUM 仓库安装方法

   对于通过对象存储模式使用Ceph，需要安装 ``Ceph Object Gateway`` ，我将另外撰写文章；对于虚拟化平台使用Ceph块设备则需要通过 ``librdb`` 驱动，我也会另外撰写实践文章。

Ceph集群的初始
=================

Ceph集群要求至少1个monitor，以及至少和对象存储的副本数量相同（或更多）的OSD运行在集群中。 monitor部署是整个集群设置的重要步骤，例如存储池的副本数量，每个OSD的placement groups数量，心跳间隔，是否需要认证等等。这些配置都有默认值，但是在部署生产集群需要仔细调整这些配置。

本案例采用3个节点：

.. figure:: ../../../_static/ceph/deploy/install_ceph_manual/simple_3nodes_cluster.png

   Figure 1: 三节点Ceph集群

.. note::

   我在部署初始采用1个monitor，准备后续再通过monitor方式扩容(缩容及替换)来演练生产环境的维护。

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

   我在 :ref:`install_ceph_manual_zdata` 步骤 :ref:`add_ceph_osds_zdata` 没有解决自定义Ceph集群名的添加OSDs问题，所以目前只采用标准默认 ``ceph`` 作为集群名字，后续我将构建虚拟机环境来学习和实践部署多集群。 

.. note::

   Ceph默认部署集群名字就是 ``ceph`` ，需要注意，很多工具和配置文件都是以集群名字作为配置文件名，例如 ``/etc/ceph/zdata.conf`` 表示 ``zdata`` 集群，对应的集群访问证书是 ``/etc/ceph/zdata.client.admin.keyring`` 。在官方文档中，很多使用 ``name`` 来指代集群名字。

部署monitor
================

- 登陆到monitor节点，这里案例我安装在 ``z-b-data-1`` 节点，所以 ``ssh z-b-data-1``

- 由于我们已经安装了ceph软件，所以安装程序已经创建了 ``/etc/ceph`` 目录

.. note::

   如果集群清理，例如 ``ceph-deploy purgedata {node-name}`` 或者 ``ceph-deploy purge {node-name}`` 则部署工具可能会移除 ``/etc/ceph`` 目录。

- 生成一个unique ID，用于fsid::

   cat /proc/sys/kernel/random/uuid

输出::

   0e6c8b6f-0d32-4cdb-a45d-85f8c7997c17

.. note::

   也可以使用 ``uuidgen`` 工具来生成uuid，这个工具包含在 ``util-linux`` 软件包中（ 参考 `uuidgen - create a new UUID value <http://manpages.ubuntu.com/manpages/xenial/man1/uuidgen.1.html>`_ ）

- 创建Ceph配置文件 - 默认 Ceph 使用 ``ceph.conf`` 配置，这个配置文件的命名规则是 ``{cluster_name}.conf`` 这里我依然使用默认集群名字，所以配置文件是 ``ceph.conf`` ，对于指定集群名，将在 :ref:`install_ceph_manual_zdata` 中探索::

   sudo vim /etc/ceph/ceph.conf

配置案例:

.. literalinclude:: install_ceph_mon/ceph.conf
   :language: bash
   :linenos:
   :caption: /etc/ceph/ceph.conf

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

- 创建集群的keyring和monitor密钥::

   sudo ceph-authtool --create-keyring /tmp/ceph.mon.keyring --gen-key -n mon. --cap mon 'allow *'

提示::

   creating /tmp/ceph.mon.keyring

- 生成管理员keyring，生成 ``client.admin`` 用户并添加用户到keyring::

   sudo ceph-authtool --create-keyring /etc/ceph/ceph.client.admin.keyring --gen-key -n client.admin --cap mon 'allow *' --cap osd 'allow *' --cap mds 'allow *' --cap mgr 'allow *'

提示::

   creating /etc/ceph/ceph.client.admin.keyring

.. warning::

   这里 ``/etc/ceph/ceph.client.admin.keyring`` 是和集群名 ``ceph`` 对应的，所以如果创建其他集群管理，例如对 ``zdata`` 集群管理，则这个keyring名字必须是 ``/etc/ceph/zdata.client.admin.keyring``

- 生成 ``bootstrap-osd`` keyring(命名应该也是和集群名相关，没有验证，感觉应该是 ``<cluseter>.keyring`` )，生成 ``client.bootstrap-osd`` 用户并添加用户到keyring::

   sudo ceph-authtool --create-keyring /var/lib/ceph/bootstrap-osd/ceph.keyring --gen-key -n client.bootstrap-osd --cap mon 'profile bootstrap-osd' --cap mgr 'allow r'

提示::

   creating /var/lib/ceph/bootstrap-osd/ceph.keyring

- 将生成的key添加到 ``ceph.mon.keyring`` ::

   sudo ceph-authtool /tmp/ceph.mon.keyring --import-keyring /etc/ceph/ceph.client.admin.keyring
   sudo ceph-authtool /tmp/ceph.mon.keyring --import-keyring /var/lib/ceph/bootstrap-osd/ceph.keyring

提示::

   importing contents of /etc/ceph/ceph.client.admin.keyring into /tmp/ceph.mon.keyring
   importing contents of /var/lib/ceph/bootstrap-osd/ceph.keyring into /tmp/ceph.mon.keyring

- 更改 ``ceph.mon.keyring`` 的owner::

   sudo chown ceph:ceph /tmp/ceph.mon.keyring

- 使用主机名、主机IP和FSID生成一个监控映射，保存为 ``/tmp/monmap`` ::

   monmaptool --create --add {hostname} {ip-address} --fsid {uuid} /tmp/monmap

实际操作为::

   monmaptool --create --add z-b-data-1 192.168.6.204 --fsid 0e6c8b6f-0d32-4cdb-a45d-85f8c7997c17 /tmp/monmap

提示信息::

   monmaptool: monmap file /tmp/monmap
   monmaptool: set fsid to 0e6c8b6f-0d32-4cdb-a45d-85f8c7997c17
   monmaptool: writing epoch 0 to /tmp/monmap (1 monitors)

.. note::

   这个步骤非常重要

- 创建一个监控主机到默认数据目录::

   sudo mkdir /var/lib/ceph/mon/{cluster-name}-{hostname}

实际操作为-我的实验环境存储集群名设置为 ``ceph`` 主机名是 ``z-b-data-1`` ::

   sudo -u ceph mkdir /var/lib/ceph/mon/zdata-z-b-data-1

- 发布监控服务的monitor的map和keyring::

   sudo -u ceph ceph-mon [--cluster {cluster-name}] --mkfs -i {hostname} --monmap /tmp/monmap --keyring /tmp/ceph.mon.keyring

实际操作::

   sudo -u ceph ceph-mon --cluster ceph --mkfs -i z-b-data-1 --monmap /tmp/monmap --keyring /tmp/ceph.mon.keyring

- ``如果使用自定义集群名，则非常重要`` : 配置 ``systemd`` 启动集群的环境变量，修订 ``/etc/default/ceph`` 添加::

   CLUSTER=ceph

.. warning::

   这个步骤非常重要，因为 ``ceph-mon@<hostname>`` 启动 ``ceph-mon`` 服务会读取 ``/etc/default/ceph`` 中环境变量，如果没有配置 ``CLUSTER`` 环境变量，就会尝试启动名字为 ``ceph`` 的集群。所以如果要配置一个非默认名字的集群，一定要配置 ``CLUSTER`` 环境变量，否则启动会失败。

   这里我的环境还是使用默认名 ``ceph`` 则此步骤可以跳过

   对于采用非默认Ceph集群名字命名，则会遇到很多困难，我在 :ref:`install_ceph_mon_zdata` 中有相关实践记录

- 启动monitor(s)

通常发行版使用 ``systemctl`` 启动监控::

   sudo systemctl start ceph-mon@z-b-data-1

- 验证monitor运行::

   sudo ceph -s

如果正常，会看到如下输出::

   cluster:
     id:     39392603-fe09-4441-acce-1eb22b1391e1
     health: HEALTH_WARN
             mon is allowing insecure global_id reclaim
             1 monitors have not enabled msgr2
   services:
      mon: 1 daemons, quorum z-b-data-1 (age 3m)
      mgr: no daemons active
      osd: 0 osds: 0 up, 0 in
   data:
      pools:   0 pools, 0 pgs
      objects: 0 objects, 0 B
      usage:   0 B used, 0 B / 0 B avail
      pgs:

.. note::

   参考 `Ceph HEALTH_WARN with 'mons are allowing insecure global_id reclaim' after install/upgrade to RHCS 4.2z2 (or newer) <https://access.redhat.com/articles/6136242>`_ (原因是新版本要求严格安全) 或者 `ceph: Mons are allowing insecure global_id reclaim #7746 <https://github.com/rook/rook/issues/7746>`_ ::

      sudo ceph config set mon auth_allow_insecure_global_id_reclaim false

   上述安全设置加严会禁止没有补丁过的不安全客户端连接并且超时以后需要重新生成认证ticket(默认72小时)

   也可以关闭这个报错输出(我采用这种方法)::

      sudo ceph config set mon mon_warn_on_insecure_global_id_reclaim_allowed false

.. note::

   参考 `MON_MSGR2_NOT_ENABLED <https://docs.ceph.com/en/latest/rados/operations/health-checks/#mon-msgr2-not-enabled>`_ :

   ``ms_bind_msgr2`` 选项已经激活但是monitor没有配置成绑定到集群的monmap ``v2`` 端口。激活这个功能将使用 ``msgr2`` 协议，对于一些连接不可用。大多数情况可以通过以下命令修正::

      ceph mon enable-msgr2

   我执行以下命令修正::

      sudo ceph mon enable-msgr2

最终完成后，执行::

   sudo ceph -s

输出以下信息::

   cluster:
     id:     39392603-fe09-4441-acce-1eb22b1391e1
     health: HEALTH_OK
   services:
     mon: 1 daemons, quorum z-b-data-1 (age 5s)
     mgr: no daemons active
     osd: 0 osds: 0 up, 0 in
   data:
     pools:   0 pools, 0 pgs
     objects: 0 objects, 0 B
     usage:   0 B used, 0 B / 0 B avail
     pgs:

下一步
========

- :ref:`install_ceph_mgr`

参考
======

- `Ceph document - Installation (Manual) <http://docs.ceph.com/docs/master/install/>`_
