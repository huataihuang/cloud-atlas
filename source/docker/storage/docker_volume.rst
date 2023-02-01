.. _docker_volume:

====================
Docker 卷
====================

卷(volume)是Docker容器数据持久化的首选机制，虽然 :ref:`docker_bind_mount` 也能够实现数据持久化，但是bind mounts依赖于主机的目录结构和操作系统，而volume则完全由Docker管理，具有以下优点:

- 卷(volume)比 :ref:`docker_bind_mount` 更容易备份和迁移
- 可以通过Docker CLI命令或者Docker API来管理卷
- 卷在Linux和Windows都是可以使用的
- 卷能够更安全地在不同容器间共享
- 卷驱动程序允许将卷存储在远程主机或者云厂商上，并且提供卷内容加密或提供其他功能
- 新卷的内容可以由容器预先填充
- :ref:`docker_desktop` 的卷性能比 :ref:`macos` 和 :ref:`windows` 主机上的 :ref:`docker_bind_mount` 性能更好

此外，和容器中的可写层中持久化数据相比，卷通常是更好的选择:

- 卷不会增加容器的大小
- 卷的内容和容器的生命周期无关，可以更容易保持

卷(Volumes)使用 ``rprivate`` 绑定传播(bind propagation)，并且卷的这个 "绑定传播" 是不可配置的

.. figure:: ../../_static/docker/storage/types-of-mounts-volume.png
   :scale: 80

.. note::

   如果追求高性能且不需要持久化数据，可以考虑采用 :ref:`docker_tmpfs_mount`

选择 ``-v`` 或 ``--mount`` 参数
================================

总而言之， ``--mount`` 参数更为明确和冗长。最大的不同是在语法上， ``-v`` 参数需要将所有选项组合在一个字段中，而 ``--mount`` 参数则将选项分离开。

**如果需要指定卷驱动程序选项，则必须使用 --mount** 

- ``-v`` 或 ``--volume`` : 由三个字段组成，以冒号字符 ( ``:`` ) 分隔。 字段的顺序必须正确，每个字段的含义不是很明显

  - 在命名卷(named volumes)的情况下，第一个字段是卷的名称，并且在给定的主机上是唯一的。 对于匿名卷，省略第一个字段。
  - 第二个字段是文件或目录在容器中的挂载路径
  - 第三个字段是可选的，并且是以逗号分隔的选项列表，例如 ``ro``

- ``--mount`` : 由多个键值对组成，以逗号分隔，每个键值对由一个 ``<key>=<value>`` 元组组成。 ``--mount`` 语法比 ``-v`` 或 ``--volume`` 更冗长，但是键的顺序无需关注，且标记的值更容易理解

  - 挂载类型( ``type`` ): 可以是 ``bind`` ( :ref:`docker_bind_mount` )、volume ( :ref:`docker_volume` )或 tmpfs ( :ref:`docker_tmpfs_mount` )
  - 挂载源( ``srouce`` ): 对于命名卷(named volumes)，表示卷的名称。 对于匿名卷，则省略此字段。这里 ``source`` 可以简写为 ``src``
  - 挂载目标( ``destination`` ): 表示将文件或目录挂载到容器内部的路径。这里 ``destination`` 可以简写为 ``dst`` ，通常也可以用 ``target`` ( ``target`` 是比较常用的方法)
  - 只读( ``readonly`` )选项: （如果存在）会使绑定挂载以只读方式挂载到容器中。通常 ``readonly`` 可以简写为 ``ro``
  - 卷选项( ``volume-opt`` ): 这个卷选项可以多次使用，来配置多个键值对表示配置选项

创建卷
======

参考
=======

- `docker docs: Storage >> Volumes <https://docs.docker.com/storage/volumes/>`_
