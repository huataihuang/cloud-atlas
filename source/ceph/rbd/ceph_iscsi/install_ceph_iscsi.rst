.. _install_ceph_iscsi:

==================
安装Ceph iSCSI
==================

iSCSI targets
=================

在OpenStack早期版本，对Ceph集群的块存储访问仅采用 :ref:`qemu` 和 ``librbd`` ，不过从Ceph Luminous版本开始，块级别访问正在扩展亦提供标准的iSCSI访问，这样可以提供更广泛的平台支持。

- 运行Ceph iSCSI网关的服务器必须满足: :ref:`redhat_linux` Enterprise Linux / CentOS 7.5 或更新版本，Linux :ref:`kernel` 4.16 或更新版本
- Ceph iSCSI网关可以和OSD节点部署在一起，也可以位于专用节点
- 对于高负载Ceph集群，可以采用iSCSI前端流量和Ceph后端流量分布在各自独立的网络子网(接口)

可以使用 :ref:`ansible` 或者像我这里采用命令行部署iSCSI网关

部署
=======

Ceph iSCSI网关即是iSCSI target(服务器)又是Ceph客户端: 你可以理解成Ceph :ref:`rbd` 接口和iSCSI标准的 "转换器" 。所以 Ceph iSCSI网关可以运行在一个独立节点，或者就和OSD部署在一起。

我在 :ref:`install_mobile_cloud_ceph` 的3节点Ceph集群，其中节点1已经部署了 :ref:`ceph_mgr` 所以考虑到高可用，规划在节点2和节点3各部署一个 ``ceph-iscsi`` 网关

前提条件
----------

- 已经完成Ceph Luminous或更新版本的Ceph集群部署
- Ceph iSCSI网关服务器是 :ref:`redhat_linux` Enterprise Linux / CentOS 7.5或更高，内核 4.16 以上版本 ( :ref:`install_mobile_cloud_ceph` 采用了 :ref:`fedora` 37满足要求 )

内核参数需要支持::

   CONFIG_TARGET_CORE=m
   CONFIG_TCM_USER2=m
   CONFIG_ISCSI_TARGET=m

- 在 Ceph iSCSI网关服务器节点安装以下软件包:

  - targetcli-2.1.fb47 or newer package
  - python-rtslib-2.1.fb68 or newer package
  - tcmu-runner-1.4.0 or newer package
  - ceph-iscsi-3.2 or newer package

准备工作包括，在 :ref:`install_mobile_cloud_ceph` 的节点2和3上先完成上述准备工作的软件:

.. literalinclude:: install_ceph_iscsi/prepare_ceph_iscsi_install_software
   :language: bash
   :caption: 在ceph-iscsi网关节点上先安装依赖软件包

.. note::

   ``targetcli`` 是配置iSCSI的Linux-IO(LIO)内核target子系统工具

   ``ceph-iscsi`` 是一个纯 :ref:`python` 的工具， `GitHub ceph/ceph-iscsi <https://github.com/ceph/ceph-iscsi>`_ 官方只提供RHEL 7/8的rpm包，对于Fedora系统则没有提供。不过，可以手工安装，见下文

- 将Ceph集群的 ``/etc/ceph/${CLUSTER}.conf`` 配置文件复制到 Ceph iSCSI网关节点(重要步骤)
- 安装 ``Ceph命令行工具`` (我理解是需要安装 ``ceph`` 组件)
- 关闭防火墙或者开启 ``3260`` 和 ``5000`` 端口( 我的惨痛教训 :ref:`debug_ceph_authenticate_time_out` )
- 创建一个新的或者使用一个现有的 :ref:`rados` 块设备( :ref:`rbd` )

软件仓库安装
------------

考虑到 ``ceph-iscsi`` 是和架构无关的纯 :ref:`pyhon` 软件，所以我在 :ref:`install_mobile_cloud_ceph` 采用的 :ref:`fedora` 理论上也应该可以采用。不过，参考 `Fedora and Red Hat Enterprise Linux <https://docs.fedoraproject.org/en-US/quick-docs/fedora-and-red-hat-enterprise-linux/`_ 可以看到 Red Hat Enterprise Linux 8 是2019年5月7日推出，相当于 Fedora 28，所以版本比我当前使用的 :ref:`fedora` 37要落后很多。

- 下载 ``ceph-iscsi`` 软件仓库配置并安装 ``ceph-iscsi`` ::

   curl https://download.ceph.com/ceph-iscsi/latest/rpm/el8/ceph-iscsi.repo -o /etc/yum.repos.d/ceph-iscsi.repo
   sudo dnf install ceph-iscsi

这里会提示错误::

    Error: 
     Problem: conflicting requests
      - nothing provides python(abi) = 3.6 needed by ceph-iscsi-3.5-1.el8.noarch
    (try to add '--skip-broken' to skip uninstallable packages) 

.. note::

   由于无法直接在 :ref:`fedora` ARM上安装针对CentOS 8的rpm包，所以改为手工安装，见下文

手工安装
----------

tcmu-runner
~~~~~~~~~~~~

- :ref:`fedora` 提供了 ``temu-runner`` 软件包，所以我已经在上文中安装。 `Manual ceph-iscsi Installation <https://docs.ceph.com/en/latest/rbd/iscsi-target-cli-manual-install/>`_ 提供了从github下载代码安装方法

- 启动和激活 ``temu-runner`` 服务:

.. literalinclude:: install_ceph_iscsi/enable_run_tcmu_runner
   :language: bash
   :caption: 激活和运行 tcmu-runner

rtslib-fb
~~~~~~~~~~~

- 安装 ``rtslib-fb`` :

.. literalinclude:: install_ceph_iscsi/install_rtslib_fb
   :language: bash
   :caption: 安装 rtslib-fb

这里有一个报错，依赖需要安装 ``pyparsing<3.0,>=2.0.2`` (系统安装仓库版本是 ``python3-pyparsing-3.0.9-2.fc37.noarch`` 版本过高)，但是安装过程从 https://pypi.org/simple/ 下载超时。后来我发现是本地物理主机开启了 :ref:`wireguard` ，关闭后解决(why，都是 :ref:`libvirt_nat_network` 访问外网)

configshell-fb
~~~~~~~~~~~~~~~~

- 安装 ``configshell-fb`` :

.. literalinclude:: install_ceph_iscsi/install_configshell_fb
   :language: bash
   :caption: 安装 configshell-fb

targetcli-fb
~~~~~~~~~~~~~~

- 安装 ``targetcli-fb`` :

.. literalinclude:: install_ceph_iscsi/install_targetcli_fb
   :language: bash
   :caption: 安装 targetcli-fb

ceph-iscsi
~~~~~~~~~~~~

- 安装 ``ceph-iscsi`` :

.. literalinclude:: install_ceph_iscsi/install_ceph_iscsi
   :language: bash
   :caption: 安装 ceph-iscsi

- 激活和启动服务:

.. literalinclude:: install_ceph_iscsi/enable_start_ceph_iscsi
   :language: bash
   :caption: 激活和启动 ceph-iscsi

安装到这里就完成了，下面可以开始配置

参考
=======

- `Ceph Block Device » Ceph Block Device 3rd Party Integration » Ceph iSCSI Gateway <https://docs.ceph.com/en/quincy/rbd/iscsi-overview/>`_
- `Manual ceph-iscsi Installation <https://docs.ceph.com/en/latest/rbd/iscsi-target-cli-manual-install/>`_
