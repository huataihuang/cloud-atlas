.. _understand_k8s_objects:

===================
理解Kubernetes对象
===================

``Kubernetes Objects`` 是kubernetes系统的持久实体。Kubernetes使用这些实体来表述集群的状态。特别是，Kubernetes对象可以描述:

- 哪些容器化应用正在运行（以及在哪个节点运行）
- 应用程序的可用资源
- 应用程序特性相关的策略，例如重启策略，更新以及故障恢复侧露

Kubernetes对象是一种"声明的记录" -- 一旦创建对象，Kubernetes系统将持续确保对象存在。即创建对象就是要求集群持续照看对象，确保集群的终态正确。

对象规格和状态
===============

每个kubernetes对象包含两个嵌套对象字段决定了对象配置：

- object spec（对象规格）：描述对象的终态，即你需要对象具有的特性
- object status（对象状态）：描述对象当前实际状态，这个状态是通过kubernetes系统提供更新

在 ``任何时刻`` ，Kubernetes管控平台（Kubernetes Control Plane）将实时管理对象的状态(object status)以符合你指定的状态(object spec)。例如，设置deployment spec指定运行的应用程序采用3副本，则Kubernetes系统会读取部署规格并启动3个指定应用程序实例以更新状态符合你的spec。任何实例故障（即状态变化），kubernetes就会对比两个spec差异并修正状态 -- 也就是启动一个替代实例，使得最终状态依然保持3个应用程序运行实例。

描述Kubernetes对象
====================

在创建Kubernetes对象时，需要提供 obejct spec 描述对象的终态。这样，在使用 Kuernetes API创建对象（或者通过 ``kubectl`` ），API请求中必须包含使用JSON作为请求内容的信息。 通常是通过一个 ``.yaml`` 文件提供信息给 ``kubectl`` ，而 ``kubectl`` 会将yaml数据转换成JSON然后发出API请求。

kubernetes官方提供的案例 ``deployment.yaml`` 可以帮助我们理解如何完成一个部署::

   kubectl apply -f https://k8s.io/examples/application/deployment.yaml --record

执行后提示信息::

   deployment.apps/nginx-deployment created

- ``application/deployment.yaml``

.. literalinclude:: kubernetes_objects_example/application/deployment.yaml
   :language: yaml
   :linenos:

- 解析 ``application/deployment.yaml``
  - ``apiVersion: apps/v1`` 设置创建对象时使用的Kubernetes API版本
  - ``kind: Deployment`` 创建对象的类型
  - ``metadata`` - 元数据唯一标识对象，包括 ``name`` 字符串， ``UID`` 和可选的 ``namespace``
  - 需要提供对象 ``spec`` 字段，对象 ``spec`` 的清晰格式对于每个Kubernetes对象都是不同的，并且包含嵌套字段来描述对象。

执行上述创建后，kubernetes将根据模版（标签是 ``app: nginx`` ）采用指定镜像 ``image: nginx:1.7.9`` 创建容器，采用端口 ``containerPort: 80`` 共创建2个pod（ ``replicas: 2`` ），并且这个容器的模版具备了标签 ``app: nginx`` 。

.. figure:: ../../../_static/kubernetes/deployment_pod_example.png
   :scale: 25

- 检查部署::

   kubectl get deployments

输出::

   NAME               READY   UP-TO-DATE   AVAILABLE   AGE
   nginx-deployment   2/2     2            2           91m

可以进一步检查这个部署::

   kubectl get deployments nginx-deployment -o yaml

   kubectl describe deployments nginx-deployment

则可以看到详细的部署信息

- 检查pod::

   kubectl get pods

输出::

   NAME                               READY   STATUS    RESTARTS   AGE
   nginx-deployment-6dd86d77d-lmg92   1/1     Running   0          90m
   nginx-deployment-6dd86d77d-zr9c4   1/1     Running   0          90m

.. note::

   虽然已经启动了pod，但是此时还没有把部署输出到外部网络，所以此时还无法访问nginx的页面。请参考 :ref:`kubernetes_expose_service` 完成服务输出。

   在kubernetes中展示的pod命名和运行主机上的docker容器命名相关，在物理主机上使用 ``docker ps`` 可以看到 ``XXXX_nginx-deployment-6dd86d77d-lmg92_YYYY`` 命名的容器。

参考
===========

- `Understanding Kubernetes Objects <https://kubernetes.io/docs/concepts/overview/working-with-objects/kubernetes-objects/>`_
