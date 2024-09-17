.. _install_docker_raspberry_pi_os:

=======================================
树莓派Raspberry Pi OS(64位)安装Docker
=======================================

.. note::

   根据Docker官方说明，树莓派Raspberry Pi OS(64位)安装Docker的方法和Debian是一样的，所以本文也作为Debian安装Docker的参考

准备工作
===========

防火墙
--------

- 如果 :ref:`ubuntu_linux` / :ref:`debian` 使用了 :ref:`ufw` 则需要设置防火墙允许访问docker输出的容器端口
- docker只兼容 ``iptables-nft`` 和 ``iptables-legacy`` ，通过 ``nft`` 创建的防火墙规则不被Docker安装的系统所支持。确保所有防火墙规则是通过 ``iptables`` 或 ``ip6tables`` 创建，并且将规则添加到 ``DOCKER-USER`` 链路

操作系统
------------

在64位Debian(Raspberry Pi OS)上支持以下版本:

- Debian Bookworm 12 (stable)
- Debian Bullseye 11 (oldstable)

Docker Engine for :ref:`debian` 兼容 x86_64 (amd64), armhf, arm64, 以及 ppc64le (ppc64el) 架构

卸载旧版本
------------

安装Docker官方的Docker Engine之前，务必卸载系统上任何冲突版本:

- docker.io
- docker-compose
- docker-doc
- podman-docker

.. literalinclude:: install_docker_raspberry_pi_os/uninstall_old_docker
   :caption: 卸载系统上的旧版本Docker

安装
======

Docker官方文档提供了多种安装途径，不过我的实践只选择通过官方 :ref:`apt` 仓库安装

- 设置 Debian(Raspberry Pi OS) 的Docker apt仓库:

.. literalinclude:: install_docker_raspberry_pi_os/apt
   :caption: 设置Docker的apt仓库

- 需要配置 :ref:`curl_proxy` :

.. literalinclude::  ../../web/curl/curl_proxy/environment
   :caption: 设置操作系统环境配置了代理变量 ``/etc/environment``

- 安装Docker最新版本:

.. literalinclude:: install_docker_raspberry_pi_os/debian_install_docker
   :caption: 安装Docker

- 设置 :ref:`run_docker_without_sudo` :

.. literalinclude:: install_docker_linux/usermod
   :caption: 将当前用户添加到 ``docker`` 用户组

参考
======

- `Install Docker Engine on Debian <https://docs.docker.com/engine/install/debian/>`_
