.. _docker_image_prune:

======================
Docker清理镜像
======================

在生产环境长期运行的容器服务器，你会发现磁盘空间越来越少，例如 :ref:`trace_disk_space_usage` :

.. literalinclude:: ../../shell/bash/trace_disk_space_usage/du_large_dir
   :caption: 查找消耗磁盘空间最大的目录

输出类似:

.. literalinclude:: ../../shell/bash/trace_disk_space_usage/du_large_dir_output
   :caption: 查找消耗磁盘空间最大的目录输出案例(占用最大空间的的是容器镜像)
   :emphasize-lines: 1

上述这是一个简单案例，实际上我在生产环境见过消耗了几百G甚至上T的镜像存储空间，大多数是因为历史上反复更新发布导致很多无用的镜像堆积在本地。

``dangling`` image
======================

没有使用的镜像，在英语世界有一种非常形象的动作 ``dangling`` ，也就是 **悬空** 。例如 `how to get the dangling images using crictl <https://stackoverflow.com/questions/71901193/how-to-get-the-dangling-images-using-crictl>`_

.. figure:: ../../_static/docker/images/dangling.png
   
   ``dangling`` 就是悬空的意思

``prune``
===========

``docker`` 提供了一个非常实用的 ``image`` 子命令 ``prune`` 用于清理不再使用的镜像:

.. literalinclude:: docker_image_prune/docker_image_prune
   :caption: ``docker image prune`` 没有任何参数则仅删除dangling镜像(即没有任何容器使用的镜像)

这里使用了 ``-f`` 参数是为了避免交互，否则默认会提示是否进行

注意，不使用任何参数，则只会删除dangling镜像(没有任何容器使用的镜像)。如果要删除没有任何现存容器使用的所有镜像，则加上 ``-a`` 参数:

.. literalinclude:: docker_image_prune/docker_image_prune_all
   :caption: ``docker image prune`` 使用 ``-a`` 参数会删除所有没有现有容器关联的镜像，更为彻底

可以限制停止多少小时前的容器奖项:

.. literalinclude:: docker_image_prune/docker_image_prune_24h
   :caption: ``docker image prune`` 指定24小时前停止容器关联镜像

其他方法
===========

其实不用 ``prune`` 也能清理镜像，就是使用 ``rmi`` ，例如:

.. literalinclude:: docker_image_prune/docker_rmi
   :caption: 使用 ``docker rmi`` 清理不再使用的镜像

这里虽然使用 ``rmi`` 删除所有镜像，但是实际上如果正在使用的 image 是不会删除的，只会提示一个无法删除信息。遮掩，实际上就完成了无效镜像的清理。

``prune`` 一切
================

``docker`` 提供了更多的清理选项，可以用来清理容器，卷，网络甚至一切:

.. literalinclude:: docker_image_prune/docker_prune
   :caption: 可以使用 ``docker`` 的 ``prune`` 多种资源，甚至一切

参考
=======

- `Prune unused Docker objects <https://docs.docker.com/config/pruning/>`_
- `How to remove old and unused Docker images <https://stackoverflow.com/questions/32723111/how-to-remove-old-and-unused-docker-images>`_ 这里有更多案例以及说明，如有需要可以参考
