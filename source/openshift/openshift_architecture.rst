.. _openshift_architecture:

==============================
OpenShift架构
==============================

管控平面(control plane)
=========================

OpenShift和 :ref:`kubernetes` 类似采用了 control plane + worker 模式，也就是集群分为两种角色:

- 管控平面: 管理worker节点和集群中的pod

  - 使用operator来打包、部署和管理 control plane 的服务(pods)
  - 健康检查
  - 监控应用
  - 实现在线更新
  - 确保应用终态(也就是K8S的面向状态的理念)

OpenShift容器化应用是通过以下技术来实现的:

- 使用 构建工具、基础镜像 和 镜像中心(registry) 来实现应用容器化和灵活部署
- 使用 OperatorHub 和 模版 来开发应用
- 将应用程序打包和部署成 Operator (尚未理解)

OpenShift 没有采用常规的操作系统作为基础镜像，而是采用专用于容器的CoreOS。对于企业市场，采用的是 RHEL CoreOS，你可以认为是类似于 :ref:`fedora_coreos` 的RHEL定制版本。由于我的实践采用社区 ``OKD`` ，所以对应采用的就是 :ref:`fedora_coreos` 。

组件
======

- OpenShift service mesh 和 OpenShift serverless: 基于 :ref:`knative`
- OpenShift virtualization: 基于 :ref:`kubevirt`
- OpenShift Pipelines: 基于 :ref:`tekton`

参考
=======
