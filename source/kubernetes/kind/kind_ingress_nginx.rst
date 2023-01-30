.. _kind_ingress_nginx:

==================
kind Ingress Nginx
==================

完成 :ref:`kind_ingress` 补丁配置方式 Kind 集群创建之后，可以部署不同的Ingress来实现 :ref:`k8s_services` 输出。我的实践采用最常用的 :ref:`ingress_nginx` 完成

.. note::

   :ref:`cilium` 也可以在 kind 集群部署，提供了非常完整的 :ref:`cilium_install_using_kind` ，我另外部署一个验证集群 ``cilium-dev``

   仅使用 :ref:`ingress_nginx` 就可以把 :ref:`k8s_services` 对外输出，对于 :ref:`install_docker_macos` 稍微麻烦一些，需要将 :ref:`macos` 上运行的Docker虚拟机再做一次端口映射，以便能够在物理主机(网络)访问。

   本文尝试部署一个简化版的 :ref:`ingress_nginx` + :ref:`metallb` 来实现轻量级部署Kubernetes服务输出

安装Ingress NGINX
=======================

配合 :ref:`kind_ingress`
--------------------------

- Kind在自己patch过的 :ref:`kind_ingress` 做了 ``extraPortMappings`` ，所以提供了一个明确包含kind特殊patches版本来将 ``hostPorts`` 转发给ingress controller的安装版本:

.. literalinclude:: kind_ingress_nginx/install_kind_patched_ingress_nginx
   :language: bash
   :caption: 安装kind补丁过的ingress-nginx

- 执行一下请求等待进程就绪:

.. literalinclude:: kind_ingress_nginx/wait_kind_patched_ingress_nginx_ready
   :language: bash
   :caption: 等待kind补丁过的ingress-nginx安装完成就绪

.. note::

   使用 ``ingress-nginx`` 案例见下文

标准版 ``ingress-nginx``
---------------------------

我部署 简化版的 :ref:`ingress_nginx` + :ref:`metallb` 来实现轻量级部署Kubernetes服务输出，所以实际安装标准版 :ref:`ingress_nginx`


参考
======

- `kind User Guide: Ingress NGINX <https://kind.sigs.k8s.io/docs/user/ingress/#ingress-nginx>`_
