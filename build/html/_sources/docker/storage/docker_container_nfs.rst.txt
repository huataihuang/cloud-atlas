.. _docker_container_nfs:

==================
Docker容器使用NFS
==================

.. note::

   :ref:`kubernetes` 在Docker基础上采用了 :ref:`k8s_persistent_volumes` 实现更为抽象化的持久化存储。

.. note::

   简单来说，Docker使用NFS存储有两种形式：

   - Host主机上创建NFS类型的Docker Volume，然后将docker volume映射到容器内部，这样容器就可以直接使用Docker共享卷，这种方式最为简洁优雅。
   - 在容器内部安装 ``nfs-utils`` ，就如同常规到NFS客户端一样，在容器内部直接通过rpcbind方式挂载NFS共享输出，这种方式需要每个容器独立运行rpcbind服务，并且要使用到systemd，复杂且消耗较多资源。不过，优点是完全在容器内部控制，符合传统SA运维方式。

在容器内部使用NFS
===================

要知道，容器并不是完整的虚拟机，天然就是瘦客户端并且有意削减了部分操作系统功能。

参考
======

- `TECH::Using NFS with Docker – Where does it fit in? <https://whyistheinternetbroken.wordpress.com/2015/05/12/techusing-nfs-with-docker-where-does-it-fit-in/>`_
