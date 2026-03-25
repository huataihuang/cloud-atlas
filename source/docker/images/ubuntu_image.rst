.. _ubuntu_image:

================================
Ubuntu镜像(纯粹版本)
================================

之前我在 :ref:`ubuntu_tini_image` 实践中，一直努力在构建一个能够模拟全功能虚拟机的镜像，也就是在一个容器中同时运行多个服务，特别是 :ref:`ssh` 以及 :ref:`nginx` 这样的基础服务，以便构建一个灵活的开发环境。

不过，有得必有失，过于复杂的容器包装，导致了容器失去了灵活性以及符合 :ref:`kubernetes` 运行标准的能力，或者说兼容更为繁琐臃肿。所以，大道至简，我现在更倾向于采用标准且轻量的容器，通过编排来灵活组合。

沿用 :ref:`podman_images` 实践经验，我现在调整构建 Ubuntu 镜像，来为 :ref:`container_direct_access_amd_gpu` 提供基础

base镜像
=============

首先创建一个基础镜像

- 创建 Dockerfile 为Ubuntu构建基本的系统升级和用户帐号环境:

.. literalinclude:: ubuntu_image/base/Dockerfile
   :caption: 基础镜像Dockerfile
   :language: dockerfile

.. note::
 
   - Ubuntu官方镜像中默认设置了 ubuntu 帐号(uid=1000,gid=1000)，我修订为 ``admin`` 以便和我的集群中Host主机对齐
   - 通过对比镜像中组名和组id，我增加了一个 ``render`` 用于后续AMD GPU所使用 :ref:`rocm` 所用组对齐
   - 调整 ``/etc/sudoers`` 时需要主机默认配置中列分割符号是 ``TAB`` 而不是空格，所以在执行 ``sed`` 修改时务必复制粘贴正确，否则替换会失败

- 执行镜像构建:

.. literalinclude:: ubuntu_image/base/build
   :caption: 执行镜像构建
   :language: bash

- 运行容器:

.. literalinclude:: ubuntu_image/base/run
   :caption: 运行容器
   :language: bash
   :emphasize-lines: 7

.. note::

   ``docker run`` 时使用了参数 ``--user 1000:1000`` : 这个参数可以让容器始终运行在指定 ``uid/gid`` 下，对安全有很大提高。

   不过，这个参数也带来一个问题: 当使用了 ``--user 1000:1000`` 参数之后，Docker默认只加载该UID的主组:

   - 当 ``docker exec -it ubuntu-base /bin/bash`` 进入容器，可以看到进入时身份就是 ``uid=1000`` 的用户 ``admin`` ，并且执行 ``id`` 命令可以看到该用户只有一个主组，其他在 ``/etc/group`` 中设置的 gid 都不生效:

   .. literalinclude:: ubuntu_image/id
      :caption: ``id`` 命令输出显示 ``admin`` 用户只有主组生效
      :emphasize-lines: 2

   - 正因为 ``admin`` 只有主组生效，所以即使镜像中已经修订了 ``/etc/sudoers`` ，但是 ``admin`` 的 ``sudo`` 组没有生效，无法使用 ``sudo`` 命令

