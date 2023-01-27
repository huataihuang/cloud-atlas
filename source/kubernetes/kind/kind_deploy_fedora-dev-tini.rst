.. _kind_deploy_fedora-dev-tini:

===============================================
kind部署 ``fedora-dev-tini`` (tini替代systmed)
===============================================

在完成 :ref:`fedora_tini_image` 制作之后，将镜像推送到 :ref:`kind_local_registry` 再次尝试部署个人开发环境( 暂时放弃 :ref:`kind_deploy_fedora-dev` )

准备工作
============

- 将制作完成的 :ref:`fedora_tini_image` ``fedora-dev-tini`` 打上tag并推送Local Registry:

.. literalinclude:: kind_deploy_fedora-dev-tini/push_fedora-dev-tini_registry
   :language: bash
   :caption: 将 ``fedora-dev-tini`` 镜像tag后推送Local Registry

部署
========

简单部署
----------

- 参考 :ref:`k8s_deploy_squid_startup` 相似部署:

.. literalinclude:: kind_deploy_fedora-dev-tini/fedora-dev-tini-deployment.yaml
   :language: yaml
   :caption: 部署到kind集群的fedora-dev-tini-deployment.yaml

- 部署:

.. literalinclude:: kind_deploy_fedora-dev-tini/deploy_fedora-dev-tini
   :language: bash
   :caption: 将 ``fedora-dev-tini`` 部署到kind集群

