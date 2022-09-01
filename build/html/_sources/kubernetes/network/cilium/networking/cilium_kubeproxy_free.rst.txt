.. _cilium_kubeproxy_free:

=========================================
Cilium完全取代kube-proxy运行Kubernetes
=========================================

Cilium提供了完全取代 ``kube-proxy`` 的运行模式。比较简单的方式是在 ``kubeadm`` bootstrap 集群的时候就不安装 ``kube-proxy`` 。

.. note::

   Cilium代替 ``kube-proxy`` 需要依赖 ``socket-LB`` 功能，这要求内核 ``v4.19.57`` , ``v5.1.16`` , ``v5.2.0`` 或者更新的 Linux 内核。 Linux 内核 v5.3 和 v5.8 添加了更多功能，可以让Cilium更加优化替代 ``kube-proxy`` 的实现。

快速起步
=========

- 在 ``kubeadm`` 初始化集群时候就可以跳过安装 ``kube-proxy`` :

.. literalinclude:: cilium_kubeproxy_free/kubedam_init_skip_kube-proxy
   :language: bash
   :caption: kubeadm初始化集群时跳过安装kube-proxy

已经安装 ``kube-proxy`` 的替换方法
========================================

对于已经安装了 ``kube-proxy`` 作为 DaemonSet 的Kubernetes集群，则通过以下命令移除 ``kube-proxy`` 。 ``注意: 删除kube-proxy会导致现有服务中断链接，并且停止流量，直到Cilium替换完全安装好才能恢复``

.. literalinclude:: cilium_kubeproxy_free/delete_ds_kube-proxy
   :language: bash
   :caption: 移除Kubernetes集群Kube-proxy DaemonSet

- 设置Helm仓库:

.. literalinclude:: ../installation/cilium_install_with_external_etcd/helm_repo_add_cilium
   :language: bash
   :caption: 设置cilium Helm仓库

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

- 现在我们可以检查cilium是否在每个节点正常工作:

.. literalinclude:: cilium_kubeproxy_free/kubectl_get_cilium_pods
   :language: bash
   :caption: kubectl检查cilium的pods是否在各个节点正常运行

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

不过看起来还是下载镜像较慢，最终还是运行起来了::

   NAME                       READY   STATUS    RESTARTS   AGE   IP           NODE        NOMINATED NODE   READINESS GATES
   my-nginx-df7bbf6f5-457mh   1/1     Running   0          12h   10.0.6.22    z-k8s-n-5   <none>           <none>
   my-nginx-df7bbf6f5-6gndk   1/1     Running   0          12h   10.0.3.160   z-k8s-n-1   <none>           <none>

- 为两个实例创建 NodePort :ref:`kubernetes_services` ::

   kubectl expose deployment my-nginx --type=NodePort --port=80

提示信息::

   service/my-nginx exposed

- 检查 NodePort 服务::

   kubectl get svc my-nginx

状态显示::

   NAME       TYPE       CLUSTER-IP       EXTERNAL-IP   PORT(S)        AGE
   my-nginx   NodePort   10.101.117.255   <none>        80:30828/TCP   110s

- 现在我们可以通过 ``cilium service list`` 命令来验证 Cilium eBPF kube-proxy 替换所创建的新的 NodePort 服务:

.. literalinclude:: cilium_kubeproxy_free/cilium_service_list
   :language: bash
   :caption: 检查cilium DaemonSet的服务列表

输出显示:

.. literalinclude:: cilium_kubeproxy_free/cilium_service_list_output
   :language: bash
   :caption: 检查cilium DaemonSet的服务列表输出信息
   :emphasize-lines: 23-28

- 通过以下命令获取服务输出的NodePort端口::

   node_port=$(kubectl get svc my-nginx -o=jsonpath='{@.spec.ports[0].nodePort}')

实际上，现在我们有3种方式访问，从前文 ``cilium service list`` 可以看到:

  - 10.101.117.255:80     ClusterIP
  - 192.168.6.102:30828   NodePort
  - 0.0.0.0:30828         NodePort

对应:

  - 在集群任何节点上访问 10.101.117.255 端口 80
  - 访问 ``z-k8s-m-2`` (192.168.6.102) 端口 30828
  - 访问集群任何节点的端口 30828

都能够看到nginx的页面(这里举例访问 ``z-k8s-n-2`` 192.168.6.112)::

   curl 192.168.6.112:30828

输出可以看到::

   <!DOCTYPE html>
   <html>
   <head>
   <title>Welcome to nginx!</title>
   <style>
   html { color-scheme: light dark;  }
   body { width: 35em; margin: 0 auto;
   font-family: Tahoma, Verdana, Arial, sans-serif; }
   </style>
   </head>
   <body>
   <h1>Welcome to nginx!</h1>
   <p>If you see this page, the nginx web server is successfully installed and
   working. Further configuration is required.</p>

   <p>For online documentation and support please refer to
   <a href="http://nginx.org/">nginx.org</a>.<br/>
   Commercial support is available at
   <a href="http://nginx.com/">nginx.com</a>.</p>

   <p><em>Thank you for using nginx.</em></p>
   </body>
   </html>

.. _cilium_hubproxy_free_socketlb_bypass:

Socket LoadBalancer Bypass in Pod Namespace
==============================================

在 :ref:`cilium_istio_startup` 配置Cilium时，如果部署的Cilium采用本文 kube-proxy replacement 模式( ``kube-proxy_free`` )，就需要调整 Cilium 的socket load balancing，配置 ``socketLB.hostNamespaceOnly=true`` ，否则会导致Istio的加密和遥测功能失效。

由于我已经在上文中启用了 ``hub-proxy_free`` ，所以，在部署 :ref:`cilium_istio_startup` 的第一个步骤就是本段落配置更新，激活 ``socketLB.hostNamespaceOnly=true`` :

.. warning::

   我这里配置错误了，折腾了一下才解决，请参考下文的排查和纠正。最后我给出一个正确的简化配置(不修订默认值)。Cilium有很多强大的网络功能配置需要联动，并且和底层云计算underlay网络(vxlan等)有关，所以调整要非常小心。

.. literalinclude:: cilium_kubeproxy_free/socketlb_hostnamespaceonly
   :language: bash
   :caption: 更新Cilium kube-proxy free配置，激活 socketLB.hostNamespaceOnly 以集成Istio(存在错误，无法启动cilium)

不过，我这次更新遇到奇怪的问题，就是节点上的 ``cilium`` 不断crash::

   $ kubectl get pods -n kube-system -o wide
   NAME                                READY   STATUS             RESTARTS      AGE    IP              NODE        NOMINATED NODE   READINESS GATES
   cilium-2brxn                        0/1     CrashLoopBackOff   4 (67s ago)   3m4s   192.168.6.103   z-k8s-m-3   <none>           <none>
   cilium-6rhms                        1/1     Running            0             25h    192.168.6.115   z-k8s-n-5   <none>           <none>
   cilium-mzrkm                        0/1     CrashLoopBackOff   4 (79s ago)   3m5s   192.168.6.113   z-k8s-n-3   <none>           <none>
   cilium-operator-6dfc84b7fc-m8ftr    1/1     Running            0             3m5s   192.168.6.114   z-k8s-n-4   <none>           <none>
   cilium-operator-6dfc84b7fc-sxjp5    1/1     Running            0             3m6s   192.168.6.113   z-k8s-n-3   <none>           <none>
   cilium-pmdj4                        1/1     Running            0             25h    192.168.6.102   z-k8s-m-2   <none>           <none>
   cilium-qjxcc                        0/1     CrashLoopBackOff   4 (81s ago)   3m5s   192.168.6.101   z-k8s-m-1   <none>           <none>
   cilium-t5n4c                        1/1     Running            0             25h    192.168.6.114   z-k8s-n-4   <none>           <none>
   cilium-vjqlr                        1/1     Running            0             25h    192.168.6.111   z-k8s-n-1   <none>           <none>
   cilium-vk624                        0/1     CrashLoopBackOff   4 (74s ago)   3m4s   192.168.6.112   z-k8s-n-2   <none>           <none>

检查pods::

   kubectl -n kube-system describe pods cilium-vk624

显示容器健康检查失败:

.. literalinclude:: cilium_kubeproxy_free/socketlb_hostnamespaceonly_fail
   :language: bash
   :caption: 激活 socketLB.hostNamespaceOnly 出现pods不断crash
   :emphasize-lines: 18-19

检查也可以看到::

   kubectl -n kube-system exec ds/cilium -- cilium status --verbose

显示有异常::

   ...
   Encryption:               Disabled
   Cluster health:           4/8 reachable   (2022-08-22T16:34:16Z)
     Name                    IP              Node          Endpoints
     z-k8s-n-4 (localhost)   192.168.6.114   reachable     reachable
     z-k8s-m-1               192.168.6.101   unreachable   reachable
     z-k8s-m-2               192.168.6.102   reachable     reachable
     z-k8s-m-3               192.168.6.103   unreachable   reachable
     z-k8s-n-1               192.168.6.111   reachable     reachable
     z-k8s-n-2               192.168.6.112   unreachable   reachable
     z-k8s-n-3               192.168.6.113   unreachable   reachable
     z-k8s-n-5               192.168.6.115   reachable     reachable

检查crash的pod日志::

   kubectl -n kube-system logs cilium-vk624

发现错误是参数错误:

.. literalinclude:: cilium_kubeproxy_free/socketlb_hostnamespaceonly_fail_pod_log
   :language: bash
   :caption: 激活 socketLB.hostNamespaceOnly 后crash pod日志
   :emphasize-lines: 3,326

关键点是::

   ...
   level=warning msg="If auto-direct-node-routes is enabled, then you are recommended to also configure ipv4-native-routing-cidr. If ipv4-native-routing-cidr is not configured, this may lead to pod to pod traffic being masqueraded, which can cause problems with performance, observability and policy" subsys=config
   ...
   evel=fatal msg="Error while creating daemon" error="invalid daemon configuration: native routing cidr must be configured with option --ipv4-native-routing-cidr in combination with --enable-ipv4-masquerade --tunnel=disabled --ipam=cluster-pool --enable-ipv4=true" subsys=daemon
   
这个原因:

注意 ``tunnel`` 配置参数只有3个 ``{vxlan, geneve, disabled}`` ，其中 ``geneve`` 是BGP模式tunnel

一旦关闭 ``tunnel`` ，则必须同时配置 ``ipv4-native-routing-cidr: x.x.x.x/y`` 表示不执行封包的路由 参考 `Cilium Concepts >> Networking >> Routing >> Native-Routing <https://docs.cilium.io/en/v1.12/concepts/networking/routing/#native-routing>`_

cilium 默认就启用了 ``Encapsulation`` (封包)，不需要配置，这样就可以和 underlying 网络架构配合无需更多配置。此时所有集群节点之间采用 ``mesh of tunnels`` 的UDP封包协议，如VXLAN或Geneve。所有Cilium node的流量都是封包的。

所以，我现在修订为:

.. literalinclude:: cilium_kubeproxy_free/socketlb_hostnamespaceonly_fix
   :language: bash
   :caption: 重新更新Cilium kube-proxy free配置，激活 socketLB.hostNamespaceOnly 以集成Istio，部分配置恢复默认

综上所述，实际上我走了弯路，应该保持默认配置情况下有限修订，简化配置如下(以此为准):

.. literalinclude:: cilium_kubeproxy_free/socketlb_hostnamespaceonly_simple
   :language: bash
   :caption: 简化且正确配置方法: 更新Cilium kube-proxy free配置，激活 socketLB.hostNamespaceOnly 以集成Istio(不修改默认配置)

.. note::

   有关路由和加速请参考:

   - `Direct Server Return (DSR) <https://docs.cilium.io/en/v1.12/gettingstarted/kubeproxy-free/#direct-server-return-dsr>`_
   - `Cilium Concepts >> Networking >> Routing <https://docs.cilium.io/en/v1.12/concepts/networking/routing/>`_ 这篇文章非常重要

参考
=====

- `Cilium docs: Kubernetes Without kube-proxy <https://docs.cilium.io/en/stable/gettingstarted/kubeproxy-free>`_
