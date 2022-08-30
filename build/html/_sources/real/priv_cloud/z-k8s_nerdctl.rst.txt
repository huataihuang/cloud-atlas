.. _z-k8s_nerdctl:

==================================
Kubernetes集群(z-k8s)使用nerdctl
==================================

在完成 :ref:`z-k8s` 之后，我们需要使用 :ref:`nerdctl` 来完成镜像制作和管理，已经推送镜像到 :ref:`z-k8s_docker_registry` 以实现应用部署

buildkit安装和准备
====================

- 安装 :ref:`nerdctl` (minimal版本，即只安装 ``nerdctl`` ):

.. literalinclude:: ../../kubernetes/container_runtimes/containerd/nerdctl/install_nerdctl
   :language: bash

- 从 `buildkit releases <https://github.com/moby/buildkit/releases>`_ 下载最新 :ref:`buildkit` 解压缩后移动到 ``/usr/bin`` 目录下 :

.. literalinclude:: ../../docker/moby/buildkit/buildkit_startup/install_buildkit
   :language: bash

- 运行(需要先安装和运行 OCI(runc) 和 containerd):

.. literalinclude:: ../../docker/moby/buildkit/buildkit_startup/buildkitd
   :language: bash
   :caption: 使用root身份运行buildkitd，启动后工作在前台等待客户端连接

- 配置 ``/etc/buildkit/buildkitd.toml`` :

.. literalinclude:: ../../docker/moby/buildkit/buildkit_startup/buildkitd.toml
   :language: bash
   :caption: 配置 /etc/buildkit/buildkitd.toml

然后就可以使用 :ref:`nerdctl` 工具执行 ``nerdctl build`` 指令来构建镜像。

使用nerdctl构建镜像
=====================

.. literalinclude:: ../../docker/init/docker_systemd/fedora-systemd.dockerfile
   :language: dockerfile
   :caption: fedora官方镜像增加systemd，注释中包含启动方法
