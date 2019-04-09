.. _build_image_from_dockerfile:

================================
从Dockerfile构建Docker镜像
================================

在 :ref:`assign_static_ip_to_docker_container` 和 :ref:`docker_ssh` 我们实现了启动一个富容器（包含了SSH和很多必要工具）、设置静态IP地址、启动时运行多个服务（例如SSH），但是每次去手工从官方镜像开始处理容器效率低下，而自定义镜像也至少需要相对麻烦的手工处理。Docker提供了通过Dockerfile方式构建镜像，类似脚本方式，也就容易实现重放（在脚本基础上改进）。

.. note::

   Dockerfile案例分为Ubuntu和CentOS

.. literalinclude:: ubuntu18.04-ssh
   :language: dockerfile
   :linenos:
   :caption:
   :emphasize-lines: 37,51,57,64

.. note::

   - 安装了openssh服务之后，需要创建主机key才能启动服务，所以需要执行 ``RUN ssh-keygen -A``
   - 将host主机上 ``authorized_keys`` 复制到镜像中，这里可以使用 ``COPY`` 指令或 ``ADD`` 指令。推荐使用 ``COPY`` （ ``ADD`` 指令用于添加 ``tar.gz`` 文件，可以自动展开 ) 。请参考 `Dockerfile COPY vs ADD: key differences and best practices <https://medium.freecodecamp.org/dockerfile-copy-vs-add-key-differences-and-best-practices-9570c4592e9e>`_
   - ``EXPOSE`` 指令用来将指示容器中运行端口输出到host主机，这样其他人在使用 ``docker inspect`` 检查镜像时就能够发现这个端口映射提示(hint)。但是，需要 ``注意`` ：如果没有在 ``docker run`` 命令显式使用 ``-p 22:1122`` ，则实际从镜像创建的容器依然是没有输出端口映射的。 请参考 `What is the use of EXPOSE in Docker file <https://forums.docker.com/t/what-is-the-use-of-expose-in-docker-file/37726>`_ 
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
