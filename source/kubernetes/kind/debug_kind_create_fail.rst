.. _debug_kind_create_fail:

=============================
排查kind集群创建失败
=============================

我在 :ref:`asahi_linux` (ARM架构) :ref:`kind_multi_node` 执行:

.. literalinclude:: kind_multi_node/kind_create_cluster
   :language: yaml
   :caption: kind构建3个管控节点，5个工作节点集群配置

遇到之前在CentOS 8(x86_64)平台没有遇到过的报错(启动管控平台初始化失败):

.. literalinclude:: kind_multi_node/kind_create_cluster_fail_output
   :language: yaml
   :caption: kind集群创建失败输出信息
   :emphasize-lines: 92,93

这里看到提示信息是使用 ``systemctl status kubelet`` 等命令来排查，但是 ``kind`` 是一个 ``docker_in_docker`` 容器，也就是说在物理服务器上是没有 ``kubelet`` 的，需要进入第一层docker容器来执行这个检查命令

注意启动报错::

   Creating cluster "kind" ...
    ✓ Ensuring node image (kindest/node:v1.25.3) 🖼
    ✓ Preparing nodes 📦  
    ✓ Writing configuration 📜 
    ✗ Starting control-plane 🕹 
   ERROR: failed to create cluster: failed to init node with kubeadm: command "docker exec --privileged kind-control-plane kubeadm init --skip-phases=preflight --config=/kind/kubeadm.conf --skip-token-print --v=6" failed with error: exit status 1

使用的node镜像是 ``kindest/node:v1.25.3``

排查方法
==========

- 再次启动 ``kind create cluster`` 命令，在容器运行时立即执行 ``docker exec -it <CONTAINER_ID> /bin/bash`` 登录到容器内部检查::

   systemctl status kubelet

可以看到报错信息:

.. literalinclude:: kind_multi_node/kind_systemctl_status_kubelet_error
   :language: yaml
   :caption: kind节点容器systemctl status kubelet报错信息
   :emphasize-lines: 16

这里可以看到启动 ``Failed to create sandbox for pod`` ，原因是 ``runc create failed: unable to start container process: exec: \\\"/pause\\\": stat /pause: operation not supported: unknown``

原因分析
========


这个问题和ARM架构有关，参考 `Failed to Create Cluster on M1 #2448 <https://github.com/kubernetes-sigs/kind/issues/2448>`_ 提出的 ``workaroudn`` 方法::

   As a workaround, having a Dockerfile:
   
   FROM --platform=arm64 kindest/node:v1.21.1
   RUN arch
   
   building it:
   
   docker build -t tempkind .
   
   and using that image:
   
   kind create cluster --image tempkind 

我参考这个方法执行以下步骤:

- 针对ARM架构创建指定平台架构的镜像:

.. literalinclude:: kind_multi_node/build_arm_kind_image.sh
   :language: bash
   :caption: 构建ARM架构的kind镜像

- 此时执行 ``docker images`` 就会看到如下镜像:

.. literalinclude:: kind_multi_node/docker_images_arm64
   :language: bash
   :caption: 针对ARM的镜像

- 然后执行以下命令使用特定ARM64镜像创建集群:

.. literalinclude:: kind_multi_node/kind_create_cluster_arm64
   :language: bash
   :caption: 指定ARM镜像创建kind集群
