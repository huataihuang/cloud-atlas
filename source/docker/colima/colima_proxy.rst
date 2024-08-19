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
