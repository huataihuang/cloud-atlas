.. _debian-dev_podman_image:

==============================
``debian-dev`` Podman image
==============================

.. note::

   参考 :ref:`alpine-dev_podman_image` 构建基于debian镜像的轻量级开发环境

.. note::

   由于docker hub被GFW屏蔽，所以首先设置 :ref:`podman_proxy` ，但是需要注意仅仅在下载镜像时开启proxy，而在 ``podman build`` 时候，不要在环境变量中开启代理，以免代理变量被podman注入到镜像构建中影响构建效率。

准备工作
=========

- 首先通过 ``podman pull`` 下载镜像:

.. literalinclude:: debian-dev_podman_image/pull
   :caption: 预先下载好debian镜像

这里我遇到一个报错:

.. literalinclude:: debian-dev_podman_image/pull_error
   :caption: 预先下载好debian镜像报错
   :emphasize-lines: 4

原因是在 :ref:`ubuntu_podman` 安装后发现 ``podman info`` 显示当前 ``admin`` 用户的子用户ID没有配置，修订了 ``/etc/subuid`` 和 ``/etc/subgid`` 。但是这个修订之前已经初始化过podman(应该是 pdoman info)，导致在解压镜像时，遇到UID/GID映射(不一致)问题。

按照提示执行一次迁移命令 ``podman system migrate`` 之后就能正常下载镜像了

Dockerfile
==============

.. note::

   在 :ref:`alpine-dev_podman_image` 的Dockerfile中，执行 :ref:`alpine_apk` 时使用了 ``--no-cache`` 参数，更改到 :ref:`debian` 系统后， :ref:`apt` 没有内置类似 ``--no-cache`` 参数，但是可以通过结合 ``rm -rf /var/lib/apt/lists/*`` 来实现类似效果。

   同时使用 ``--no-install-recommends`` 防止 ``apt-get`` 自动安装非必要的推荐软件包，以便为镜像瘦身。

.. warning::

   暂时还没有时间完整验证和修复Dockerfile，待续...

.. literalinclude:: debian-dev_podman_image/debian-dev/Dockerfile
   :language: dockerfile
   :caption: ``debian-dev`` Dockerfile
