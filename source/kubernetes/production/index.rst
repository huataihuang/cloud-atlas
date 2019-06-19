.. _kubernetes_production:

=====================
Kubernees生产环境
=====================

通过在minikube的模拟集群中 :ref:`kubernetes_startup` 为我们掌握Kubernetes打下了基础，但是，Kubernetes的生产环境部署复杂程度远超过单机模拟，需要考虑分布式系统构建、监控、性能、容灾、故障切换等等。

我们在这个章节模拟大规模的Kubernetes集群，并且做各种故障演练，以锻炼出真正适合生产环境的Kubernetes系统。

.. note::

   开发环境和生产环境的差异，可以参考 `Kubernetes in production vs. Kubernetes in development: 4 myths <https://enterprisersproject.com/article/2018/11/kubernetes-production-4-myths-debunked>`_ 和 `7 Key Considerations for Kubernetes in Production <https://thenewstack.io/7-key-considerations-for-kubernetes-in-production/>`_ 做一些思考:

   - 生产环境更依赖自动化：在开发阶段就需要考虑大规模横向扩展的解决方案，没有自动化部署和自动化监控、自动修复能力，从开发环境转向生产环境会带来巨大的代价
   - 性能: 开发阶段往往会忽视性能只关注到功能的实现，而生产环境的复杂程度和业务压力会暴露出开发阶段的缺陷
   - 安全性：从设计和部署方案上需要解决集群整体的安全管控 `ten layers of container security <https://go.redhat.com/container-security-20181012?intcmp=701f2000000tjyaAAA&extIdCarryOver=true&sc_cid=701f2000001OH8HAAW>`_
   - 监控和日志：需要构建大数据平台以及实时流数据分析日志和服务监控告警
   - 镜像仓库和包管理：构建私有镜像仓库，并通过 :ref:`helm` / :ref:`terraform` 这样的工具来构建包管理
   -

.. toctree::
   :maxdepth: 1
