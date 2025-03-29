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

设置服务输出
==============

- ``kubernetes-dashboard`` 默认部署在 ``kubernetes-dashboard`` namespace，也可能部署在 ``kube-system`` namespace，所以可以通过 ``kubectl get svc -A | grep kubernetes-dashboard`` 查找，输出可能类似::

   kube-system   kubernetes-dashboard   ClusterIP    10.233.12.29    <none>        443:32642/TCP                  10d

- 有两种方式输出，一种是采用 ``LoadBalancer`` ，一种是采用 ``NodePort`` ，配置方法类似，以下为 ``NodePort`` 方式配置::

   kubectl --namespace kubernetes-dashboard patch svc kubernetes-dashboard -p '{"spec": {"type": "NodePort"}}'

修订以后再次见检查 ``kubectl get svc -n kube-system | grep kubernetes-dashboard`` 输出显示::

   kubernetes-dashboard   NodePort    10.233.12.29   <none>        443:32642/TCP                  10d

``kubernetes-dashboard`` 主机证书错误问题
==========================================

我遇到一个非常奇怪的问题，当使用 ``NodePort`` 对外输出了 ``kubernetes-dashboard`` 之后，通过浏览器访问时显示 ``NET::ERR_CERT_INVALID`` (chrome)。此时，浏览器阻止我访问 ``kubernetes-dashboard`` (没有允许的选项)

这个问题似乎出现在最新版本的Firefox/Safari/Chrome浏览器，是因为服务器证书是 ``localhost`` 签名，但是通过 ``NodePort`` 输出以后，地址是局域网或者公网IP，浏览器会拒绝访问。

.. literalinclude:: k8s_deploy_dashboard_startup/fix_kubernetes-dashboard_secret
   :language: bash
   :caption: 生成kubernetes-dashboard证书

上述secret重新生成后，主机证书就能够被chrome浏览器接受，也就能够打开 ``kubernetes-dashboard`` 了:

``kubernetes-dashboard`` Bearer Token
========================================

``Kubernetes-dashboard`` 访问需要使用 ``Token`` 或者集群管理 ``Kubeconfig`` ，建议使用 ``Token`` 。

但是怎么获得这个Token呢？

通过 ``kubectl`` 获取Token
------------------------------

- 检查 ``kubernetes-dashboard`` 中的 ``scrects`` :

.. literalinclude:: k8s_deploy_dashboard_startup/get_kubernetes-dashboard_secret
   :language: bash
   :caption: 检查 ``kubernetes-dashboard`` namespace中的secret

输出显示

.. literalinclude:: k8s_deploy_dashboard_startup/get_kubernetes-dashboard_secret_output
   :language: bash
   :caption: 检查 ``kubernetes-dashboard`` namespace中的secret

- 输出名为 ``kubernetes-dashboard-token-XXXXX`` 的toke内容: 

.. literalinclude:: k8s_deploy_dashboard_startup/get_kubernetes-dashboard_token
   :language: bash
   :caption: 获取 ``kubernetes-dashboard`` namespace中的token

将输出信息中的 ``token`` 字段内容去除作为 ``kubernetes-dashboard`` 登陆的 ``token``

账号角色
=============

此时登陆后可能没有权限访问任何资源，需要为 ``kubernetes-dashboard`` 的登陆用户创建一个Role绑定到 ``cluster-admin`` 这个 ``ClusterRole`` 上:

.. literalinclude:: k8s_deploy_dashboard_startup/admin-user.yaml
   :language: yaml
   :caption: 为 ``admin-user`` 绑定集群管理员角色

.. note::

   这里采用的是官方发布版本安装角色。我遇到 :ref:`kubespray` 自动安装的 ``kubernetes-dashboard`` 的账号名不同，可能需要根据错误提示修改。见下文

登陆后无权限问题
===================

.. note::

   特殊错误: 我修复这个问题是因为 :ref:`kubespray` 部署的Kubernetes系统，使用了不同的访问账号 ``system:serviceaccount:kube-system:kubernetes-dashboard`` 

解决了主机证书和token之后，确实可以登陆 ``kubernetes-dashboard`` 了，但是遇到一个问题，所有界面内容都是空的。消息中显示没有权限的错误::

   roles.rbac.authorization.k8s.io is forbidden: User "system:serviceaccount:kube-system:kubernetes-dashboard" cannot list resource "roles" in API group "rbac.authorization.k8s.io" in the namespace "default"

类似错误消息多条

这是因为没有创建 ``Service Account`` 和 ``ClusterRoleBinding``  ，也就是为 ``kube-system`` 这个namespace的 ``kubernetes-dashboard`` 构建管理员角色(使用 :ref:`kubespray` 部署的Kubernetes系统，其 ``kubernetes-dashboard`` 使用了 ``kube-system`` namespace 中的 ``kubernetes-dashboard`` )，所以需要模仿之前为 dashboard 配置服务账号的方法，为这个账号修订 ``dashboard-account.yaml``

.. literalinclude:: k8s_deploy_dashboard_startup/dashboard-account.yaml
   :language: yaml
   :caption: 为 ``system:serviceaccount:kube-system:kubernetes-dashboard`` 修订角色，仿照之前安装部署步骤

参考
======

- `Deploy and Access the Kubernetes Dashboard <https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/>`_
- `How To Install Kubernetes Dashboard with NodePort / LB <https://computingforgeeks.com/how-to-install-kubernetes-dashboard-with-nodeport/>`_
- `Discussion on: Bare metal load balancer on Kubernetes with MetalLB <https://dev.to/zimmertr/comment/gefd>`_ 这个帖子解决了 ``kubernetes-dashboard`` 主机证书错误问题
- `dashboard/docs/user/access-control/README.md <https://github.com/kubernetes/dashboard/blob/v2.0.0/docs/user/access-control/README.md>`_ 获取token可参考这篇文档
- `dashboard/docs/user/access-control/creating-sample-user.md <https://github.com/kubernetes/dashboard/blob/v2.0.0/docs/user/access-control/creating-sample-user.md>`_ 创建用户账号可参考这篇文档
