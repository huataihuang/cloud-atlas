.. _colima_proxy_archive:

======================
Colima代理(文章归档)
======================

.. note::

   2025年5月，再次部署使用Colima，发现 containerd 版本已经更新到 v2.0.0 ，并且 :ref:`lima` 运行的虚拟机已经是 :ref:`ubuntu_linux` ``24.04.1 LTS`` ，其中代理部分已经和我之前的实践有所不同。所以我重新实践并记录为 :ref:`colima_proxy` ，本文改为归档参考。

   **本文归档，仅供参考** ，现在请参考 :ref:`colima_proxy`

对于中国的软件开发者、运维者来说，要顺利使用 ``dockerhub`` 来获取镜像， :ref:`proxy` 是必须采用的技术，所以也要为Colima解决绕过GFW阻塞的问题。

我最初没有使用代理，发现 :ref:`debian_tini_image` 无法拉取镜像:

.. literalinclude:: images/debian_tini_image/ssh/build_debian-ssh-tini_image
   :caption: 执行镜像构建

始终报错:

.. literalinclude:: colima_proxy_archive/build_err
   :caption: 无法下载镜像导致构建失败
   :emphasize-lines: 14

此外，在 ``colima ssh`` 进入 :ref:`lima` 虚拟机内部，就会发现即使 :ref:`ubuntu_linux` 系统更新( ``apt update`` )也是存在和 :ref:`docker` 更新相关错误:

.. literalinclude:: colima_proxy_archive/apt_err
   :caption: 在 :ref:`lima` 虚拟机内执行 ``apt update`` 报错
   :emphasize-lines: 12

解决实践小结
=============

如果你没有耐心看完本文，这里给出一个结论:

- 只需要在物理主机上配置好代理服务器的用户环境变量，例如我使用 :ref:`ssh_tunneling` 访问远端服务器的 :ref:`squid` / :ref:`privoxy`
- 执行 ``colima start`` 启动colima虚拟机的时候，会自动将物理主机环境变量中有关代理配置设置注入虚拟机，不过只有 :ref:`apt` 解决了 :ref:`across_the_great_wall` (此时可以顺利执行 ``apt update && apt upgrade``
- 需要同时配置 :ref:`docker_server_proxy` 和 :ref:`containerd_server_proxy` (目前我的验证，尚未验证是否可以只配置其中之一)
- 在 ``colima`` 虚拟机内部配置 :ref:`docker_client_proxy` 这样执行 ``docker build`` 就能够在docker客户端获取meta信息，再进一步盗用docker/containerd服务器端下载镜像

.. warning::

   配置代理需要同时满足 docker 客户端和服务器的代理设置，单方面配置客户端和服务器端都不能实现代理跨越GFW

分析和解决思路
================

这个问题需要采用 :ref:`docker_proxy` 方式解决:

- :ref:`ubuntu_linux` 系统需要 :ref:`set_linux_system_proxy` ：至少需要配置 :ref:`apt` 的代理
- :ref:`docker` / :ref:`containerd` 需要配置 :ref:`docker_server_proxy` ，这样可以让容器运行时能够下载镜像
- 容器内部需要通过 :ref:`docker_client_proxy` 注入代理配置，这样容器内部的应用就能够顺畅访问internet

代理服务器(之前的尝试，可行但复杂，留作参考)
==============================================

我个人的经验是使用轻量级的HTTP/HTTPS代理 :ref:`privoxy` 最为简单(服务器无缓存)，如果希望更为稳定和企业级，则选择 :ref:`squid` (服务器有缓存)，不过对实际效果没有太大影响，都是非常好的选择。

- 首先通过 :ref:`ssh_tunneling` 构建一个本地到远程服务器代理服务端口(服务器上代理服务器仅监听回环地址)的SSH加密连接。我实际采用的是在 ``~/.ssh/config`` 配置如下:

.. literalinclude:: colima_proxy_archive/ssh_config
   :caption: ``~/.ssh/config`` 配置 :ref:`ssh_tunneling` 构建一个本地到远程服务器Proxy端口加密连接

- 执行构建SSL Tunnel:

.. literalinclude:: colima_proxy_archive/ssh
   :caption: 通过SSH构建了本地的一个SSH Tunneling到远程服务器的 :ref:`proxy` 服务

apt代理
----------

- 修改Colima虚拟机内部配置 ``/etc/apt/apt.conf.d/01-vendor-ubuntu`` 添加一行 :ref:`apt` 代理配置:

.. literalinclude:: colima_proxy_archive/apt_proxy
   :caption: 在 apt 配置中添加代理设置

现在再次执行 ``apt update && apt upgrade`` 就不会有任何GFW的阻塞，顺利完成虚拟机操作系统更新

**Colima虚拟机内部运行的 docker/containerd 需要设置代理以便能够下载镜像运行容器:**

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

.. literalinclude:: colima_proxy_archive/environment
   :caption: ``/etc/environment`` 设置代理环境变量

- ``colima ssh`` 重新登陆系统使上述代理环境变量生效，然后执行以下脚本为containerd服务添加代理配置:

.. literalinclude:: ../../kubernetes/container_runtimes/containerd/containerd_proxy/create_http_proxy_conf_for_containerd
   :language: bash
   :caption: 生成 /etc/systemd/system/containerd.service.d/http-proxy.conf 为containerd添加代理配置
   :emphasize-lines: 7-9

代理服务器再次尝试(建议方案)
==============================

发现colima会将HOST主机proxy环境变量注入虚拟机
------------------------------------------------

在晚上折腾时偶然发现，如果我的 macOS 操作系统环境变量设置了代理，例如:

.. literalinclude:: colima_proxy_archive/macos_env
   :caption: 如果macOS的host环境配置了代理变量

则重新启动colima虚拟机之后，这个环境变量会注入到虚拟机内部，但是会做修改(IP地址从 ``127.0.0.1`` 调整为 ``192.168.5.2`` )，而且这个修改是写到虚拟机内部 ``/etc/environment`` 中:

.. literalinclude:: colima_proxy_archive/colima_environment_proxy
   :caption: Colima启动时会自动将HOST物理主机proxy环境变量注入到虚拟机 ``/etc/environment``
   :emphasize-lines: 3-5

我忽然想到，既然Colima将我的HOST物理主机的 ``PROXY`` 相关环境变量在启动 :ref:`lima` 虚拟机时候注入到虚拟机内部作为环境变量，那么说明Colima开发者默认就是让虚拟机继承物理服务器的代理配置。同时，观察到Colima在虚拟机的 ``/etc/environment`` 标准配置中添加了代理配置，但是很巧妙地将物理主机 ``127.0.0.1`` 回环地址转变成了 ``192.158.5.2`` ，也就是对应虚拟机( ``192.168.5.1`` )的默认网关( ``192.168.5.2`` )。这说明，Colima会借助物理主机的代理服务器访问外网。

综上所述，看起来完全不用手工配置虚拟机内部服务的代理，而是之际在启动 ``colima`` 虚拟机时，操作命令所在的HOST物理主机shell环境变量PROXY相关设置会自动注入，来解决Colima虚拟机内部的代理。这是Colima的feature。

通过HOST物理主机 ``HTTP_PROXY`` 配置注入虚拟机
------------------------------------------------

- 首先删除掉刚才测试的虚拟机，准备干净地启动一个全新虚拟机:

.. literalinclude:: colima_startup/colima_delete
   :caption: 执行 ``colima delete`` 删除不需要的colima虚拟机(所有数据丢失!!!)

- 在启动 ``colima`` 虚拟机之前，先确保发起启动的用户的环境变量如下(配置到 ``~/.zshrc`` 中，或者直接在SHELL中执行):

.. literalinclude:: colima_proxy_archive/macos_env
   :caption: macOS的host环境 ``colima start`` 用户的环境变量配置代理

- 重新创建colima虚拟机:

.. literalinclude:: colima_startup/colima_vz_4c8g
   :caption: 使用 ``vz`` 模式虚拟化的 ``4c8g`` 虚拟机运行 ``colima``

- 果然，这次干净启动的 ``colima`` 虚拟机内部注入了原先在HOST物理主机配置的PROXY相关配置， ``colima ssh`` 登陆后检查 ``/etc/environment`` 可以看到配置:

.. literalinclude:: colima_proxy_archive/colima_environment_proxy
   :caption: Colima启动时会自动将HOST物理主机proxy环境变量注入到虚拟机 ``/etc/environment``
   :emphasize-lines: 3-8

注意，这里配置环境变量 ``HTTP_PROXY`` / ``http_proxy`` ，有全大写也有全小写，这是因为不同的程序的默认差异，比较搞...

``HTTP_PROXY`` 配置注入虚拟机的 colima.yaml
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

实际上还有一个更为方便的注入方法，就是使用 ``$HOME/.colima/default/colima.yaml`` 直接添加PROXY配置:

.. literalinclude:: colima_proxy_archive/colima_proxy.yaml
   :language: YAML
   :caption: ``$HOME/.colima/default/colima.yaml`` 直接添加PROXY配置

新的困扰
============

其实上述两种方案(虚拟机内部配置 :ref:`containerd_server_proxy` 和 通过注入HOST主机PROXY配置到colima虚拟机)都是完成相同的工作，看起来都很完善。但是，我实际构建 :ref:`colima_images` 还是再次遇到了报错(两个方法都是一样的报错):

当 ``containerd`` 开始同步时是使用代理的(因为我看到如果不启动SSH tunnel，则出现如下访问代理报错::

   error: failed to solve: debian:latest: failed to authorize: failed to fetch anonymous token: Get "https://auth.docker.io/token?scope=repository%3Alibrary%2Fdebian%3Apull&service=registry.docker.io": proxyconnect tcp: dial tcp 127.0.0.1:3128: connect: connection refused

   这里代理IP地址也可能是 ``192.168.5.2`` ，取决于采用上述两个方案之一

但是我发现接下来的https请求居然不再走代理，原因是我发现它报错信息解析的地址 ``production.cloudflare.docker.com => 210.209.84.142`` 是我本地虚拟机解析DNS的结果::

   error: failed to solve: DeadlineExceeded: DeadlineExceeded: DeadlineExceeded: debian:latest: failed to copy: httpReadSeeker: failed open: failed to do request: Get "https://production.cloudflare.docker.com/registry-v2/docker/registry/v2/blobs/sha256/19/19fa7f391c55906b0bbe77bd45a4e7951c67ed70f8054e5987749785450c0442/data?verify=1724172530-5QFH8JiRFjY5RRAQqyHkaNW0Kb4%3D": dial tcp 210.209.84.142:443: i/o timeout

而不是远在墙外squid服务器解析的域名地址(不同地区解析同一个域名返回的地址不同)。看起来 :ref:`containerd` 的代理设置并不是和 :ref:`docker_proxy` 一致，这让我很困扰。

那么怎么解决这个问题呢？

Colima是Docker/Containerd混合体?
---------------------------------------

我原本以为我在 ``colima start`` 运行时传递了参数 ``--runtime containerd`` 就会在 ``colima`` 虚拟机中只单纯运行 :ref:`containerd` 从而避免运行 ``dockerd`` 。然而，事实证明不管怎样，实际上服务器上是通过 ``dockerd`` 去访问 ``containerd`` ( **containerd.sock** )。

从服务器上 ``systemctl status dockerd`` 和 ``systemctl status conainerd`` 可以看到，两个服务同时在运行:

.. literalinclude:: colima_proxy_archive/systemctl_status
   :emphasize-lines: 12,35

这说明需要同时设置 :ref:`docker` 和 :ref:`containerd` 的代理配置，特别是 :ref:`docker_server_proxy` 

:ref:`systemd` 的 :ref:`docker` 方法见 :ref:`docker_server_proxy` ( ``/etc/default/docker`` 配置是针对 ``SysVinit`` 配置，对systemd不生效) ，其实也是设置 :ref:`systemd` 启动配置的环境变量

.. literalinclude:: ../../docker/network/docker_proxy/create_http_proxy_conf_for_docker
   :language: bash
   :caption: 生成 /etc/systemd/system/docker.service.d/http-proxy.conf 为docker服务添加代理配置
   :emphasize-lines: 7-9

现在，加上前面配置 :ref:`containerd_server_proxy` ，实际上服务器端运行时(containerd)和管控(docker)都已经启用的PROXY代理。可以通过在colima虚拟机内部检查 ``systemctl show <service_name> --property Environment`` 查看:

.. literalinclude:: colima_proxy_archive/systemctl_show_env
   :caption: 通过 ``systemctl show`` 检查 ``Environment`` 属性

输出显示 ``docker`` 和 ``containerd`` 都已经具备了PROXY环境配置

然而很不幸，我发现 ``nerdctl build`` 输出依然是报错， ``httpReadSeeker`` 复制错误。奇怪，为何没有通过代理来访问 docker 官方仓库？::

   error: failed to solve: DeadlineExceeded: DeadlineExceeded: DeadlineExceeded: debian:latest: failed to copy: httpReadSeeker: failed open: failed to do request: Get "https://production.cloudflare.docker.com/registry-v2/docker/registry/v2/blobs/sha256/19/19fa7f391c55906b0bbe77bd45a4e7951c67ed70f8054e5987749785450c0442/data?verify=1724231825-HSnthXcWUnRbhLGA8eMXCizsEq8%3D": dial tcp 199.59.150.43:443: i/o timeout

我理解实际上 ``nerdctl build`` 和 ``docker build`` 并不仅仅是服务器端需要访问internet，有一部分数据是通过客户端这边下载的，也就是META数据是通过客户端下载，来定位需要下载的镜像，再由服务器端去pull镜像。这个逻辑导致客户端和服务器端都要能够跨越GFW。

我突然感觉到是 ``nerdctl`` 客户端的问题，看起来 ``nerdctl build`` 不支持代理？ 我尝试在客户端(macOS HOST主机以及colima虚拟机内部都设置了 ``http_proxy`` 和 ``HTTP_PROXY`` 环境变量，避免大小写差异)，但是始终没有解决通过代理访问问题。

从 ``nerdctl build --help`` 输出来看，没有提供 proxy 相关配置 -- **nerdctl这样的docker复刻工具实际上功能做了精简，并不能完全支持docker丰富的功能**

``最终的解决之道``
=====================

最终解决，说来难以置信地简单，就是: 如果要使用代理服务器来下载docker镜像，务必使用 ``docker`` 客户端来管理，支持代理； ``nerdctl`` 客户端不支持代理。

具体解决方法是: 在 ``colima`` 虚拟机内部执行 ``docker build`` 命令，这样结合前面的的服务器配置:

- ``colima start`` 通过HOST物理主机 ``HTTP_PROXY`` 配置注入虚拟机，此时仅解决 :ref:`apt` 翻墙
- 配置 :ref:`docker_server_proxy` 和 :ref:`containerd_server_proxy` (目前我验证两者都配置，没有验证是否可以只配置其中之一) 确保服务器端能够翻墙拉取镜像
- 一定要在 ``colima`` 虚拟机内部，配置 docker 客户端使用代理，即配置 ``~/.docker/config.json`` 如下:

.. literalinclude:: colima_proxy/config.json
   :caption: 配置 ``colima`` 虚拟机内部 ``docker`` 客户端使用代理 ``~/.docker/config.json``

- 最后一定要使用 ``docker build`` 才能支持客户端使用代理， ``nerdctl`` 客户端不支持代理

参考
========

- `Pulling docker images from behind a company VPN #294 <https://github.com/abiosoft/colima/issues/294>`_
 
