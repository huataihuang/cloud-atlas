.. _privoxy_docker_ssh_tunneling:

===============================
Privoxy Docker SSH Tunneling
===============================

.. note::

   本文是一个快捷构建Docker容器自由上网的方案，是多个技术的组合方案

   目的是方便我的 :ref:`gentoo_linux` 容器使用。对于其他发行版或环境也是通用的 :ref:`docker_proxy` 方案。

我在 Android 手机上采用 :ref:`privoxy_android_ssh_tunneling` 也是一种简洁的通用方法，例如，对于物理主机运行 :ref:`gentoo_linux` 是非常容易设置 :ref:`ssh_tunneling_dynamic_port_forwarding` 为 :ref:`firefox` 设置 :ref:`across_the_great_wall` 。但是，对于 :ref:`gentoo_docker` 众多的虚拟容器，显然也需要一个通用的代理方式，以满足容器的无阻碍访问互联网:

- 物理主机启动 :ref:`ssh_tunneling_dynamic_port_forwarding` 提供本地回环地址 socks 代理
- 物理主机 :ref:`gentoo_linux` 上安装 :ref:`privoxy` 并设置上游代理为本地 socks5 代理，这样只要访问这个 ``privoxy`` 的客户端都能科学上网: 注意 ``privoxy`` 仅对以下2个地址绑定服务:

  - ``127.0.0.1`` 本地回环地址
  - ``172.17.0.1`` Docker的NAT网络地址，这样运行容器访问这个IP地址 ``8118`` 就能够使用物理主机代理

- 配置 :ref:`docker_client_proxy` ，这样每个运行的docker容器都会注入代理配置

启动SSH Tunneling
==================

- 在物理主机上执行简单的一条命令构建起本地socks代理，创建SSH Tunnel:

.. literalinclude:: ../../../infra_service/ssh/ssh_tunneling_dynamic_port_forwarding/ssh_tunnel_dynamic
   :caption: 执行一条命令建立起动态端口转发的翻墙ssh tunnel

安装和运行privoxy
=======================

- 我的 :ref:`gentoo_linux` 安装 ``privoxy`` (其他发行版安装方法不同，但后续配置方法相同):

.. literalinclude:: privoxy_docker_ssh_tunneling/gentoo_privoxy
   :caption: 在 :ref:`gentoo_linux` 上安装 ``privoxy``

- 配置 ``/etc/privoxy/config`` 设置绑定IP以及上游socks5代理:

.. literalinclude:: privoxy_docker_ssh_tunneling/privoxy.config
   :caption: ``/etc/privoxy/config`` 设置绑定IP以及上游socks5代理

- 启动 ``privoxy`` 服务(注意，我的 :ref:`gentoo_linux` 使用的是 :ref:`openrc` 服务管理):

.. literalinclude:: privoxy_docker_ssh_tunneling/openrc_privoxy
   :caption: 在 :ref:`openrc` 配置 ``privoxy``

配置 :ref:`docker_client_proxy`
===================================

- 配置 ``~/.docker/config.json`` 设置指向privoxy代理:

.. literalinclude::  privoxy_docker_ssh_tunneling/config.json
   :language: json
   :caption: 配置 ``~/.docker/config.json`` 设置Docker客户端代理

则创建的docker容器会注入代理配置的环境变量

**如果上述docker代理配置注入无效，则手工配置容器环境变量添加如下** :

.. literalinclude::  privoxy_docker_ssh_tunneling/bashrc
   :caption: 手工配置docker容器的用户环境变量使用代理
