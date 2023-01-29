.. _kind_multi_node:

=================
kind多节点集群
=================

在 :ref:`kind_cluster` 可以部署多个集群，不过默认部署的集群都是单个节点的，看上去和 minikube 并没有太大差别，只能验证应用功能，而不能实际演练Kubernetes集群的功能。

kind的真正功能在于部署多节点集群(multi-node clusters)，这种部署提供了完整的集群模拟。

kind官方网站提供了 `kind-example-config <https://raw.githubusercontent.com/kubernetes-sigs/kind/master/site/content/docs/user/kind-example-config.yaml>`_ ，可以通过以下命令创建一个定制的集群::

   kind create cluster --config kind-example-config.yaml

多节点集群实践
===============

- 配置3个管控节点，5个工作节点的集群配置文件如下：

.. literalinclude:: kind_multi_node/kind-config.yaml
   :language: yaml
   :caption: kind构建3个管控节点，5个工作节点集群配置

- 执行创建集群，集群命名为 ``dev`` :

.. literalinclude:: kind_multi_node/kind_create_cluster
   :language: bash
   :caption: kind构建3个管控节点，5个工作节点集群配置

.. note::

   为方便使用， **建议** 采用 :ref:`kind_local_registry` 中脚本方法(配置文件相同，但增加了创建本地Registry步骤)。

.. note::

   如果确实下载困难，可以参考 `kind User Guide: Working Offline <https://kind.sigs.k8s.io/docs/user/working-offline/>`_ 先下载镜像，打包后恢复镜像方法来部署。

ARM构建kind集群fix方法
------------------------

我在 :ref:`asahi_linux` 上创建 ``dev`` 集群启动报错，原因是 ``kind`` 官方提供的 ``kindest/node`` 镜像是multi架构的，在ARM环境会存在架构错误，详见 :ref:`debug_kind_create_fail` 。 ``workaround`` 的方法如下:

- 针对ARM架构创建指定平台架构的镜像:

.. literalinclude:: kind_multi_node/build_arm_kind_image.sh
   :language: bash
   :caption: 构建ARM架构的kind镜像

.. note::

   制作 :ref:`docker_images` 时，可以通过 :ref:`dockerfile_platform` 来实现

- 此时执行 ``docker images`` 就会看到如下镜像:

.. literalinclude:: kind_multi_node/docker_images_arm64
   :language: bash
   :caption: 针对ARM的镜像

- 然后执行以下命令使用特定ARM64镜像创建集群:

.. literalinclude:: kind_multi_node/kind_create_cluster_arm64
   :language: bash
   :caption: 指定ARM镜像创建kind集群

- 则正常完成kind集群创建，输出信息:

.. literalinclude:: kind_multi_node/kind_create_cluster_arm64_output
   :language: bash
   :caption: 指定ARM镜像创建kind集群的正常输出信息

检查
=======

- 检查集群::

   kubectl cluster-info --context kind-dev

状态如下::

   Kubernetes control plane is running at https://127.0.0.1:44963
   CoreDNS is running at https://127.0.0.1:44963/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

   To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.

- 完成以后检查集群::

   kubectl --context kind-dev get nodes

可以看到创建的集群节点如下::

   NAME                 STATUS   ROLES           AGE     VERSION
   dev-control-plane    Ready    control-plane   5m6s    v1.25.3
   dev-control-plane2   Ready    control-plane   4m52s   v1.25.3
   dev-control-plane3   Ready    control-plane   4m      v1.25.3
   dev-worker           Ready    <none>          3m54s   v1.25.3
   dev-worker2          Ready    <none>          3m54s   v1.25.3
   dev-worker3          Ready    <none>          3m54s   v1.25.3
   dev-worker4          Ready    <none>          3m54s   v1.25.3
   dev-worker5          Ready    <none>          3m54s   v1.25.3

通过 ``docker ps`` 命令可以看到，kind还多启动了一个容器来运行haproxy，以提供外部访问这个集群的apiserver的负载均衡分发，例如以下案例中端口 ``40075`` 就是访问该集群的apiserver端口(见第一行)::

   CONTAINER ID   IMAGE                                COMMAND                  CREATED             STATUS             PORTS                       NAMES
   22b5211339aa   kindest/node:v1.25.3-arm64           "/usr/local/bin/entr…"   6 minutes ago       Up 6 minutes       127.0.0.1:40075->6443/tcp   dev-control-plane
   fe81ebfaf493   kindest/node:v1.25.3-arm64           "/usr/local/bin/entr…"   6 minutes ago       Up 6 minutes                                   dev-worker2
   d1d88de19435   kindest/node:v1.25.3-arm64           "/usr/local/bin/entr…"   6 minutes ago       Up 6 minutes                                   dev-worker4
   7af7558e3339   kindest/node:v1.25.3-arm64           "/usr/local/bin/entr…"   6 minutes ago       Up 6 minutes                                   dev-worker3
   d4cd1a9851ca   kindest/node:v1.25.3-arm64           "/usr/local/bin/entr…"   6 minutes ago       Up 6 minutes                                   dev-worker5
   2c84abeb9eeb   kindest/haproxy:v20220607-9a4d8d2a   "haproxy -sf 7 -W -d…"   6 minutes ago       Up 6 minutes       127.0.0.1:44963->6443/tcp   dev-external-load-balancer
   e2fdcb424eab   kindest/node:v1.25.3-arm64           "/usr/local/bin/entr…"   6 minutes ago       Up 6 minutes                                   dev-worker
   619b562dc7bb   kindest/node:v1.25.3-arm64           "/usr/local/bin/entr…"   6 minutes ago       Up 6 minutes       127.0.0.1:45187->6443/tcp   dev-control-plane3
   2d40652bf4f4   kindest/node:v1.25.3-arm64           "/usr/local/bin/entr…"   6 minutes ago       Up 6 minutes       127.0.0.1:35769->6443/tcp   dev-control-plane2

所以，在运行 kind 的服务器上执行::

   kubectl cluster-info

可以看到如下输出::

   Kubernetes control plane is running at https://127.0.0.1:44963
   CoreDNS is running at https://127.0.0.1:44963/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

   To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.

参考
=======

- `kind User Guide: Configuration <https://kind.sigs.k8s.io/docs/user/configuration/>`_
