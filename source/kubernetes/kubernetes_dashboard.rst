.. _kubernetes_dashboard:

========================
Kubernetes仪表盘
========================

`kubenetes dashboard <https://github.com/kubernetes/dashboard>`_ 是通用用途的基于WEB的Kubenetes集群管理平台，可以管理集群以及运行在集群中的应用程序。

在minikube中 :ref:`minikube_dashboard` 可以帮助我们学习和了解kubernetes系统，本文将详细解析这个开源的Kubernetes仪表盘的部署和运维，以及自己的一些使用经验。

.. note::

   注意在minikube中默认没有启用dashboard，启动和访问dashboard的方法请参考 :ref:`minikube_dashboard` 。

   但是，dashboard实际上是在kubectl所在客户端运行的一个仪表盘服务，原理是通过本地kubectl去连接Kubernetes集群，获取集群数据并实时在本地的dashboard上
