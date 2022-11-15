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

.. literalinclude:: kind-config.yaml
   :language: yaml
   :linenos:
   :caption: 

- 执行创建集群，集群命名为 ``dev`` ::

   kind create cluster --name dev --config kind-config.yaml

- 完成以后检查集群::

   kubectl --context kind-dev get nodes

可以看到创建的集群节点如下::

   NAME                 STATUS   ROLES    AGE     VERSION
   dev-control-plane    Ready    master   2m15s   v1.18.2
   dev-control-plane2   Ready    master   99s     v1.18.2
   dev-control-plane3   Ready    master   49s     v1.18.2
   dev-worker           Ready    <none>   32s     v1.18.2
   dev-worker2          Ready    <none>   32s     v1.18.2
   dev-worker3          Ready    <none>   32s     v1.18.2
   dev-worker4          Ready    <none>   29s     v1.18.2
   dev-worker5          Ready    <none>   32s     v1.18.2

通过 ``docker ps`` 命令可以看到，kind还多启动了一个容器来运行haproxy，以提供外部访问这个集群的apiserver的负载均衡分发，例如以下案例中端口 ``33401`` 就是访问该集群的apiserver端口(见第一行)::

   #docker ps
   CONTAINER ID        IMAGE                          COMMAND                  CREATED             STATUS              PORTS                       NAMES
   48309bdd8439        kindest/haproxy:2.1.1-alpine   "/docker-entrypoint.…"   42 hours ago        Up 42 hours         127.0.0.1:33401->6443/tcp   dev-external-load-balancer
   b0f8267aa09a        kindest/node:v1.18.2           "/usr/local/bin/entr…"   42 hours ago        Up 42 hours                                     dev-worker2
   524c7b50790b        kindest/node:v1.18.2           "/usr/local/bin/entr…"   42 hours ago        Up 42 hours                                     dev-worker
   9790bbe67900        kindest/node:v1.18.2           "/usr/local/bin/entr…"   42 hours ago        Up 42 hours         127.0.0.1:21003->6443/tcp   dev-control-plane
   21c86c9750dd        kindest/node:v1.18.2           "/usr/local/bin/entr…"   42 hours ago        Up 42 hours         127.0.0.1:32351->6443/tcp   dev-control-plane3
   8abd58281f54        kindest/node:v1.18.2           "/usr/local/bin/entr…"   42 hours ago        Up 42 hours                                     dev-worker5
   634df18e345e        kindest/node:v1.18.2           "/usr/local/bin/entr…"   42 hours ago        Up 42 hours                                     dev-worker4
   06d46f9ff05e        kindest/node:v1.18.2           "/usr/local/bin/entr…"   42 hours ago        Up 42 hours         127.0.0.1:14861->6443/tcp   dev-control-plane2
   a8f88cb59b1b        kindest/node:v1.18.2           "/usr/local/bin/entr…"   42 hours ago        Up 42 hours                                     dev-worker3

所以，在运行 kind 的服务器上执行::

   kubectl cluster-info

可以看到如下输出::

   Kubernetes master is running at https://127.0.0.1:33401
   KubeDNS is running at https://127.0.0.1:33401/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

   To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.


