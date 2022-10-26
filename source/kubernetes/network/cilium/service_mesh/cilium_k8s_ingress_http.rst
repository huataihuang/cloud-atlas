.. _cilium_k8s_ingress_http:

========================================
Cilium Kubernetes Ingress HTTP配置案例
========================================

在完成 :ref:`cilium_k8s_ingress` 部署之后，我们可以部署一个HTTP案例来验证，这里的案例是Cilium官方文档介绍的 :ref:`istio` 项目的一个 ``bookinfo`` demo microservices app

部署Demo App
================

- 执行以下命令部署Demo::

   kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.11/samples/bookinfo/platform/kube/bookinfo.yaml

- 部署完成后检查::

   kubectl get pods

输出类似::

   NAME                              READY   STATUS    RESTARTS   AGE
   details-v1-586577784f-fwhmx       1/1     Running   0          28m
   productpage-v1-589b848cc9-lcx9x   1/1     Running   0          28m
   ratings-v1-679fc7b4f-bj8q9        1/1     Running   0          28m
   reviews-v1-7b76665ff9-5t94l       1/1     Running   0          28m
   reviews-v2-6b86c676d9-dv4tm       1/1     Running   0          28m
   reviews-v3-b77c579-962sj          1/1     Running   0          28m

部署第一个ingress
===================

- 部署ingress::

   kubectl apply -f https://raw.githubusercontent.com/cilium/cilium/1.12.1/examples/kubernetes/servicemesh/basic-ingress.yaml

上述 ``basic-ingress.yaml`` 内容如下:

.. literalinclude:: cilium_k8s_ingress_http/basic-ingress.yaml
   :language: yaml
   :caption: 部署ingress案例 basic-ingress.yaml

上述案例将访问路径 ``/details`` 路由到 ``details`` 服务，而将 ``/`` 访问请求路由到 ``productpage`` 服务 (你可以将其视为 :ref:`nginx` ``locate`` 指令，分别映射不同的后端)

- 此时检查服务列表::

   kubectl get svc

此时看到::

   NAME                           TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)        AGE
   cilium-ingress-basic-ingress   LoadBalancer   10.100.187.26    <pending>     80:32598/TCP   11m
   details                        ClusterIP      10.96.29.36      <none>        9080/TCP       41m
   productpage                    ClusterIP      10.107.25.111    <none>        9080/TCP       41m
   ratings                        ClusterIP      10.111.223.74    <none>        9080/TCP       41m
   reviews                        ClusterIP      10.97.184.48     <none>        9080/TCP       41m

需要注意，这里 ``cilium-ingress-basic-ingress`` 的外部IP ``EXTERNAL-IP`` 一直是 ``pending`` ，也就是没有分配上对外IP地址(实际上外部还访问不了)

- 检查 ``ingress`` 确实也看到没有分配到地址(ADDRESS列是空的)::

   kubectl get ingress

输出显示没有分配外部地址::

   NAME            CLASS    HOSTS   ADDRESS   PORTS   AGE
   basic-ingress   cilium   *                 80      12m

这里 ``service`` (svc) 没有分配外部IP( ``EXTERNAL-IP`` )是因为没有外部provider提供IP分配，通常在云计算平台，由AWS, Azure等分配IP，所以没有问题。但是对于自己在裸服务器上构建Kubernetes，就需要自己部署 :ref:`metallb` 提供IP给load balancer服务 (我最初阅读文档以为部署 :ref:`cilium_ipam` 可以为LoadBalancer Expose服务提供IP地址，但是仔细阅读IPAM文档，发现这个IP是提供给节点上pods的，不是提供给Ingress这样的LoadBalance的)

完整输出ingress服务配置方法见 :ref:`metallb_with_cilium` ，可以实现为裸服务器配置负载均衡实现ingress的服务输出

一些思考
---------

参考 `Kubernetes service external ip pending <https://stackoverflow.com/questions/44110876/kubernetes-service-external-ip-pending>`_ ``Damith Udayanga`` 的回答:

在 Kubernetes 中，输出一组Pods上运行的应用程序到外部称为 :ref:`k8s_services` 。在Kuberntes中有4种服务：

  - ClusterIP 服务仅在集群内部可以访问
  - NodePort 通过 ``NodeIP:NodePort`` 向集群外提供服务通讯。默认的node port范围是 ``30000-32767`` ，这个端口范围可以通过集群创建时 ``--service-node-port-range`` 修改
  - LoadBalancer 使用云厂商的负载均衡输出服务到外部
  - ExternalName 映射服务到externalName字段的内容(例如 foo.bar.example.com)，通过返回带有这个值的CNAME记录。不需要设置代理

只有LoadBalancer需要External-IP字段值，并且这个模式只在Kubernetes集群可以为协作服务指定IP地址时才能工作。可以使用 :ref:`metallb` 负载均衡来为load balnacer服务提供IP。

此外 `Kubernetes service external ip pending <https://stackoverflow.com/questions/44110876/kubernetes-service-external-ip-pending>`_ ``Thilee`` 的回答也是基于 :ref:`metallb` 解决，并且提供了操作步骤可以参考。

在 `Kubernetes文档/概念/服务、负载均衡和联网/Ingress <https://kubernetes.io/zh-cn/docs/concepts/services-networking/ingress/>`_ 对 ``Ingress 是什么？`` 做了定义:

Ingress 公开从集群外部到集群内服务的 HTTP 和 HTTPS 路由。流量路由由 Ingress 资源上定义的规则控制。 (不太好理解是么? 我理解Ingres就是类似Nginx的locate规则，将流量在Kubernetes集群内部分担到不同的pods)

Ingress 不会公开任意端口或协议。 将 HTTP 和 HTTPS 以外的服务公开到 Internet 时，通常使用 Service.Type=NodePort 或 Service.Type=LoadBalancer 类型的 Service。

注意这里的关键点: Ingress如果使用 ``Service.Type=LoadBalancer`` 是需要控制外部云服务商的负载均衡来暴露服务。这是为什么呢? 

``我的理解可能是错误的`` (待进一步学习后再来修订)

(我的架构理解)原因是Pod不断在Kubernetes集群生死，实际上是不固定运行在任意Node节点的。如果将一个对外IP地址直接由Ingress来管理，那这个对外IP应该浮动在Kubernetes集群的哪个Node上呢？当然，也可以任意绑定到一个Node上，然后做反向负载均衡访问到实际的pods上，但是这个管理复杂。Kubernetes的Ingress实际上采用了:

  - 开启 ``nodePort`` 映射，将运行pods的服务端口映射到Node的指定端口
  - 控制外部云厂商提供的负载均衡，配置云厂商的负载均衡realserver的IP指向当前运行pod的Node节点IP，以及realserver的Port指向 ``nodePort`` ，这样云厂商的负载均衡就会把流量正确引向运行pod的工作节点的工作端口
  - 当Pods出现死亡并重新生成Pod(可能调度到其他Node)，则Ingress立即就知道这个新Node节点IP( ``nodePort`` 不变 )，就会立即修订云厂商的负载均衡realserver的IP地址，也就确保流量服务不断

例如我上面这个案例检查 service ::

   kubectl get svc cilium-ingress-basic-ingress -o yaml

可以看到::

     ports:
     - name: http
       nodePort: 32598
       port: 80
       protocol: TCP
       targetPort: 80
     sessionAffinity: None
     type: LoadBalancer

你可以看到Pod映射到运行该Pod的Node的端口 ``nodePort`` 是 ``32598`` ，而要求对外服务的 ``port`` 是 ``80`` ，这也就是告诉ingress配置云厂商的LoadBalancer，负载均衡VIP的realserver的端口是 ``32598`` 指向Node的IP，而负载均衡VIP对外的服务端口是 ``80`` 

.. note::

   我将部署 :ref:`metallb` 来替代云厂商的Load Balancer实现这个协作

**验证是不是需要先启用LoadBalancer** ?

- 先查看pods(对应ingress配置的service)::

   kubectl get pods -o wide

可以看到::

   NAME                              READY   STATUS    RESTARTS   AGE     IP           NODE        NOMINATED NODE   READINESS GATES
   details-v1-586577784f-fwhmx       1/1     Running   0          23h     10.0.4.182   z-k8s-n-2   <none>           <none>
   productpage-v1-589b848cc9-lcx9x   1/1     Running   0          23h     10.0.6.70    z-k8s-n-5   <none>           <none>

这个验证探索后续补充...

.. note::

   IPAM不是给ingress提供IP的，而是给Pods提供IP:

   参考 `Cilium 1.12 – Ingress, Multi-Cluster, Service Mesh, External Workloads, and much more <https://isovalent.com/blog/post/cilium-release-112/>`_ :
   
   Dynamic Allocation of Pod CIDRs (beta)
   
   When Cilium is the primary CNI, it is responsible for the allocation and management of IP addresses used by Kubernetes Pods. Cilium has many different IP Address Management (IPAM) modes, but the most popular choices for self-managed Kubernetes installations are the Kubernetes and Cluster Pool IPAM modes.

手工分配EXTERNAL IP(不成功)
------------------------------

这里我们为了简化，可以参考 `Assign External IP to a Kubernetes Service <https://stackoverflow.com/questions/44519980/assign-external-ip-to-a-kubernetes-service>`_ 手工配置一个固定IP地址。实际生产环境，需要部署IP分配服务，例如，可以参考 :ref:`dynamic_dns_loadbalancing_without_cloud_provider` 的方案，采用 :ref:`metallb` 服务来分配IP地址和对外公告。
- 手工分配EXTERNAL-IP::

   kubectl patch svc cilium-ingress-basic-ingress -p '{"spec":{"externalIPs":["192.168.6.151"]}}'

提示信息::

   service/cilium-ingress-basic-ingress patched

此时检查 ``svc`` ::

   kubectl get svc cilium-ingress-basic-ingress

可以看到已经分配了外部IP::

   NAME                           TYPE           CLUSTER-IP      EXTERNAL-IP     PORT(S)        AGE
   cilium-ingress-basic-ingress   LoadBalancer   10.100.187.26   192.168.6.151   80:32598/TCP   85m

但是，此时还访问不了这个IP，因为 ``ingress`` 还没有地址 why? ::

   kubectl get ingress basic-ingress

显示::

   NAME            CLASS    HOSTS   ADDRESS   PORTS   AGE
   basic-ingress   cilium   *                 80      88m

- 手工分配ingress相同IP(未找到方法)::

   kubectl patch ingress basic-ingress -p '{"spec":{"不知道这里填写什么":["192.168.6.151"]}}'

参考
=====

- `Cilium docs: Kubernetes Ingress Support >> Ingress HTTP Example <https://docs.cilium.io/en/stable/gettingstarted/servicemesh/http/>`_
- `Assigning Unique External IPs for Ingress Traffic <https://docs.openshift.com/container-platform/3.11/admin_guide/tcp_ingress_external_ports.html>`_
