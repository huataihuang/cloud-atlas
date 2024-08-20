.. _colima_proxy:

=================
Colima代理
=================

对于中国的软件开发者、运维者来说，要顺利使用 ``dockerhub`` 来获取镜像， :ref:`proxy` 是必须采用的技术，所以也要为Colima解决绕过GFW阻塞的问题。

我最初没有使用代理，发现 :ref:`debian_tini_image` 无法拉取镜像:

.. literalinclude:: images/debian_tini_image/ssh/build_debian-ssh-tini_image
   :caption: 执行镜像构建

始终报错:

.. literalinclude:: colima_proxy/build_err
   :caption: 无法下载镜像导致构建失败
   :emphasize-lines: 14

此外，在 ``colima ssh`` 进入 :ref:`lima` 虚拟机内部，就会发现即使 :ref:`ubuntu_linux` 系统更新( ``apt update`` )也是存在和 :ref:`docker` 更新相关错误:

.. literalinclude:: colima_proxy/apt_err
   :caption: 在 :ref:`lima` 虚拟机内执行 ``apt update`` 报错
   :emphasize-lines: 12

分析和解决思路
================

这个问题需要采用 :ref:`docker_proxy` 方式解决:

- :ref:`ubuntu_linux` 系统需要 :ref:`set_linux_system_proxy` ：至少需要配置 :ref:`apt` 的代理
- :ref:`docker` / :ref:`containerd` 需要配置 :ref:`docker_server_proxy` ，这样可以让容器运行时能够下载镜像
- 容器内部需要通过 :ref:`docker_client_proxy` 注入代理配置，这样容器内部的应用就能够顺畅访问internet

代理服务器
============

我个人的经验是使用轻量级的HTTP/HTTPS代理 :ref:`privoxy` 最为简单(服务器无缓存)，如果希望更为稳定和企业级，则选择 :ref:`squid` (服务器有缓存)，不过对实际效果没有太大影响，都是非常好的选择。

- 首先通过 :ref:`ssh_tunneling` 构建一个本地到远程服务器代理服务端口(服务器上代理服务器仅监听回环地址)的SSH加密连接。我实际采用的是在 ``~/.ssh/config`` 配置如下:

.. literalinclude:: colima_proxy/ssh_config
   :caption: ``~/.ssh/config`` 配置 :ref:`ssh_tunneling` 构建一个本地到远程服务器Proxy端口加密连接

- 执行构建SSL Tunnel:

.. literalinclude:: colima_proxy/ssh
   :caption: 通过SSH构建了本地的一个SSH Tunneling到远程服务器的 :ref:`proxy` 服务

apt代理
=========

- 修改Colima虚拟机内部配置 ``/etc/apt/apt.conf.d/01-vendor-ubuntu`` 添加一行 :ref:`apt` 代理配置:

.. literalinclude:: colima_proxy/apt_proxy
   :caption: 在 apt 配置中添加代理设置

现在再次执行 ``apt update && apt upgrade`` 就不会有任何GFW的阻塞，顺利完成虚拟机操作系统更新

docker/containerd 服务器代理
==============================

Colima虚拟机内部运行的 docker/containerd 需要设置代理以便能够下载镜像运行容器:

Docker服务器代理
-------------------

我的实践中虚拟机中运行containerd取代默认的Docker:

.. literalinclude:: colima_startup/colima_vz_4c8g
   :caption: 使用 ``vz`` 模式虚拟化的 ``4c8g`` 虚拟机运行 ``colima``

所以这段Docker服务器代理设置是我之前实践 :ref:`docker_server_proxy` ( 👈 请参考)

Containerd服务器代理
---------------------

Colima虚拟机内部使用的操作系统是 :ref:`ubuntu_linux` ，完整使用了 :ref:`systemd` 系统来管理进程服务，所以可以采用我之前的实践 :ref:`containerd_proxy` 相同方法:

- 修订 ``/etc/environment`` 添加代理配置:

.. literalinclude:: colima_startup/environment
   :caption: ``/etc/environment`` 设置代理环境变量

- ``colima ssh`` 重新登陆系统使上述代理环境变量生效，然后执行以下脚本为containerd服务添加代理配置:

.. literalinclude:: ../../kubernetes/container_runtimes/containerd/containerd_proxy/create_http_proxy_conf_for_containerd
   :language: bash
   :caption: 生成 /etc/systemd/system/containerd.service.d/http-proxy.conf 为containerd添加代理配置
   :emphasize-lines: 7-9

但是我发现一个尴尬的问题，当 ``containerd`` 开始同步时是使用代理的(因为我看到如果虚拟机内部不启动SSH tunnel，则出现如下访问代理报错::

   error: failed to solve: debian:latest: failed to authorize: failed to fetch anonymous token: Get "https://auth.docker.io/token?scope=repository%3Alibrary%2Fdebian%3Apull&service=registry.docker.io": proxyconnect tcp: dial tcp 127.0.0.1:3128: connect: connection refused

但是我发现接下来的https请求居然不再走代理，原因是我发现它报错信息解析的地址 ``production.cloudflare.docker.com => 210.209.84.142`` 是我本地虚拟机解析DNS的结果::

   error: failed to solve: DeadlineExceeded: DeadlineExceeded: DeadlineExceeded: debian:latest: failed to copy: httpReadSeeker: failed open: failed to do request: Get "https://production.cloudflare.docker.com/registry-v2/docker/registry/v2/blobs/sha256/19/19fa7f391c55906b0bbe77bd45a4e7951c67ed70f8054e5987749785450c0442/data?verify=1724172530-5QFH8JiRFjY5RRAQqyHkaNW0Kb4%3D": dial tcp 210.209.84.142:443: i/o timeout

而不是远在墙外squid服务器解析的域名地址(不同地区解析同一个域名返回的地址不同)。看起来 :ref:`containerd` 的代理设置并不是和 :ref:`docker_proxy` 一致，这让我很困扰。

发现colima会将HOST主机proxy环境变量注入虚拟机
------------------------------------------------

我偶然发现，如果我的 macOS 操作系统环境变量设置了代理，例如:

.. literalinclude:: colima_startup/macos_env
   :caption: 如果macOS的host环境配置了代理变量

则重新启动colima虚拟机之后，这个环境变量会注入到虚拟机内部，但是会做修改(IP地址从 ``127.0.0.1`` 调整为 ``192.168.5.2`` )，而且这个修改是写到虚拟机内部 ``/etc/environment`` 中:

.. literalinclude:: colima_startup/colima_environment_proxy
   :caption: Colima启动时会自动将HOST物理主机proxy环境变量注入到虚拟机 ``/etc/environment``
   :emphasize-lines: 3-5

.. warning::

   为了解决这个问题，我重新用空白的macOS环境来执行 ``colima start`` ，避免导入这个 ``192.168.5.2`` 作为代理配置。不过，似乎这个配置和 ``127.0.0.1`` 是同一个回环地址

**继续折腾**
