.. _zdata_ceph:

=========================
私有云数据层 ZData Ceph
=========================

在 :ref:`priv_cloud_infra` 规划中，只有3个虚拟机 ``z-b-data-X`` 承担了整个虚拟化集群的数据存储，构建分布式存储来存放集群的数据。其中， :ref:`ceph` 是主要的虚拟机镜像存储服务。

.. note::

   部署Ceph采用 :ref:`install_ceph_manual` ，本文汇总精要

Ceph部署
=============

- 虚拟机采用 :ref:`priv_kvm` clone方法创建::

   z-b-data-1
   z-b-data-2
   z-b-data-3

- 安装Ceph软件包（在每个节点上执行）::

   sudo apt update && sudo apt install ceph ceph-mds

``z-b-data-1`` 部署Ceph集群初始化
------------------------------------

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
------------------------------------

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

添加OSD
---------------

- 分别登陆3台 ``z-b-data-X`` 虚拟机，执行以下命令准备好磁盘分区 500G ::

   sudo parted /dev/nvme0n1 mklabel gpt
   sudo parted -a optimal /dev/nvme0n1 mkpart primary 0% 500GB

- 登陆第一台服务器 ``z-b-data-1``  创建第一个OSD::

   sudo ceph-volume lvm create --bluestore --data /dev/nvme0n1p1

- 完成后检查OSD::

   sudo ceph-volume lvm list
