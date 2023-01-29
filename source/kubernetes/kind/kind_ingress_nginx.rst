.. _kind_ingress_nginx:

==================
kind Ingress Nginx
==================

完成 :ref:`kind_ingress` 补丁配置方式 Kind 集群创建之后，可以部署不同的Ingress来实现 :ref:`k8s_services` 输出。我的实践采用最常用的 :ref:`ingress_nginx` 完成

.. note::

   :ref:`cilium` 也可以在 kind 集群部署，提供了非常完整的 :ref:`cilium_install_using_kind` ，我另外部署一个验证集群 ``cilium-dev``

   本文尝试部署一个简化版的 :ref:`ingress_nginx` + :ref:`metallb` 来实现轻量级部署Kubernetes服务输出

参考
======

- `kind User Guide: Ingress NGINX <https://kind.sigs.k8s.io/docs/user/ingress/#ingress-nginx>`_
