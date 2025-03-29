.. _k8s_master_pod_create_error:

===================================================
Kubernetes管控节点Pods创建"CreateContainerError"
===================================================

测试环境ARM平台的Kubernetes集群，管控检点升级系统重启后出现了非常奇怪的 "CreateContainerError" 错误:

- ``kubectl get pods -o wide -n kube-system | grep master`` 显示::

   coredns-78fcd69978-775zr             1/1     Running                2 (3d23h ago)     17d     10.244.0.7      pi-master1   <none>           <none>
   coredns-78fcd69978-cx94g             1/1     Running                2 (3d6h ago)      17d     10.244.0.6      pi-master1   <none>           <none>
   etcd-pi-master1                      0/1     CreateContainerError   4 (2d8h ago)      9m50s   192.168.6.11    pi-master1   <none>           <none>
   kube-apiserver-pi-master1            0/1     CreateContainerError   9 (2d8h ago)      17d     192.168.6.11    pi-master1   <none>           <none>
   kube-controller-manager-pi-master1   1/1     Running                12 (2d8h ago)     17d     192.168.6.11    pi-master1   <none>           <none>
   kube-flannel-ds-jqgsm                1/1     Running                1239 (2d8h ago)   17d     192.168.6.11    pi-master1   <none>           <none>
   kube-proxy-rfgxq                     1/1     Running                5 (2d8h ago)      17d     192.168.6.11    pi-master1   <none>           <none>
   kube-scheduler-pi-master1            0/1     CreateContainerError   12 (2d8h ago)     17d     192.168.6.11    pi-master1   <none>           <none>

可以看到关键组件 etcd, apiserver 和 scheduler 都创建失败。通常管控节点大量服务pod失败很可能和etcd相关，因为etcd是所有组件数据存储和交换的数据库。

- 执行pod检查

etcd检查::

   kubectl -n kube-system describe pods etcd-pi-master1

奇怪，事件显示只有::

   ...
   Events:
     Type    Reason  Age                       From     Message
     ----    ------  ----                      ----     -------
     Normal  Pulled  2m14s (x15298 over 3d6h)  kubelet  Container image "k8s.gcr.io/etcd:3.5.0-0" already present on machine

同样，apiserver也是如此::

   kubectl -n kube-system describe pods kube-apiserver-pi-master1

事件显示::

   ...
   Events:
     Type    Reason  Age                     From     Message
     ----    ------  ----                    ----     -------
     Normal  Pulled  16s (x15280 over 3d6h)  kubelet  Container image "k8s.gcr.io/kube-apiserver:v1.22.0" already present on machine

- 尝试直接清理掉pod::

   $ kubectl -n kube-system  delete pod etcd-pi-master1
   pod "etcd-pi-master1" deleted

但是检查 ``etcd`` 进程发现，这个进程还是2天前启动的进程::

   root        4613  5.2  1.9 10611120 76868 ?      Ssl  Aug25 178:03 etcd --advertise-client-urls=https://192.168.6.11:2379 ...

也就是说，这个pod销毁重启是不生效。

- 尝试重启一次操作系统，重启后发现，还是同样的pods无法启动::

   NAME                                 READY   STATUS                 RESTARTS          AGE
   coredns-78fcd69978-775zr             1/1     Running                2 (4d ago)        17d
   coredns-78fcd69978-cx94g             1/1     Running                2 (3d7h ago)      17d
   etcd-pi-master1                      0/1     CreateContainerError   4 (2d9h ago)      14m
   kube-apiserver-pi-master1            0/1     CreateContainerError   9 (2d9h ago)      17d
   ...
   kube-scheduler-pi-master1            0/1     CreateContainerError   12 (2d9h ago)     17d

但是神奇的是，过了一会 etcd 和 apiserver / scheduler 启动起来了，但是 coredns 和  flannel 网络存在问题::

   $ kubectl -n kube-system get pods -o wide
   NAME                                 READY   STATUS             RESTARTS         AGE   IP              NODE         NOMINATED NODE   READINESS GATES
   coredns-78fcd69978-775zr             0/1     Completed          2                17d   <none>          pi-master1   <none>           <none>
   coredns-78fcd69978-cx94g             0/1     Completed          2                17d   <none>          pi-master1   <none>           <none>
   etcd-pi-master1                      1/1     Running            5 (2d9h ago)     19m   192.168.6.11    pi-master1   <none>           <none>
   kube-apiserver-pi-master1            1/1     Running            10 (2d9h ago)    17d   192.168.6.11    pi-master1   <none>           <none>
   kube-controller-manager-pi-master1   1/1     Running            13 (8m42s ago)   17d   192.168.6.11    pi-master1   <none>           <none>
   kube-flannel-ds-4dxvz                1/1     Running            1 (7d7h ago)     17d   192.168.6.16    pi-worker2   <none>           <none>
   kube-flannel-ds-jdwcr                1/1     Running            1931 (8d ago)    15d   192.168.6.200   zcloud       <none>           <none>
   kube-flannel-ds-jqgsm                0/1     CrashLoopBackOff   1244 (66s ago)   17d   192.168.6.11    pi-master1   <none>           <none>
   kube-flannel-ds-l7j6b                1/1     Running            6 (5d21h ago)    17d   30.73.165.29    jetson       <none>           <none>
   kube-flannel-ds-nqg77                1/1     Running            1 (7d7h ago)     17d   192.168.6.15    pi-worker1   <none>           <none>
   kube-flannel-ds-pkhch                1/1     Running            3 (2d8h ago)     15d   30.73.167.10    kali         <none>           <none>
   kube-proxy-bn9q8                     1/1     Running            2 (2d8h ago)     15d   30.73.167.10    kali         <none>           <none>
   kube-proxy-d9xlj                     1/1     Running            1 (7d7h ago)     17d   192.168.6.15    pi-worker1   <none>           <none>
   kube-proxy-gz9bh                     1/1     Running            6 (5d21h ago)    17d   30.73.165.29    jetson       <none>           <none>
   kube-proxy-nt27w                     1/1     Running            1 (7d7h ago)     17d   192.168.6.16    pi-worker2   <none>           <none>
   kube-proxy-pbtcz                     1/1     Running            2 (10d ago)      15d   192.168.6.200   zcloud       <none>           <none>
   kube-proxy-rfgxq                     1/1     Running            6 (8m42s ago)    17d   192.168.6.11    pi-master1   <none>           <none>
   kube-scheduler-pi-master1            1/1     Running            13 (2d9h ago)    17d   192.168.6.11    pi-master1   <none>           <none>

- 检查 ``kube-flannel`` 失败原因::

   kubectl -n kube-system logs kube-flannel-ds-tq9x5

原来 ``kube-flannel`` 需要主机有一个默认路由来判断默认网络接口::

   I0827 09:48:41.911302       1 main.go:520] Determining IP address of default interface
   E0827 09:48:41.912029       1 main.go:205] Failed to find any valid interface to use: failed to get default interface: Unable to find default route

我的测试服务器，默认网络是通过无线网卡实现的，只是每次服务器重启，无线网卡没有初始化，所以 ``wlan0`` 是 ``DOWN`` 状态

- 重新执行一次 :ref:`netplan` 命令来恢复无线网络::

   sudo netplan apply

然后检查网卡::

   ip addr

确定无线网络恢复工作

- 此时再次检查 ``kube-system`` 中的pods，就可以看到 ``kube-flannel`` 能够正常启动，也同时恢复了 ``coredns`` ::

   kubectl -n kube-system get pods

::

   NAME                                 READY   STATUS    RESTARTS        AGE
   coredns-78fcd69978-775zr             1/1     Running   3 (14m ago)     17d
   coredns-78fcd69978-cx94g             1/1     Running   3 (14m ago)     17d
   etcd-pi-master1                      1/1     Running   5 (2d9h ago)    25m
   kube-apiserver-pi-master1            1/1     Running   10 (2d9h ago)   17d
   kube-controller-manager-pi-master1   1/1     Running   13 (14m ago)    17d
   kube-flannel-ds-4dxvz                1/1     Running   1 (7d7h ago)    17d
   kube-flannel-ds-jdwcr                1/1     Running   1931 (8d ago)   15d
   kube-flannel-ds-l7j6b                1/1     Running   6 (5d22h ago)   17d
   kube-flannel-ds-nqg77                1/1     Running   1 (7d7h ago)    17d
   kube-flannel-ds-pkhch                1/1     Running   3 (2d8h ago)    15d
   kube-flannel-ds-tq9x5                1/1     Running   5 (2m40s ago)   4m30s
   kube-proxy-bn9q8                     1/1     Running   2 (2d8h ago)    15d
   kube-proxy-d9xlj                     1/1     Running   1 (7d7h ago)    17d
   kube-proxy-gz9bh                     1/1     Running   6 (5d22h ago)   17d
   kube-proxy-nt27w                     1/1     Running   1 (7d7h ago)    17d
   kube-proxy-pbtcz                     1/1     Running   2 (10d ago)     15d
   kube-proxy-rfgxq                     1/1     Running   6 (14m ago)     17d
   kube-scheduler-pi-master1            1/1     Running   13 (2d9h ago)   17d

.. note::

   ``kube-flannel`` 的daemonset启动需要确保物理主机的默认路由网卡启动，如果网卡没有设置默认路由，会导致daemonset pod无法启动。这也是我之前发现，如果没有启动无线网卡（默认路由接口），管控master服务器的负载极高，应该也是和网络相关的 ``kube-flannel`` 无法正常工作有关。