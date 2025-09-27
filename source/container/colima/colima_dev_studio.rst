.. _colima_dev_studio:

=====================
Colima容器化开发环境
=====================

.. note::

   在colima环境中快速构建了一个基于 :ref:`debian` 的开发容器，综合整理作为快速指南

- :ref:`macos` 中通过 :ref:`homebrew` 安装Colima:

.. literalinclude:: colima_startup/brew_install_colima
   :caption: 在 :ref:`macos` 平台安装colima

- :ref:`colima_startup` 启动VZ虚拟机:

.. literalinclude:: colima_startup/colima_vz_4c8g
   :caption: 使用 ``vz`` 模式虚拟化的 ``4c8g`` 虚拟机运行 ``colima``

.. note::

   如果是早期的Intel架构mac，则不支持 ``--vm-type`` 参数，原因是只有Apple Silicon架构才支持 :ref:`apple_virtualization` (VZ)。所以实际上在Intel架构mac，还需要安装 ``qemu`` 来运行虚拟化 :ref:`lima`

- 修订 ``~/.colima/default/colima.yaml`` 的 :ref:`colima_storage_manage` 管理部分:

.. literalinclude:: colima_storage_manage/colima-docs.yaml
   :caption: ``colima`` 存储挂载配置 ``docs`` 和 ``secrets``
   :emphasize-lines: 14-18

- 确保发起启动的用户的环境变量如下(配置到 ``~/.zshrc`` 中，或者直接在SHELL中执行):

.. literalinclude:: colima_proxy_archive/macos_env
   :caption: macOS的host环境 ``colima start`` 用户的环境变量配置代理

- 重启 ``colima`` 服务，此时会挂载HOST主机上指定目录，并且注入HOST主机的代理配置

.. literalinclude:: colima_startup/colima_restart
   :caption: 重启 colima 虚拟机

进入虚拟机( ``colima ssh`` ) 可以看到目录挂载:

.. literalinclude:: colima_storage_manage/df_docs_output
   :caption: 在 ``colima`` 虚拟机内部通过 ``df -h`` 检查 ``docs`` 目录映射
   :emphasize-lines: 8,11

进入虚拟机( ``colima ssh`` )检查 ``/etc/environment`` 可以看到代理配置:

.. literalinclude:: colima_proxy_archive/colima_environment_proxy
   :caption: Colima启动时会自动将HOST物理主机proxy环境变量注入到虚拟机 ``/etc/environment``
   :emphasize-lines: 3-8

- (物理主机)在HOST主机上 :ref:`ssh_tunneling` 构建一个本地到远程服务器代理服务端口(服务器上代理服务器仅监听回环地址)的SSH加密连接。我实际采用的是在 ``~/.ssh/config`` 配置如下:

.. literalinclude:: colima_proxy_archive/ssh_config
   :caption: ``~/.ssh/config`` 配置 :ref:`ssh_tunneling` 构建一个本地到远程服务器Proxy端口加密连接

- (物理主机)执行构建SSL Tunnel:

.. literalinclude:: colima_proxy_archive/ssh
   :caption: 通过SSH构建了本地的一个SSH Tunneling到远程服务器的 :ref:`proxy` 服务

- 登陆到 ``colima`` 虚拟机内部:

.. literalinclude:: colima_startup/colima_ssh
   :caption: 通过SSH登陆到colima虚拟机内

- 执行以下命令，将 ``colima`` 虚拟机内部的 ``docker`` 和 ``containerd`` 都配置为通过代理访问internet，这样才能正确下载镜像:

.. literalinclude:: ../../docker/network/docker_proxy/create_http_proxy_conf_for_docker
   :language: bash
   :caption: 生成 /etc/systemd/system/docker.service.d/http-proxy.conf 为containerd添加代理配置
   :emphasize-lines: 7-9

.. literalinclude:: ../../kubernetes/container_runtimes/containerd/containerd_proxy/create_http_proxy_conf_for_containerd
   :language: bash
   :caption: 生成 /etc/systemd/system/containerd.service.d/http-proxy.conf 为containerd添加代理配置
   :emphasize-lines: 7-9

- 最后，还需要为 ``colima`` 虚拟机内部用户的 ``docker`` 客户端配置代理(部分meta信息是通过docker客户端下载的)，这里的 ``docker`` 本地用户是 ``huatai`` ，在这个用户身份下配置 ``~/.docker/config.json`` 如下:

.. literalinclude:: colima_proxy/config.json
   :caption: 配置 ``colima`` 虚拟机内部 ``docker`` 客户端使用代理 ``~/.docker/config.json``

**一切准备就绪**

现在可以执行 :ref:`debian_tini_image` 构建，执行的是 dev 容器构建:

- ``debian-dev-tini`` 包含了安装常用工具和开发环境:

.. literalinclude:: images/debian_tini_image/dev/Dockerfile
   :language: dockerfile
   :caption: 包含常用工具和开发环境的debian镜像Dockerfile

- 构建 ``debian-dev-tini`` 镜像:

.. literalinclude:: images/debian_tini_image/dev/build_debian-dev_image
   :language: bash
   :caption: 构建包含开发环境的debian镜像

- 运行 ``debian-dev-tini`` :

.. literalinclude:: images/debian_tini_image/dev/run_debian-dev_container
   :language: bash
   :caption: 运行包含开发环境的debian容器
