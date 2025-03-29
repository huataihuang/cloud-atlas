.. _ceph_iscsi_initator:

===========================
Ceph iSCSI initator客户端
===========================

:ref:`config_ceph_iscsi` 服务端iSCSI target配置完成后，就可以配置Linux的iSCSI initator客户端。需要安装和配置2个客户端:

- ``iscsi-initiator-utils``
- ``device-mapper-multipath``

.. note::

   按照 :ref:`install_mobile_cloud_ceph` ，访问iSCSI Gateway的 :ref:`libvirt` 客户端位于物理笔记本 :ref:`apple_silicon_m1_pro` MacBook Pro 2022，运行的操作系统是 :ref:`asahi_linux` 。也就是，需要在 :ref:`arch_linux` 上实现 iSCSI initator客户端配置。

安装
======

在 :ref:`arch_linux` 上iSCSI客户端(initator)使用 ``open-iscsi`` ，安装:

.. literalinclude:: ceph_iscsi_initator/archlinux_install_open_iscsi_multipath_tools
   :language: bash
   :caption: arch linux安装open-iscsi和multipath-tools软件包

为方便生成配置，安装 ``mpathconf`` 工具(通过 :ref:`archlinux_aur` ):

.. literalinclude:: ceph_iscsi_initator/archlinux_install_mpathconf
   :language: bash
   :caption: arch linux安装mpathconf配置工具

配置
========

- 创建默认 ``/etc/multipath.conf`` 配置并激活 ``multipathd`` 服务:

.. literalinclude:: ceph_iscsi_initator/mpathconf_multipathd
   :language: bash
   :caption: 使用mpathconf工具生成默认/etc/multipath.conf配置并激活multipathd

.. warning::

   这个 ``mpathconf`` 工具( :ref:`shell` )已经落伍了，无法正常工作。我最初没有在意，后来发现 ``multipath -ll`` 是需要依赖这个工具生成的 ``find_multipaths yes`` 配置行。参考 `Understanding mpathconf Utility to configure DM-Multipath <https://www.thegeekdiary.com/understanding-mpathconf-utility-to-configure-dm-multipath/>`_

   我的workround方法是在 :ref:`fedora` 主机(因为这个工具是RedHat主推，Fedora系列一直有这个工具可使用)执行 ``multipath`` 工具生成初始配置，复制过来再做修改

实际生成的 ``/etc/multipath.conf`` 非常简单:

.. literalinclude:: ceph_iscsi_initator/multipath.conf.init
   :language: bash
   :caption: 使用mpathconf工具生成默认/etc/multipath.conf(非常简单)

- 在 ``/etc/multipath.conf`` 配置文件中添加以下内容:

.. literalinclude:: ceph_iscsi_initator/multipath.conf
   :language: bash
   :caption: /etc/multipath.conf添加配置,其中blacklist剔除了本地NVMe硬盘
   :emphasize-lines: 10-24

然后重新启动 ``multipathd`` 服务:

.. literalinclude:: ceph_iscsi_initator/restart_multipathd
   :language: bash
   :caption: 重启multipathd服务

iSCSI发现和设置
=================

- 在 ``/etc/iscsi/iscsid.conf`` 配置中添加 :ref:`config_ceph_iscsi` 时在 ``/etc/ceph/iscsi-gateway.cfg`` 中配置的 CHAP 用户名和密码: 

.. literalinclude:: ceph_iscsi_initator/iscsid.conf
   :language: bash
   :caption: 配置/etc/iscsi/iscsid.conf访问iSCSI target认证(CHAP)

.. warning::

   这里的认证账号是 :ref:`config_ceph_iscsi` 步骤中 **创建一个 initator 名为 iqn.1989-06.io.cloud-atlas:libvirt-client 客户端，并且配置intiator的CHAP名字和密码** 配置的，不是服务器的 ``/etc/ceph/iscsi-gateway.cfg`` 配置中的管理账号。

   我最初搞错了，导致iSCSI initator无法登陆(见下文)。这里已经订正

这里有多种CHAP认证设置，对应于 :ref:`config_ceph_iscsi` 的 ``/etc/ceph/iscsi-gateway.cfg`` 简单认证配置上述内容。详细不同认证方法参考配置文件注释或者 `arch linxu: Open-iSCSI <https://wiki.archlinux.org/title/Open-iSCSI>`_

- 启动并激活 ``iscsid`` 服务:

.. literalinclude:: ceph_iscsi_initator/start_enable_iscsid
   :language: bash
   :caption: 启动并激活iscsid

- 向 iSCSI target节点发送请求，语法如下::

   iscsiadm --mode discovery --portal target_ip --type sendtargets

实践操作如下:

.. literalinclude:: ceph_iscsi_initator/iscsiadm_discovery_target
   :language: bash
   :caption: 使用iscsiadm discovery模式扫描target IP获取访问

输出信息就是iSCSI target，成功的关于节点和target信息会自动保存到本地的initator中:

.. literalinclude:: ceph_iscsi_initator/iscsiadm_discovery_target_output
   :language: bash
   :caption: 使用iscsiadm discovery模式扫描target IP获取的成功信息会保存到本地initator中

- 登陆到 iSCSI target:

.. literalinclude:: ceph_iscsi_initator/iscsiadm_login
   :language: bash
   :caption: iscsiadm登陆到target

iSCSI initator登陆失败排查
---------------------------

这里我遇到一个登陆报错::

   Logging in to [iface: default, target: iqn.2022-12.io.cloud-atlas.iscsi-gw:iscsi-igw, portal: 192.168.8.205,3260]
   Logging in to [iface: default, target: iqn.2022-12.io.cloud-atlas.iscsi-gw:iscsi-igw, portal: 192.168.8.206,3260]
   iscsiadm: Could not login to [iface: default, target: iqn.2022-12.io.cloud-atlas.iscsi-gw:iscsi-igw, portal: 192.168.8.205,3260].
   iscsiadm: initiator reported error (24 - iSCSI login failed due to authorization failure)
   iscsiadm: Could not login to [iface: default, target: iqn.2022-12.io.cloud-atlas.iscsi-gw:iscsi-igw, portal: 192.168.8.206,3260].
   iscsiadm: initiator reported error (24 - iSCSI login failed due to authorization failure)
   iscsiadm: Could not log into all portals

但是我检查服务端 ``/etc/ceph/iscsi-gateway.cfg`` 和客户端 ``/etc/issi/iscsid.conf`` ，显示的认证信息是一致的

从客户端系统日志来看有::

   [Tue Dec 20 14:46:42 2022] scsi host0: iSCSI Initiator over TCP/IP
   [Tue Dec 20 14:46:42 2022] scsi host1: iSCSI Initiator over TCP/IP
   [Tue Dec 20 14:46:42 2022]  connection1:0: detected conn error (1020)
   [Tue Dec 20 14:46:42 2022]  connection2:0: detected conn error (1020)

我仔细核对了 :ref:`config_ceph_iscsi` 配置步骤，发现我搞错了一个概念:

  - 在 ``gwcli`` 交互步骤中， **创建一个 initator 名为 iqn.1989-06.io.cloud-atlas:libvirt-client 客户端，并且配置intiator的CHAP名字和密码** ，这个账号密码才是 iSCSI initator 客户端的登陆密码::

     username=libvirtd password=mypassword12

  - 服务器的 ``/etc/ceph/iscsi-gateway.cfg`` 配置的是Ceph的iSCSI网关的管理密码

所以修订物理主机iSCSI initator的CHAP认证配置，将错误的::

    node.session.auth.username = admin
    node.session.auth.password = admin

修订成::

    node.session.auth.username = libvirtd
    node.session.auth.password = mypassword12

然后重启 ``iscsid`` 再重复上述登陆...

**还是同样报错** 

仔细阅读了 `arch linxu: Open-iSCSI >> Troubleshooting/Client IQN <https://wiki.archlinux.org/title/Open-iSCSI#Client_IQN>`_  提到了服务器端(target)可能需要包含 **客户端** 的 ``/etc/iscsi/initiatorname.iscsi`` 配置中 ``IQN`` 。对啊，我在 :ref:`config_ceph_iscsi`  ``gwcli`` 交互步骤中， **创建一个 initator 名为 iqn.1989-06.io.cloud-atlas:libvirt-client 客户端，并且配置intiator的CHAP名字和密码** 步骤是包含了::

   create iqn.1989-06.io.cloud-atlas:libvirt-client

也就是说服务器端是指定配置了客户端的 IQN

果然，在客户端 ``/etc/iscsi/initiatorname.iscsi`` 指定了客户端的IQN!!!

既然服务器端配置了 ``iqn.1989-06.io.cloud-atlas:libvirt-client`` ，那么也需要对应修订客户端的 ``/etc/iscsi/initiatorname.iscsi`` 内容改为::

   InitiatorName=iqn.1989-06.io.cloud-atlas:libvirt-client

然后重启客户端 ``iscsid`` 再次重复上述登陆...

终于，终于看到了成功登陆的信息:

.. literalinclude:: ceph_iscsi_initator/iscsiadm_login_success
   :language: bash
   :caption: iscsiadm登陆到target成功信息

检查iSCSI initator信息
-------------------------

- 检查运行的会话:

.. literalinclude:: ceph_iscsi_initator/iscsiadm_session
   :language: bash
   :caption: iscsiadm检查当前运行的会话

此时可以看到:

.. literalinclude:: ceph_iscsi_initator/iscsiadm_session_output
   :language: bash
   :caption: iscsiadm检查当前运行的会话输出信息，可以看到iSCSI挂载了2块磁盘 ``sda`` 和 ``sdb``
   :emphasize-lines: 50,97

- 可以使用以下命令验证iSCSI会话:

.. literalinclude:: ceph_iscsi_initator/iscsiadm_session_show
   :language: bash
   :caption: iscsiadm检查当前运行的会话

此时可以看到:

.. literalinclude:: ceph_iscsi_initator/iscsiadm_session_show_output
   :language: bash
   :caption: iscsiadm检查当前运行的会话输出，可以看到有2个会话连接

- 使用 ``fdisk -l`` 也可以看到::

   Disk /dev/sda: 46 GiB, 49392123904 bytes, 96468992 sectors
   Disk model: TCMU device     
   Units: sectors of 1 * 512 = 512 bytes
   Sector size (logical/physical): 512 bytes / 512 bytes
   I/O size (minimum/optimal): 512 bytes / 524288 bytes


   Disk /dev/sdb: 46 GiB, 49392123904 bytes, 96468992 sectors
   Disk model: TCMU device     
   Units: sectors of 1 * 512 = 512 bytes
   Sector size (logical/physical): 512 bytes / 512 bytes
   I/O size (minimum/optimal): 512 bytes / 524288 bytes

Multipath IO设置
====================

前文已经配置了 ``multipath.conf`` 来发现 ``LIO iSCSI`` 设备，所以这里执行:

.. literalinclude:: ceph_iscsi_initator/multipath_ll
   :language: bash
   :caption: multipath -ll检查可用的多路设备

我这里遇到一个问题， ``multipaht -ll`` 没有任何输出，虽然前面已经正确登陆了iSCSI target，显示本地已经挂载了2个磁盘。原因是 :ref:`arch_linux` 上的 ``mpathconf`` 工具初始配置失败导致(见上文)，通过在 :ref:`fedora` 主机生成初始配置并复制到 :ref:`arch_linux` 上重新完成 ``/etc/multipath.conf`` 修复。

这样能够正常工作显示如下:

.. literalinclude:: ceph_iscsi_initator/multipath_ll_output
   :language: bash
   :caption: multipath -ll检查可用的多路设备输出信息

- 现在完成设置，可以退出 target :

.. literalinclude:: ceph_iscsi_initator/iscsiadm_logout
   :language: bash
   :caption: iscsiadm退出target登陆

接下来，终于可以正式开始 :ref:`mobile_cloud_ceph_iscsi_libvirt`
   
参考
======

- `Ceph Block Device » Ceph Block Device 3rd Party Integration » Ceph iSCSI Gateway » Configuring the iSCSI Initiators » iSCSI Initiator for Linux <https://docs.ceph.com/en/latest/rbd/iscsi-initiator-linux/>`_
- `arch linxu: Open-iSCSI <https://wiki.archlinux.org/title/Open-iSCSI>`_
- `Ubuntu: Device Mapper Multipathing - Introduction <https://ubuntu.com/server/docs/device-mapper-multipathing-introduction>`_
