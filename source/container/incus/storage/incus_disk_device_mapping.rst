.. _incus_disk_device_mapping:

========================================
Incus磁盘设备挂载(Disk Device Mapping)
========================================

在 Incus 中，将宿主机（Host）的目录映射到容器内部以实现数据持久化，被称为磁盘设备挂载（Disk Device Mapping）。

与 Docker 的 ``-v /host/path:/container/path`` 非常类似，Incus 允许你将宿主机上的任意绝对路径挂载到容器内的指定目录中。即使该容器被销毁，宿主机上的数据依然完好保存。

卷映射
=======

可以通过 ``incus config device add`` 命令来添加一个 disk 类型的设备。

基本语法:

.. literalinclude:: incus_disk_device_mapping/device_add_disk
   :caption: 添加磁盘目录

举例: 将host主机上的 ``/home/admin/docs`` 目录添加到容器 ``debian12-dev`` 目录

.. literalinclude:: incus_disk_device_mapping/device_add_docs
   :caption: 添加 ``/home/admin/docs`` 目录到容器内部

那么在容器中看到的映射目录的属主是谁呢？是 ``nobody:nogroup`` :

.. literalinclude:: incus_disk_device_mapping/owner
   :caption: 映射目录的属主
   :emphasize-lines: 3

.. note::

   这个卷挂载为 ``nobody:nogroup`` 对于默认的容器内运行属主 ``root`` 来说没有影响，依然能够读写(以容器内root身份)。但是，对于将Host主机的 ``admin`` 用户数据目录映射进容器并使用容器内 ``admin`` 帐号就很麻烦: 在容器内创建的 ``admin`` 无法读写Host主机上 ``admin`` 映射目录。

   解决方法见下文
 
- 查看容器当前的挂载情况:

.. literalinclude:: incus_disk_device_mapping/device_show
   :caption: 检查有哪些设备添加到了容器

输出显示:

.. literalinclude:: incus_disk_device_mapping/device_show_output
   :caption: 可以看到docs设备类型是disk
   :emphasize-lines: 1-4

- 删除挂载映射

.. literalinclude:: incus_disk_device_mapping/device_remove
   :caption: 删除挂载映射

``admin`` 用户
=======================

在 Incus 的非特权容器（Unprivileged Container）中，实现宿主机与容器内 UID/GID 完全一致（例如都是 1000），不仅能完美解决文件权限冲突，还能让挂载目录用起来和本地目录一模一样。

- 举例，我的 :ref:`ubuntu_linux` 上使用了 UID 为 ``1000`` 的 ``admin`` 帐号( :ref:`ubuntu_username_admin` )

- 修订容器自定义ID映射，将宿主机的UID/GID 1000直接映射到容器内的 UID/GID 1000，这样就对齐了容器内外admin帐号:

.. literalinclude:: incus_disk_device_mapping/raw.idmap
   :caption: 映射容器用户id

- 进入容器 ``incus shell debian12-dev`` 执行以下命令创建 ``admin`` 用户并且UID为 ``1000`` :

.. literalinclude:: incus_disk_device_mapping/create_admin
   :caption: 在容器内部创建admin帐号

(可选)将该用户加入 ``sudo`` 组:

.. literalinclude:: incus_disk_device_mapping/usermod
   :caption: 将 ``admin`` 用户加入 ``sudo`` 组

修订 ``/etc/sudoers`` 将 ``admin`` 组设置为无需密码(方便自己切换)

.. literalinclude:: incus_disk_device_mapping/sudoers
   :caption: 允许admin组用户无密码切换

- 在容器内部创建 ``/home/admin/docs`` 目录(以admin创建)

- 在Host主机上为这个容器创建 ``/home/admin/docs`` 目录挂载

.. literalinclude:: incus_disk_device_mapping/device_add_docs
   :caption: 添加 ``/home/admin/docs`` 目录到容器内部

- 在Host主机将上将默认登录用户修订为admin:

.. literalinclude:: incus_disk_device_mapping/config_set_user
   :caption: 设置容器登录用户帐号为admin

- 重新启动 ``debian12-dev``

.. literalinclude:: incus_disk_device_mapping/restart
   :caption: 重新启动容器

- 注意: 这里启动 ``debian12-dev`` 有一个报错:

.. literalinclude:: incus_disk_device_mapping/start_fail
   :caption: 启动报错

按照提示执行检查 ``incus info --show-log debian12-dev`` 可以看到是由于Linux 内核的 ``newuidmap`` 出于安全限制，默认不允许把宿主机的特权/常规低位 UID（比如 1000）直接单独映射到容器里，除非宿主机的 ``/etc/subuid`` 和 ``/etc/subgid`` 文件中明确授权了该范围，或者配置了全局的子用户映射:

.. literalinclude:: incus_disk_device_mapping/show-log
   :caption: 日志显示 ``newuidmap`` 安全限制导致映射uid错误

解决方法是在Host宿主机上授权 UID 1000 允许映射，即修改 ``/etc/subudi`` 和 ``/etc/subgid`` ，在其中添加一行:

.. literalinclude:: incus_disk_device_mapping/subuid
   :caption: 修订 ``/etc/subuid`` 和 ``/etc/subgid`` 添加一行内容

.. note::

   在 Linux 系统中， ``/etc/subuid`` 和 ``/etc/subgid`` 文件用于定义用户命名空间（User Namespaces）中可以分配的从属用户 ID（Subordinate UIDs）和从属组 ID（Subordinate GIDs）。这正是 Incus（及 LXD、Podman 等工具）用来实现非特权容器隔离的核心机制。

   这里两个配置文件格式完全相同 ``用户名:起始子ID:子ID数量范围``

   - 第一个字段(用户名 / 用户): 指的是宿主机上的哪个系统用户(或者 Incus 后台运行的守护进程用户，通常是 ``root`` 或 ``incus`` )拥有使用这批从属 ID 的权限
   - 第二个字段(起始子ID / Start ID): 分配给该用户的 **第一个** 从属 ID 的数值，因为这里需要映射的是UID为1000，所以就设置为允许第一个从属ID是 ``1000``
   - 第三个字段(子ID数量范围 / Count): 从起始子ID开始，连续分配的 ID **总数量** 。例如 ``1`` 表示从起始 ID 开始往后连续的 ``1`` 个 ID（即 ``1000`` 到 ``1000`` ）

.. note::

   修订完 ``/etc/subuid`` 和 ``/etc/subgid`` 之后，需要重启 ``incus`` 服务以让配置生效

- 执行以下命令一步切换到admin用户进入容器:

.. literalinclude:: incus_disk_device_mapping/su_admin
   :caption: 进入容器admin用户

其他方法
-----------

特权容器
~~~~~~~~~

如果容器主要用于个人开发环境、且跑在可信的宿主机上，也可以直接将容器创建为特权容器。

在特权容器中，容器内的 ``root`` 和宿主机的 ``root`` 是同一个， ``UID 1000`` 也完全一致，根本不存在用户命名空间映射的问题

.. literalinclude:: incus_disk_device_mapping/privileged
   :caption: 特权容器

Incus自带shift机制
~~~~~~~~~~~~~~~~~~~~

Incus 实际上自带了对挂载目录自动调整权限的能力（类似于 Docker 的卷挂载处理）。

- 先把 raw.idmap 撤销：

.. literalinclude:: incus_disk_device_mapping/unset_raw.idmap
   :caption: 撤销idmap

- 通过为 disk 设备指定 ``shift=true`` 属性，让 Incus 在挂载时自动把宿主机的 UID 映射到容器内部:

.. literalinclude:: incus_disk_device_mapping/disk_shift
   :caption: 允许挂载宿主机目录UID映射到容器内部

参考
=====

- gemini
