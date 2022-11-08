.. _cilium_install_with_external_etcd:

=========================
在扩展etcd环境安装cilium
=========================

:ref:`cilium_startup` 介绍了快速安装cilium的方法，但是只是适合比较简单环境，即采用堆叠etcd模式环境，而在采用外部独立etcd集群，则需要做一些调整，把 ``etcd`` 集群配置传递给cilium安装程序

cilium使用外部KV存储(通常是 :ref:`etcd` )优点:

- 使用外部扩展KV存储可以解决Kubernetes大量事件传播开销极大的问题
- 使用外部扩展KV存储可以避免cilium将状态存储在Kubernetes自定义资源(CRD)中
- 使用外部扩展KV存储可以支持更多pod和节点

运行cilium环境要求:

- Kubernetes >= 1.16
- Linux kernel >= 4.9
- Kubernetes使用CNI模式
- 在所有工作节点挂载了 :ref:`ebpf` 文件系统
- **建议** : 在 ``kube-controller-manager`` 上激活 ``PodCIDR`` 分配( ``--allocate-node-cidrs`` )

配置Cilium
==============

Cilium需要在ConfigMap中配置扩展外部KV存储，这个配置是通过 :ref:`helm` 完成的，所以需要首先安装 ``helm3`` :

.. literalinclude:: ../../../deploy/helm/linux_helm_install
   :language: bash
   :caption: 在Linux平台安装helm

- 设置cilium Helm仓库:

.. literalinclude:: cilium_install_with_external_etcd/helm_repo_add_cilium
   :language: bash
   :caption: 设置cilium Helm仓库

此时提示::

   "cilium" has been added to your repositories

- 通过 :ref:`helm` 部署Cilium:

.. literalinclude:: cilium_install_with_external_etcd/helm_install_cilium
   :language: bash
   :caption: 为cilium配置访问etcd的Kubernetes secret，安装cilium采用SSL模式访问etcd

执行安装以后提示信息::

   W0719 01:01:50.091851  995900 warnings.go:70] spec.template.spec.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[1].matchExpressions[0].key: beta.kubernetes.io/os is deprecated since v1.14; use "kubernetes.io/os" instead
   NAME: cilium
   LAST DEPLOYED: Tue Jul 19 01:01:48 2022
   NAMESPACE: kube-system
   STATUS: deployed
   REVISION: 1
   TEST SUITE: None
   NOTES:
   You have successfully installed Cilium with Hubble.

   Your release version is 1.11.7.

   For any further help, visit https://docs.cilium.io/en/v1.11/gettinghelp

此时，在安装了 cilium 这样的 CNI 之后，在 :ref:`k8s_dnsrr` 部署过程中没有运行起来的coredns容器就能够分配IP地址并运行起来:

.. literalinclude:: ../../../deploy/bootstrap_kubernetes_ha/ha_k8s_dnsrr/k8s_dnsrr/kubectl_get_pods_after_net
   :language: bash
   :caption: 安装cilium CNI网络之后coredns就可以运行，此时 kubectl get pods 输出可以看到所有pods已分配IP并运行

验证安装
==========

- 安装最新版本Cilium CLI:

.. literalinclude:: cilium_install_with_external_etcd/install_cilium_cli
   :language: bash
   :caption: 安装cilium CLI

- 检查::

   cilium status

此时屏幕会输出:

.. literalinclude:: cilium_install_with_external_etcd/cilium_status_after_install
   :language: bash
   :caption: cilium安装完成后状态验证

.. note::

   这里显示 ``cilium-operator`` 配置了2个pod，但只有1个pod运行是因为目前我正在bootstrap管控节点，当前只运行了一个管控节点，所以deployment配置了2个replicas只能先运行1个。稍后完成管控节点扩容后就能保证有足够master节点运行 ``cilium-operator``

- :ref:`k8s_dnsrr` 第一个管控节点安装好 ``cilium`` 之后 :ref:`coredns` 就可以分配到IP地址运行起来。接下来可以完成第二、第三个管控节点以及各个工作节点添加，直到整个集群建立

.. note::

   只需要在第一个管控节点上安装 :ref:`helm` 以及 ``cilium`` 客户端(验证)，通过 ``helm`` 就可以为整个集群安装部署 ``cilium`` 网络，扩展安装非常方便。

- 当 :ref:`k8s_dnsrr` 工作节点正确运行之后，就可以通过 ``cilium`` 客户端来验证网络连接性::

   cilium connectivity test

``cilium connectivity test`` 是一个非常 ``赞`` 的探针功能，自动构建了同一个worker节点和不同worker节点上的 ``cilium-test`` 容器相互间进行网络联通测试::

   $ kubectl get pods -o wide -n cilium-test
   NAME                              READY   STATUS    RESTARTS   AGE     IP           NODE        NOMINATED NODE   READINESS GATES
   client-7df6cfbf7b-kc4mz           1/1     Running   0          5m50s   10.0.3.103   z-k8s-n-1   <none>           <none>
   client2-547996d7d8-pv4n5          1/1     Running   0          4m38s   10.0.3.210   z-k8s-n-1   <none>           <none>
   echo-other-node-d79544ccf-hxjzb   2/2     Running   0          57s     10.0.7.132   z-k8s-n-4   <none>           <none>
   echo-same-node-5d466d5444-kbgzl   2/2     Running   0          2m5s    10.0.3.68    z-k8s-n-1   <none>           <none>

完成测试后会在终端显示测试结果

参考
======

- `cilium Getting Started Guides: Installation with external etcd <https://docs.cilium.io/en/stable/gettingstarted/k8s-install-external-etcd/>`_
