.. _debian_tini_image:

==========================
Debian镜像(tini进程管理器)
==========================

Debian官方仓库已经提供了 :ref:`docker_tini` ，这意味着无需单独复制 ``tini`` (类似 :ref:`fedora_tini_image` 就不得不从容器外部复制对应的 ``tini`` 到镜像中)

`dockerhub: debian <https://hub.docker.com/_/debian>`_ 提供官方镜像(需要梯子):

- 当前 `debian.org <https://www.debian.org/>`_ 最新版本是 ``bookworm`` (12.6)，通过 ``tag`` 关键字 ``bookworm`` 或 ``latest`` 引用

tini运行ssh ``debian-ssh-tini``
===================================

- 参考之前 :ref:`ubuntu_tini_image` 经验，构建Dockerfile

.. literalinclude:: debian_tini_image/ssh/Dockerfile
   :language: dockerfile
   :caption: 具备ssh服务的debian镜像Dockerfile

- 构建镜像:

.. literalinclude:: debian_tini_image/ssh/build_debian-ssh-tini_image
   :language: bash
   :caption: 构建包含tini和ssh的debian镜像

这里我遇到一个报错:

.. literalinclude:: ../colima_proxy/build_err
   :caption: 无法下载镜像导致构建失败
   :emphasize-lines: 14

通过 :ref:`colima_proxy` 来解决无法访问问题

- 运行容器: 注意这里继承了 :ref:`colima_storage_manage` 中两个HOST物理主机卷映射到容器内部，以便提供SSH密钥以及工作 ``docs`` 目录

.. literalinclude:: debian_tini_image/ssh/run_debian-ssh-tini_container
   :language: bash
   :caption: 运行容器挂载2个从HOST主机映射到colima虚拟机的卷(这样可以直接访问HOST主机数据)

- 一切顺利，现在在HOST主机上配置 ``~/.ssh/config`` 添加访问debian容器的SSH登陆(端口1122):

.. literalinclude:: debian_tini_image/ssh/ssh_config
   :caption: ``~/.ssh/config`` 添加访问debian容器的SSH登陆

.. note::

   HOST主机的 ``~/secrets`` 包含了SSH公钥，所以如果被正确挂载到容器的 ``~/.ssh`` 目录，就能够无需密码登陆容器
