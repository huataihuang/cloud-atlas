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

这里 ``service`` (svc) 没有分配外部IP( ``EXTERNAL-IP`` )是因为没有外部provider提供IP分配，这里我们为了简化，可以参考 `Assign External IP to a Kubernetes Service <https://stackoverflow.com/questions/44519980/assign-external-ip-to-a-kubernetes-service>`_ 手工配置一个固定IP地址。实际生产环境，需要部署IP分配服务，例如，可以参考 :ref:`dynamic_dns_loadbalancing_without_cloud_provider` 的方案，采用 :ref:`metallb` 服务来分配IP地址和对外公告。

不过，参考 `Cilium 1.12 – Ingress, Multi-Cluster, Service Mesh, External Workloads, and much more <https://isovalent.com/blog/post/cilium-release-112/>`_ :

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

但是，此时还访问不了这个IP，因为 ``ingress`` 还没有地址::

   kubectl get ingress basic-ingress

显示::

   NAME            CLASS    HOSTS   ADDRESS   PORTS   AGE
   basic-ingress   cilium   *                 80      88m

- 手工分配ingress相同IP(未找到方法)::

   kubectl patch ingress basic-ingress -p '{"spec":{"不知道这里填写什么":["192.168.6.151"]}}'

.. note::

   我放弃手工配置，还是参考 :ref:`cilium_ipam` 来分配IP地址, 待续

参考
=====

- `Cilium docs: Kubernetes Ingress Support >> Ingress HTTP Example <https://docs.cilium.io/en/stable/gettingstarted/servicemesh/http/>`_
