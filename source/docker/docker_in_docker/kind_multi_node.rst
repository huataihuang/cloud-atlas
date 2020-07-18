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

.. note::

   我发现物理服务器重启以后，docker容器自动恢复，则apiserver映射端口可能变化，此时使用 ``kubectl --context kind-dev get nodes`` 会显示访问拒绝。

   我目前解决方法是使用 ``docker ps`` 检查当前运行实例的端口映射，例如输出::

      CONTAINER ID        IMAGE                  COMMAND                  CREATED             STATUS              PORTS                       NAMES
      b45fbc686a7e        kindest/node:v1.18.2   "/usr/local/bin/entr…"   5 weeks ago         Up 9 days                                       dev-worker5
      ccb37b172d80        kindest/node:v1.18.2   "/usr/local/bin/entr…"   5 weeks ago         Up 9 days                                       dev-worker4
      ed9d75f5372c        kindest/node:v1.18.2   "/usr/local/bin/entr…"   5 weeks ago         Up 9 days           127.0.0.1:20393->6443/tcp   dev-control-plane2
      87d67866ae4c        kindest/node:v1.18.2   "/usr/local/bin/entr…"   5 weeks ago         Up 9 days           127.0.0.1:36379->6443/tcp   dev-control-plane3
      01e52aaad127        kindest/node:v1.18.2   "/usr/local/bin/entr…"   5 weeks ago         Up 9 days           127.0.0.1:20923->6443/tcp   dev-control-plane
      d1e9cf091d97        kindest/node:v1.18.2   "/usr/local/bin/entr…"   5 weeks ago         Up 9 days                                       dev-worker
      79ab28c0f6a6        kindest/node:v1.18.2   "/usr/local/bin/entr…"   5 weeks ago         Up 9 days                                       dev-worker2

   则可以看到访问apiserver的端口是 ``20393 / 36379 / 20923`` ，则只需要修改一下 ``.kube/config`` 配置文件，修订访问apiserver的端口到上述3个端口之一就可以继续使用 ``kubectl`` 来管理集群了。
