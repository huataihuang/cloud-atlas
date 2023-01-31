.. _docker_macos_kind_port_forwarding:

==================================================
Docker Desktop for mac 端口转发(port forwarding)
==================================================

在完成 :ref:`metallb_with_kind` 之后，也就已经实现了标准Kubernets集群应用部署的输出了。但是对于 :ref:`docker_desktop_network` 限制，实际上整个Kubernets都是在一个Linux虚拟机中运行，从物理足迹 :ref:`macos` 上不能直接访问这个输出地址，还需要做一个端口转发(port forwarding)来访问。

.. note::

   在 :ref:`mobile_cloud_x86_kind` ，采用直接在Linux物理主机上部署 :ref:`kind` 就没有这个麻烦，外部可以直接访问

解决方案
============

- 在 :ref:`docker_desktop` 中运行一个连接 ``kind`` bridge 的容器 ``dev-gw`` ( Gateway，为了精简系统采用 :ref:`fedora_tini_image` 的 ``dev-ssh`` 基础镜像 )
- 在 ``dev-gw`` 运行时使用 ``-p`` 参数将所有需要从外部访问的端口都映射到这个 ``dev-gw`` 容器上
- 在 ``dev-gw`` 内部运行 :ref:`iptables` 实现端口转发，转发到 :ref:`metallb_with_kind` 输出的LoadBalancer的 ``EXTERNAL-IP`` 的端口，实现访问 :ref:`kind` 部署的应用

.. note::

   另一种方式是采用 :ref:`docker_squid` 运行反向代理服务器来实现端口转发

部署
=======

- 基于 :ref:`fedora_tini_image` 的 ``fedora-ssh-tini`` 做一些改进定制构建一个 ``fedora-gw`` 镜像:

.. literalinclude:: docker_macos_kind_port_forwarding/Dockerfile
   :language: dockerfile
   :caption: 构建 ``fedora-gw`` 镜像的Dockerfile

- 构建 ``fedora-gw`` 镜像:

.. literalinclude:: docker_macos_kind_port_forwarding/build_fedora-gw_image
   :language: bash
   :caption: 构建 ``fedora-gw`` 镜像

- 基于 ``fedora-gw`` 镜像运行 ``dev-gw`` 容器 :

.. literalinclude:: docker_macos_kind_port_forwarding/run_dev-gw_container
   :language: bash
   :caption: 基于 ``fedora-gw`` 镜像运行 ``dev-gw`` 容器，将host主机的 10000-10099 端口全部映射到这个网关容器

.. note::

   Docker支持端口范围的Port Mapping，不需要一个个映射可以方便这个 ``fedora-gw`` 容器内部自行进行端口转发。但是，我发现端口映射会拖慢Docker容器启动的速度(例如我尝试映射999个端口)，所以我最终改为只映射99个端口(小型开发测试环境足够了)
