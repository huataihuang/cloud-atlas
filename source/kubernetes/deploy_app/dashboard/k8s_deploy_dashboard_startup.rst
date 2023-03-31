.. _k8s_deploy_dashboard_startup:

================================
Kubernetes部署Dashboard快速起步
================================

:ref:`k8s_dashboard` (原先案例是minikube)简单快速可以提供一个对集群的概览

部署Kubernetes Dashboard
===========================

- 在操作系统中安装好 ``wget`` 和 ``curl``

- 获取最新 ``Kubernetes dashboard`` yaml并部署:

.. literalinclude:: k8s_deploy_dashboard_startup/k8s_deploy_dashboard
   :language: bash
   :caption: 部署 ``Kubernetes dashboard``

语法兼容问题
--------------

.. note::

   本段落问题我实际没有解决，而是绕过。这个解决方法可能不正确。我感觉应该是采用正确的Kubernetes版本来安装对应的 ``Kubernetes dashboard`` 。过高的 ``Kubernetes dashboard```Kubernetes dashboard``` 版本可能会存在隐患

我部署时候遇到一个报错:

.. literalinclude:: k8s_deploy_dashboard_startup/k8s_deploy_dashboard_output
   :language: bash
   :caption: 部署 ``Kubernetes dashboard`` 报错输出
   :emphasize-lines: 12

我检查了一下 ``kubernetes-dashboard.yaml`` :

.. literalinclude:: k8s_deploy_dashboard_startup/k8s_deploy_dashboard_seccompProfile
   :language: bash
   :caption: ``kubernetes-dashboard.yaml`` 中 ``seccompProfile`` 和当前版本不兼容，清理
   :emphasize-lines: 3-5

感觉可以忽略，所以清理掉上述 ``securityContext`` 配置重新执行

参考
======

- `Deploy and Access the Kubernetes Dashboard <https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/>`_
- `How To Install Kubernetes Dashboard with NodePort / LB <https://computingforgeeks.com/how-to-install-kubernetes-dashboard-with-nodeport/>`_
