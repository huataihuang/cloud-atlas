.. _kubernetes_dashboard:

========================
Kubernetes仪表盘
========================

`kubenetes dashboard <https://github.com/kubernetes/dashboard>`_ 是通用用途的基于WEB的Kubenetes集群管理平台，可以管理集群以及运行在集群中的应用程序。

在minikube中 :ref:`minikube_dashboard` 可以帮助我们学习和了解kubernetes系统，本文将详细解析这个开源的Kubernetes仪表盘的部署和运维，以及自己的一些使用经验。

.. note::

   注意在minikube中默认没有启用dashboard，启动和访问dashboard的方法请参考 :ref:`minikube_dashboard` 。

   但是，dashboard实际上是在kubectl所在客户端运行的一个仪表盘服务，原理是通过本地kubectl去连接Kubernetes集群，获取集群数据并实时在本地的dashboard上

启动minikube dashboard异常排查
=================================

首次启动dashboard需要等待
--------------------------

在 :ref:`install_run_minikube` 时采用了裸物理主机运行minikube，几经波折运行成功。但是在启动 dashboard 时候遇到异常::

   sudo minikube dashboard --url

显示错误::

   X http://127.0.0.1:33073/api/v1/namespaces/kube-system/services/http:kubernetes-dashboard:/proxy/ is not responding properly: Temporary Error: unexpected response code: 503

此时检查pod状态::

   kubectl get pods --all-namespaces

输出显示pod始终时创建状态::

   NAMESPACE     NAME                                   READY   STATUS              RESTARTS   AGE
   ...
   kube-system   kubernetes-dashboard-d7c9687c7-ggrdf   0/1     ContainerCreating   0          4m1s

不过，可以可能是首次启动原因，我发现大约9分钟以后，容器进入running状态::

   kubernetes-dashboard-d7c9687c7-ggrdf   1/1     Running   0          9m12s

此时通过浏览器访问 http://127.0.0.1:8001/api/v1/namespaces/kube-system/services/http:kubernetes-dashboard:/proxy/ 则恢复正常。
