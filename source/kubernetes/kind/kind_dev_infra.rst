.. _kind_dev_infra:

======================
kind dev集群架构
======================

和 :ref:`alipine-nginx` 的Docker容器不同的是:

:ref:`kind_diagram` 显示 ``kind`` 的容器和我们的物理主机隔了一层 ``Node Container`` ，也就是说 ``User Pod`` 不能直接将物理主机的 :ref:`k8s_hostpath_volumes` 挂载到容器内部(对应于 :ref:`docker_volume` )

最简单的方法是每次都重新制作镜像: 在 :ref:`alipine-nginx` 基础上，每次都把 :ref:`sphinx_doc` 的 ``build`` 目录复制到镜 像中推送到 :ref:`kind` 集群的 :ref:`kind_local_registry` 部署(这通常是大型网站的标注部署方式)。不过，要模拟这种标准部署不是一个简单的操作(手工执行不算)，而是要集成 :ref:`jenkins` 实现CI/CD的复杂架构。

.. note::

   我在后续会尝试在 :ref:`kind` 中构建一个 :ref:`continuous_integration` ( :ref:`jenkins` )

所以，(我认为)更为简单的方式是采用 :ref:`btrfs_nfs` 输出 :ref:`k8s_nfs` :

- 在 :ref:`mobile_cloud_infra` 的物理笔记本上，只需要有任何更新，就立即通过 :ref:`btrfs_nfs` / :ref:`zfs_nfs` 直接更新 到容器内部输出
- 不需要不断更新发布镜像，适合简单的小型部署

这种架构也是有局限性的:

- 中心化的数据共享，如果出现中心存储故障(例如NAS故障)，会导致整个网站瘫痪
- 中心化的存储往往是性能瓶颈，不能支持海量的容器并发访问

不过，对于目前我在笔记本电脑上运行的模拟架构中，上述NFS共享模型是一种比较简洁的模式。在模拟更为复杂的 :ref:`mobile_cloud_infra` 中，则会采用 :ref:`ceph` 来构建底层分布式存储。
