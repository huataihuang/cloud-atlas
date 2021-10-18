.. _docker_debug:

======================
排查Docker容器问题
======================

和 :ref:`kubernetes_debug` 类似，实际上Docker的排查不外乎检查日志、状态以及通过巧妙方法重试和排查日志，特别是Docker出现crash的时候。

容器日志
===========

如果 ``docker run`` 运行失败，你可以通过检查容器日志找到蛛丝马迹::

   docker logs <container_id>

上述命令会获得容器初始化的完整 ``STDOUT`` 和 ``STDERR`` ，从而找到线索

容器状态
=========

如果你需要不断检查容器是否正常运行，通常可以检查状态，例如扫描大量的容器来获得系统运行健康度::

   docker stats <container_id>

复制容器文件
=============

有时候从容器内部获取文件，例如 coredump 文件，进行检查能够帮助我们排查问题::

   docker cp <container_id>:/path/to/useful/file /local-path

启动容器bash
==============

通常我们会在容器中直接运行服务，但是有时候容器可能crash，你需要调试的话，可以先运行容器的shell，通过shell进入容器去执行服务，排查日志::

   docker exec -it <container_id> /bin/bash

快照和运行
============

如果不能启动容器，有一个技巧可以帮助排查问题，即将容器快照保存下来，立即以这个快照来运行shell进行排查::

   docker commit <container_id> my-broken-container && docker run -it my-broken-container /bin/bash

保存关闭容器的当前状态作为镜像，然后启动基于该镜像的shell，可以避免启动问题，并且进入容器排查

参考
====

- `5 ways to debug an exploding Docker container <https://medium.com/@pimterry/5-ways-to-debug-an-exploding-docker-container-4f729e2c0aa8>`_
