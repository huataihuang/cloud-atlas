.. _z-k8s_docker_registry:

========================================
Kubernetes集群(z-k8s)部署镜像Redgistry
========================================

规划
=======

- 初期实现 :ref:`k8s_deploy_registry_startup` ，简化部署
- 改造后端存储，采用 :ref:`zdata_ceph` 实现分布式后端存储
- 改在前端，采用 replica 部署多副本实现容宰
