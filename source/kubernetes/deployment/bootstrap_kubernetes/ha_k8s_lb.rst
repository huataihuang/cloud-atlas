.. _ha_k8s_lb:

============================
高可用k8s的Master负载均衡
============================

正如 :ref:`ha_k8s` 所述，构建Kubernetes高可用集群，以etcd是否独立部署来划分两种不同对HA部署架构：

- 堆叠部署etcd
- 独立部署etcd

在部署扩展多Master节点高可用集群之前，我们先要为apiserver准备好负载均衡。即完成本章节准备工作之后，我们才能继续 :ref:`create_ha_k8s` 。

负载均衡
==========

不管采用哪种HA部署方式，都需要使负载均衡来分发worker节点对请求和连接给后端的多个apiserver。在 :ref:`create_ha_k8s` 中，我们扩展了Kubenetes Master服务器，使得对外同时具备了多个Kube-apiserver服务，现在我们需要在apiserver之前构建负载均衡，使得worker节点可以通过负载均衡的VIP来访问后端实际服务器。

kube-apiserver负载均衡：

- 对外服务VIP需要DNS解析
- 控制平面节点(Master节点)使用的是TCP转发负载均衡，该负载均衡将请求分发给所有健康的控制平面节点(健康检查是TCP检查kube-apiserver端口，默认6443)
- 在云环境中不建议直接使用IP地址(通过DNS解析可以按需调整IP)
- 负载均衡必须能够和所有控制平面节点的apiserver端口通讯，并且在负载均衡的监听端口允许进入流量(请参考下文通过 ``firewall-cmd`` 添加防火墙规则方法)
- 确保负载均衡的地址和 kubeadm 的 ``ControlPlaneEndpoint`` 地址完全一致

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

准备工作
----------

- ``haproxy-1`` 和 ``haproxy-2`` 需要关闭SELinux，否则启动haproxy服务无法绑定端口(详细见下文 ``问题排查`` )::

   setenforce 0
   sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

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
       state MASTER
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

   对于Keepalived其他节点，例如 ``haproxy-2`` ，需要修订 ``unicast`` 部分，将对等部分互换。此外， ``state BACKUP`` 和 ``priority 100`` 表示后备节点::

      vrrp_instance haproxy-vip {
          state BACKUP
          priority 100
          interface eth0
          virtual_router_id 47
          advert_int 3

          unicast_src_ip 192.168.122.9
          unicast_peer {
              192.168.122.8
              # 可配置多个peer
              # 192.168.122.X
          }
      }

.. note::

   keepalived 使用VRRP协议(ip protocol 112)以及多播地址 ``224.0.0.18`` ，需要在防火墙上开启::

      firewall-cmd --add-rich-rule='rule protocol value="vrrp" accept' --permanent
      firewall-cmd --reload

   通过以下命令可以检查已经添加的filter rules::

      firewall-cmd --list-rich-rules

   参考文档： `Red Hat Enterprise Linux7 > Load Balancer Administration > 3.3. Putting the Configuration Together <https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/load_balancer_administration/s1-lvs-connect-vsa>`_

    也可以参考 `Oracle® Linux Administrator's Guide for Release 7 > Load Balancing Configuration > 17.5 Installing and Configuring Keepalived <https://docs.oracle.com/cd/E52668_01/E54669/html/section_ksr_psb_nr.html>`_ 通过以下命令添加::

      firewall-cmd --direct --permanent --add-rule ipv4 filter INPUT 0 \
        --in-interface eth0 --destination 224.0.0.18 --protocol vrrp -j ACCEPT
      firewall-cmd --direct --permanent --add-rule ipv4 filter OUTPUT 0 \
        --in-interface eth0 --destination 224.0.0.18 --protocol vrrp -j ACCEPT
      firewall-cmd --reload

- 启动keeplived::

   sudo systemctl start keepalived
   sudo systemctl enable keepalived

启动后观察服务器，可以看到其中一台服务器的 eth0 上会绑定浮动IP 192.168.122.10 ::

   2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
       link/ether 52:54:00:d2:30:88 brd ff:ff:ff:ff:ff:ff
       inet 192.168.122.8/24 brd 192.168.122.255 scope global noprefixroute eth0
          valid_lft forever preferred_lft forever
       inet 192.168.122.10/32 scope global eth0
          valid_lft forever preferred_lft forever
       inet6 fe80::5054:ff:fed2:3088/64 scope link
          valid_lft forever preferred_lft forever

注意：浮动VIP只绑定在 ``haproxy-1`` 和 ``haproxy-2`` 的其中一台网卡上，所以只有一个服务器能够启动haproxy(因为启动时缺少浮动IP ``192.168.122.10`` 则不能启动haproxy)。

.. note::

   采用Keepalived管理HAProxy也有一个不足，就是只使用了一台HAProxy的负载能力。为了能够提供更多的HAProxy负载均衡能力，我考虑可以采用两两配对方式，分别在多对服务器上启用keeplived来实现对不同端口对HAProxy进行监控和提供浮动VIP。

   在HAProxy前端，则部署Nginx做反向代理，Nginx实现简单的四层负载均衡。Nginx对外采用DNS轮询方式实现GSLB。

   GSLB结合脚本侦测和DDNS动态更新DNS记录，自动摘除故障的Nginx节点。

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
     :emphasize-lines: 6,51,54-56,60,62-70
     :linenos:
     :caption:

.. note::

   同样需要放开HAProxy的apiserver访问端口，参考 :ref:`kubeadm` ::

      sudo firewall-cmd --zone=public --add-port=6443/tcp --permanent
      sudo firewall-cmd --reload

.. note::

   ``stats socket /var/lib/haproxy/stats`` 替换了 ``stats socket /run/haproxy/admin.sock mode 660 level admin`` ，原因是发行版操作系统启动默认没有 ``/run/haproxy`` 目录，会导致无法创建 sock 文件。见下文。

   ``bind *:6443`` 是为了使得haproxy启动时能绑定任何的接口，因为keeplived只在主服务器上启动了VIP地址，所以设置了通配符 ``*`` 来匹配，否则haproxy在没有浮动VIP的主机上无法启动。

keepalived+haproxy验证
========================

测试apiserver VIP
--------------------

现在 VIP ``192.168.122.10`` 浮动在 ``proxy-1`` 虚拟机上，所以我们可以通过以下命令验证是否可以访问集群。

- 首先验证端口::

   telnet 192.168.122.10 6443

验证端口可以正常打开，则修改物理主机 ``worker4`` 上访问集群的配置文件 ``.kube/config`` ::

   server: https://192.168.122.11:6443

修订成::

   server: https://192.168.122.10:6443

- 再次访问服务 ``kubectl cluster-info`` 则显示证书错误::

   Unable to connect to the server: x509: certificate is valid for 10.96.0.1, 192.168.122.11, not 192.168.122.10



问题排查
============

HAProxy无法绑定socket
-----------------------

启动遇到报错::

   haproxy-systemd-wrapper[20624]: [ALERT] 229/120654 (20625) : Starting frontend GLOBAL: cannot bind UNIX socket [/run/haproxy/admin.sock]

上述报错是因为默认系统没有 ``/run/haproxy`` 目录，原文配置中指定的 ``/run/haproxy/admin.sock`` 无法构构建。我参考发行版将目录修改成 ``/var/lib/haproxy`` ::

   stats socket /var/lib/haproxy/stats

keepalived启动无问题，但是haproxy启动显示无法绑定服务端口::

   Aug 13 17:32:13 haproxy-1 haproxy[11385]: Proxy monitor-in started.
   Aug 13 17:32:13 haproxy-1 haproxy-systemd-wrapper[11384]: [ALERT] 224/173213 (11385) : Starting frontend k8s-api: cannot bind socket [192.168.122.10:6443]
   Aug 13 17:32:13 haproxy-1 haproxy-systemd-wrapper[11384]: [ALERT] 224/173213 (11385) : Starting frontend k8s-api: cannot bind socket [127.0.0.1:6443]
   Aug 13 17:32:13 haproxy-1 haproxy-systemd-wrapper[11384]: haproxy-systemd-wrapper: exit, haproxy RC=1
   Aug 13 17:32:13 haproxy-1 systemd[1]: haproxy.service: main process exited, code=exited, status=1/FAILURE
   Aug 13 17:32:13 haproxy-1 systemd[1]: Unit haproxy.service entered failed state.
   Aug 13 17:32:13 haproxy-1 systemd[1]: haproxy.service failed.

参考 `could not bind socket while haproxy restart <https://serverfault.com/questions/286598/could-not-bind-socket-while-haproxy-restart>`_ 原因是默认CentOS激活了SELinux不允许绑定，可以通过以下命令设置selinux::

   setsebool haproxy_connect_any on

或者参考 :ref:`kubeadm` 同样设置HAProxy 节点上的 SELinux 设置成 ``permissive`` 模式::

   setenforce 0
   sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

参考
========

- `Kubernetes cluster step-by-step: Kube-apiserver with Keepalived and HAProxy for HA <https://icicimov.github.io/blog/kubernetes/Kubernetes-cluster-step-by-step-Part5/>`_
- `How To Configure A High Available Load-balancer With HAProxy And Keepalived <https://www.unixmen.com/configure-high-available-load-balancer-haproxy-keepalived/>`_
- `INSTALL HAPROXY AND KEEPALIVED ON CENTOS 7 FOR MARIADB CLUSTER <https://snapdev.net/2015/09/08/install-haproxy-and-keepalived-on-centos-7-for-mariadb-cluster/>`_
- `Managing Failovers with Keepalived & HAproxy <https://medium.com/@sliit.sk95/managing-failovers-with-keepalived-haproxy-c8de98d0c96e>`_
