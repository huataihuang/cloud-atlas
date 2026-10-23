.. _incus_startup:

=======================
Incus快速起步
=======================

安装
======

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

Incus和KVM
===========

Incus提供了一个 `Image server for Incus and LXC <https://images.linuxcontainers.org/>`_ 提供常见发行版的镜像

我最初选择在 :ref:`ubuntu_linux` 中使用 :ref:`incus` 是因为希望通过容器化取代虚拟化来轻量级运行 :ref:`k3s` (简化 :ref:`kubernetes` )，但逐步发现Incus和早期的LXC还是有很大的区别，已经演进为一个统一的"实例(Instance)"管理平台——既支持系统容器(System Containers)，也支持全虚拟化虚拟机（Virtual Machines, VM）。

当Incus通过 :ref:`qemu` / :ref:`kvm` 启动独立的硬件虚拟机，能提供独立的CPU、内存和完整的操作系统内核，适合进行操作系统级别的内核开发。

.. note::

   Incus官方镜像仓库提供了 :ref:`freebsd` 镜像，底层通过 :ref:`kvm` 可以实现 :ref:`incus_freebsd`

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
