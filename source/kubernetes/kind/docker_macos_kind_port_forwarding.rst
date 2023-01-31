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

.. note::

   镜像 :ref:`dockerfile` 添加了 ``iptables`` 工具( ``iptables-services`` )以及必要的运维工具

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

.. note::

   在容器内部使用 ``iptables`` 需要在运行容器时添加参数 ``--cap-add=NET_ADMIN`` 和 ``--cap-add=NET_RAW`` (从 Docker 1.2开始支持)

检查和验证
------------

- 检查运行起来的 ``dev-gw`` 可以看到运行的容器实现了 ``10000-10099`` 的端口范围映射，并且 ``ssh -p 122`` 从host主机能够登陆到 ``dev-gw`` 容器中 :

.. literalinclude:: docker_macos_kind_port_forwarding/check_dev-gw_container
   :language: bash
   :caption: 检查 ``dev-gw`` 容器
   :emphasize-lines: 3,5,7

- 在 :ref:`metallb_with_kind` 配置了负载均衡流量转发到后端 :ref:`k8s_services` ``fedora-dev-service`` ，可以看到对外服务的 ``EXTERNAL-IP`` 是 ``172.22.255.201`` 

.. literalinclude:: ../network/metallb/metallb_with_kind/get_services
   :language: bash
   :caption: 配置 ``fedora-dev-tini`` 设置LoadBalancer服务类型后 ``kubectl get services`` 显示服务具备了 ``EXTERNAL-IP``
   :emphasize-lines: 3

端口转发
==========

- 在 ``dev-gw`` 内部执行 ``iptables`` 进行端口转发:

.. literalinclude:: docker_macos_kind_port_forwarding/iptables_port_forwarding
   :language: bash
   :caption: ``dev-gw`` 容器内执行iptables转发端口

.. note::

   这里我遇到一个错误，在容器内部无法修改 ``/proc/sys/net/ipv4/ip_forward`` ，提示报错::

      iptables_port_forwarding: line 3: /proc/sys/net/ipv4/ip_forward: Read-only file system

   Docker虚拟机内核参数必须在host主机，也就是 :ref:`docker_macos_vm` 内修改

- 使用 :ref:`docker_macos_vm` 中方法进入Docker 虚拟机中:

.. literalinclude:: ../../docker/desktop/docker_macos_vm/docker_run_nsenter
   :language: bash
   :caption: 通过nsenter进入运行容器的控制台

在Docker VM内部执行以下命令开启内核IP转发::

   echo 1 > /proc/sys/net/ipv4/ip_forward

此时就完成了所有端口转发的配置，从Host主机访问本机(所有网络接口)的端口 ``10001`` 都会被 :ref:`docker_desktop` 映射到 ``dev-gw`` 虚拟机，然后又被 ``dev-gw`` 端口转发给目标 :ref:`metallb_with_kind` 对外提供的 ``fedora-dev`` 虚拟机的 ``fedora-dev-service`` 服务上(对外提供了多个服务端口)。整个过程虽然繁复，但是能够真正实现访问 :ref:`kind` 集群提供的Kubernetes服务，和生产环境没有差别。

改进
=======

- 为了方便快捷完成端口转发，修订运行 ``dev-gw`` 容器的命令，将 ``iptables_port_forwarding`` 脚本直接 ``bind`` 到容器内部，这样随时可以在物理主机上修改好脚本，只要重新创建一次容器就可以运行了:

.. literalinclude:: docker_macos_kind_port_forwarding/run_dev-gw_container_bind_mounts
   :language: bash
   :caption:  ``dev-gw`` 容器运行时bind mount进端口转发脚本，方便自动执行
   :emphasize-lines: 3


下一步
========

接下来需要解决如何将物理主机映射到 :ref:`docker_desktop` 内部并被 :ref:`kind` 运行的容器挂载，这样就能够方便在物理主机上保存数据，实现在Kubernetes容器中进行各种开发和模拟，数据不会丢失:

- :ref:`docker_macos_kind_nfs_sharing`

参考
========

- `Installing iptables in docker container based on alpinelinux <https://stackoverflow.com/questions/41706983/installing-iptables-in-docker-container-based-on-alpinelinux>`_ 
