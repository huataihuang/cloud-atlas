.. _deploy_sles12sp5_gluster11_client:

======================================
在SLES 12 sp5中部署GlusterFS 11客户端
======================================

部署方案
=========

:ref:`suse_linux` 作为主要的企业级Linux发行版，不仅在欧洲应用广泛，也在中国的金融、运营商和电力等关键领域得到采用。本文采用模拟多磁盘服务器构建GlusterFS集群:

- :ref:`install_opensus_leap` 作为基础操作系统( 运行在 :ref:`priv_cloud_infra` )

在生产系统中，需要平衡不同操作系统的服务端和客户端搭配:

- 服务器端采用RHEL/CentOS7 :ref:`deploy_centos7_gluster11` ，客户端采用 :ref:`suse_linux` SLES 12 SP5

.. note::

   本文是在 :ref:`deploy_sles15sp4_gluster11_client` 基础上重新演练，原因是项目底层操作系统变更为 :ref:`suse_linux` SLES 12 SP5 。可能部署会有不同或差异，待续...

准备
============

- 安装 glusterfs 客户端时候会安装操作系统依赖软件包，所以挂载安装光盘镜像:

.. literalinclude:: ../../../linux/suse_linux/zypper/zypper_add_sles15sp4_iso
   :caption: 安装 glusterfs 客户端需要安装操作系统依然软件包，所以挂载SLES 15 SP4光盘镜像

- 从 `opensuse.org 软件仓库 glusterfs SLES15SP4-11 / 15.4 / x86_64 <http://download.opensuse.org/repositories/home:/glusterfs:/SLES15SP4-11/15.4/x86_64/>`_ 下载安装包，同样通过 :ref:`gluster11_rpm_createrepo` 添加到仓库路径中

使用 :ref:`wget` 镜像下载rpm包:

.. literalinclude:: deploy_sles15sp4_gluster11_client/wget_mirror_gluster_sles15sp4
   :caption: 使用 :ref:`wget` 镜像网站方式下载GlusterFS 11 for SLES 15SP4

将下载后的 GlusterFS 11 for SLES 15SP4 RPM包全部移动到 ``gluster11/glusterfs/11.0/SLES/15SP4/`` 目录下，然后执行 :ref:`createrepo` :

.. literalinclude:: deploy_sles15sp4_gluster11_client/createrepo_gluster_sles15sp4
   :caption: 使用 :ref:`createrepo` 为 下载GlusterFS 11 for SLES 15SP4 rpm包创建仓库

- 将构建好的 ``gluster11`` 软件仓库加入到SUSE的YaST中, 配置 ``/etc/zypp/repos.d/glusterfs-11_sles15sp4.repo`` :

.. literalinclude:: ../../../linux/suse_linux/zypper/glusterfs-11_sles15sp4.repo
   :caption: ``/etc/zypp/repos.d/glusterfs-11_sles15sp4.repo`` 配置

安装
======

- :ref:`suse_linux` 安装GlusterFS客户端和服务器都使用相同软件包 ``glusterfs`` :

.. literalinclude:: deploy_sles15sp4_gluster11_client/zypper_install_glusterfs
   :caption: 在 SLES 15 sp4中安装GlusterFS软件包

如果解决了依赖问题，则正确的安装提示如下:

.. literalinclude:: deploy_sles15sp4_gluster11_client/zypper_install_glusterfs_output
   :caption: 在 SLES 15 sp4中安装GlusterFS软件包以及依赖软件包

.. note::

   对于直接从 `openSUSE Oss x86_64 Repository <https://opensuse.pkgs.org/15.4/opensuse-oss-x86_64/>`_ 下载的rpm软件包，这些软件包是有签名的，如果没有导入对应Oss仓库的公钥，则会提示错误::

      Repository SELS-15.4 - Gluster 11 does not define additional 'gpgkey=' URLs.
      glusterfs-11.0-150400.105.2.x86_64 (SELS-15.4 - Gluster 11): Signature verification failed [4-Signatures public key is not available]
      Abort, retry, ignore? [a/r/i] (a):

   这输入 ``i`` 忽略，以便继续安装

- 安装完成后执行 ``gluster --version`` 检查安装版本，确认已经安装成功

异常排查
-----------

.. note::

   GlusterFS for :ref:`suse_linux` 的依赖软件包是由 `openSUSE Oss x86_64 Repository <https://opensuse.pkgs.org/15.4/opensuse-oss-x86_64/>`_ 提供。所以如果服务器能够联网，最好直接添加这个仓库以便进行安装。我的实践是因为服务器无法联网，所以采用手工下载软件包方式添加到 :ref:`createrepo` 仓库。

- 首先遇到的依赖报错:

.. literalinclude:: deploy_sles15sp4_gluster11_client/zypper_install_glusterfs_error
   :caption: 在 SLES 15 sp4中安装GlusterFS软件包缺少 'libtcmalloc_minimal.so.4()(64bit)'
   :emphasize-lines: 5

需要安装 ``libtcmalloc4`` ，在 `pkgs.org libtcmalloc_minimal.so.4()(64bit) <https://pkgs.org/download/libtcmalloc_minimal.so.4()(64bit)>`_ 可以找到位于 `openSUSE Oss x86_64 Repository <https://opensuse.pkgs.org/15.4/opensuse-oss-x86_64/>`_ (是由 openSUSE Leap 15.4 发行版提供) 。下载链接是 `libtcmalloc4-2.5-4.12.x86_64.rpm.html <https://opensuse.pkgs.org/15.4/opensuse-oss-x86_64/libtcmalloc4-2.5-4.12.x86_64.rpm.html>`_

依赖清单::

   libtcmalloc_minimal.so.4()(64bit)  libtcmalloc4
   python3-requests
   python3-py
   python3-certifi
   python3-idna
   python3-urllib3
   libunwind.so.8()(64bit)  libunwind
   python3-pyOpenSSL
   python3-cryptography
   python3-cffi
   python3-asn1crypto
   python3-pyasn1
   python3-pycparser

都可以从 `openSUSE Oss x86_64 Repository <https://opensuse.pkgs.org/15.4/opensuse-oss-x86_64/>`_ 搜索下载

完整处理脚本:

.. literalinclude:: deploy_sles15sp4_gluster11_client/download_gluster_11_dependent_rpm
   :caption: 下载安装 SLES 15 sp4中安装GlusterFS 所需依赖包

配置
=========

SUSE平台的GlusterFS客户端配置和 :ref:`deploy_centos7_gluster11` 完全一致，只需要配置 ``/etc/fstab`` 挂载点即可( 服务器端采用 :ref:`deploy_centos7_gluster11` )

- 配置 ``/etc/fstab`` :

.. literalinclude:: ../centos/deploy_centos7_gluster11/gluster_fuse_fstab
   :caption: GlusterFS客户端的 ``/etc/fstab``

- 挂载存储卷:

.. literalinclude:: ../centos/deploy_centos7_gluster11/mount_gluster
   :caption: 挂载GlusterFS卷

参考
=====

- `GlusterFS : Client Setting <https://www.server-world.info/en/note?os=SUSE_Linux_Enterprise_15&p=glusterfs&f=3>`_
- `GlusterFS : Install <https://www.server-world.info/en/note?os=SUSE_Linux_Enterprise_15&p=glusterfs&f=1>`_
