.. _apiserver_port_2379_refuse:

==================================
apiserver服务器无法连接端口2379
==================================

在升级了 :ref:`arm_k8s` 管控服务器，意外发现 apiserver 运行异常::

   kubectl get pods --all-namespaces -o wide

显示::

   NAMESPACE     NAME                                 READY   STATUS                 RESTARTS   AGE     IP             NODE         NOMINATED NODE   READINESS GATES
   ...
   kube-system   kube-apiserver-pi-master1            0/1     CreateContainerError   23         110d    192.168.6.11   pi-master1   <none>           <none>
   ...
   kube-system   kube-flannel-ds-arm64-dwq86          0/1     Evicted                0          89s     <none>         jetson       <none>           <none>
   ...
   kube-system   kube-flannel-ds-jcbhq                1/1     Running                0          6h50m   192.168.6.10   jetson       <none>           <none>
   ...
   kube-system   kube-proxy-62sgn                     1/1     Running                0          6h50m   192.168.6.10   jetson       <none>           <none>

不过管控服务器 ``pi-master1`` 上其他服务运行正常。

排查
=====

- 检查 apiserver 日志::

   kubectl logs kube-apiserver-pi-master1 -n kube-system

日志显示::

   Flag --insecure-port has been deprecated, This flag will be removed in a future version.
   I0312 03:29:07.332584       1 server.go:625] external host was not specified, using 192.168.6.11
   I0312 03:29:07.333502       1 server.go:163] Version: v1.19.4
   I0312 03:29:08.642808       1 plugins.go:158] Loaded 12 mutating admission controller(s) successfully in the following order: NamespaceLifecycle,LimitRanger,ServiceAccount,NodeRestriction,TaintNodesByCondition,Priority,DefaultTolerationSeconds,DefaultStorageClass,StorageObjectInUseProtection,RuntimeClass,DefaultIngressClass,MutatingAdmissionWebhook.
   I0312 03:29:08.642890       1 plugins.go:161] Loaded 10 validating admission controller(s) successfully in the following order: LimitRanger,ServiceAccount,Priority,PersistentVolumeClaimResize,RuntimeClass,CertificateApproval,CertificateSigning,CertificateSubjectRestriction,ValidatingAdmissionWebhook,ResourceQuota.
   I0312 03:29:08.646102       1 plugins.go:158] Loaded 12 mutating admission controller(s) successfully in the following order: NamespaceLifecycle,LimitRanger,ServiceAccount,NodeRestriction,TaintNodesByCondition,Priority,DefaultTolerationSeconds,DefaultStorageClass,StorageObjectInUseProtection,RuntimeClass,DefaultIngressClass,MutatingAdmissionWebhook.
   I0312 03:29:08.646183       1 plugins.go:161] Loaded 10 validating admission controller(s) successfully in the following order: LimitRanger,ServiceAccount,Priority,PersistentVolumeClaimResize,RuntimeClass,CertificateApproval,CertificateSigning,CertificateSubjectRestriction,ValidatingAdmissionWebhook,ResourceQuota.
   I0312 03:29:08.652661       1 client.go:360] parsed scheme: "endpoint"
   I0312 03:29:08.652792       1 endpoint.go:68] ccResolverWrapper: sending new addresses to cc: [{https://127.0.0.1:2379  <nil> 0 <nil>}]
   I0312 03:29:08.681074       1 client.go:360] parsed scheme: "endpoint"
   I0312 03:29:08.681309       1 endpoint.go:68] ccResolverWrapper: sending new addresses to cc: [{https://127.0.0.1:2379  <nil> 0 <nil>}]
   I0312 03:29:08.710556       1 client.go:360] parsed scheme: "passthrough"
   I0312 03:29:08.710685       1 passthrough.go:48] ccResolverWrapper: sending update to cc: {[{https://127.0.0.1:2379  <nil> 0 <nil>}] <nil> <nil>}
   I0312 03:29:08.710716       1 clientconn.go:948] ClientConn switching balancer to "pick_first"
   I0312 03:29:08.713323       1 client.go:360] parsed scheme: "endpoint"
   I0312 03:29:08.713425       1 endpoint.go:68] ccResolverWrapper: sending new addresses to cc: [{https://127.0.0.1:2379  <nil> 0 <nil>}]
   ...
   ...
   E0312 03:29:19.225719       1 controller.go:152] Unable to remove old endpoints from kubernetes service: StorageError: key not found, Code: 1, Key: /registry/masterleases/192.168.6.11, ResourceVersion: 0, AdditionalErrorMsg:
   ...
   ...
   W0312 03:48:55.984001       1 clientconn.go:1223] grpc: addrConn.createTransport failed to connect to {https://127.0.0.1:2379  <nil> 0 <nil>}. Err :connection error: desc = "transport: Error while dialing dial tcp 127.0.0.1:2379: connect: connection refused". Reconnecting...
   ...
   ...
   I0312 03:48:55.986358       1 clientconn.go:897] blockingPicker: the picked transport is not ready, loop back to repick
   ...
   ...
   I0312 03:48:55.993287       1 clientconn.go:897] blockingPicker: the picked transport is not ready, loop back to repick
   W0312 03:48:55.993714       1 clientconn.go:1223] grpc: addrConn.createTransport failed to connect to {https://127.0.0.1:2379  <nil> 0 <nil>}. Err :connection error: desc = "transport: Error while dialing dial tcp 127.0.0.1:2379: connect: connection refused". Reconnecting...
   I0312 03:48:55.996428       1 controller.go:181] Shutting down kubernetes service endpoint reconciler
   I0312 03:48:55.997715       1 controller.go:123] Shutting down OpenAPI controller
   ...

看起来最初的报错是有关 ``StorageError`` ，找不到key文件 ``/registry/masterleases/192.168.6.11``

- 观察 ``dmesg -T`` 输出，发现一个奇怪的报错::

   ...
   [Mon Mar 22 11:01:52 2021] RPC: fragment too large: 1246907721

- 但是，既然 apiserver 创建失败，但是为何我还能使用 ``kubectl`` 命令来访问 apiserver 呢？例如，我使用::

   kubectl get nodes
   kubectl get pods -o wide -n kubesystem
   kubectl get pods -o wide -n kube-verify

上述命令都能够正常工作，并且我在回复 :ref:`arm_k8s_deploy` 的Jetson节点时候，完全顺利实现了 :ref:`remove_node` 并重新加回 Jetson 节点。

etcd错误
==========

- 检查 ``ps aux | grep apiserver`` 就可以看到，访问端口 ``2379`` 其实就是访问 ``etcd`` 服务::

   kube-apiserver --advertise-address=192.168.6.11 ... --etcd-servers=https://127.0.0.1:2379 ....

这说明apiserver访问etcd出现错误，很可能就是 etcd 错误导致的。

- 再次检查 etcd 这个pod::

   kubectl get pods -n kube-system -o wide

看到::

   NAME                                 READY   STATUS                 RESTARTS   AGE     IP             NODE         NOMINATED NODE   READINESS GATES
   ...
   etcd-pi-master1                      1/1     Running                18         110d    192.168.6.11   pi-master1   <none>           <none>
   ...

- 检查 etcd 日志，并没有发现异常错误

kubelet错误
=============

`kubenetes #74262 <https://github.com/kubernetes/kubernetes/issues/74262>`_ 提到可以检查kubelet日志::

   journalctl -xeu kubelet

注意， ``journalctl`` 参数 ``-xeu`` 则日志不换行，有些过长日志不方便检查。可以加上 ``--no-pager`` 则直接屏幕打印，可以重定向到 ``|  vim -`` 检查

我的日志输出确实存在大量报错::

   Mar 22 21:05:33 pi-master1 kubelet[1115805]: E0322 21:05:33.780814 1115805 pod_workers.go:191] Error syncing pod 1403dda53affdfee1130475a6d9609da ("kube-apiserver-pi-master1_kube-system(1403dda53affdfee1130475a6d9609da)"), skipping: failed to "StartContainer" for "kube-apiserver" with CreateContainerError: "Error response from daemon: Conflict. The container name \"/k8s_kube-apiserver_kube-apiserver-pi-master1_kube-system_1403dda53affdfee1130475a6d9609da_24\" is already in use by
   container \"eced8537863007db9a915924785306b26238cabbd3feec0e5226e2ad0710807b\". You have to remove (or rename) that container to be able to reuse that name."

原来启动容器命名出现了重名，之前的 ``kube-apiserver-pi-master1`` 尚未清理导致无法启动相同名字的容器

- 检查 ``docker ps --all`` 查看是否有同名残留::

   docker ps --all | grep kube-apiserver-pi-master1

可以看到::

   8470235abd66        4958a2396b16                 "kube-apiserver --ad…"   10 days ago         Exited (0) 10 days ago                         k8s_kube-apiserver_kube-apiserver-pi-master1_kube-system_1403dda53affdfee1130475a6d9609da_23
   eced85378630        4958a2396b16                 "kube-apiserver --ad…"   10 days ago         Up 10 days                                     k8s_kube-apiserver_kube-apiserver-pi-master1_kube-system_1403dda53affdfee1130475a6d9609da_24
   07637544b672        k8s.gcr.io/pause:3.2         "/pause"                 10 days ago         Up 10 days                                     k8s_POD_kube-apiserver-pi-master1_kube-system_1403dda53affdfee1130475a6d9609da_17
   46497b3b5724        k8s.gcr.io/pause:3.2         "/pause"                 10 days ago         Exited (0) 10 days ago                         k8s_POD_kube-apiserver-pi-master1_kube-system_1403dda53affdfee1130475a6d9609da_15

- 尝试删除已经退出的容器::

   sudo docker rm 8470235abd66
   sudo docker rm 46497b3b5724

- 果然，现在 ``apiserver`` 容器能够正常创建了::

   kubectl get pods -o wide -n kube-system

显示正常运行::

   NAME                                 READY   STATUS    RESTARTS   AGE    IP             NODE         NOMINATED NODE   READINESS GATES
   ...
   kube-apiserver-pi-master1            1/1     Running   24         4h8m   192.168.6.11   pi-master1   <none>           <none>

- 再次检查系统中存在退出但是没有清理的docker容器::

   sudo docker ps --all | grep Exited

- 然后检查确定后做清理::

   sudo docker ps --all | grep Exited | awk '{print $1}' | xargs sudo docker rm

推测
======

我注意到kubernetes升级，下一个 kubernetes apiserver 容器命名是后缀是依次递增的，这点可以从 ``docker ps --all`` 看到::
   
   k8s_kube-apiserver_kube-apiserver-pi-master1_kube-system_1403dda53affdfee1130475a6d9609da_23
   k8s_kube-apiserver_kube-apiserver-pi-master1_kube-system_1403dda53affdfee1130475a6d9609da_24

也就是说如果有一个升级过程中 ``kube-apiserver...24`` 意外退出，则升级程序还会重新尝试用同一个容器名创建启动，这就在docker上导致冲突

看来连接 ``etcd`` 端口失败仅仅是表象，实际排查故障还是需要从 ``kubelet`` 日志着手。

参考
=======

- `kubenetes #74262 <https://github.com/kubernetes/kubernetes/issues/74262>`_
