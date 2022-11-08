.. _z-k8s:

=======================
Kubernetes集群(z-k8s)
=======================

部署 ``基于DNS轮询构建高可用Kubernetes`` ，后续部署集群改造成 :ref:`haproxy` 负载均衡的 :ref:`ha_k8s_lb` 架构

准备etcd访问证书
===================

由于是访问外部扩展etcd集群，所以首先需要将etcd证书复制到管控服务器节点，以便管控服务器服务(如apiserver)启动后能够正常读写etcd:

- 在管控服务器 ``z-k8s-m-1`` / ``z-k8s-m-2`` / ``z-k8s-m-3`` 上创建 ``etcd`` 访问证书目录，并将 :ref:`priv_etcd` 准备好的证书复制过来:

.. literalinclude:: ../../kubernetes/deploy/etcd/priv_deploy_etcd_cluster_with_tls_auth/etcdctl_endpoint_env
      :language: bash
      :caption: etcd客户端配置:使用证书
      :emphasize-lines: 4-6

将上述 ``etcdctl`` 客户端配置文件和Kubernetes访问etcd配置文件一一对应如下:

.. csv-table:: kubernetes apiserver访问etcd证书对应关系
      :file: ../../kubernetes/deploy/bootstrap_kubernetes_ha/ha_k8s_dnsrr/k8s_dnsrr/etcd_key.csv
      :widths: 40, 60
      :header-rows: 1

- 分发kubernetes的apiserver使用的etcd证书:

.. literalinclude:: ../../kubernetes/deploy/bootstrap_kubernetes_ha/ha_k8s_dnsrr/k8s_dnsrr/deploy_k8s_apiserver_key
   :language: bash
   :caption: 分发kubernetes的apiserver使用的etcd证书

.. note::

   我是在具备密钥认证管理主机 ``z-b-data-1`` 上作为客户端，通过ssh远程登录到 ``z-k8s-m-1`` / ``z-k8s-m-2`` / ``z-k8s-m-3`` ，执行上述 ``deploy_k8s_etcd_key.sh`` 分发密钥

配置第一个管控节点(control plane ndoe)
=======================================

- 创建 ``create_kubeadm-config.sh`` 脚本 :

.. literalinclude:: ../../kubernetes/deploy/bootstrap_kubernetes_ha/ha_k8s_dnsrr/k8s_dnsrr/create_kubeadm-config
   :language: bash
   :caption: 创建第一个管控节点配置 kubeadm-config.yaml

- 执行 ``sh create_kubeadm-config.sh`` 生成 ``kubeadm-config.yaml`` 配置文件

- 创建第一个管控节点:

.. literalinclude:: ../../kubernetes/deploy/bootstrap_kubernetes_ha/ha_k8s_dnsrr/k8s_dnsrr/kubeadm_init
   :language: bash
   :caption: 初始化第一个管控节点 kubeadm init

- 根据提示，执行以下命令为自己的账户准备好管理配置

.. literalinclude:: ../../kubernetes/deploy/bootstrap_kubernetes_ha/ha_k8s_dnsrr/k8s_dnsrr/kube_config
   :language: bash
   :caption: 配置个人账户的管理k8s环境

并且提供了如何添加管控平面节点的操作命令(包含密钥，所以必须保密)，以及添加工作节点的命令(包含密钥，所以必须保密)

.. note::

   由于 :ref:`containerd` 取代了 ``docker`` ，所以运维方式已经改变，详情参考 :ref:`z-k8s_nerdctl`

- 检查Kubernetes节点和pods::

    kubectl get nodes -o wide

    kubectl get pods -n kube-system -o wide

.. note::

   如果出现 ``Unable to connect to the server: Forbidden`` 请检查操作系统是否设置了代理服务器环境变量，我吃过苦头

输出:

.. literalinclude:: ../../kubernetes/deploy/bootstrap_kubernetes_ha/ha_k8s_dnsrr/k8s_dnsrr/kubectl_get_pods_before_net
   :language: bash
   :caption: 没有安装网络前无法启动coredns，此时 kubectl get pods 输出

.. note::

   目前还有2个问题没有解决:

   - ``z-k8s-m-1`` 节点状态是 ``NotReady``
   - ``coredns`` 管控pods无法启动(网络没有配置)

     - 这个问题我之前在 :ref:`single_master_k8s` 已经有经验，只要为Kubernetes集群安装正确的网络接口即可启动容器
     - 请注意，Kubernetes集群的3大组件 ``apiserver`` / ``scheduler`` / ``controller-manager`` 都是使用物理主机的IP地址 ``192.168.6.101`` ，也就是说，即使没有安装网络接口组件这3个管控组件也是能够启动的；这也是为何在 ``kubeadm-config.yaml`` 配置的 ``controlPlaneEndpoint`` 项域名 ``z-k8s-api.staging.huatai.me`` 就是指向物理主机IP地址的解析

安装 :ref:`cilium`
======================

需要注意，针对 :ref:`priv_deploy_etcd_cluster_with_tls_auth` (扩展外部etcd)需要采用 :ref:`cilium_install_with_external_etcd` :

- 首先在节点安装 :ref:`helm` :

.. literalinclude:: ../../kubernetes/deploy/helm/linux_helm_install
   :language: bash
   :caption: 在Linux平台安装helm

- 设置cilium Helm仓库:

.. literalinclude:: ../../kubernetes/network/cilium/installation/cilium_install_with_external_etcd/helm_repo_add_cilium
   :language: bash
   :caption: 设置cilium Helm仓库

- 通过 :ref:`helm` 部署Cilium:

.. literalinclude:: ../../kubernetes/network/cilium/installation/cilium_install_with_external_etcd/helm_install_cilium
   :language: bash
   :caption: 为cilium配置访问etcd的Kubernetes secret，安装cilium采用SSL模式访问etcd

.. note::

   在安装 :ref:`cilium` 之前，务必检查官方发行版的最新版本号，将上文安装脚本的 ``VERSION=1.11.7`` 替换成正确版本。这样可以在安装后不用再做 :ref:`cilium_upgrade`

.. note::

   正确安装了 :ref:`cilium`  CNI 之后，之前部署过程中没有运行起来的coredns容器就能够分配IP地址并运行起来

- 安装cilium客户端:

.. literalinclude:: ../../kubernetes/network/cilium/installation/cilium_install_with_external_etcd/install_cilium_cli
   :language: bash
   :caption: 安装cilium CLI

- 检查::

   cilium status

.. literalinclude:: ../../kubernetes/network/cilium/installation/cilium_install_with_external_etcd/cilium_status_after_install
   :language: bash
   :caption: cilium安装完成后状态验证

添加第二个管控节点
====================

- 按照 ``kubeadm init`` 输出信息，在第二个管控节点 ``z-k8s-m-2`` 上执行节点添加:

.. literalinclude:: ../../kubernetes/deploy/bootstrap_kubernetes_ha/ha_k8s_dnsrr/k8s_dnsrr/kubeadm_join_control-plane
   :language: bash
   :caption: kubeadm join添加control-plane节点

添加工作节点
==================

- 按照 ``kubeadm init`` 输出信息，在工作节点 ``z-k8s-n-1`` 等上执行:

.. literalinclude:: ../../kubernetes/deploy/bootstrap_kubernetes_ha/ha_k8s_dnsrr/k8s_dnsrr/kubeadm_join_worker
   :language: bash
   :caption: kubeadm join添加worker节点

.. note::

   ``kubeadm`` 初始化集群时候生成的 ``certificate`` 和 ``token`` (24小时) 都是有一定有效期限。所以如果在初始化之后，再经过较长时间才添加管控节点和工作节点，就会遇到 ``token`` 和 ``certificate`` 相关错误。此时，需要重新上传certifiate和重新生成token。并且，对于使用 external etcd，还需要通过 ``kubeadm-config.yaml`` 传递etcd参数。
