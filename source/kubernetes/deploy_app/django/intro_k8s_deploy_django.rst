.. _intro_k8s_deploy_django:

==============================
Kubernetes部署Django应用简介
==============================

:ref:`django` 是快速部署 :ref:`python` 应用的web框架，提供了全面的对象关系映射、用户认证、可定制管理界面等，并且提供了缓存、模版系统、URL调度系统等清晰等应用设计模式。

通过在Kubernets部署可扩展的Django应用:

- :ref:`nginx` ingress 实现入口
- :ref:`django` 应用框架
- :ref:`pgsql` 数据库: 从单机扩展成集群
- 缓存系统
- :ref:`redis` KV存储: 从单机扩展到集群
- 持久化存储可以引入 :ref:`ceph` 构建高可用分布式存储

完整的软件堆栈可以全面演练应用部署，也为Kuberntes真正投入实战打下基础

DigitalOcean提供了非常明晰的 `How To Deploy a Scalable and Secure Django Application with Kubernetes <https://www.digitalocean.com/community/tutorials/how-to-deploy-a-scalable-and-secure-django-application-with-kubernetes>`_ 为我部署整个软件架构提供了参考，我将结合存储、数据库相关技术进行扩展，力争将整个部署构建成满足大规模、可扩展、高性能的大型软件架构。

.. note::

   DigitalOcean网站的文章实用性很强，虽然它主要是围绕该公司云产品推广来撰写，但是提供了很多架构和实现步骤的参考。

参考
=======

- `How To Deploy a Scalable and Secure Django Application with Kubernetes <https://www.digitalocean.com/community/tutorials/how-to-deploy-a-scalable-and-secure-django-application-with-kubernetes>`_
