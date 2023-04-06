.. _install_ingress_nginx:

==========================
安装Ingress NGINX
==========================

安装NGINX ingress controller的方法有如下几种:

- 通过 :ref:`helm` 使用项目仓库chart(我采用此方法)
- 通过 ``kubectl apply`` 使用YAML机制进行安装
- 对于特定平台(如 :ref:`minikube` 或 ``MicroK8s`` )可以使用特定插件安装

.. note::

   本文实践在 :ref:`kind_local_registry` 的 :ref:`kind` 上完成

准备工作(集群部署helm)
========================

.. note::

   :ref:`kind` 环境在 :ref:`install_docker_macos` ( ``Docker Desktop on Mac`` )，所以helm安装采用 :ref:`homebrew` 。其他Linux版本请参考 :ref:`helm` 实践

- :ref:`macos` 安装本地 ``helm`` 客户端:

.. literalinclude:: ../../../deploy/helm/helm_startup/homebrew_helm_install
   :language: bash
   :caption: 在 :ref:`macos` 平台通过 :ref:`homebrew` 安装Helm

.. note::

   从 :ref:`helm` v3 开始，仅需要安装 helm 客户端(无需Tiller服务器端)

部署NGINX ingress controller
==============================

- 使用 ``helm`` 部署安装 ``NGINX ingress controller`` :

.. literalinclude:: install_ingress_nginx/helm_install_ingress_nginx
   :language: bash
   :caption: 使用helm安装NGINX ingress controller

安装显示:

.. literalinclude:: install_ingress_nginx/helm_install_ingress_nginx_output
   :language: bash
   :caption: 使用helm安装NGINX ingress controller 输出信息

- 执行检查安装进度:

.. literalinclude:: install_ingress_nginx/check_ingress_nginx_controller
   :language: bash
   :caption: 检查NGINX ingress controller安装进度

提示信息:

.. literalinclude:: install_ingress_nginx/ingress_nginx_controller_pending
   :language: bash
   :caption: 检查NGINX ingress controller状态pending

这里看到 ``EXTERNAL-IP pending`` 状态是因为没有安装 :ref:`metallb` ，请参考 :ref:`bare-metal_ingress_nginx`

参考
======

- `ingress-nginx Installation Guide <https://kubernetes.github.io/ingress-nginx/deploy/>`_
