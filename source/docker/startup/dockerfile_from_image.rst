.. _dockerfile_from_image:

==============================
从Docker镜像提取Dockerfile
==============================

有时候我们拿到一个Docker镜像，我们需要了解这个Docker镜像是怎么制作的，以便进行分析和定制。

Docker的基础镜像 :ref:`alpine_linux` 提供了一个 `dfimage工具 <https://hub.docker.com/repository/docker/alpine/dfimage>`_ 逆向解析Docker镜像::

   alias dfimage="docker run -v /var/run/docker.sock:/var/run/docker.sock --rm alpine/dfimage"
   dfimage -sV=1.36 nginx:latest

上述方法将下载目标docker镜像，并自动输出 ``Dockerfile`` ，参数 ``-sV=1.36`` 不是必须的。

另外一种方法是使用 ``docker history --no-trunc <IMAGE_ID>`` 命令，可以查看历史上添加到Docker镜像中的命令。

参考
======

- `How to generate a Dockerfile from an image? <https://stackoverflow.com/questions/19104847/how-to-generate-a-dockerfile-from-an-image>`_
