.. _k8s_controller:

========================
Kubernetes 控制器
========================

- 控制器概念: 设定期望状态( ``Desired State`` )，控制器通过监控集群的状态(state)，不断循环(loop)来调节集群的 **当前状态** (current state)去接近 **期望状态** (desired state)

- 控制器模式(Controller pattern): 

  - 一个控制器至少跟踪一个Kubernetes资源类型: **对象** 有一个代表期望状态的 ``spec`` 字段，资源控制器的任务就是确保当前状态接近期望状态
  - 控制器可以自动执行操作，也可以由控制器发送信息给API Server来完成操作(这种模式更常见)

    - 控制器自动执行操作: 常见的是和集群外部平台交互，例如确保集群有足够多的节点(也就是调用云平台底座来不断维护Kubernetes的可用节点，例如故障服务器维修替换)
    - 控制器调用API Server完成操作: 例如Job Controller就是典型的Kubernetes内置控制器，通过和API Server交互来执行任务

Kuternetes使用了很多控制器，每个控制器管理集群的一个特定方面。这种分工设计，使得Kubernetes能够分摊工作，不集中到一个单点组件上。

参考
=====

- `Kubernetes 文档 >> 概念 >> Kubernetes 架构 >> 控制器 <https://kubernetes.io/zh-cn/docs/concepts/architecture/controller/>`_
