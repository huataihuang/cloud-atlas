.. _create_k8s_cluster:

=========================
创建单一控制平面集群
=========================

初始化控制平面节点(control-plane node)
========================================

管控平面节点(control-plane node)是指控制平面组件运行的主机节点，包括 ``etcd`` (集群数据库) 和 API 服务器(kubectl命令行工具通讯的服务器组件)。

- 规划并选择一个pod network add-on，请注意所选择CNI是否需要的任何参数传递给kubeadm初始化

我这里选择 Flannel 作为CNI，以便采用精简的网络配置和获得较好的性能。根据Flannel CNI的安装要求，是需要想 ``kubeadm init`` 传递参数 ``--pod-network-cidr=10.244.0.0/16`` 。

.. note::

   必须安装一个 pod network add-on 这样你的pod才能彼此通讯。

   在部署任何应用程序之前需要部署网络，并且网络安装之前不能启动 CoreDNS。 kubeadm 只支持 Container Network Interface (CNI) 网络(并且不支持kubenet)。

   由于有多种CNI容器网络接口，对比选择很重要，可以参考 `Choosing a CNI Network Provider for Kubernetes <https://chrislovecnm.com/kubernetes/cni/choosing-a-cni-provider/>`_ 和 `Kubernetes 网络模型 <https://feisky.gitbooks.io/kubernetes/network/network.html>`_

   `Kubernetes网络插件（CNI）基准测试的最新结果 <https://tonybai.com/2019/04/18/benchmark-result-of-k8s-network-plugin-cni/>`_ 一文对比测试了不同CNI的性能、易用性和高级加密特性，推荐如下:

   - 服务器硬件资源有限并且不需要安全功能，推荐 Flannel ：最精简和易用的CNI，兼容x86和ARM，自动检测MTU，无需配置。
   - 如果需要加密网络则使用WeaveNet，但是徐亚注意MTU设置，并且性能较差（加密的代价）
   - 其他常用场景推荐 Calico ，是广泛用于Kubernetes部署工具(Kops, Kubespray, Rancher等)的CNI，在资源消耗、性能和安全性有较好平衡。需要注意ConfigMap中设置MTU以适配巨型帧。

.. note::

   kubeadm默认设置了一个较为安全的集群并且使用 RBAC ，所以需要确保你选择的网络框架支持 RBAC 。

   使用的 Pod network 必须不覆盖任何主机网络，否则会导致故障。如果你发现网络插件的Pod neetowrk和物理主机网络冲突，则需要选择合适的CIDR，并且采用 ``kubeadm init`` 的 ``--pod-network-cidr`` 来指定

- (可选)从v1.14开始，kubeadm可以自动检测Linux所使用的container runtime。如果使用不同的container runtime，则指定 ``--cri-socket`` 参数传递给 ``kubeadm init``

- (可选)除非指定，否则kubeadm将使用默认网关相关的网络接口来公告master的IP。如果要使用不同的网络接口，则传递 ``--apiserver-advertise-address=<ip-address>`` 参数给 ``kubeadm init``

- (可选)可运行 ``kubeadm config images pull`` 使得 ``kubeadm init`` 验证到 ``gcr.io`` 仓库的网络连接


初始化命令执行
----------------

::

   kubeadm init --pod-network-cidr=10.244.0.0/16

.. note::

   上述 ``kubeadm init`` 要求主机已经正确运行了kubelet，否则会出现报错::

      [kubelet-check] It seems like the kubelet isn't running or healthy.
      [kubelet-check] The HTTP call equal to 'curl -sSL http://localhost:10248/healthz' failed with error: Get http://localhost:10248/healthz: dial tcp 127.0.0.1:10248: connect: connection refused.
      
      Unfortunately, an error has occurred:
              timed out waiting for the condition

   可通过以下方法检查 ``kubelet`` 问题::

      systemctl status kubelet
      journalctl -xeu kubelet

参考
=========

- `Creating a single control-plane cluster with kubeadm <https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/>`_
- `使用kubeadm部署k8s集群 <https://www.jianshu.com/p/d5ce8a9ecbbf>`_
- `k8s与网络--Flannel解读 <https://segmentfault.com/a/1190000016304924>`_
- `Choosing a CNI Network Provider for Kubernetes <https://chrislovecnm.com/kubernetes/cni/choosing-a-cni-provider/>`_
- `Kubernetes 网络模型 <https://feisky.gitbooks.io/kubernetes/network/network.html>`_
