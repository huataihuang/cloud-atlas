.. _alpine_cfssl:

============================
编译安装cfssl(Alpine Linux)
============================

在部署 :ref:`k3s_ha_etcd` 之前，需要先准备用于签发 :ref:`etcd_tls` 工具 ``cfssl`` 。虽然可以用其他发行版提供的 ``cfssl`` ，不过，我还是决定在部署 :ref:`k3s` 的 :ref:`alpine_linux` 环境中完整实现Kuberntes，所以先使用 :ref:`dockerfile` 构建 ``x-dev`` 容器，再安装 ``cfssl`` 工具。

构建x-dev容器
===============

- 采用 :ref:`alpine_dev` 的Dockerfile配置:

.. literalinclude:: ../../linux/alpine_linux/alpine_dev/alpine-dev
   :language: dockerfile
   :caption: alpine构建开发环境的Dockerfile

- 执行以下命令构建镜像并启动容器:

.. literalinclude:: ../../linux/alpine_linux/alpine_dev/alpine-dev_docker
   :language: bash
   :caption: 构建alpine开发环境docker容器

- 登陆容器::

   ssh 127.0.0.1 -p 122

通过软件仓库安装cfssl
=======================

- Alpine Linux的 community 仓库提供了 ``cfssl`` ，但是需要使用 ``test`` 分支::

   apk add cfssl --update-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing/ --allow-untrusted

通过源代码编译安装cfssl
=========================

通过 :ref:`alpine_dev` 安装的 :ref:`golang` 编译 ``cfssl`` 工具链可以验证Go编译环境安装是否正确::

   git clone git@github.com:cloudflare/cfssl.git
   cd cfssl
   make

编译完成后在 ``bin`` 目录下有以下执行文件::

   bin
   ├── cfssl
   ├── cfssl-bundle
   ├── cfssl-certinfo
   ├── cfssl-newkey
   ├── cfssl-scan
   ├── cfssljson
   ├── mkbundle
   ├── multirootca
   └── rice

参考
======

- `GitHub:cloudflare/cfssl <https://github.com/cloudflare/cfssl>`_
