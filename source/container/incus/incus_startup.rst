.. _incus_startup:

=======================
Incus快速起步
=======================

Ubuntu 24.04 LTS以及后续版本都默认包含了 ``incus`` 软件包，可以非常轻松直接安装：

.. literalinclude:: incus_startup/install
   :caption: 安装Incus

- 将自己加入 ``incus-admin`` 组以便能够以普通用户身份来管理:

.. literalinclude:: incus_startup/user
   :caption: 加入 ``incus-admin`` 组

.. note::

   incus有两个组:

   - ``incus`` 是普通的用户使用，不提供配置和限制到每个用户的项目操作
   - ``incus-adin`` 允许所有的控制操作

- incus初始化:

.. literalinclude:: incus_zfs/incus_admin_init
   :caption: 初始化incus

.. note::

   这里使用了 :ref:`incus_zfs` 实践构建的ZFS存储

- 启动运行 :ref:`debian` 12:

.. literalinclude:: incus_startup/debian12
   :caption: 运行debian 12容器

这里使用了 ``incus launch`` 表示下载、创建并直接启动容器(如果只想创建但不启动，可以使用 ``incus create`` )

``image:debian/12`` 指定了官方镜像，这会下载最新的Debian 12(Bookworm)官方纯净系统镜像

``debian12-dev`` 则是为容器起的名字

- 检查容器状态:

.. literalinclude:: incus_startup/list
   :caption: 检查容器状态

输出类似:

.. literalinclude:: incus_startup/list_output
   :caption: 检查容器状态

- 进入容器(方法其实类似Docker)

.. literalinclude:: incus_startup/exec
   :caption: 执行进入容器

此时可以看到位于 ``root@debian12-dev:~#`` 提示符下，表明已经进入了容器内部

- 对于执行容器内命令，可以按照docker的方式来执行单条命令:

.. literalinclude:: incus_startup/exec_command
   :caption: 执行单条命令


参考
======

- `Incus Getting Started <https://linuxcontainers.org/incus/docs/main/tutorial/first_steps/>`_
