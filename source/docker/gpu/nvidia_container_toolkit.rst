.. _nvidia_container_toolkit:

============================
NVIDIA Container Toolkit
============================

:ref:`nvidia-docker` 已经被 ``NVIDIA Container Toolkit`` 取代，用于构建和运行GPU加速的 :ref:`container` 。 ``NVIDIA Container Toolkit`` 包含了一个容器运行库 `libnvidia-container <https://github.com/NVIDIA/libnvidia-container>`_ 

.. note::

   在Host主机上只需要 :ref:`install_nvidia_linux_driver_ubuntu` ，不需要完整安装 :ref:`cuda`

Ubuntu/Debian系统安装
========================

- 首先安装必要的工具:

.. literalinclude:: nvidia_container_toolkit/prepare
   :caption: 安装工具

- 配置仓库:

.. literalinclude:: nvidia_container_toolkit/repo
   :caption: 仓库

.. note::

   配置仓库时 :ref:`curl` 很可能被防火墙阻挡无法下载，首先设置 :ref:`ssh_tunneling_dynamic_port_forwarding` :

   .. literalinclude:: ../../infra_service/ssh/ssh_tunneling_dynamic_port_forwarding/ssh_config
      :caption: 配置动态端口转发的 ~/.ssh/config
      :emphasize-lines: 12

   则只需要执行 ``ssh MyProxy`` 就立即建立起动态端口转发

   需要配置 :ref:`curl_proxy` :

   .. literalinclude:: ../../web/curl/curl_proxy/socks5_proxy_env
      :caption: 配置curl的socks5代理环境变量

.. note::

   另外可选配置使用测试性软件包:

   .. literalinclude:: nvidia_container_toolkit/repo_experimental
      :caption: 可选的测试性配置(我没有使用)

- 更新仓库:

.. literalinclude:: nvidia_container_toolkit/update_repo
   :caption: 更新仓库

.. note::

   在添加NVIDIA仓库之后，也同样需要配置 :ref:`apt_proxy` :

   .. literalinclude:: ../../linux/ubuntu_linux/admin/apt/proxy.conf
      :caption: 配置APT代理 ``/etc/apt/apt.conf.d/proxy.conf``

- 安装 ``NVIDIA Container Toolkit`` 软件包:

.. literalinclude:: nvidia_container_toolkit/install
   :caption: 安装 ``NVIDIA Container Toolkit``

配置
============

根据NVIDIA官方文档 `Installing the NVIDIA Container Toolkit <https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html>`_ ，NVIDIA Container Toolkit支持4种 :ref:`container_runtimes` :

.. csv-table:: 容器引擎对比
   :file: nvidia_container_toolkit/container_runtime.csv
   :widths: 20,20,20,20,20
   :header-rows: 1

考虑到我的HomeLab需要灵活构建镜像以及方便维护，我选择"开箱即用"的 :ref:`docker` ，这样能够灵活使用 :ref:`docker_compose` 快速构建多容器组合运行。当然，如果在生产环境使用 :ref:`kubernetes` ，精简工作节点的架构，则推荐采用 :ref:`containerd` 。

安装 Docker CE
------------------

为了能够灵活和强大配置，我选择安装Docker官方提供的Docker CE:

- 设置Docker官方apt仓库:

.. literalinclude:: ../startup/install_docker-ce/apt_repo
   :caption: 设置Docker apt仓库

- 安装Docker软件包

.. literalinclude:: ../startup/install_docker-ce/apt_install
   :caption: 安装Docker官方软件包

- 启动docker服务:

.. literalinclude:: ../startup/install_docker-ce/start_docker
   :caption: 启动docker服务

- 将当前用户加入 ``docker`` 组，这样后续就无需 ``sudo`` 就可以管理                                               
                                                                                                                 
.. literalinclude:: ../startup/install_docker_linux/usermod
   :caption: 将当前用户添加到 ``docker`` 用户组

配置 Docker
-------------

- 使用 ``nvidia-ctk`` 命令来配置容器运行时:

.. literalinclude:: nvidia_container_toolkit/nvidia-ctk
   :caption: 配置容器运行时

输出显示

.. literalinclude:: nvidia_container_toolkit/nvidia-ctk_output
   :caption: 配置容器运行时的输出信息

- 然后重启Docker服务:

.. literalinclude:: ../startup/install_docker-ce/restart_docker
   :caption: 重启docker服务


参考
=======

- `GitHub: NVIDIA/nvidia-container-toolkit <https://github.com/NVIDIA/nvidia-container-toolkit>`_
