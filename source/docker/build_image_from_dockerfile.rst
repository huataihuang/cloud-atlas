.. _build_image_from_dockerfile:

================================
从Dockerfile构建Docker镜像
================================

Dockerfile
=============

在 :ref:`assign_static_ip_to_docker_container` 和 :ref:`docker_ssh` 我们实现了启动一个富容器（包含了SSH和很多必要工具）、设置静态IP地址、启动时运行多个服务（例如SSH），但是每次去手工从官方镜像开始处理容器效率低下，而自定义镜像也至少需要相对麻烦的手工处理。Docker提供了通过Dockerfile方式构建镜像，类似脚本方式，也就容易实现重放（在脚本基础上改进）。

Dockerfile就是包含用户调用命令行来组装镜像所有命令的一个文本文档，并且可以通过 ``docker build`` 来使用这个文档自动创建镜像。

::

   docker build .

这个build过程将通过Docker daemon运行，而不是命令行。最好在一个包含Dockerfile的独立目录中运行上述命令。

.. warning::

   不要在根目录下运行 ``docker build .`` ，这会导致把整个硬盘内容传输给Docker daemon。

.. note::

   如果目录下有多个文件，为了加快build，可以过滤掉目录下的不需要传递的文件，采用一个 ``.dockerignore`` 文件（类似 ``.gitignore`` 。

docker build参数
==================

- ``-f /path/to/a/Dockerfile`` 传递Dockerfile文件名，这样可以不用默认的 ``Dockerfile`` 作为文件名，例如::

   docker build -f ubuntu18.04-ssh .

也可以使用如下方法（只传递Dockerfile，不传递目录中的文件）::

   docker build - < ubuntu18.04-ssh

- ``-t 标签`` ，并且可以使用多个 ``-t`` 参数来标记镜像属于多个镜像仓库，例如::

   docker build -t shykes/myapp:1.0.2 -t shykes/myapp:latest .

.. note::

   当使用 ``-f`` 参数指定Dockerfile来build镜像时，创建的镜像是没有 ``REPOSITORY`` 和 ``TAG`` 的，所以引用起来非常不便，类似::

      REPOSITORY              TAG                  IMAGE ID            CREATED             SIZE
      <none>                  <none>               845219589871        12 hours ago        277MB

   建议结合 ``-f`` 和 ``-t`` 参数，这样就可以对镜像标记::

      docker build -f ubuntu18.04-ssh -t local:ubuntu18.04-ssh .

标签`` ，并且可以使用多个 ``-t`` 参数来标记镜像属于多个镜像仓库，例如::
   docker build -t shykes/myapp:1.0.2 -t shykes/myapp:latest .

.. note::

   当使用 ``-f`` 参数指定Dockerfile来build镜像时，创建的镜像是没有 ``REPOSITORY`` 和 ``TAG`` 的，所以引用起来非常不便，类似::

      REPOSITORY              TAG                  IMAGE ID            CREATED             SIZE
      <none>                  <none>               845219589871        12 hours ago        277MB

   建议结合 ``-f`` 和 ``-t`` 参数，这样就可以对镜像标记::

      docker build -f ubuntu18.04-ssh -t local:ubuntu18.04-ssh .

   这样创建的镜像具有仓库和标签，显示如下::

      REPOSITORY              TAG                  IMAGE ID            CREATED             SIZE
      local                   ubuntu18.04-ssh      1db298cb83f2        2 hours ago         278MB

.. note::

   从 18.09 版本开始，Docker支持在后台执行build过程，这样可以并行执行多个build，并且可以检测并跳过不实用对build状态。这个实现是通过 `moby/buildkit <https://github.com/moby/buildkit>`_ 项目实现对。要使用 BuildKit 后端，需要设置环境变量 ``DOCKER_BUILDKIT=1`` ，然后再执行 ``docker build`` 。

集成SSH的镜像制作Dockerfile
=============================

.. note::

   Dockerfile案例分为Ubuntu和CentOS

.. literalinclude:: ubuntu18.04-ssh
   :language: dockerfile
   :linenos:
   :caption:
   :emphasize-lines: 37,51,57,64

.. note::

   - 安装了openssh服务之后，需要创建主机key才能启动服务，所以需要执行 ``RUN ssh-keygen -A``
   - 将host主机上 ``authorized_keys`` 复制到镜像中，这里可以使用 ``COPY`` 指令或 ``ADD`` 指令。推荐使用 ``COPY`` （ ``ADD`` 指令用于添加 ``tar.gz`` 文件，可以自动展开: ``ADD rootfs.tar.xz /`` ) 。请参考 `Dockerfile COPY vs ADD: key differences and best practices <https://medium.freecodecamp.org/dockerfile-copy-vs-add-key-differences-and-best-practices-9570c4592e9e>`_
   - ``EXPOSE`` 指令用来将指示容器中运行端口输出到host主机，这样其他人在使用 ``docker inspect`` 检查镜像时就能够发现这个端口映射提示(hint)。但是，需要 ``注意`` ：如果没有在 ``docker run`` 命令显式使用 ``-p 2211:22`` ，则实际从镜像创建的容器依然是没有输出端口映射的。 请参考 `What is the use of EXPOSE in Docker file <https://forums.docker.com/t/what-is-the-use-of-expose-in-docker-file/37726>`_ 
   - 虽然能够使用 ``CMD ["/usr/sbin/sshd", "-D"]`` 在镜像最后启动一个sshd服务，但是在Dockerfile中，只能执行一次 ``CMD`` ，多条 ``CMD`` 时后面的命令会覆盖前面的命令（即只有最后一条命令生效）；所以如果有多条命令需要运行，则需要使用 ``ENTRYPOINT`` 。

.. warning::

   虽然可以使用 ``docker build - < ubuntu18.04-ssh`` 来构建镜像，但是不如使用 ``docker build -f ubuntu18.04-ssh .`` 。因为后者可以从当前目录复制文件到容器中（使用 ``COPY`` 指令或者 ``ADD`` 指令），而前者会失去当前目录引用，复制文件会失败。

.. note::

   如果要在容器内部使用某个用户身份执行命令，则在命令前先使用 ``USER`` 指令切换，例如 ``USER huatai`` 切换。类似 Python的 ``virtualenv`` 环境创建，都需要先切换身份再执行指令。

.. literalinclude:: centos7-ssh
   :language: dockerfile
   :linenos:
   :caption:

参考
======

- `docker build <https://docs.docker.com/engine/reference/commandline/build/>`_
- `Dockerfile reference <https://docs.docker.com/engine/reference/builder/>`_
