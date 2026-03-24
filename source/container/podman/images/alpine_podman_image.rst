.. _alpine_podman_image:

=======================
Alpine Podman image
=======================

精简 :ref:`alpine_linux` 的开发环境

.. literalinclude:: alpine_podman_image/alpine-dev/Dockerfile
   :language: dockerfile
   :caption: 精简的alpine开发环境

其中 ``entrypoint.sh`` 脚本如下:

.. literalinclude:: alpine_podman_image/alpine-dev/entrypoint.sh
   :language: bash
   :caption: entrypoint.sh 提供对Docker环境进行修正

构建镜像:

.. literalinclude:: alpine_podman_image/alpine-dev/build
   :language: bash
   :caption: 构建镜像

然后再运行:

.. literalinclude:: alpine_podman_image/alpine-dev/run
   :language: bash
   :caption: 运行podman

docker compose运行
=======================

为了方便构建，采用 ``docker compose`` 来启动容器，即创建 ``docker-compose.yml`` :

.. literalinclude:: alpine_podman_image/alpine-dev/docker-compose.yml
   :language: yaml
   :caption:  ``docker-compose.yml``

然后执行:

.. literalinclude:: alpine_podman_image/alpine-dev/docker_compose
   :language: bash
   :caption: 运行 ``docker compose```
