.. _docker_storage_manage:

===================
Docker存储管理
===================

默认情况下，所有在容器中创建的文件都存储在一个可写入的容器层（writable container layer），这意味着:

- 如果容器销毁，数据也就不存在了，并且这种方式很难在容器之间共享数据
- 这个容器可写入层是和容器所运行的host主机紧密结合的，很难迁移数据
- 写入容器的可写入层需要一个 :ref:`docker_storage_driver` 来管理文件系统。这个存储驱动使用Linux内核来提供了一个联合文件系统（union filesystem）。

.. note::

   Docker容器默认使用的union filesystem需要通过 :ref:`docker_storage_driver` 读写文件系统，由于增加了这层额外的抽象层，导致读写性能低于 :ref:`docker_volume` （直接读写host主机文件系统)。

   在生产环境中使用Docker容器，务必尽可能将所有数据读写都通过 :ref:`docker_volume` 来实现，以获得最佳的存储性能。 :ref:`docker_storage_driver` 应用于构建容器（静态数据）而不是生产数据。

Docker可以使用两种方式把文件存储到Host主机上，以实现数据持久化：

- :ref:`docker_volume`
- :ref:`docker_bind_mount`

此外借助Host主机的内存文件系统 ``tmpfs`` ，Docker可以实现速度最快的外部文件交换（通常用于向外部传输日志）:

- :ref:`docker_tmpfs_mount`

选择正确的挂载模式
======================

无论你选择哪种挂载方式，数据在容器内部看起来都是一样的，数据在容器内部表现为文件系统一个目录或独立文件。如何区分数据挂载类型，例如 卷，绑定挂载，以及 ``tmpfs`` 挂载，最简单的方式是考虑数据在Docker Host（底层主机）上存储的位置：

.. image:: ../../_static/docker/types-of-mounts.png

- ``Volumes`` （卷）将数据存储在host主机文件系统中由Docker管理的部分（ ``/var/lib/docker/volumes/`` ）。不是Docker的进程将不会修改这部分文件系统，通常卷是Docker持久化数据的最佳选择。
- ``Bind mounts`` （绑定挂载）可以将数据存储在host主机的任何位置，甚至可以存储在重要的系统文件和目录。在Docker主机上非Docker进程也能够访问和修改这些数据。（限制最小，但存在安全隐患，因为不仅每个容器都可以修改系统文件导致影响其他容器，而且在host主机修改也将影响所有容器）
- ``tmpfs mounts``  （内存文件系统tmpfs挂载） 只将数据存储在host主机系统内存，但绝不存储到host主机磁盘存储文件系统。

挂载类型的详细解析
-------------------

- volumes ( :ref:`docker_volume` ) 由Docker创建和管理，可以使用 ``docker volume create`` 命令显式创建一个卷，或者有Docker在容器或服务创建时创建一个卷。

创建的卷位于Docker host的目录，可以在多个容器中挂载相同的卷，这样就可以实现容器间数据共享。和 :ref:`docker_bind_mount` 区别是 Volume 卷只能位于Docker管理目录下而不是host主机的任意位置。

.. note::

   当没有容器使用某个卷时，这个卷依然位于Docker中不会自动移除，需要使用命令 ``docker volume prune`` 来删除一个不使用的卷。

在挂载一个卷时，卷可以是 ``named`` （命名的）也可以是 ``anonymous`` （匿名的）。匿名卷没有明确给出名字，当挂载到一个容器上时，Docker会随机给卷命名，已确保在Docker host上卷的命名唯一性。

卷也支持 ``volume drivers`` 的使用方式，这样允许将数据存储到远程主机或者云存储。

- bind mounts ( :ref:`docker_bind_mount` )是Docker早期提供的挂载方式，和volume相比较，bind mount 有功能限制。当使用bind mount，在host主机上的文件或目录被挂载到容器内部，文件和目录是通过它在host主机的完整路径来引用的，在Docker host主机上，这个挂载文件或目录并不需要一定存在，如果不存在，文件和目录会在必要时自动创建。bind mount的性能很好，但是它依赖host主机文件系统具备一个特定的目录结构。注意，不能使用Docker CLI命令来直接管理bind mount。

.. warning::

   :ref:`docker_bind_mount` 是一个强大的存储方式：可以在容器中直接修改host主机上的文件，甚至包括修改和删除系统文件。这是具有安全隐患的，会影响host系统中非Docker进程。

- tmpfs mounts ( :ref:`docker_tmpfs_mount` ) 是非持久化数据存储，只在容器的生命周期内存在，用于存储非持久化数据或敏感信息。例如，在Docker内部，swarm服务使用 ``tmpfs`` 挂载来挂载 `secrets <https://docs.docker.com/engine/swarm/secrets/>`_ 到服务的容器中。

bind mounts 和 volumes 都是使用 ``-v`` 或者 ``--volume`` 命令参数来挂载到容器内，不过有轻微的差异。 对于 ``tmpfs`` 挂载，则需要使用 ``--tmpfs`` 参数。从 Docker 17.06 或更高版本，建议使用 ``--mount`` 参数用于容器和服务，以及用于bind mounts 和volumes 、 tmpfs 挂载，以保持清晰语法。

参考
========

- `Manage data in Docker <https://docs.docker.com/storage/>`_
