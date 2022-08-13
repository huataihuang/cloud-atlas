.. _cilium_kubeproxy_free:

=========================================
Cilium完全取代kube-proxy运行Kubernetes
=========================================

Cilium提供了完全取代 ``kube-proxy`` 的运行模式。比较简单的方式是在 ``kubeadm`` bootstrap 集群的时候就不安装 ``kube-proxy`` 。

.. note::

   Cilium代替 ``kube-proxy`` 需要依赖 ``socket-LB`` 功能，这要求内核 ``v4.19.57`` , ``v5.1.16`` , ``v5.2.0`` 或者更新的 Linux 内核。 Linux 内核 v5.3 和 v5.8 添加了更多功能，可以让Cilium更加优化替代 ``kube-proxy`` 的实现。

快速起步
=========

- 在 ``kubeadm`` 初始化集群时候就可以跳过安装 ``kube-proxy`` ::

   kubeadm init --skip-phases=addon/kube-proxy

已经安装 ``kube-proxy`` 的替换方法
========================================

对于已经安装了 ``kube-proxy`` 作为 DaemonSet 的Kubernetes集群，则通过以下命令移除 ``kube-proxy`` 。 ``注意: 删除kube-proxy会导致现有服务中断链接，并且停止流量，直到Cilium替换完全安装好才能恢复``

.. literalinclude:: cilium_kubeproxy_free/delete_ds_kube-proxy
   :language: bash
   :caption: 移除Kubernetes集群Kube-proxy DaemonSet

- 设置Helm仓库::

   helm repo add cilium https://helm.cilium.io/

- 执行以下命令进行安装:

.. literalinclude:: cilium_kubeproxy_free/kubeproxy_replacement
   :language: bash
   :caption: Cilium替换kube-proxy

这里有一个报错::

   Error: INSTALLATION FAILED: cannot re-use a name that is still in use

原因官方文档是以第一次初始安装cilium为准，也就是直接删除掉kube-proxy之后，立即进行cilium安装。而我的操作步骤是，安装了cilium之后，再删除掉kube-proxy并重新安装cilium，所以就会出现冲突报错。这个问题参考 `Cannot install kubernetes helm chart Error: cannot re-use a name that is still in use <https://stackoverflow.com/questions/70464815/cannot-install-kubernetes-helm-chart-error-cannot-re-use-a-name-that-is-still-i>`_ ，也就是采用 :ref:`helm` 提供的
``upgrade`` 命令代替 ``install`` 命令，就可以重新安装:

.. literalinclude:: cilium_kubeproxy_free/kubeproxy_replacement_helm_upgrade
   :language: bash
   :caption: Cilium替换kube-proxy

此时可以看到替换成功::

   W0813 23:39:08.689475 1285915 warnings.go:70] spec.template.spec.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[1].matchExpressions[0].key: beta.kubernetes.io/os is deprecated since v1.14; use "kubernetes.io/os" instead
   Release "cilium" has been upgraded. Happy Helming!
   NAME: cilium
   LAST DEPLOYED: Sat Aug 13 23:39:06 2022
   NAMESPACE: kube-system
   STATUS: deployed
   REVISION: 3
   TEST SUITE: None
   NOTES:
   You have successfully installed Cilium with Hubble.

   Your release version is 1.11.7.

   For any further help, visit https://docs.cilium.io/en/v1.11/gettinghelp

另外一种解决方法可以参考 `Cannot re-use a name that is still in use <https://docs.microfocus.com/doc/Containerized_Operations_Bridge/2020.08/TShelmCannotreusename>`_ ，即先使用 ``helm uninstall`` 卸载组件，然后再进行 ``helm install`` (未尝试)。

- 现在我们可以检查cilium是否在每个节点正常工作::

   kubectl -n kube-system get pods -l k8s-app=cilium -o wide

输出显示::

   NAME           READY   STATUS    RESTARTS   AGE   IP              NODE        NOMINATED NODE   READINESS GATES
   cilium-2qcdd   1/1     Running   0          16m   192.168.6.113   z-k8s-n-3   <none>           <none>
   cilium-4drkm   1/1     Running   0          17m   192.168.6.102   z-k8s-m-2   <none>           <none>
   cilium-4xktc   1/1     Running   0          17m   192.168.6.101   z-k8s-m-1   <none>           <none>
   cilium-5j2xb   1/1     Running   0          16m   192.168.6.112   z-k8s-n-2   <none>           <none>
   cilium-d7mmq   1/1     Running   0          17m   192.168.6.114   z-k8s-n-4   <none>           <none>
   cilium-fw9b5   1/1     Running   0          17m   192.168.6.115   z-k8s-n-5   <none>           <none>
   cilium-t675t   1/1     Running   0          16m   192.168.6.103   z-k8s-m-3   <none>           <none>
   cilium-tsntp   1/1     Running   0          16m   192.168.6.111   z-k8s-n-1   <none>           <none>

验证设置
==========

在完成了kube-proxy替代之后，首先验证是否在节点上运行了Cilium agent正确模式::

   kubectl -n kube-system exec ds/cilium -- cilium status | grep KubeProxyReplacement

此时显示输出类似::

   Defaulted container "cilium-agent" out of: cilium-agent, mount-cgroup (init), apply-sysctl-overwrites (init), clean-cilium-state (init)
   KubeProxyReplacement:   Strict   [enp1s0 192.168.6.102 (Direct Routing)]

- 检查详细信息::

   kubectl -n kube-system exec ds/cilium -- cilium status --verbose

可选步骤:通过Nginx部署验证
===========================

- 准备 ``my-nginx.yaml`` :

.. literalinclude:: cilium_kubeproxy_free/my-nginx.yaml
   :language: yaml
   :caption: 部署Nginx my-nginx.yaml

- 执行部署::

   kubectl create -f my-nginx.yaml

检查pod创建::

   kubectl get pods -o wide

出现一个意外，镜像始终没有下载成功::

   NAME                       READY   STATUS              RESTARTS   AGE   IP           NODE        NOMINATED NODE   READINESS GATES
   my-nginx-df7bbf6f5-457mh   0/1     ContainerCreating   0          12m   <none>       z-k8s-n-5   <none>           <none>
   my-nginx-df7bbf6f5-6gndk   0/1     ContainerCreating   0          12m   <none>       z-k8s-n-1   <none>           <none>

通过 ``kubectl describe pods my-nginx-df7bbf6f5-457mh`` 可以看到一直停留在pulling image状态::

   ...
   Events:
     Type    Reason     Age   From               Message
     ----    ------     ----  ----               -------
     Normal  Scheduled  10m   default-scheduler  Successfully assigned default/my-nginx-df7bbf6f5-457mh to z-k8s-n-5
     Normal  Pulling    10m   kubelet            Pulling image "nginx" 

此时检查集群事件::

   kubectl get events --sort-by=.metadata.creationTimestamp

可以看到::

   LAST SEEN   TYPE     REASON              OBJECT                          MESSAGE
   16m         Normal   Scheduled           pod/my-nginx-df7bbf6f5-457mh    Successfully assigned default/my-nginx-df7bbf6f5-457mh to z-k8s-n-5
   16m         Normal   Scheduled           pod/my-nginx-df7bbf6f5-6gndk    Successfully assigned default/my-nginx-df7bbf6f5-6gndk to z-k8s-n-1
   16m         Normal   SuccessfulCreate    replicaset/my-nginx-df7bbf6f5   Created pod: my-nginx-df7bbf6f5-6gndk
   16m         Normal   SuccessfulCreate    replicaset/my-nginx-df7bbf6f5   Created pod: my-nginx-df7bbf6f5-457mh
   16m         Normal   ScalingReplicaSet   deployment/my-nginx             Scaled up replica set my-nginx-df7bbf6f5 to 2
   16m         Normal   Pulling             pod/my-nginx-df7bbf6f5-457mh    Pulling image "nginx"
   16m         Normal   Pulling             pod/my-nginx-df7bbf6f5-6gndk    Pulling image "nginx"

参考
=====

- `Cilium docs: Kubernetes Without kube-proxy <https://docs.cilium.io/en/stable/gettingstarted/kubeproxy-free>`_
