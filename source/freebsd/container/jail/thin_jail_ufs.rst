.. _thin_jail_ufs:

=================================
在UFS文件系统上构建Thin Jail
=================================

我因为 :ref:`zfs` 非常方便管理和使用，所以大多数FreeBSD和Linux部署时都会采用ZFS作为数据存储文件系统。在 :ref:`thin_jail` 甚至 :ref:`vnet_thin_jail` 也采用ZFS来实践构建。

不过，也有一些环境采用了传统的UFS文件系统，例如，我在阿里云租用的VM，阿里云默认提供的FreeBSD镜像就是采用UFS文件系统。我需要为 :ref:`freebsd_update` 构建一个反向代理缓存服务器，考虑在租用的VM中构建一个隔离的Thin Jail来运行 :ref:`nginx_reverse_proxy` 。这里记录准备工作，构建一个UFS上的Thin Jail。

主机激活 jail
===============

- 执行以下命令配置在系统启动时启动 ``Jail`` :

.. literalinclude:: vnet_thin_jail/enable
   :caption: 激活jail

Jail目录树
=============

- 准备环境变量(方便后续操作);

.. literalinclude:: thin_jail_ufs/env
   :caption: 准备jail相关环境变量

- 创建RELEASE-base模版目录:

.. literalinclude:: thin_jail_ufs/jail_template
   :caption: 在UFS中创建模板数据集

- 和 :ref:`thick_jail` 一样下载用户空间:

.. literalinclude:: vnet_thin_jail/fetch
   :caption: 下载用户空间

- 将下载内容解压缩到模版目录:

.. literalinclude:: vnet_thin_jail/tar
   :caption: 解压缩

- 将时区和DNS配置复制到模板目录:

.. literalinclude:: vnet_thin_jail/cp
   :caption: 将时区和DNS配置复制到模板目录

- 更新模板补丁:

.. literalinclude:: vnet_thin_jail/update
   :caption: 更新模板补丁

- 创建一个 ``skeleton`` (**骨骼**)，这里是UFS，所以直接创建目录

.. literalinclude:: thin_jail_ufs/create_skeleton
   :caption: 创建 ``skeleton`` (骨骼)

- 执行以下命令，将特定目录移入 ``skeleton`` 数据集，并构建 ``base`` 和 ``skeleton`` 必要目录的软连接关系

.. literalinclude:: vnet_thin_jail/skeleton_link
   :caption: 特定目录移入 ``skeleton`` 数据集

- 执行以下命令创建软连接:

.. literalinclude:: vnet_thin_jail/link
   :caption: 创建软连接

- **在host上执行** 修复 ``/etc/ssl/certs`` 目录下证书文件软链接

.. literalinclude:: vnet_thin_jail/fix_link.sh
   :caption: 修复软链接

- 在 ``skeleton`` 就绪之后，需要将数据复制到 jail 目录(如果是UFS文件系统):

.. literalinclude:: thin_jail_ufs/cp_skeleton
   :caption: 将 ``skeleton`` 数据复制到 jail 目录

- 创建一个 ``base`` template的目录，这个目录是 ``skeleton`` 挂载所使用的根目录

.. literalinclude:: vnet_thin_jail/nullfs-base
   :caption: 创建 ``skeleton`` 挂载所使用的根目录


配置jail
============

- 创建所有jail使用的公共配置部分 ``/etc/jail.conf`` (这里使用共享网络模式):

.. literalinclude:: thin_jail_ufs/jail.conf
   :caption: 所有jail使用的公共配置部分 ``/etc/jail.conf``

- ``/etc/jail.conf.d/web.conf`` (主机名 ``web`` )独立配置部分(这里因为都是公用部分，所以实际上是一个只包含主机名的空配置):

.. literalinclude:: thin_jail_ufs/web.conf
   :caption: ``/etc/jail.conf.d/web.conf``

数据目录(可选)
-------------------

为了能够将Host主机上的数据目录映射到jail容器内部使用(方便在Host主机上统一管理和备份)，执行以下命令:

.. literalinclude:: thin_jail_ufs/mkdir_docs
   :caption: 创建将要映射到jail ``web`` 的 ``/docs`` 目录


目录挂载
------------

- 注意，这里配置引用了一个针对nullfs的fstab配置(主机名 ``web`` )，所以还需要创建一个 ``/data/jails/web-nullfs-base.fstab`` :

.. literalinclude:: thin_jail_ufs/fstab
   :caption: ``/data/jails/web-nullfs-base.fstab``

.. note::

   这里将Host主机的 ``/data/docs/web`` 目录映射到jail ``web`` 中的 ``/docs`` 目录，方法和 :ref:`share_folder_between_jails` 一样

- 最后启动 ``web`` :

.. literalinclude:: thin_jail_ufs/start
   :caption: 启动 ``web``

通过 ``jexec web`` 进入jail

此时在jail ``web`` 中检查目录 ``df -h`` 显示如下:

.. literalinclude:: thin_jail_ufs/df_output
   :caption: 在jail ``web`` 中检查目录 ``df -h``
   :emphasize-lines: 4

其中 ``/skeleton/docs`` 对应Host主机的数据目录 ``/data/docs/web`` ，就可以在Host主机操作容器数据，方便维护

- 设置Jail ``web`` 在操作系统启动时启动，修改 ``/etc/rc.conf`` :

.. literalinclude:: thin_jail_ufs/rc.conf
   :caption: ``/etc/rc.conf``
   :emphasize-lines: 3,4

.. note::

   这里完成了阿里云FreeBSD虚拟机的 ``web`` jail 运行，下一步来构建一个 :ref:`nginx_reverse_proxy` 实现WEB服务器: 

参考
============

- `FreeBSD Handbook: Chapter 17. Jails and Containers > 17.5. Thin Jails <https://docs.freebsd.org/en/books/handbook/jails/#thin-jail>`_
