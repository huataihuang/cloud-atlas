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

