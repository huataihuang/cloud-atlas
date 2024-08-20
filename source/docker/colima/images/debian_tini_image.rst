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

我尝试通过 :ref:`colima_proxy` 来解决无法访问问题

