.. _kubespray_startup:

=====================
Kubespray快速起步
=====================

``部署产品化Kubernetes集群``
==============================

`kubespray.io <https://kubespray.io/>`_ 是基于 :ref:`ansible` 实现的快速部署可用于生产的Kubernetes集群解决方案。

准备
=======

- 下载代码仓库:

.. literalinclude:: kubespray_startup/git_clone_kubespray
   :language: bash
   :caption: git clone下载kubespray

在代码仓库根目录下有一个 ``requirements-$ANSIBLE_VERSION.txt`` 分别对应不同的Ansible版本(也就是不同的 :ref:`python` 版本)

.. csv-table:: Ansible和Python对应版本
   :file: kubespray_startup/kubespray_ansible_python_version.csv
   :widths: 50,50
   :header-rows: 1

- 安装Ansible :

.. literalinclude:: kubespray_startup/install_ansible_for_kubespray
   :language: bash
   :caption: 基于kubespray的requirements.txt安装ansible( :ref:`virtualenv` )

.. note::

   对于 :ref:`ubuntu_linux` 22.04 LTS 需要先安装 ``python3-venv`` :

   .. literalinclude:: ../../../python/startup/virtualenv/ubuntu_venv
      :language: bash
      :caption: 在 :ref:`ubuntu_linux` 22.04 LTS 安装 ``python3-venv``

安装
=======

对于 Kubespray 安装清单(inventory)分为 3 个组:

- ``kube_node`` : 运行pods的Kubernetes节点
- ``kube_control_plane`` : 部署Kubernetes管控平面的组件( apiserver, scheduler, controller  )的master服务器
- ``etcd`` : 运行 :ref:`etcd` 的服务节点

此外还有2个特殊的组:

- ``calico_rr`` :  面向 :ref:`kubespray_calico`
- ``bastion`` : 如果服务器不能直接访问(隔离网络)，则需要指定堡垒机(bastion)

- 首先复制出需要修订的集群配置集，这里群名为 :ref:`y-k8s` :

.. literalinclude:: kubespray_startup/cp_y-k8s
   :language: bash
   :caption: 复制出作为修改的集群配置集

- 使用Ansible inventory builder构建inventory:

.. literalinclude:: kubespray_startup/create_hosts_yaml
   :language: bash
   :caption: 使用Ansible inventory builder构建inventory( hosts.yaml )

此时输出信息如下:

.. literalinclude:: kubespray_startup/create_hosts_yaml_output
   :language: bash
   :caption: 使用Ansible inventory builder构建inventory( hosts.yaml )输出信息

- 此时上述构建生成了一个 ``hosts.yaml`` 文件内容如下:

.. literalinclude:: kubespray_startup/hosts.yaml
   :language: bash
   :caption: 使用Ansible inventory builder构建inventory得到的 hosts.yaml

- 检查参数配置文件(默认可以不修改): 

.. literalinclude:: kubespray_startup/review
   :language: bash
   :caption: 检查默认配置参数

这里主要控制参数在 ``inventory/y-k8s/grpup_vars`` 目录下: 可选参数则位于 ``inventory/y-k8s/group_vars/all.yml`` ，角色可以在 ``inventory/y-k8s/group_vars/k8s_cluster.yml`` 中查看

- 清理旧Ansible Playbook的旧集群:

.. literalinclude:: kubespray_startup/cleanup
   :language: bash
   :caption: 清理旧集群

- 部署集群:

.. literalinclude:: kubespray_startup/deploy
   :language: bash
   :caption: 部署集群

.. note::

   我实际部署集群采用下文 ini 配置部署 ，原因是ini文件看起来更为清晰易懂

使用案例 ini 配置部署
======================

实际上在案例中某人提供了一个 ``inventory.ini`` 配置文件，更容易修改，对于上文部署情况，可以直接修订如下:

.. literalinclude:: kubespray_startup/inventory.ini
   :language: ini
   :caption: 基于案例修改后的 ``inventory.ini``

- 简单执行以下命令部署:

.. literalinclude:: kubespray_startup/deploy_inventory
   :language: bash
   :caption: 使用 ``inventory.ini`` 部署集群

如果失败，则回滚:

.. literalinclude:: kubespray_startup/deploy_inventory_reset
   :language: bash
   :caption: 使用 ``inventory.ini`` 部署集群

然后再次执行部署

如果一切顺利(取决于你的网络连接，特别是需要无障碍访问internet)，就会运行起一个完整的生产规格的Kubernetes::

   kubectl get nodes -o wide

显示集群已经部署完成::

   NAME        STATUS   ROLES           AGE    VERSION   INTERNAL-IP     EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION      CONTAINER-RUNTIME
   y-k8s-m-1   Ready    control-plane   5h9m   v1.24.7   192.168.8.116   <none>        Ubuntu 22.04.2 LTS   5.15.0-71-generic   containerd://1.7.1
   y-k8s-m-2   Ready    control-plane   5h8m   v1.24.7   192.168.8.117   <none>        Ubuntu 22.04.2 LTS   5.15.0-71-generic   containerd://1.7.1
   y-k8s-m-3   Ready    control-plane   5h8m   v1.24.7   192.168.8.118   <none>        Ubuntu 22.04.2 LTS   5.15.0-71-generic   containerd://1.7.1
   y-k8s-n-1   Ready    <none>          5h6m   v1.24.7   192.168.8.119   <none>        Ubuntu 22.04.2 LTS   5.15.0-71-generic   containerd://1.7.1
   y-k8s-n-2   Ready    <none>          5h6m   v1.24.7   192.168.8.120   <none>        Ubuntu 22.04.2 LTS   5.15.0-71-generic   containerd://1.7.1

检查系统部署pods::

   kubectl get pods -A -o wide

显示 ``kube-system`` 部署了基础pods::

   NAMESPACE     NAME                                      READY   STATUS    RESTARTS        AGE     IP              NODE        NOMINATED NODE   READINESS GATES
   kube-system   calico-kube-controllers-6dfcdfb99-4rgxb   1/1     Running   0               5h26m   10.233.78.65    y-k8s-n-2   <none>           <none>
   kube-system   calico-node-442kp                         1/1     Running   0               5h27m   192.168.8.118   y-k8s-m-3   <none>           <none>
   kube-system   calico-node-bcwb7                         1/1     Running   0               5h27m   192.168.8.116   y-k8s-m-1   <none>           <none>
   kube-system   calico-node-m7mfs                         1/1     Running   0               5h27m   192.168.8.117   y-k8s-m-2   <none>           <none>
   kube-system   calico-node-n78sg                         1/1     Running   0               5h27m   192.168.8.120   y-k8s-n-2   <none>           <none>
   kube-system   calico-node-xmngx                         1/1     Running   0               5h27m   192.168.8.119   y-k8s-n-1   <none>           <none>
   kube-system   coredns-645b46f4b6-k466l                  1/1     Running   0               5h25m   10.233.93.194   y-k8s-m-3   <none>           <none>
   kube-system   coredns-645b46f4b6-s5vnj                  1/1     Running   0               5h26m   10.233.121.1    y-k8s-m-2   <none>           <none>
   kube-system   dns-autoscaler-659b8c48cb-hjd49           1/1     Running   0               5h26m   10.233.93.193   y-k8s-m-3   <none>           <none>
   kube-system   kube-apiserver-y-k8s-m-1                  1/1     Running   1               5h30m   192.168.8.116   y-k8s-m-1   <none>           <none>
   kube-system   kube-apiserver-y-k8s-m-2                  1/1     Running   1               5h29m   192.168.8.117   y-k8s-m-2   <none>           <none>
   kube-system   kube-apiserver-y-k8s-m-3                  1/1     Running   1               5h29m   192.168.8.118   y-k8s-m-3   <none>           <none>
   kube-system   kube-controller-manager-y-k8s-m-1         1/1     Running   4 (5h24m ago)   5h30m   192.168.8.116   y-k8s-m-1   <none>           <none>
   kube-system   kube-controller-manager-y-k8s-m-2         1/1     Running   2 (5h29m ago)   5h30m   192.168.8.117   y-k8s-m-2   <none>           <none>
   kube-system   kube-controller-manager-y-k8s-m-3         1/1     Running   2               5h29m   192.168.8.118   y-k8s-m-3   <none>           <none>
   kube-system   kube-proxy-4vhcn                          1/1     Running   0               5h28m   192.168.8.118   y-k8s-m-3   <none>           <none>
   kube-system   kube-proxy-9zss7                          1/1     Running   0               5h28m   192.168.8.119   y-k8s-n-1   <none>           <none>
   kube-system   kube-proxy-bbv8b                          1/1     Running   0               5h28m   192.168.8.117   y-k8s-m-2   <none>           <none>
   kube-system   kube-proxy-dfpkc                          1/1     Running   0               5h28m   192.168.8.120   y-k8s-n-2   <none>           <none>
   kube-system   kube-proxy-z4b8k                          1/1     Running   0               5h28m   192.168.8.116   y-k8s-m-1   <none>           <none>
   kube-system   kube-scheduler-y-k8s-m-1                  1/1     Running   1               5h30m   192.168.8.116   y-k8s-m-1   <none>           <none>
   kube-system   kube-scheduler-y-k8s-m-2                  1/1     Running   1               5h30m   192.168.8.117   y-k8s-m-2   <none>           <none>
   kube-system   kube-scheduler-y-k8s-m-3                  1/1     Running   1               5h29m   192.168.8.118   y-k8s-m-3   <none>           <none>
   kube-system   nginx-proxy-y-k8s-n-1                     1/1     Running   0               5h27m   192.168.8.119   y-k8s-n-1   <none>           <none>
   kube-system   nginx-proxy-y-k8s-n-2                     1/1     Running   0               5h27m   192.168.8.120   y-k8s-n-2   <none>           <none>
   kube-system   nodelocaldns-2klzt                        1/1     Running   0               5h25m   192.168.8.116   y-k8s-m-1   <none>           <none>
   kube-system   nodelocaldns-jxpsr                        1/1     Running   0               5h25m   192.168.8.117   y-k8s-m-2   <none>           <none>
   kube-system   nodelocaldns-lcxjz                        1/1     Running   0               5h25m   192.168.8.120   y-k8s-n-2   <none>           <none>
   kube-system   nodelocaldns-q6x9t                        1/1     Running   0               5h25m   192.168.8.119   y-k8s-n-1   <none>           <none>
   kube-system   nodelocaldns-ztl8p                        1/1     Running   0               5h25m   192.168.8.118   y-k8s-m-3   <none>           <none>

可以看到:

- :ref:`calico` 网络
- 为何默认部署了 ``nginx-proxy`` ?待研究

参考
======

- `Kubespray Docs: Getting started <https://kubespray.io/#/docs/getting-started>`_
