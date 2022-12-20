.. _mobile_cloud_ceph_iscsi_libvirt:

================================
移动云计算Libvirt集成Ceph iSCSI
================================

由于 :ref:`arch_linux` ARM的软件仓库对 ``libvirt-storage-ceph`` 缺失，所以我在部署 :ref:`mobile_cloud_ceph_rbd_libvirt` 遇到较大困难暂时放弃。我调整方案，改为采用 :ref:`ceph_iscsi` 为 :ref:`kvm` 虚拟化服务器集群提供分布式存储。

:ref:`ceph_iscsi` 可以解决客户端(libvirt)无法原生支持Ceph的缺憾，通过输出 :ref:`rados` 块设备(RBD)镜像作为SCSI磁盘来提供了一个高可用(Highly Available, HA) iSCSI target:

.. figure:: ../../../_static/ceph/rbd/ceph_iscsi/ceph_iscsi.png
   :scale: 80

   通过Ceph iSCSI网关将RBD镜像映射为iSCSI target

准备工作
=========

- 为减少iSCSI initiator超时的可能性，调整OSD监控检测的心跳间隔，即修订 ``/etc/ceph/ceph.conf`` 配置:

.. literalinclude:: ../../rbd/ceph_iscsi/prepare_ceph_iscsi/ceph.conf
   :language: bash
   :caption: /etc/ceph/ceph.conf 修订OSD心跳参数，降低间隔值减少iSCSI initiator启动超时可能性

- 从一个Ceph Monitor (ceph-mon)节点更新运行状态:

.. literalinclude:: ../../rbd/ceph_iscsi/prepare_ceph_iscsi/ceph_update_osd_heartbeat_config
   :language: bash
   :caption: 选择一个ceph-mon节点发起更新监控OSD心跳运行配置的状态，降低间隔值减少iSCSI initiator启动超时可能性

- 在每个OSD节点 上更新运行状态:

.. literalinclude:: ../../rbd/ceph_iscsi/prepare_ceph_iscsi/ceph_update_osd_daemon_heartbeat_running_state
   :language: bash
   :caption: 在每个ceph-osd节点发起更新OSD服务进程心跳运行状态，降低间隔值减少iSCSI initiator启动超时可能性

部署 :ref:`ceph_iscsi`
=========================

:ref:`ceph_iscsi` 部署比预想要复杂，虽然客户端可以采用标准的iSCSI initator访问，但是服务端iSCSI和客户端initator需要配置完成以下步骤:

- :ref:`prepare_ceph_iscsi`
- :ref:`install_ceph_iscsi`
- :ref:`config_ceph_iscsi`
- :ref:`ceph_iscsi_initator`

libvirt支持iSCSI方式
======================

libvirt有两种方式使用iSCSI:

- iSCSI pool: 使用iSCSI target来存储卷，所有卷需要在iSCSI服务器上预先分配
- iSCSI direct pool: 是iSCSI pool的变体，不使用iscsiadm，而是使用 ``libscsi`` ，需要提供 host , target IQN 和 initiator IQN

libvirt配置iSCSI存储池(iSCSI pool)
=====================================

``target path`` 决定了libvirt如何输出(expose)存储池的的河北路径: ``/dev/sda`` ``/dev/sdb`` 等路径不是好多选择，因为这些路径在启动时不稳定，或者在集群中的机器上不稳定(名称由内核按照先到先得的原则分配)。强烈建议使用 ``/dev/disk/by-path`` ，除非你知道自己在做什么(显然大多数情况你不知道^_^)。这种 ``/dev/disk/by-path`` 的路径名可以获得稳定的命名方案。

``host name`` 是iSCSI服务器的FQDN

``Source Path`` 是创建iSCSI target时候获得的IQN，我的案例是 ``iqn.2022-12.io.cloud-atlas.iscsi-gw:iscsi-igw`` ( 见 :ref:`ceph_iscsi_initator` 扫描 :ref:`config_ceph_iscsi` 输出的iSCSI Node )

- 创建一个 ``ceph_iscsi_libvirt.xml`` 配置:

.. literalinclude:: mobile_cloud_ceph_iscsi_libvirt/ceph_iscsi_libvirt.xml
   :language: xml
   :caption: 定义iSCSI pool: ceph_iscsi_libvirt.xml

- 使用 ``virsh`` 定义iSCSI存储池:

.. literalinclude:: mobile_cloud_ceph_iscsi_libvirt/virsh_pool_define_iscsi_pool
   :language: xml
   :caption: 使用virsh命令通过ceph_iscsi_libvirt.xml定义创建存储池

提示信息::

   Pool images_iscsi defined from ceph_iscsi_libvirt.xml

- 检查存储池 ``images_iscsi`` 尚未激活:

.. literalinclude:: mobile_cloud_ceph_iscsi_libvirt/virsh_pool_list
   :language: xml
   :caption: 使用virsh pool-list检查存储池，可以看到images_iscsi尚未激活

显示输出::

    Name           State      Autostart
   --------------------------------------
    ...
    images_iscsi   inactive   no

- 参考 `Secret XML format: Usage type "iscsi" <https://libvirt.org/formatsecret.html#usage-type-iscsi>`_ 在 ``ceph_iscsi_libvirt.xml`` 中定义了 ``<secret usage='libvirtiscsi'/>`` 这个secret，现在就需要创建这个secret，然后再给这个secret插入密码值(你可以认为这是一个分离的密码本):

.. literalinclude:: mobile_cloud_ceph_iscsi_libvirt/ceph_iscsi_libvirt_secret.xml
   :language: xml
   :caption: 定义iSCSI pool所使用的secret "libvirtiscsi"

- 执行以下命令创建secret:

.. literalinclude:: mobile_cloud_ceph_iscsi_libvirt/virsh_secret_define
   :language: xml
   :caption: 使用virsh secret-define定义名为 "libvirtiscsi" 的secret，注意此时这个secret是空定义(没有密码)

此时会提示这个secret对应的UUID，例如::

   ca36b1f9-6299-4b69-a3c9-c44e1349c66d

- 然后向secret插入密码值:

.. literalinclude:: mobile_cloud_ceph_iscsi_libvirt/virsh_secret_set_value
   :language: xml
   :caption: 使用virsh secret-set-value向secret插入密码

在交互模式下输入密钥，则提示secret的值设置成功::

   Enter new value for secret:
   Secret value set

终于，我们现在完成了认证密钥设置，可以启动存储池了

- 激活存储池 ``images_iscsi`` 并设置为自动启动:

.. literalinclude:: mobile_cloud_ceph_iscsi_libvirt/virsh_pool_start
   :language: xml
   :caption: 使用virsh pool-start启动images_iscsi存储池

这里可能会提示错误::

   error: Failed to start pool images_iscsi
   error: internal error: Child process (/usr/bin/iscsiadm --mode node --portal a-b-data-2.dev.cloud-atlas.io:3260,1 --targetname iqn.2022-12.io.cloud-atlas.iscsi-gw:iscsi-igw --login) unexpected exit status 15: iscsiadm: Could not login to [iface: default, target: iqn.2022-12.io.cloud-atlas.iscsi-gw:iscsi-igw, portal: a-b-data-2.dev.cloud-atlas.io,3260].
   iscsiadm: initiator reported error (15 - session exists)
   iscsiadm: Could not log into all portals

原因是之前的会话没有退出，需要先退出。

但是我发现奇怪，我执行了:

.. literalinclude:: ../../rbd/ceph_iscsi/ceph_iscsi_initator/iscsiadm_logout
   :language: bash
   :caption: iscsiadm退出target登陆

并且重复执行上述logout命令，已经明确看到::

   iscsiadm: No matching sessions found

说明没有当前会话

但是再次启动 ``images_iscsi`` 存储池还是同样报错，而再次执行 ``iscsiadm`` logout，发现确实又出现了会话。这说明执行启动存储确实发起了iscsi登陆会话。

我考虑之前实践 :ref:`ceph_iscsi_initator` 配置了initator，本地似乎缓存，可能需要清理

待续...

libvirt配置iSCSI直接存储池(iSCSI direct pool)
================================================

libvirt通过 ``libiscsi`` 来构建iSCSI direct pool 访问iSCSI target，配置需要:

- host
- target IQN
- initator IQN

iSCSI direct pool的支持是libvirt v4.7.0开始支持的( iSCSI pool 则是早期 v0.4.1 开始支持 )

- 创建一个 ``ceph_direct_iscsi_libvirt.xml`` 配置:

.. literalinclude:: mobile_cloud_ceph_iscsi_libvirt/ceph_direct_iscsi_libvirt.xml
   :language: xml
   :caption: 定义iSCSI direct pool

multipath(未实践)
=====================

.. note::

   `openstack/cinder-specs/specs/kilo/iscsi-multipath-enhancment.rst <https://github.com/openstack/cinder-specs/blob/master/specs/kilo/iscsi-multipath-enhancement.rst>`_ 介绍了 nova-compute 支持iSCSI卷数据路径的multipath。但我还没有找到 libvirt 采用 multipath 的参考资料，后续再实践

   从 `libvirt storage: Multipath pool <ttps://libvirt.org/storage.html#multipath-pool>`_ 来看，仅提供一个本地挂载的Multipath pool，主要实现应该是依赖主机底层的multipath来实现的。

参考
=======

- `Provisioning KVM virtual machines on iSCSI the hard way (Part 2 of 2) <https://www.berrange.com/posts/2010/05/05/provisioning-kvm-virtual-machines-on-iscsi-the-hard-way-part-2-of-2/>`_ 步骤有些简略
- `libvirt: Secret XML format set secret values <https://libvirt.org/formatsecret.html#setting-secret-values-in-virsh>`_
- `Ceph Block Device » Ceph Block Device 3rd Party Integration » Ceph iSCSI Gateway » iSCSI Gateway Requirements <https://docs.ceph.com/en/quincy/rbd/iscsi-requirements/>`_
- `libvirt storage: iSCSI direct pool <https://libvirt.org/storage.html#iscsi-direct-pool>`_
- `Creating an iSCSI-based Storage Pool with virsh <https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/6/html/virtualization_administration_guide/sect-virtualization-storage_pools-creating-iscsi-adding_target_virsh>`_
