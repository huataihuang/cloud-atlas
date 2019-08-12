.. _create_ha_k8s:

============================
使用kubeadm创建高可用集群
============================

正如 :ref:`ha_k8s` 所述，构建Kubernetes高可用集群，以etcd是否独立部署来划分两种不同对HA部署架构：

- 堆叠部署etcd
- 独立部署etcd

负载均衡
==========

不管采用哪种HA部署方式，都需要使负载均衡来分发worker节点对请求和连接给后端的多个apiserver，所以构建高可用集群，首先需要构建的是管控平面的负载均衡。

.. note::

   apiserver高可用采用的是负载均衡方式实现，不论堆叠部署etcd还是分离部署etcd，集群的worker节点访问apiserver都是通过负载均衡实现的。负载均衡有多种解决方案，这里采用的是HAProxy实现，并且结合了Keepalived实现HAProxy的高可用部署。

   HAProxy虚拟机采用 :ref:`k8s_hosts` 所创建的2个 ``haproxy-1`` 和 ``haproxy-2`` 虚拟机。

      192.168.122.8   haproxy-1 haproxy-1.huatai.me
      192.168.122.9   haproxy-2 haproxy-2.huatai.me
      192.168.122.10  kubeapi kubeapi.huatai.me            #在HAProxy上构建apiserver的VIP

.. note::

   `Kubernetes cluster step-by-step: Kube-apiserver with Keepalived and HAProxy for HA <https://icicimov.github.io/blog/kubernetes/Kubernetes-cluster-step-by-step-Part5/>`_ 采用的是直接在3个Kuberenetes Master构建Keepalived和HAProxy，这种方式可以节约服务器使用。不过，我的部署采用了独立的haproxy服务器，目的是为了能够功能清晰并且能够更好横向扩展，以便适应大型负载网络。
   
.. warning::

   由于kubelet客户端采用长连接方式访问apiserver，所以一旦kubelet通过负载均衡分发到后端到apiserver之后，除非kubelet客户端重启，一般情况下kubelete客户端会始终访问同一台apiserver。这就带来了一个均衡性问题：当apiserver由于升级重启或者crash重启，kubelet客户端连接会集中到其他正常服务器上并且不会再平衡。极端情况下，可能虽然有多个apiserver，但负载会集中到少量服务器上。

   这个问题在KubeCon China 2019的阿里云演讲 `Understanding Scalability and Performance in the Kubenetes Masteer <https://www.youtube.com/watch?v=1ThhTbMO1NE>`_ 有详细介绍和解决方案思路介绍(中文观看请访问 `了解 Kubernetes Master 的可扩展性和性能 <https://v.qq.com/x/page/v0906j1czvd.html>`_ )。

API高可用HAProxy和Keeplived
==============================

Keepalived
-------------

Keepalived提供Kubernetes集群Master VIP 192.168.122.10 ( :ref:`studio_ip` )，即浮动在HAProxy的健康节点之一，提供对外服务的访问IP，并在节点故障时自动切换到其他健康节点。Kubernetes API将始终通过HAProxy提供对外访问。

- 安装 keepalived ::

   sudo yum install keepalived 

.. note::

   默认安装 keepalived 已经具备了一个案例配置 ``/etc/keepalived/keepalived.conf`` ，备份这个文件再重新按本文配置::

      mv /etc/keepalived/keepalived.conf /etc/keepalived/keepalived.conf.bak

在 ``haproxy-1`` 节点的 ``/etc/keepalived/keepalived.conf`` 配置如下::

   vrrp_script haproxy-check {
       script "killall -0 haproxy"
       interval 2
       weight 20
   }
   
   vrrp_instance haproxy-vip {
       state BACKUP
       priority 101
       interface eth0
       virtual_router_id 47
       advert_int 3
   
       unicast_src_ip 192.168.122.8
       unicast_peer {
           192.168.122.9
           # 可配置多个peer
           # 192.168.122.X
       }
   
       virtual_ipaddress {
           192.168.122.10
       }
   
       track_script {
           haproxy-check weight 20
       }
   }     

.. note::

   对于Keepalived其他节点，例如 ``haproxy-2`` ，需要修订 ``unicast`` 部分，将对等部分互换，例如::

      unicast_src_ip 192.168.122.9
      unicast_peer {
          192.168.122.8
          # 可配置多个peer
          # 192.168.122.X
      }

HAProxy
-----------

HAProxy将检查后端 ``kubemaster-X`` 服务器上的 ``kube-apiserver`` 端口健康状态，并且负载均衡请求到集群的健康实例上，并且也将对局域网提供Kubernetes web UI(Dashboard)服务，对外提供服务的虚拟VIP即Keepalived的浮动IP地址 ``192.168.122.10`` 。

- 安装HAProxy::

   sudo yum install haproxy

.. note::

   默认安装HAProxy配置文件备份::

      mv /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg.bak

.. note::

   `Kubernetes cluster step-by-step: Kube-apiserver with Keepalived and HAProxy for HA <https://icicimov.github.io/blog/kubernetes/Kubernetes-cluster-step-by-step-Part5/>`_ 原文 `haproxy-k8s.cfg案例配置 <https://icicimov.github.io/blog/download/haproxy-k8s.cfg>`_ 中包含了 `trafik (Cloud Native边缘路由器，用于提供代理和负载均衡，取代nginx) <https://traefik.io/>`_ 配置，这里我没有采用。后续再做学习和实践。

- 配置 ``/etc/haproxy/haproxy.cfg`` 内容如下，注意相关 ``k8s-api`` 部分高亮

 .. literalinclude:: haproxy.cfg
     :language: bash
     :emphasize-lines: 57-61,67,69-77
     :linenos:
     :caption:

参考
========

- `Kubernetes cluster step-by-step: Kube-apiserver with Keepalived and HAProxy for HA <https://icicimov.github.io/blog/kubernetes/Kubernetes-cluster-step-by-step-Part5/>`_
- `How To Configure A High Available Load-balancer With HAProxy And Keepalived <https://www.unixmen.com/configure-high-available-load-balancer-haproxy-keepalived/>`_
- `INSTALL HAPROXY AND KEEPALIVED ON CENTOS 7 FOR MARIADB CLUSTER <https://snapdev.net/2015/09/08/install-haproxy-and-keepalived-on-centos-7-for-mariadb-cluster/>`_
  `
