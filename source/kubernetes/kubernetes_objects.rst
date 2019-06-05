.. _kubernetes_objects:

===================
Kubernetes对象
===================

理解Kubernetes对象
===================

``Kubernetes Objects`` 是kubernetes系统的持久实体。Kubernetes使用这些实体来表述集群的状态。特别是，Kubernetes对象可以描述:

- 哪些容器化应用正在运行（以及在哪个节点运行）
- 应用程序的可用资源
- 应用程序特性相关的策略，例如重启策略，更新以及故障恢复侧露

Kubernetes对象是一种"声明的记录" -- 一旦创建对象，Kubernetes系统将持续确保对象存在。即创建对象就是要求集群持续照看对象，确保集群的终态正确。

对象规格和状态
-----------------

每个kubernetes对象包含两个嵌套对象字段决定了对象配置：

- object spec（对象规格）：描述对象的终态，即你需要对象具有的特性
- object status（对象状态）：描述对象当前实际状态，这个状态是通过kubernetes系统提供更新

在 ``任何时刻`` ，Kubernetes管控平台（Kubernetes Control Plane）将实时管理对象的状态(object status)以符合你指定的状态(object spec)。例如，设置deployment spec指定运行的应用程序采用3副本，则Kubernetes系统会读取部署规格并启动3个指定应用程序实例以更新状态符合你的spec。任何实例故障（即状态变化），kubernetes就会对比两个spec差异并修正状态 -- 也就是启动一个替代实例，使得最终状态依然保持3个应用程序运行实例。

描述Kubernetes对象
---------------------

在创建Kubernetes对象时，需要提供 obejct spec 描述对象的终态。这样，在使用 Kuernetes API创建对象（或者通过 ``kubectl`` ），API请求中必须包含使用JSON作为请求内容的信息。 通常是通过一个 ``.yaml`` 文件提供信息给 ``kubectl`` ，而 ``kubectl`` 会将yaml数据转换成JSON然后发出API请求。



标签和选择器
==============



参考
===========

- `Understanding Kubernetes Objects <https://kubernetes.io/docs/concepts/overview/working-with-objects/kubernetes-objects/>`_
