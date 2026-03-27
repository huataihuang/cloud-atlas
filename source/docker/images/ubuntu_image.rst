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

dev镜像
==========

- 在开发镜像中，安装 :ref:`helix` 以及对应的 :ref:`ubuntu_helix_lsp`

.. literalinclude:: ubuntu_image/dev/Dockerfile
   :caption: 开发镜像中增加了开发工具并设置初步环境
   :language: dockerfile
   :emphasize-lines: 50

为了能够解决使用 ``--user 1000`` 参数执行 ``docker run`` 只加载主组的问题，需要配合 ``--group-add`` 参数来为 ``admin`` 增加辅助组，以便能够使用 ``sudo`` 以及AMD GPU。这种方式在开发环境会非常方便，能够从 ``admin`` 用户随时切换到 ``root`` 进行一些系统操作:`

.. literalinclude:: ubuntu_image/dev/run
   :caption: 运行容器,为admin用户添加组
   :language: bash
   :emphasize-lines: 9-12

这里 ``--group-add`` 分别为 ``admin`` 用户添加了组:

  - ``4(adm)`` : 在 :ref:`ubuntu_linux` 中， ``adm`` 组用于 **查看系统日志(Monitoring & Auditing)** ，而无需获得 ``root`` 权限。该组成员对 ``/var/log/`` 目录下大部分日志(如 ``syslog`` , ``auth.log`` , ``kern.log`` )拥有读取权限，这样 ``admin`` 能够在调试程序时方便查看系统日志
  - ``27(sudo)`` : 该组成员通过 ``sudo`` 提升为 ``root`` 用户拥有整个系统超级权限，适合在特定情况下处理系统维护工作
  - ``44(video)`` 和 ``993(render)`` 在开发和维护 :ref:`amd_gpu` 时需要该组身份权限

开发环境的系统能力和安全策略
------------------------------

在dev镜像运行时，特别使用了:

- ``--cap-add SYS_PTRACE`` : 允许容器内部的进程调用 ``ptrace`` 。 ``ptrace`` 是Linux下所有调试工具的核心。例如在容器中使用 :ref:`strace` 查看Go程序的系统调用，或者用 ``gdb`` 调试崩溃堆栈，都需要这个权限

- ``--security-opt seccomp=unconfined`` : 将 ``seccomp`` 设置为 ``unconfined`` (不限制)表示允许容器内的进程能够尝试调用任何内核支持的指令。这对于开发环境、内核调试或性能工具(如 :ref:`perf` )是必不可少的。如果不设置这个参数，那么即使允许了上文的 ``SYS_PTRACE`` 能力，则依然可能拦截 ``ptrace`` 的某些子功能。(Docker默认会禁止约40多个危险或不常用的系统调用)

.. warning::

   在生产环境运行容器绝对不要使用上述两个开发环境的运行参数，存在重大安全隐患

在开发环境中，如果Ubuntu容器中运行 ``llm-ls`` 没有反应，可以尝试配置:

- ``--sysctl net.core.somaxconn=1204`` 高并发环境测试监控脚本
- ``--shm-size=2g`` 如果涉及到GPU显存和大量内存操作，默认容器的 ``/dev/shm`` 只有 ``64MB`` 可能会导致深度学习框架或高性能内存映射我呢键(mmap)崩溃

``ENV``
------------

上述 ``dev`` 镜像中使用了 ``ENV`` 命令:

.. literalinclude:: ubuntu_image/env
   :caption: Dockerfile中 ``ENV`` 指令`

在Dockerfile中使用 ``ENV`` 指令，该配置行 **不会添加** 到容器内的任何"文件" (如  ``.bashrc`` 或 ``/etc/profile`` )中，而是直接写入镜像的 **元数据(Metadata)** 里:

- 在镜像的JSON配置文件中(通过 ``docker inspect <image_id>`` 查看)
- 当容器启动时，Docker守护进程( :ref:`containerd` )会读取这些元数据，并在创建容器进程(Runtime)时，直接通过系统调用将这些变量注入到进程的环境变量列表( ``envp`` )中

.. csv-table:: ``ENV`` 与 ``.bashrc`` 区别
   :file: ubuntu_image/env_bashrc.csv
   :widths: 20,40,40
   :header-rows: 1

上述使用 ``ENV`` 设置镜像环境变量在执行类似 ``docker exec <container> gopls`` 命令时，由于没有使用SHELL，会导致 ``.bashrc`` 中设置的环境变量失效，但是如果在 ``ENV`` 中定义的环境变量则依然有效。
