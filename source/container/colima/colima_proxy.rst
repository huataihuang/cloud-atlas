.. _colima_proxy:

===========================
Colima 代理
===========================

2025年5月，我在旧笔记本 :ref:`mbp15_late_2013` 重新部署 :ref:`colima` 。由于时隔多时，软件堆栈有了很大的更新，我想重新实践和整理手册，修订之前 :ref:`colima_proxy_archive` 中过时的操作步骤，通过简洁有效的方式实现 :ref:`across_the_great_wall` 完成容器的流畅部署。

之所以需要设置Colima代理，是因为GFW屏蔽了 ``dockerhub`` 导致无法直接从开源社区获取官方镜像。例如在build镜像:

.. literalinclude:: images/debian_tini_image/dev/build_debian-dev_image
   :caption: 构建镜像

此时显示访问registry仓库端口超时:

.. literalinclude:: colima_proxy/build_error
   :caption: 构建镜像网络超时报错
   :emphasize-lines: 14

未代理之前的初始部署
=====================

:ref:`colima_startup` 中采用基本启动运行方式:

.. literalinclude:: colima_startup/colima_qemu_2c4g
   :caption: 使用 ``qemu`` 模式虚拟化的 ``2c4g`` 虚拟机运行 ``colima``

- 这里运行指定了 :ref:`containerd` 作为 runtime，所以Colima虚拟机内部只有 ``containerd`` 一个服务，没有安装 :ref:`docker` 。现在需要通过 ``colima ssh`` 登陆到Colima虚拟机内部完成 ``docker`` 服务安装:

.. literalinclude:: colima_proxy/install_docker
   :caption: 登陆到Colima虚拟内部安装docker服务

Host主机代理准备
==================

Colima使用的代理通道是在Host主机(macOS)上创建的，在macOS上执行以下命令构建 :ref:`ssh_tunneling` :

代理配置注入虚拟机
===================

Host主机环境变量方法
---------------------

如果在执行 ``colima start`` 命令时，Host主机的环境变量中包含代理配置，例如:

.. literalinclude:: colima_proxy/proxy_env
   :caption: 环境变量中包含代理配置

Colima虚拟机配置文件方法
------------------------

上述通过Host主机环境变量注入proxy配置的方法要求Host主机shell环境中必须有代理配置，如果这个环境变量在启动colima之前被修改就会不起作用(如果环境变量是临时手工输入的)。所以，更为可靠的方法是修订Colima配置。

- 修改 ``~/.colima/default/colima.yaml`` :

.. literalinclude:: colima_proxy/colima.yaml
   :language: yaml
   :caption: ``$HOME/.colima/default/colima.yaml`` 直接添加PROXY配置

代理配置注入虚拟机的分析和要点
--------------------------------

完成上述两种配置方法之一以后，启动的 ``default`` Colima虚拟机会自动注入代理配置，也就是 ``colima ssh`` 登陆到虚拟机内部检查 ``env | grep -i proxy`` 会看到和Host主机一样的配置:

.. literalinclude:: colima_proxy/colima_env
   :caption: 在 ``colima`` 虚拟机内部检查 ``env`` 输出可以看到注入的代理配置

上述配置是 ``colima`` 虚拟机启动时自动添加到虚拟机内部的 ``/etc/environment`` 中实现的，即虚拟机内部可以看到动态在 ``/etc/environment`` 中添加了如下配置行:

.. literalinclude:: colima_proxy/environment
   :caption: 在 ``colima`` 虚拟机内部 ``/etc/environment`` 中自动添加的代理配置
   :emphasize-lines: 3-8

.. note::

   注入的proxy配置的IP地址，在Host主机上的 ``127.0.0.1:3128`` 会自动转换成Colima虚拟机内部的 ``192.168.5.2:3128``

   这是正确的: 因为这个 ``192.168.5.2`` 代表了Host物理主机。此时只需要在Host物理主机上创建起 :ref:`ssh_tunneling` 连接墙外服务器的 :ref:`squid` 代理端口，就能够 :ref:`across_the_great_wall`

.. warning::

   需要 ``注意`` ，在Host主机上的待注入配置或环境变量配置 **必须使用完整格式** ，也就配置项必须带上 ``http://`` ，不可以是简化格式。我实践发现，如果使用以下简化配置(虽然在macOS的Host主机上工作正常):
   
   .. literalinclude:: colima_proxy/proxy_env_simple
      :caption: 在Host主机使用简化配置形式(不建议)
   
   会影响 :ref:`apt` 使用，我的实践发现，apt受到这个环境变量影响，但格式会转换导致不支持报错::
   
      Unsupported proxy configured: 127.0.0.1://3128

Colima虚拟机内部容器服务的代理配置
====================================

.. note::

   我最初在 :ref:`colima_proxy_archive` 实践中，因为不确定是 :ref:`docker` 服务还是 :ref:`containerd` 需要代理设置，所以两者都做了配置。但是我现在重新对比验证确认:

   - **只需要诶之docker服务的proxy代理** 环境变量就可以实现镜像通过代理下载
   - :ref:`containerd` 和 :ref:`nerdctl` 不支持代理，所以之前实践中配置containerd的 ``http_proxy`` 和 ``https_proxy`` 环境变量实际上并没有生效(我对比了)

在Colima虚拟机内部运行了 ``docker`` 服务(containerd不需要配置)，需要为这个容器服务配置 :ref:`systemd` 服务的环境变量来传递代理配置

- ``colima ssh`` 登陆到Colima虚拟机内部，执行以下命令创建 ``docker`` 服务的环境配置:

.. literalinclude:: ../../docker/network/docker_proxy/create_http_proxy_conf_for_docker
   :language: bash 
   :caption: 生成 /etc/systemd/system/docker.service.d/http-proxy.conf 为docker服务添加代理配置
   :emphasize-lines: 7-9

- 现在在Colima虚拟机内部，执行以下命令检查 ``docker`` 服务环境配 :

.. literalinclude:: colima_proxy/systemctl_show_env
   :caption: 通过 ``systemctl show`` 检查 ``Environment`` 属性

输出显示 ``docker`` 都已经具备了PROXY环境配置

docker客户端配置
------------------

.. note::

   实践验证，当Colima虚拟机已经注入了 ``http_proxy`` 和 ``https_proxy`` 代理配置环境变量，依然要配置docker客户端的 ``config.json``

docker镜像的下载要通过proxy，不仅需要 ``dockerd`` 配置代理， ``docker`` 客户端程序也需要配置代理。这是因为:

  - docker的meta元数据是通过 ``docker`` 客户端下载的
  - docker容器内部需要注入代理配置，否则容器内部的部分安装执行(被墙)会无法完成

.. note::

   docker镜像内部注入代理配置也可以在 ``Dockerfile`` 中配置:

   .. literalinclude:: colima_proxy/dockerfile_env
      :caption: 在Dockerfile内添加环境变量

- 在 ``colima`` 虚拟机内部配置 ``~/.docker/config.json`` :

.. literalinclude:: colima_proxy/config.json
   :caption: 配置 ``colima`` 虚拟机内部 ``docker`` 客户端使用代理 ``~/.docker/config.json``

构建容器
=========

采用 :ref:`debian_tini_image` 的 ``debian-dev`` :

- ``debian-dev`` 包含了安装常用工具和开发环境:

.. literalinclude:: images/debian_tini_image/dev/Dockerfile
   :language: dockerfile
   :caption: 包含常用工具和开发环境的debian镜像Dockerfile

- 构建 ``debian-dev`` 镜像:

.. literalinclude:: images/debian_tini_image/dev/build_debian-dev_image
   :language: bash
   :caption: 构建包含开发环境的debian镜

- 运行 ``dev`` :

.. literalinclude:: images/debian_tini_image/dev/run_debian-dev_container
   :language: bash
   :caption: 运行包含开发环境的debian容器

此时在Colima中运行的容器 ``dev`` 可以在macOS的Host主机上直接访问(端口1122)::

   ssh admin@127.0.0.1 -p 1122

- 在 ``dev`` 容器中检查就可以看到几乎和Host主机完全一致的HOME目录访问，所有文件都具备，非常方便融合Linux+macOS工作
