.. _install_ceph_mon:

=========================
安装 ceph-mon
=========================

.. note::

   2021年10月我购买了 :ref:`hpe_dl360_gen9` 构建 :ref:`priv_cloud_infra` ，底层数据存储层采用Ceph实现。为了完整控制部署并了解Ceph组件安装，采用本文手工部署Ceph方式安装。本文在原先 :ref:`install_ceph_manual_old` 基础上重新开始。

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

部署monitor
================

- 登陆到monitor节点，这里案例我安装在 ``z-b-data-1`` 节点，所以 ``ssh z-b-data-1``

- 由于我们已经安装了ceph软件，所以安装程序已经创建了 ``/etc/ceph`` 目录

.. note::

   如果集群清理，例如 ``ceph-deploy purgedata {node-name}`` 或者 ``ceph-deploy purge {node-name}`` 则部署工具可能会移除 ``/etc/ceph`` 目录。

- 生成一个unique ID，用于fsid::

   cat /proc/sys/kernel/random/uuid

.. note::

   也可以使用 ``uuidgen`` 工具来生成uuid，这个工具包含在 ``util-linux`` 软件包中（ 参考 `uuidgen - create a new UUID value <http://manpages.ubuntu.com/manpages/xenial/man1/uuidgen.1.html>`_ ）

- 创建Ceph配置文件 - 默认 Ceph 使用 ``ceph.conf`` 配置，这个配置文件的命名规则是 ``{cluster_name}.conf`` ，由于我准备设置集群名字 ``zdata`` (表示 ``zcloud`` 服务器上数据层) ，所以这个配置文件命名为 ``zdata.conf`` ::

   sudo vim /etc/ceph/zdata.conf

配置案例:

.. literalinclude:: install_ceph_mon/zdata.conf
   :language: bash
   :linenos:
   :caption: /etc/ceph/zdata.conf

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

   sudo ceph-authtool --create-keyring /etc/ceph/zdata.client.admin.keyring --gen-key -n client.admin --cap mon 'allow *' --cap osd 'allow *' --cap mds 'allow *' --cap mgr 'allow *'

提示::

   creating /etc/ceph/zdata.client.admin.keyring

.. warning::

   这里 ``/etc/ceph/zdata.client.admin.keyring`` 必须要注意配置文件名必须以集群名字 ``zdata`` 开始，否则后续步骤都会错误

- 生成 ``bootstrap-osd`` keyring，生成 ``client.bootstrap-osd`` 用户并添加用户到keyring::

   sudo ceph-authtool --create-keyring /var/lib/ceph/bootstrap-osd/ceph.keyring --gen-key -n client.bootstrap-osd --cap mon 'profile bootstrap-osd' --cap mgr 'allow r'

提示::

   creating /var/lib/ceph/bootstrap-osd/ceph.keyring

- 将生成的key添加到 ``ceph.mon.keyring`` ::

   sudo ceph-authtool /tmp/ceph.mon.keyring --import-keyring /etc/ceph/zdata.client.admin.keyring
   sudo ceph-authtool /tmp/ceph.mon.keyring --import-keyring /var/lib/ceph/bootstrap-osd/ceph.keyring

提示::

   importing contents of /etc/ceph/ceph.client.admin.keyring into /tmp/ceph.mon.keyring
   importing contents of /var/lib/ceph/bootstrap-osd/ceph.keyring into /tmp/ceph.mon.keyring

- 更改 ``ceph.mon.keyring`` 的owner::

   sudo chown ceph:ceph /tmp/ceph.mon.keyring

- 使用主机名、主机IP和FSID生成一个监控映射，保存为 ``/tmp/monmap`` ::

   monmaptool --create --add {hostname} {ip-address} --fsid {uuid} /tmp/monmap

实际操作为::

   monmaptool --create --add z-b-data-1 192.168.6.204 --fsid 53c3f770-d869-4b59-902e-d645eca7e34a /tmp/monmap

提示信息::

   monmaptool: monmap file /tmp/monmap
   monmaptool: set fsid to 53c3f770-d869-4b59-902e-d645eca7e34a
   monmaptool: writing epoch 0 to /tmp/monmap (1 monitors)

.. note::

   这个步骤非常重要

- 创建一个监控主机到默认数据目录::

   sudo mkdir /var/lib/ceph/mon/{cluster-name}-{hostname}

实际操作为-我的实验环境存储集群名设置为 ``zdata`` ::

   sudo -u ceph mkdir /var/lib/ceph/mon/zdata-z-b-data-1

- 发布监控服务的monitor的map和keyring::

   sudo -u ceph ceph-mon [--cluster {cluster-name}] --mkfs -i {hostname} --monmap /tmp/monmap --keyring /tmp/ceph.mon.keyring

实际操作::

   sudo -u ceph ceph-mon --cluster zdata --mkfs -i z-b-data-1 --monmap /tmp/monmap --keyring /tmp/ceph.mon.keyring

- ``重要`` : 配置 ``systemd`` 启动集群的环境变量，修订 ``/etc/default/ceph`` 添加::

   CLUSTER=zdata

.. warning::

   这个步骤非常重要，因为 ``ceph-mon@<hostname>`` 启动 ``ceph-mon`` 服务会读取 ``/etc/default/ceph`` 中环境变量，如果没有配置 ``CLUSTER`` 环境变量，就会尝试启动名字为 ``ceph`` 的集群。所以如果要配置一个非默认名字的集群，一定要配置 ``CLUSTER`` 环境变量，否则启动会失败。详见下文我的排查过程。 

- 启动monitor(s)

通常发行版使用 ``systemctl`` 启动监控::

   sudo systemctl start ceph-mon@z-b-data-1

- 验证monitor运行::

   sudo ceph -s -c /etc/ceph/zdata.conf

.. note::

   这里 ``ceph -s`` 检查命令要提供 ``-c`` 参数来指定配置文件，否则会出现报错无法读取配置文件::

      Error initializing cluster client: ObjectNotFound('RADOS object not found (error calling conf_read_file)')

如果正常，会看到如下输出::

   cluster:
     id:     53c3f770-d869-4b59-902e-d645eca7e34a
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

      sudo ceph config set mon auth_allow_insecure_global_id_reclaim false -c /etc/ceph/zdata.conf

   上述安全设置加严会禁止没有补丁过的不安全客户端连接并且超时以后需要重新生成认证ticket(默认72小时)

   也可以关闭这个报错输出(我采用这种方法)::

      sudo ceph config set mon mon_warn_on_insecure_global_id_reclaim_allowed false -c /etc/ceph/zdata.conf

.. note::

   参考 `MON_MSGR2_NOT_ENABLED <https://docs.ceph.com/en/latest/rados/operations/health-checks/#mon-msgr2-not-enabled>`_ :

   ``ms_bind_msgr2`` 选项已经激活但是monitor没有配置成绑定到集群的monmap ``v2`` 端口。激活这个功能将使用 ``msgr2`` 协议，对于一些连接不可用。大多数情况可以通过以下命令修正::

      ceph mon enable-msgr2

   我执行以下命令修正::

      sudo ceph mon enable-msgr2 -c /etc/ceph/zdata.conf

部署monitor排查记录(参考)
============================

排查 keyring 名字错误问题
-------------------------------------------

此时提示报错::

   2021-11-21T23:09:03.944+0800 7f0de6190700 -1 auth: unable to find a keyring on /etc/ceph/zdata.client.admin.keyring,/etc/ceph/zdata.keyring,/etc/ceph/keyring,/etc/ceph/keyring.bin,: (2) No such file or directory
   2021-11-21T23:09:03.944+0800 7f0de6190700 -1 AuthRegistry(0x7f0de00590e0) no keyring found at /etc/ceph/zdata.client.admin.keyring,/etc/ceph/zdata.keyring,/etc/ceph/keyring,/etc/ceph/keyring.bin,, disabling cephx
   2021-11-21T23:09:03.944+0800 7f0de6190700 -1 auth: unable to find a keyring on /etc/ceph/zdata.client.admin.keyring,/etc/ceph/zdata.keyring,/etc/ceph/keyring,/etc/ceph/keyring.bin,: (2) No such file or directory
   2021-11-21T23:09:03.944+0800 7f0de6190700 -1 AuthRegistry(0x7f0de005b248) no keyring found at /etc/ceph/zdata.client.admin.keyring,/etc/ceph/zdata.keyring,/etc/ceph/keyring,/etc/ceph/keyring.bin,, disabling cephx
   2021-11-21T23:09:03.948+0800 7f0de6190700 -1 auth: unable to find a keyring on /etc/ceph/zdata.client.admin.keyring,/etc/ceph/zdata.keyring,/etc/ceph/keyring,/etc/ceph/keyring.bin,: (2) No such file or directory
   2021-11-21T23:09:03.948+0800 7f0de6190700 -1 AuthRegistry(0x7f0de618f130) no keyring found at /etc/ceph/zdata.client.admin.keyring,/etc/ceph/zdata.keyring,/etc/ceph/keyring,/etc/ceph/keyring.bin,, disabling cephx
   [errno 2] RADOS object not found (error connecting to the cluster)

仔细看了一下，原来前面执行 ``生成管理员keyring`` 步骤时没有注意到每个配置文件的开头必须是集群名字，例如我的集群名字是 ``zdata`` 就必须生成 ``/etc/ceph/zdata.client.admin.keyring`` 。我最初按照官方文档(手册是创建 ``ceph`` 名字的集群)，所以原文是::

   sudo ceph-authtool --create-keyring /etc/ceph/ceph.client.admin.keyring --gen-key -n client.admin --cap mon 'allow *' --cap osd 'allow *' --cap mds 'allow *' --cap mgr 'allow *'

应该按照集群名字修订成::

   sudo ceph-authtool --create-keyring /etc/ceph/zdata.client.admin.keyring --gen-key -n client.admin --cap mon 'allow *' --cap osd 'allow *' --cap mds 'allow *' --cap mgr 'allow *'

所以还需要重新走一遍流程

排查 ``ceph-mon`` 失败(不同的ceph集群名)
-------------------------------------------

执行启动服务报错::

   sudo systemctl start ceph-mon@z-b-data-1

提示错误::

   Job for ceph-mon@z-b-data-1.service failed because the control process exited with error code.
   See "systemctl status ceph-mon@z-b-data-1.service" and "journalctl -xe" for details.

- 检查::

   systemctl status ceph-mon@z-b-data-1.service

显示::

   ● ceph-mon@z-b-data-1.service - Ceph cluster monitor daemon
        Loaded: loaded (/lib/systemd/system/ceph-mon@.service; disabled; vendor preset: enabled)
        Active: failed (Result: exit-code) since Sun 2021-11-21 23:03:02 CST; 30min ago
       Process: 10167 ExecStart=/usr/bin/ceph-mon -f --cluster ${CLUSTER} --id z-b-data-1 --setuser ceph --setgroup ceph (code=exited, status=1/FAILURE)
      Main PID: 10167 (code=exited, status=1/FAILURE)
   
   Nov 21 23:03:02 z-b-data-1 systemd[1]: Failed to start Ceph cluster monitor daemon.
   Nov 21 23:24:30 z-b-data-1 systemd[1]: ceph-mon@z-b-data-1.service: Start request repeated too quickly.
   Nov 21 23:24:30 z-b-data-1 systemd[1]: ceph-mon@z-b-data-1.service: Failed with result 'exit-code'.
   Nov 21 23:24:30 z-b-data-1 systemd[1]: Failed to start Ceph cluster monitor daemon.

检查 ``/var/log/ceph/zdata-mon.z-b-data-1.log`` 日志显示::

   2021-11-21T23:01:27.116+0800 7ff4e9ec2540  4 rocksdb: [db/db_impl.cc:389] Shutdown: canceling all background work
   2021-11-21T23:01:27.120+0800 7ff4e9ec2540  4 rocksdb: [db/db_impl.cc:563] Shutdown complete
   2021-11-21T23:01:27.120+0800 7ff4e9ec2540  0 ceph-mon: created monfs at /var/lib/ceph/mon/zdata-z-b-data-1 for mon.z-b-data-1
   2021-11-21T23:25:36.620+0800 7f5fe6f7b540 -1 '/var/lib/ceph/mon/zdata-z-b-data-1' already exists and is not empty: monitor may already exist

原因看来是之前启动 ``ceph-mon`` 失败失败残留数据影响，所以删除目录重新走::

   rm -rf /var/lib/ceph/mon/zdata-z-b-data-1
   sudo -u ceph mkdir /var/lib/ceph/mon/zdata-z-b-data-1

   sudo -u ceph ceph-mon --cluster zdata --mkfs -i z-b-data-1 --monmap /tmp/monmap --keyring /tmp/ceph.mon.keyring
   sudo systemctl start ceph-mon@z-b-data-1

但是依然失败::

   ● ceph-mon@z-b-data-1.service - Ceph cluster monitor daemon
        Loaded: loaded (/lib/systemd/system/ceph-mon@.service; disabled; vendor preset: enabled)
        Active: failed (Result: exit-code) since Mon 2021-11-22 10:02:32 CST; 4s ago
       Process: 11062 ExecStart=/usr/bin/ceph-mon -f --cluster ${CLUSTER} --id z-b-data-1 --setuser ceph --setgroup ce>
      Main PID: 11062 (code=exited, status=1/FAILURE)
   
   Nov 22 10:02:32 z-b-data-1 systemd[1]: ceph-mon@z-b-data-1.service: Scheduled restart job, restart counter is at 5.
   Nov 22 10:02:32 z-b-data-1 systemd[1]: Stopped Ceph cluster monitor daemon.
   Nov 22 10:02:32 z-b-data-1 systemd[1]: ceph-mon@z-b-data-1.service: Start request repeated too quickly.
   Nov 22 10:02:32 z-b-data-1 systemd[1]: ceph-mon@z-b-data-1.service: Failed with result 'exit-code'.
   Nov 22 10:02:32 z-b-data-1 systemd[1]: Failed to start Ceph cluster monitor daemon.

仔细看了进程命令::

   Process: 10467 ExecStart=/usr/bin/ceph-mon -f --cluster ${CLUSTER} --id z-b-data-1 --setuser ceph --setgroup ceph

奇怪，怎么集群参数 ``--cluster ${CLUSTER}`` 没有传递进去？

检查 ``/var/log/ceph/ceph-mon.z-b-data-1.log`` 发现这个启动监控也需要传递集群名字，否则就出现如下报错::

   2021-11-22T10:50:47.796+0800 7f3215b55540  0 set uid:gid to 64045:64045 (ceph:ceph)
   2021-11-22T10:50:47.796+0800 7f3215b55540 -1 Errors while parsing config file!
   2021-11-22T10:50:47.796+0800 7f3215b55540 -1 parse_file: filesystem error: cannot get file size: No such file or directory [ceph.conf]
   2021-11-22T10:50:47.796+0800 7f3215b55540  0 ceph version 15.2.14 (cd3bb7e87a2f62c1b862ff3fd8b1eec13391a5be) octopus (stable), process ceph-mon, pid 11162
   2021-11-22T10:50:47.796+0800 7f3215b55540 -1 monitor data directory at '/var/lib/ceph/mon/ceph-z-b-data-1' does not exist: have you run 'mkfs'?
   2021-11-22T10:50:58.056+0800 7ffa5983d540  0 set uid:gid to 64045:64045 (ceph:ceph)
   2021-11-22T10:50:58.056+0800 7ffa5983d540 -1 Errors while parsing config file!
   2021-11-22T10:50:58.056+0800 7ffa5983d540 -1 parse_file: filesystem error: cannot get file size: No such file or directory [ceph.conf]
   2021-11-22T10:50:58.056+0800 7ffa5983d540  0 ceph version 15.2.14 (cd3bb7e87a2f62c1b862ff3fd8b1eec13391a5be) octopus (stable), process ceph-mon, pid 11180
   2021-11-22T10:50:58.056+0800 7ffa5983d540 -1 monitor data directory at '/var/lib/ceph/mon/ceph-z-b-data-1' does not exist: have you run 'mkfs'?

参考 `How to start a daemon w/ custom cluster name? <https://www.reddit.com/r/ceph/comments/a0k4p8/how_to_start_a_daemon_w_custom_cluster_name/>`_ 提供了线索和原因，也就是 ``/lib/systemd/system/ceph-mon@.service`` 服务配置可以看到::

   [Service]
   ...
   EnvironmentFile=-/etc/default/ceph
   Environment=CLUSTER=ceph
   ExecStart=/usr/bin/ceph-mon -f --cluster ${CLUSTER} --id %i --setuser ceph --setgroup ceph
   ...

也就是说，如果没有配置 ``/etc/default/ceph`` 则默认会启动集群 ``Environment=CLUSTER=ceph`` ，这就导致无法正确启动我配置的集群 ``zdata`` 

- 创建配置文件 ``/etc/default/ceph`` ，这个配置文件是用来传递环境变量的，可以看到默认已经具备了以下内容::

   # /etc/default/ceph
   #
   # Environment file for ceph daemon systemd unit files.
   #
   
   # Increase tcmalloc cache size
   TCMALLOC_MAX_TOTAL_THREAD_CACHE_BYTES=134217728

在该配置文件中添加一行::

   CLUSTER=zdata

- 然后再次启动::

   sudo systemctl start ceph-mon@z-b-data-1

- 现在检查 ``ceph-mon`` 服务就可以看到正常启动了::

   sudo systemctl status ceph-mon@z-b-data-1

输出显示::

   ● ceph-mon@z-b-data-1.service - Ceph cluster monitor daemon
        Loaded: loaded (/lib/systemd/system/ceph-mon@.service; disabled; vendor preset: enabled)
        Active: active (running) since Mon 2021-11-22 11:23:32 CST; 12s ago
      Main PID: 11510 (ceph-mon)
         Tasks: 26
        Memory: 12.8M
        CGroup: /system.slice/system-ceph\x2dmon.slice/ceph-mon@z-b-data-1.service
                └─11510 /usr/bin/ceph-mon -f --cluster zdata --id z-b-data-1 --setuser ceph --setgroup ceph
   
   Nov 22 11:23:32 z-b-data-1 systemd[1]: Started Ceph cluster monitor daemon.



参考
======

- `Ceph document - Installation (Manual) <http://docs.ceph.com/docs/master/install/>`_
