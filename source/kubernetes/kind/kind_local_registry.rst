.. _kind_local_registry:

======================
kind集群本地Registry
======================

虽然使用 :ref:`load_kind_image` 可以用于部署自己的定制镜像，但是使用上有一些不直观。通常我们都是习惯将制作好的镜像推送到Registry中，然后在 Kubernetes 的YAML中直接使用Registry地址。

kind也提供了一种符合我们使用习惯的的本地Registry方式，即在本地Docker中运行一个Local Registry，然后配置kind集群使用这个Local Registry。

创建Registry
===================

`kind User Guide: Local Registry <https://kind.sigs.k8s.io/docs/user/local-registry/>`_ 提供了一个脚本来构建本地Registry并配置集群使用，我做了一些调整，以适配我在 :ref:`kind_multi_node` 部署的集群 ``dev`` :

- ``kind-with-registry.sh`` 脚本:

.. literalinclude:: kind_local_registry/kind-with-registry.sh
   :language: bash
   :caption: 运行Registry适配kind集群(dev)

- 执行 ``./kind-with-registry.sh`` 创建集群 ``dev`` ，同时可以看到运行了一个 ``kind-registry`` 的容器提供服务

使用Registry
================

将 :ref:`alpine_docker_image` 构建的本地 ``alpine-nginx`` 推送到Local Registry进行测试:

- 检查镜像 ``docker images`` ，当前输出如下::

   REPOSITORY                    TAG                  IMAGE ID       CREATED         SIZE
   alpine-nginx                  latest               236634f9c6b8   3 hours ago     14.5MB

- 将镜像打上tag，标记为local registry::

   docker tag alpine-nginx localhost:5001/alpine-nginx:latest

- 此时检查 ``docker images`` 输出如下::

   REPOSITORY                    TAG                  IMAGE ID       CREATED         SIZE
   alpine-nginx                  latest               236634f9c6b8   3 hours ago     14.5MB
   localhost:5001/alpine-nginx   latest               236634f9c6b8   3 hours ago     14.5MB

- 将镜像推入Local Reistry::

   docker push localhost:5001/alpine-nginx

此时输出信息类似::


   Using default tag: latest
   The push refers to repository [localhost:5001/alpine-nginx]
   9992941a9f7b: Pushed 
   e9f76b9eead8: Pushed 
   e40a27ff8335: Pushed 
   ea0f922ba68b: Pushed 
   1f6b17cd478d: Pushed 
   17bec77d7fdc: Pushed 
   latest: digest: sha256:05e38376828b2d2279517c04e93c2a0b072abbaf0fcbc8e32422c047e9a2c03d size: 1578

- 我们现在来模拟一个简单的Kubernetes部署::

   kubectl create deployment test-nginx --image=localhost:5001/alpine-nginx

提示::

   deployment.apps/test-nginx created

- 检查 kind 部署的这个pod::

   kubectl get pods -o wide

可以看到已经成功运行::

   NAME                          READY   STATUS    RESTARTS   AGE   IP           NODE          NOMINATED NODE   READINESS GATES
   test-nginx-84bcff4756-wszqn   1/1     Running   0          35s   10.244.3.2   dev-worker4   <none>           <none>

这只是第一步验证，实际上要访问部署在pod的服务，还需要一些步骤:

  - :ref:`kind_ingress`
  - :ref:`kind_loadbalancer`

参考
=======

- `kind User Guide: Local Registry <https://kind.sigs.k8s.io/docs/user/local-registry/>`_
