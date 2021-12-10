.. _zdata_ceph:

=========================
私有云数据层 ZData Ceph
=========================

在 :ref:`priv_cloud_infra` 规划中，只有3个虚拟机 ``z-b-data-X`` 承担了整个虚拟化集群的数据存储，构建分布式存储来存放集群的数据。其中， :ref:`ceph` 是主要的虚拟机镜像存储服务。

.. note::

   部署Ceph采用 :ref:`install_ceph_manual` ，本文汇总精要

- 虚拟机采用 :ref:`priv_kvm` clone方法创建::

   z-b-data-1
   z-b-data-2
   z-b-data-3

- 安装Ceph软件包（在每个节点上执行）::

   sudo apt update && sudo apt install ceph ceph-mds

``z-b-data-1`` 部署Ceph集群初始化
===================================

.. note::

   首先 :ref:`install_ceph_mon` ，提供Ceph bootstrap

- 生成一个unique ID，用于fsid::

   cat /proc/sys/kernel/random/uuid

- 按照生成的uuid，配置 ``/etc/ceph/ceph.conf`` :

.. literalinclude:: ../../ceph/deploy/install_ceph_manual/install_ceph_mon/ceph.conf
   :language: bash
   :linenos:
   :caption: /etc/ceph/ceph.conf

- 创建集群的keyring和monitor密钥::

   sudo ceph-authtool --create-keyring /tmp/ceph.mon.keyring --gen-key -n mon. --cap mon 'allow *'

- 生成管理员keyring，生成 ``client.admin`` 用户并添加用户到keyring::

   sudo ceph-authtool --create-keyring /etc/ceph/ceph.client.admin.keyring --gen-key -n client.admin --cap mon 'allow *' --cap osd 'allow *' --cap mds 'allow *' --cap mgr 'allow *'

- 生成 ``bootstrap-osd`` keyring，生成 ``client.bootstrap-osd`` 用户并添加用户到keyring::

   sudo ceph-authtool --create-keyring /var/lib/ceph/bootstrap-osd/ceph.keyring --gen-key -n client.bootstrap-osd --cap mon 'profile bootstrap-osd' --cap mgr 'allow r'

- 将生成的key添加到 ``ceph.mon.keyring`` ::

   sudo ceph-authtool /tmp/ceph.mon.keyring --import-keyring /etc/ceph/ceph.client.admin.keyring
   sudo ceph-authtool /tmp/ceph.mon.keyring --import-keyring /var/lib/ceph/bootstrap-osd/ceph.keyring

- 更改 ``ceph.mon.keyring`` 的owner::

   sudo chown ceph:ceph /tmp/ceph.mon.keyring

- 使用主机名、主机IP和FSID生成一个监控映射，保存为 ``/tmp/monmap`` ::

   monmaptool --create --add z-b-data-1 192.168.6.204 --fsid 0e6c8b6f-0d32-4cdb-a45d-85f8c7997c17 /tmp/monmap

- 创建一个监控主机到默认数据目录::

   sudo -u ceph mkdir /var/lib/ceph/mon/zdata-z-b-data-1

- 发布监控服务的monitor的map和keyring::

   sudo -u ceph ceph-mon --cluster ceph --mkfs -i z-b-data-1 --monmap /tmp/monmap --keyring /tmp/ceph.mon.keyring

- 启动monitor(s)::

   sudo systemctl start ceph-mon@z-b-data-1

- 检查集群状态::

   sudo ceph -s

- 处理WARN::

   sudo ceph config set mon mon_warn_on_insecure_global_id_reclaim_allowed false
   sudo ceph mon enable-msgr2

``z-b-data-1`` 部署mgr
==========================

- 创建服务的认证key::

   sudo mkdir /var/lib/ceph/mgr/ceph-z-b-data-1
   sudo ceph auth get-or-create mgr.z-b-data-1 mon 'allow profile mgr' osd 'allow *' mds 'allow *' | sudo tee /var/lib/ceph/mgr/ceph-z-b-data-1/keyring

- 修订文件属性::

   sudo chown ceph:ceph /var/lib/ceph/mgr/ceph-z-b-data-1/keyring
   sudo chmod 600 /var/lib/ceph/mgr/ceph-z-b-data-1/keyring

- 启动::

   sudo systemctl start ceph-mgr@z-b-data-1

- 安装dashboard插件::

   sudo apt install ceph-mgr-dashboard

- 检查模块::

   sudo ceph mgr module ls

- 激活模块::

   sudo ceph mgr module enable dashboard

- 安装dashboard证书::

   sudo ceph dashboard create-self-signed-cert

- 为了安全部署和移除警告，需要通过一个签名证书(certificate authority, CA)来实现::

   openssl req -new -nodes -x509 \
     -subj "/O=IT/CN=ceph-mgr-dashboard" -days 3650 \
     -keyout dashboard.key -out dashboard.crt -extensions v3_ca

- 过这个CA来签名 ``dashboard.crt`` ::

   sudo ceph dashboard set-ssl-certificate z-b-data-1 -i dashboard.crt
   sudo ceph dashboard set-ssl-certificate-key z-b-data-1 -i dashboard.key

- 配置完成后检查服务::

   sudo ceph mgr services

输出类似::

   {
       "dashboard": "https://z-b-data-1:8443/"
   }

- 使用浏览器访问 https://z-b-data-1:8443/ 就可以看到Ceph的管理界面

- 创建一个管理员角色(密码存放在一个文件 ``huatai`` 中)::

   sudo ceph dashboard ac-user-create huatai -i huatai administrator

现在可以用创建的账号登陆Ceph管理平台了

添加第一个OSD
==============

- 登陆 ``z-b-data-1`` 虚拟机，执行以下命令准备好磁盘分区 500G ::

   sudo parted /dev/nvme0n1 mklabel gpt
   sudo parted -a optimal /dev/nvme0n1 mkpart primary 0% 500GB

- 登陆第一台服务器 ``z-b-data-1``  创建第一个OSD::

   sudo ceph-volume lvm create --bluestore --data /dev/nvme0n1p1

.. note::

   ``ceph-volume lvm create`` 会自动完成OSD磁盘初始化，OSD服务启动和systemd配置，所有操作都自动完成，非常简便，无需进一步设置。

- 完成后检查OSD::

   sudo ceph-volume lvm list

- 检查集群状态::

   sudo ceph -s

添加MON(配置3个)
===================

为满足冗余，在 ``z-b-data-2`` 和 ``z-b-data-3`` 上也部署 ``ceph-mon``

- 在主机 ``z-b-data-1`` 上执行以下命令获取monitor map::

   sudo ceph mon getmap -o /tmp/monmap

注意，此时从集群中获得的 ``monmap`` 只包含了第一台服务器 ``z-b-data-1`` ，我们还需要添加增加的 ``z-b-data-2`` 和 ``z-b-data-3`` ::

   monmaptool --add z-b-data-2 192.168.6.205 --fsid 0e6c8b6f-0d32-4cdb-a45d-85f8c7997c17 /tmp/monmap
   monmaptool --add z-b-data-3 192.168.6.206 --fsid 0e6c8b6f-0d32-4cdb-a45d-85f8c7997c17 /tmp/monmap

- 停止 ``z-b-data-1`` 上 ``ceph-mon`` 并更新 monitor map::

   sudo systemctl stop ceph-mon@z-b-data-1
   sudo ceph-mon -i z-b-data-1 --inject-monmap /tmp/monmap

- 登陆需要部署monitor的服务器，执行以下命令创建mon默认目录::

   mon-id="z-b-data-2"
   sudo mkdir /var/lib/ceph/mon/ceph-${mon-id}

- 将 192.168.6.204 ( ``z-b-data-1``  ) 管理密钥复制到需要部署 ``ceph-mon`` 的配置目录下::

   scp 192.168.6.204:/etc/ceph/ceph.client.admin.keyring /etc/ceph/
   scp 192.168.6.204:/etc/ceph/ceph.conf /etc/ceph/

- 在主机 ``z-b-data-2`` 上执行以下命令获取monitors的keyring::

   sudo ceph auth get mon. -o /tmp/ceph.mon.keyring

- 在主机 ``z-b-data-2`` 上执行以下命令获取monitor map::

   sudo ceph mon getmap -o /tmp/monmap

- 在主机 ``z-b-data-2`` 准备monitor的数据目录，这里必须指定monitor map路径，这样才能够获取监控的quorum信息以及 ``fsid`` ，而且还需要提供 monitor keyring的路径::

   sudo ceph-mon --mkfs -i z-b-data-2 --monmap /tmp/monmap --keyring /tmp/ceph.mon.keyring

 - 启动服务::

    sudo systemctl start ceph-mon@z-b-data-2
    sudo systemctl enable ceph-mon@z-b-data-2

- 在 ``z-b-data-3`` 上完成和 ``z-b-data-2`` 相同的操作完成 ``ceph-mon`` 部署

- 检查集群状态::

   sudo ceph -s

增加OSD(每个节点一个,共3个)
===============================

现在Ceph集群只有 ``z-b-data-1`` 上有一个OSD运行，不能满足3副本稳定要求。所以，在 ``z-b-data-2`` 和 ``z-b-data-3`` 上各部署一个 OSD，实现3副本

- 在两台 ``z-b-data-2`` 和 ``z-b-data-3`` 复制配置和keyring (前面扩容 ``ceph-mon`` 已经做过)::

   scp 192.168.6.204:/etc/ceph/ceph.client.admin.keyring /etc/ceph/
   scp 192.168.6.204:/etc/ceph/ceph.conf /etc/ceph/

- 在 ``z-b-data-2`` 和 ``z-b-data-3`` 准备磁盘::

   sudo parted /dev/nvme0n1 mklabel gpt
   sudo parted -a optimal /dev/nvme0n1 mkpart primary 0% 500GB

- 将 ``z-b-data-1`` (192.68.6.204) ``/var/lib/ceph/bootstrap-osd/ceph.keyring`` 复制到部署OSD的服务器对应目录::

   scp 192.168.6.204:/var/lib/ceph/bootstrap-osd/ceph.keyring /var/lib/ceph/bootstrap-osd/

- 在  ``z-b-data-2`` 和 ``z-b-data-3`` 上创建OSD磁盘卷::

   sudo ceph-volume lvm create --bluestore --data /dev/nvme0n1p1

- 此时检查ceph集群状态，可以看到由于满足了3副本要求，整个集群进入稳定健康状态::

   sudo ceph -s

部署MDS(用于虚拟化RBD)
=========================

部署 ``ceph-mds`` 服务，对外提供POSIX兼容元数据

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
   sudo systemctl enable ceph-mds@${id}
   sudo systemctl status ceph-mds@${id}

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

- 检查状态::

   sudo ceph -s

   sudo ceph fs dump

