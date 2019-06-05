.. _remote_minikube:

==================
远程访问minikube
==================

由于我在 :ref:`introduce_my_studio` 中采用 :ref:`kvm_docker_in_studio` 来模拟集群，并且在服务器上 :ref:`install_run_minikube` ，所以日常需要从个人笔记本电脑上通过远程访问服务器上的minikube系统。

kubectl访问远程裸物理机minikube
=====================================

- 本地笔记本电脑上 :ref:`install_setup_kubectl`
- 将远程服务器上的 ``~/.minikube`` 复制到本地 ``~/xcloud/minikube`` ::

   mkdir -p ~/xcloud/minikube
   cd ~/xcloud/minikube
   scp 192.168.101.81:/home/huatai/.minikube/*.crt ./
   scp 192.168.101.81:/home/huatai/.minikube/*.key ./

- 修改 kubectl 配置文件 ``$HOME/.kube/config`` ::

   apiVersion: v1
   clusters:
   - cluster:
       certificate-authority: /Users/huatai/xcloud/ca.crt
       server: https://192.168.101.81:8443
     name: xminikube
   contexts:
   - context:
       cluster: xminikube
       user: minikube
     name: xminikube
   current-context: xminikube
   kind: Config
   preferences: {}
   users:
   - name: minikube
     user:
       client-certificate: /Users/huatai/xcloud/minikube/client.crt
       client-key: /Users/huatai/xcloud/minikube/client.key


这里对配置文件修改主要有:

  - ``certificate-authority`` / ``client-certificate`` / ``client-key`` 分别修改成远程服务器的证书
    - 如果对服务器证书没有要求（降低安全性），可以配置 ``certificate-authority`` 行配置可以修改成 ``insecure-skip-tls-verify: true``
  - ``server: https://192.168.101.81:8443`` 是远程服务器的IP
  - ``cluster`` 修订成我在 :ref:`install_run_minikube` 中配置的远程服务器上裸物理机运行的minikube名字，相应的context名字也修订

.. note::

   如果在VPN环境和局域网环境切换，则IP地址可能变化，所以上述 ``192.168.101.81`` 可以修改成主机名 ``xcloud`` 并通过客户端 ``/etc/hosts`` 进行主机名IP解析，方便切换。

- 现在kubectl会根据配置 ``$HOME/.kube/config`` 默认访问远程服务器上的minikube，可以通过如下命令验证::

   kubectl cluster-info

输出显示::

   Kubernetes master is running at https://192.168.101.81:8443
   KubeDNS is running at https://192.168.101.81:8443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

检查服务器节点::

   kubectl get nodes -o wide

显示输出::

   NAME       STATUS   ROLES    AGE    VERSION   INTERNAL-IP      EXTERNAL-IP   OS-IMAGE       KERNEL-VERSION      CONTAINER-RUNTIME
   minikube   Ready    master   3d8h   v1.14.0   192.168.101.81   <none>        Ubuntu 18.10   4.18.0-20-generic   docker://18.9.6

kubectl访问远程KVM虚拟机minikube
===================================

如果在远程服务器上通过KVM运行minikube，则默认是使用远程服务器上的Host虚拟网络，对外不暴露管控API端口。需要通过iptables映射或者，需要采用本地ssh登陆到服务器上开启端口转发来实现访问KVM虚拟机中端口。举例，本地端口18443转发到远程KVM虚拟机的8443::

   ssh -L 18443:192.168.122.81:8443 -N -f 192.168.101.81

.. note::

   这里物理服务器是 192.168.101.81 ，该服务器上运行的KVM虚拟机（minikube）的IP是 192.168.122.81

启用端口转发之后，就可以把 ``~/.kube/config`` 配置中 server 设置成 ``server: https://127.0.0.1:18443`` ，则访问到远程服务器上KVM的minikube。

本地minikube命令访问远程minikube集群
======================================

现在本地的kubectl已经可以连接远程服务器上运行的minikube，不过，我们现在还没有办法像本地运行minikube一样，直接运行 ``minikube dashborad`` 访问服务器的仪表盘。虽然可以在服务器上执行 ``minikube dashboard`` 命令启动服务，但是会提示无法打开浏览器::

   -   Enabling dashboard ...
   -   Verifying dashboard health ...
   -   Launching proxy ...
   -   Verifying proxy health ...
   -   Opening http://127.0.0.1:40441/api/v1/namespaces/kube-system/services/http:kubernetes-dashboard:/proxy/ in your default browser...
   /usr/bin/xdg-open: 870: /usr/bin/xdg-open: www-browser: not found
   /usr/bin/xdg-open: 870: /usr/bin/xdg-open: links2: not found
   /usr/bin/xdg-open: 870: /usr/bin/xdg-open: elinks: not found
   /usr/bin/xdg-open: 870: /usr/bin/xdg-open: links: not found
   /usr/bin/xdg-open: 870: /usr/bin/xdg-open: lynx: not found
   /usr/bin/xdg-open: 870: /usr/bin/xdg-open: w3m: not found
   xdg-open: no method available for opening 'http://127.0.0.1:40441/api/v1/namespaces/kube-system/services/http:kubernetes-dashboard:/proxy/'
   X   failed to open browser: exit status 3

实际上，此时已经启动了 dashboard ，只是无法通过服务器上的浏览器访问（默认会启动本地浏览器）。实际上，远程服务器启动dashboard的命令可以修改成::

   sudo minikube dashboard --url

此时就只会启动dashboard服务，并输出url，但是不会强制启动浏览器::

   Enabling dashboard ...
   Verifying dashboard health ...
   Launching proxy ...
   Verifying proxy health ...
   http://127.0.0.1:35293/api/v1/namespaces/kube-system/services/http:kubernetes-dashboard:/proxy/

那么，我们怎么访问远程minikube的dashboard呢？

方法是在本地电脑上运行指令 ``kubectl proxy`` ::

   $ kubectl proxy
   Starting to serve on 127.0.0.1:8001

由于本地 kubectl 已经配置了访问远程minikube，所以将之前服务器上输出的url中的端口修改成本地端口 8001 就可以访问，即本地浏览器访问:

   http://127.0.0.1:8001/api/v1/namespaces/kube-system/services/http:kubernetes-dashboard:/proxy/

就可以打开远程服务器的dashboard。

.. figure:: ../_static/kubernetes/remote_minikube_dashboard.png
   :scale: 30

.. note::

   要获取远程minikube运行的服务和pod，需要使用 ``--all-namespaces`` 参数

   - 获取服务端口::

      kubectl get services --all-namespaces

   显示输出::

      NAMESPACE     NAME                   TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)                  AGE
      default       kubernetes             ClusterIP   10.96.0.1      <none>        443/TCP                  3d9h
      kube-system   kube-dns               ClusterIP   10.96.0.10     <none>        53/UDP,53/TCP,9153/TCP   3d9h
      kube-system   kubernetes-dashboard   ClusterIP   10.96.48.109   <none>        80/TCP                   7h29m

   - 获取所有pods::

      kubectl get pods --all-namespaces

   显示输出可以看到，当前所有的pod都是kubernetes的系统pod，都运行在 ``kube-system`` 名字空间::

      NAMESPACE     NAME                                    READY   STATUS    RESTARTS   AGE
      kube-system   coredns-fb8b8dccf-9xq25                 1/1     Running   0          3d9h
      kube-system   coredns-fb8b8dccf-mtktl                 1/1     Running   0          3d9h
      kube-system   etcd-minikube                           1/1     Running   0          3d9h
      kube-system   kube-addon-manager-minikube             1/1     Running   0          3d9h
      kube-system   kube-apiserver-minikube                 1/1     Running   0          3d9h
      kube-system   kube-controller-manager-minikube        1/1     Running   0          3d9h
      kube-system   kube-proxy-zjl44                        1/1     Running   0          3d9h
      kube-system   kube-scheduler-minikube                 1/1     Running   0          3d9h
      kube-system   kubernetes-dashboard-79dd6bfc48-vj6jl   1/1     Running   0          7h32m
      kube-system   storage-provisioner                     1/1     Running   0          3d9h

参考
========

- `Remote access to Minikube with Kubectl <https://www.systemcodegeeks.com/devops/remote-access-to-minikube-with-kubectl/>`_
- `Reaching minikube from other devices <https://cwienczek.com/2017/09/reaching-minikube-from-other-devices/>`_
- `Accessing remote minikube UI via SSH port-forwarding <https://giehlman.de/2018/02/16/accessing-remote-minikube-ui-via-ssh-port-forwarding/>`_
