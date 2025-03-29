.. _intro_openshift:

==================
OpenShift简介
==================

.. note::

   我的实践基于OpenShift社区版本 ``OKD`` ，所以后续文档中基本不区分两者，只在特定差异部分注明。

   文档会同时参考 `Red Hat官方OpenShift文档 <https://access.redhat.com/documentation/en-us/openshift_container_platform/4.10>`_  以及 `OKD开源社区文档 <https://docs.okd.io/latest/welcome/index.html>`_ ，进行两者对比梳理，并结合自己的部署实践。

   Red Hat官方文档提供了中文版(社区只有英文)，所以相对更为方便，可以快速阅读。

OpenShift
===========



OKD
======

OKD是OpenShift的 **社区版本** ，提供了针对 ``持续应用部署`` 和 ``多租户部署`` 优化的 :ref:`kubernetes` 社区分发。OKD在Kubernetes之上添加了开发和中心化操作工具，以便能够快速部署应用，灵活扩展应用以及面向小型和大型团队的应用长期生命周期维护。OKD提供了在云计算或裸金属服务器上运行Kubernetes能力，并且简化了运行和更新集群的方式，也提供了容器化运行的全面工具。

OKD功能
---------

- 在主流云计算和裸金属，以及 :ref:`openstack` 或其他虚拟化供应商平台上自动部署Kubernetes
- 集成了服务发现和持久化存储的轻松构建应用
- 按需快速和方便的扩展应用
- 支持自动化高可用，负载均衡，健康检查和故障切换
- 通过Operator Hub扩展了Kubernetes的自动化应用生命周期管理
- 在Kubernetes上提供了构建容器化应用的开发者中心话工具和控制台
- 只需要将源代码推送到Git仓库就能自动化部署容器化应用
- 构建和监控应用的WEB控制台和命令行工具
- 面向全栈、团队和组织的中心化管理
- 为系统的组件创建可重用模版，就能够随时部署
- 以可控方式滚动修改软件堆栈
- 可以集成到现有认证系统，包括LDAP，Active Diretory以及类似GitHub的公共OAuth认证
- 多租户支持，包括团队和用户隔离的容器、构建和网络通讯
- 在生产环境提供良好授权控制的容器安全
- 在平台提供限制、跟踪和管理开发者以及团队的能力
- 集成容器镜像仓库，自动化边缘负载均衡以及使用 :ref:`prometheus` 全面监控

OKD技术堆栈
-------------

- :ref:`kubernetes`
- :ref:`podman`
- :ref:`fedora_coreos`
- Operator Framework : 参见 `Red Hat OpenShift Operators <https://www.redhat.com/en/technologies/cloud-computing/openshift/what-are-openshift-operators>`_
- :ref:`cri-o`
- :ref:`prometheus`

参考
=======

- `About OKD <https://www.okd.io/about/>`_
