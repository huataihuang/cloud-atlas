.. _nerdctl:

================
nerdctl
================

nerdctl 是 ``containerd`` 子项目，提供Docker兼容的CLI命令:

- 类似 :ref:`docker` 的交互方式
- 支持Docker Compose
- 支持rootless模式
- 支持 lazy-pulling (例如 :ref:`estargz_lazy_pulling` )
- 支持加密镜像
- 支持P2P镜像分发 ( :ref:`ipfs` )
- 支持容器镜像签名和验证

安装
======

- 从 `nerdctl releases <https://github.com/containerd/nerdctl/releases>`_ 下载软件包::

   tar xfz nerdctl-0.22.0-linux-amd64.tar.gz
   sudo mv nerdctl /usr/bin/

官方下载有两种软件包:

  - Minimal (nerdctl-0.22.0-linux-amd64.tar.gz): nerdctl only
  - Full (nerdctl-full-0.22.0-linux-amd64.tar.gz): Includes dependencies such as containerd, runc, and CNI

我安装的是Minimal版本，其他组件按需各自安装

快速起步
============

- 有root权限方式::

   sudo systemctl enable --now containerd
   sudo nerdctl run -d --name nginx -p 80:80 nginx:alpine

.. note::

   由于我是安装了 :ref:`containerd` 服务，是通过root模式运行的，所以后续操作以这个root权限方式为准。也就是后续 ``nerdctl`` 命令操作都是使用 ``sudo nerdctl`` 

- 无root权限方式(端口1024以上)::

   containerd-rootless-setuptool.sh install
   nerdctl run -d --name nginx -p 8080:80 nginx:alpine

实践:镜像
============

``nerdctl`` 对镜像的制作是采用 :ref:`buildkit` 实现的，请先安装 ``buildkit`` 并运行 ``buildkitd`` 服务进程

.. literalinclude:: ../../../docker/moby/buildkit/buildkit_startup/buildkitd
   :language: bash
   :caption: 使用root身份运行buildkitd，启动后工作在前台等待客户端连接

- 我这里采用 :ref:`dockerfile` 的 ``centos8-ssh`` :

.. literalinclude:: ../../../docker/admin/dockerfile/centos8-ssh
   :language: dockerfile
   :caption: CentOS 8的Dockerfile，包括ssh安装

执行以下命令构建:

.. literalinclude:: nerdctl/nerdctl_build
   :language: bash
   :caption: nerdctl build构建容器镜像

此时提示信息:

.. literalinclude:: nerdctl/nerdctl_build_fail_output
   :language: bash
   :caption: nerdctl build构建容器镜像的输出信息

这里报错应该是网络问题，待修复...

参考
======

- `nerdctl: Docker-compatible CLI for containerd <https://github.com/containerd/nerdctl>`_
- `Rancher desktop: Working with Images <https://docs.rancherdesktop.io/tutorials/working-with-images>`_
