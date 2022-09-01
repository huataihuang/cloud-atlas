.. _metallb_with_cilium:

========================
在Cilium网络部署MetalLB
========================

我在 :ref:`cilium_k8s_ingress_http` 配置 ingress 输出 http服务时，遇到一个问题: 默认配置 LoadBalancer 类型服务，但是由于是裸机部署，并没有云厂商提供的负载均衡。所以Ingress一直没有分配到IP地址，也没有对应的 External-IP。

解决方法是部署 metallb 来提供对外服务IP地址

安装
=======

- 在集群安装MetalLB:

.. literalinclude:: metallb_with_cilium/kubectl_metallb-native
   :language: bash
   :caption: kubectl apply 安装 MantalLB

输出显示:

.. literalinclude:: metallb_with_cilium/kubectl_metallb-native_output
   :language: bash
   :caption: kubectl apply 安装 MantalLB 输出显示

.. note::

   其他安装方法请参考 `metallb Installation <https://metallb.universe.tf/installation/>`_

配置
======

- 创建 ``z-k8s-ip-pool.yaml``

.. literalinclude:: metallb_with_cilium/z-k8s-ip-pool.yaml
   :language: yaml
   :caption: 为负载均衡定义IPAddressPool CR

- 创建IP池:

.. literalinclude:: metallb_with_cilium/kubectl_create_ipaddresspool
   :language: bash
   :caption: 负载均衡创建IPAddressPool

完成后检查 ``svc`` 和 ``ingress`` 会立即看到IP池中的IP被分配给了LoadBalancer EXTERNAL-IP:

.. literalinclude:: metallb_with_cilium/kubectl_get_svc
   :language: bash
   :caption: 检查SVC cilium-ingress-basic-ingress

输出显示IP池的第一个IP地址被分配给LoadBalancer的EXTERNAL-IP:

.. literalinclude:: metallb_with_cilium/kubectl_get_svc_output
   :language: bash
   :caption: 检查SVC cilium-ingress-basic-ingress 输出显示EXTERNAL-IP分配成功

再检查 ingress 也看到ADDRESS分配了同样的IP地址:

.. literalinclude:: metallb_with_cilium/kubectl_get_ingress
   :language: bash
   :caption: 检查ingress

输出信息:

.. literalinclude:: metallb_with_cilium/kubectl_get_ingress_output
   :language: bash
   :caption: 检查ingress可以看到分配了相同的IP

但是此时，不管是ping还是telnet访问不了这个分配好的 IP 地址 ``192.168.6.151`` ，原因是还没有声明服务IP地址，这个步骤有多种声明方式，比较简单的是 Layer 2 配置:

- 配置 ``z-k8s-ip-pool_announce.yaml`` :

.. literalinclude:: metallb_with_cilium/z-k8s-ip-pool_announce.yaml
   :language: yaml
   :caption: 申明IP地址池的ARP公告

- 执行IP地址池ARP声明:

.. literalinclude:: metallb_with_cilium/ip-pool_announce
   :language: yaml
   :caption: 申明IP地址池的ARP公告

现在虽然 ``ping 192.168.6.151`` 没有响应，但是 ``telnet 192.168.6.151 80`` 端口可以打开了，证明负载均衡输出SVC成功

现在使用浏览器访问 http://192.168.6.151 就可以看到在 :ref:`cilium_k8s_ingress_http` 搭建的案例WEB网站了，说明服务输出正确了

参考
====

- `Kubernetes service external ip pending <https://stackoverflow.com/questions/44110876/kubernetes-service-external-ip-pending>`_
- `metallb Configuration <https://metallb.universe.tf/configuration/>`_
