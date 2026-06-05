.. _running_jellyfin_in_docker:

===============================
在Docker容器中运行Jellyfin
===============================

准备工作
============

- :ref:`install_nvidia_linux_driver_ubuntu`
- :ref:`nvidia_container_toolkit`

运行
=======

使用Docker Compose运行
-------------------------

Docker Compose使用较为简易，使用如下 ``docker-compose.yml`` 配置:

.. literalinclude:: running_jellyfin_in_docker/docker-compose.yml
   :caption: 配置 ``docker-compose.yml``

使用Docker运行
--------------------

- Docker CLI命令行运行启动：

.. literalinclude:: running_jellyfin_in_docker/docker_run
   :caption: 采用 docker run
   :emphasize-lines: 7,11

这里使用了:

  - ``--net=host`` 表示直接容器内的服务端口直接绑定到host主机，这样就不需要一一写端口映射
  - ``-v $DIR/media:/media`` 将Host主机的一个 ``media`` 目录映射进容器，这个目录下将分别建立 ``movies`` / ``tvshows`` / ``musics`` / ``photos`` 子目录，这是因为剧集、歌曲等是多个内容归纳到一个入口，需要和电影区分开

.. note::

   后续设置和使用参考 :ref:`jellyfin_practice`
