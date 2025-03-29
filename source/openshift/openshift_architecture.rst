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

OpenShift 没有采用常规的操作系统作为基础镜像，而是采用专用于容器的CoreOS。对于企业市场，采用的是 RHEL CoreOS，你可以认为是类似于 :ref:`fedora_coreos` 的RHEL定制版本。由于我的实践采用社区 ``OKD`` ，所以对应采用的就是 :ref:`fedora_coreos` 。实际上，各个容器厂商和发行版厂商都有针对容器化技术的精简定制系统，例如Docker采用 :ref:`alpine_linux` 作为基础镜像。

OpenShift的 :ref:`fedora_coreos` / Red Hat Enterprise Linux CoreOS(RHCOS) 在部署配置过程中使用 ``Ignition`` 来完成

.. warning::

   OpenShift Container Platform只支持 RHCOS (Red Hat Enterprise Linux CoreOS) 作为操作系统，对应于社区OKD，则只支持 :ref:`fedora_coreos` 。需要注意，这个限制是对于管控平面或者master主机是强依赖(管控服务器只能用RHCOS)，不过worker节点可以使用RHEL(也就是说也可以使用CentOS)。

这里有两种部署 RHCOS / :ref:`fedora_coreos` 方法:

- 如果使用OpenShift/OKD来管理的基础架构上安装集群，则 CoreOS 会在安装过程中下载到目标平台，此时 ``Ignition`` 配置文件也同时下载并用于部署机器。你可以认为这是一个 kickstart 安装 CoreOS 过程
- 如果要把OpenShift/OKD安装到现有基础架构上，则需要按照安装手册下载RHCOS镜像，生成Ignition配置文件，并使用Ignition配置文件来配置主机




组件
======

- OpenShift service mesh 和 OpenShift serverless: 基于 :ref:`knative`
- OpenShift virtualization: 基于 :ref:`kubevirt`
- OpenShift Pipelines: 基于 :ref:`tekton`

参考
=======
