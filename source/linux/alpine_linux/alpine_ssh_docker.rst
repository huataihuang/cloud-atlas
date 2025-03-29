.. _alpine_ssh_docker:

==================================
Alpine Linux SSH服务以及Docker化
==================================

在Alpine Linux安装部署SSH服务非常简便，而且容器化SSH服务也非常容易。

- 在Alpine Linux服务器上，安装 ``openssh`` ::

   sudo apk add openssh

- 激活 ``sshd`` 服务::

   sudo rc-update add sshd

- 启动 ``sshd`` 服务::

   sudo service sshd start

- 可以通过定制 ``/etc/ssh/sshd_config`` 实现安全加固

Alpine Linux环境OpenSSH服务容器化
===================================

:ref:`dockerfile` 可以方便我们构建运行SSH服务的Alpine Linux容器，在该文中我整理了不同发行版的构建SSH服务方法，其中 Alpine Linux 非常简单(设置密码登陆方式)

- ssh容器 ``Dockerfile`` :

.. literalinclude:: ../../docker/admin/dockerfile/alpine-ssh
   :language: dockerfile
   :caption:

- 并准备 ``entrypoint.sh`` :

.. literalinclude:: ../../docker/admin/dockerfile/entrypoint.sh
   :language: bash
   :caption:

- 然后执行构建镜像命令::

   chmod +x -v entrypoint.sh
   docker build -t alpine-ssh .

- 使用以下命令启动容器::

   docker run -itd --hostname x-dev --name x-dev -p 122:22 alpine-ssh:latest

参考
======

- `How to install OpenSSH server on Alpine Linux (including Docker) <https://www.cyberciti.biz/faq/how-to-install-openssh-server-on-alpine-linux-including-docker/>`_
