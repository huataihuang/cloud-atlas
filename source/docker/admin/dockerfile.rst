.. _dockerfile:

================================
从Dockerfile构建Docker镜像
================================

Dockerfile
=============

在 :ref:`container_static_ip` 和 :ref:`docker_ssh` 我们实现了启动一个富容器（包含了SSH和很多必要工具）、设置静态IP地址、启动时运行多个服务（例如SSH），但是每次去手工从官方镜像开始处理容器效率低下，而自定义镜像也至少需要相对麻烦的手工处理。Docker提供了通过Dockerfile方式构建镜像，类似脚本方式，也就容易实现重放（在脚本基础上改进）。

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

   将 ``authorized_keys`` 公钥文件存放到当前目录下，然后再执行 ``docker build`` 命令以构建时把公钥复制到容器内部。

   当使用 ``-f`` 参数指定Dockerfile来build镜像时，创建的镜像是没有 ``REPOSITORY`` 和 ``TAG`` 的，所以引用起来非常不便，类似::

      REPOSITORY              TAG                  IMAGE ID            CREATED             SIZE
      <none>                  <none>               845219589871        12 hours ago        277MB

   **强烈** 建议结合 ``-f`` 和 ``-t`` 参数，这样就可以对镜像标记::

      docker build -f ubuntu18.04-ssh -t local:ubuntu18.04-ssh .

      docker build -f centos8-ssh -t local:centos8-ssh .

   这样创建的镜像具有仓库和标签，显示如下::

      REPOSITORY              TAG                  IMAGE ID            CREATED             SIZE
      local                   ubuntu18.04-ssh      1db298cb83f2        2 hours ago         278MB
      local                   centos8-ssh          389c6ed34b34        16 minutes ago      286MB

.. note::

   从 18.09 版本开始，Docker支持在后台执行build过程，这样可以并行执行多个build，并且可以检测并跳过不实用对build状态。这个实现是通过 `moby/buildkit <https://github.com/moby/buildkit>`_ 项目实现对。要使用 BuildKit 后端，需要设置环境变量 ``DOCKER_BUILDKIT=1`` ，然后再执行 ``docker build`` 。

集成SSH的镜像制作Dockerfile
=============================

.. note::

   Dockerfile案例分为Ubuntu和CentOS

.. literalinclude:: dockerfile/ubuntu18.04-ssh
   :language: dockerfile
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

.. literalinclude:: dockerfile/centos7-ssh
   :language: dockerfile
   :caption:

.. literalinclude:: dockerfile/centos8-ssh
   :language: dockerfile
   :caption:

alpine linux ssh容器
-----------------------

随着云计算发展， :ref:`edge_cloud` 成为轻量级容器技术的运用场景。使用 :ref:`alpine_linux` 实现精简的Linux容器可以最大化系统硬件性能发挥，同时降低系统被攻击面。

我在 :ref:`k3s` 部署中采用 Alpine Linux 构建运行容器，采用如下Dockerfile构建支持ssh的容器:

- 使用密码登陆的ssh容器 ``Dockerfile`` :

.. literalinclude:: dockerfile/alpine-ssh
   :language: dockerfile
   :caption:

- 并准备 ``entrypoint.sh`` :

.. literalinclude:: dockerfile/entrypoint.sh
   :language: bash
   :caption:

- 然后执行构建镜像命令::

   chmod +x -v entrypoint.sh
   docker build -t alpine-ssh .

- 使用以下命令启动容器::

   docker run -itd --hostname x-dev --name x-dev -p 122:22 alpine-ssh:latest

上述Dockerfile参考 `How to install OpenSSH server on Alpine Linux (including Docker) <https://www.cyberciti.biz/faq/how-to-install-openssh-server-on-alpine-linux-including-docker/>`_ ，原文提供的Dockerfile方法非常精简，我做了一点点修改:

  - 增加sudo，并配置普通用户 ``huatai`` 能够免密码sudo
   
启动容器
=============

- 既然已经构建成功image，现在可以非常容易就启动容器::

   docker run -it -d --hostname ubuntu18 --name ubuntu18 local:ubuntu18.04-ssh

此时使用 ``docker ps`` 可以看到新启动的容器::

   CONTAINER ID        IMAGE                   COMMAND                  CREATED             STATUS              PORTS               NAMES
   1a1535ce00ed        local:ubuntu18.04-ssh   "/bin/sh -c '/usr/sb…"   3 seconds ago       Up 2 seconds        22/tcp              ubuntu18

- 启动上述 ``centos8-ssh`` 案例命令::

   docker run -it -d -p 1122:22 --hostname studio --name studio local:centos8-ssh

启动后检查 ``docker ps`` 可以看到::

   CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                            NAMES
   f4928fa6c20d        local:centos8-ssh   "/bin/sh -c '/usr/sb…"   2 seconds ago       Up 2 seconds        1122/tcp, 0.0.0.0:1122->22/tcp   studio"'"

登陆
=======

为了方便ssh登陆，可以在 ``~/.ssh/config`` 中添加配置::

   Host studio
       HostName 127.0.0.1
       Port 1122
       User huatai

但是 ``ssh stuido`` 提示错误::

   "System is booting up. Unprivileged users are not permitted to log in yet. Please come back later. For technical details, see pam_nologin(8)."

原因可以通过 ``man pam_nologin`` 获得:

pam_nologin是一个PAM模块，当 ``/var/run/nologin`` 或 ``/etc/nologin`` 文件存在时，就会拒绝用户登陆。这个文件的内容就是显示给被拒绝用户的内容。但是pam_nologin模块对root用户登陆不影响。

果然，我发现CentOS 8的Docker镜像中默认包含了一个 ``/var/run/nologin`` ，是用来防范Docker容器使用ssh服务登陆的。只需要移除这个文件就可以。所以，还需要修订Dockerfile自动移除这个文件。

参考
======

- `docker build <https://docs.docker.com/engine/reference/commandline/build/>`_
- `Dockerfile reference <https://docs.docker.com/engine/reference/builder/>`_
