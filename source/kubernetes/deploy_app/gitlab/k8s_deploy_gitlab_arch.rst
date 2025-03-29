.. _k8s_deploy_gitlab_arch:

==========================
Kubernetes部署GitLab架构
==========================

GitLab在Kubernetes上部署采用了 :ref:`helm` 来实现，但是具体到生产环境，需要根据不同的规模、需求采用不同的技术堆栈组合:

- 持久化组件: :ref:`pgsql` 或者 Gitaly(一种Git仓库存储数据平面)必须在PaaS集群之外运行，此时需要考虑服务的伸缩性和可靠性
- 如果Kubernetes不是运行GitLab必须条件(其实K8S增加了复杂度)，可以参考官方架构采用更为简化的部署，例如 :ref:`deploy_gitlab_from_source`

参考
========

- `Installing GitLab by using Helm <https://docs.gitlab.com/charts/installation/index.html>`_
