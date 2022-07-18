.. _crictl:

============
crictl 
============

``crictl`` 是CRI兼容容器runtime的命令行接口。可以通过 ``crictl`` 在Kubernetes节点检查( ``inspect`` )和debug容器runtime和应用程序。

安装cri-tools
==============

- 安装crictl::

   VERSION="v1.17.0"
   wget https://github.com/kubernetes-sigs/cri-tools/releases/download/$VERSION/crictl-$VERSION-linux-amd64.tar.gz
   sudo tar zxvf crictl-$VERSION-linux-amd64.tar.gz -C /usr/local/bin
   rm -f crictl-$VERSION-linux-amd64.tar.gz

- 安装critest::

   VERSION="v1.17.0"
   wget https://github.com/kubernetes-sigs/cri-tools/releases/download/$VERSION/critest-$VERSION-linux-amd64.tar.gz
   sudo tar zxvf critest-$VERSION-linux-amd64.tar.gz -C /usr/local/bin
   rm -f critest-$VERSION-linux-amd64.tar.gz

.. note::

   我在部署 :ref:`priv_cloud_infra` 的Kubernetes集群 :ref:`ha_k8s_dnsrr` 时，完全摈弃了 :ref:`docker` 改为推荐的 :ref:`container_runtimes` :ref:`containerd` 。此时无法使用 ``docker`` 命令，需要采用Kubernetes规范的CRI工具，也就是 ``crictl`` 。这个工具安装采用了 :ref:`install_containerd_official_binaries` 步骤完成，详细步骤也可参考 :ref:`prepare_z-k8s`

使用crictl
==============

``crictl`` 命令默认连接到 ``unix:///var/run/dockershim.sock`` 如果要连接到其他runtimes，需要设置 endpoint:

- 可以通过命令行参数 ``--runtime-endpoint`` 和 ``--image-endpoint``
- 可以通过设置环境变量 ``CONTAINER_RUNTIME_ENDPOINT`` 和 ``CONTAINER_RUNTIME_ENDPOINT``
- 可以通过配置文件的endpoint设置 ``--config=/etc/crictl.yaml``

当前配置为 ``/etc/crictl.yaml`` :

.. literalinclude:: crictl/crictl.yaml
   :language: yaml
   :caption: crictl配置文件 /etc/crictl.yaml

crictl命令案例
==============

.. note::

   实践案例见 :ref:`k8s_dnsrr`

- 列出pods::

   crictl pods

输出显示类似:

.. literalinclude:: ../deployment/bootstrap_kubernetes_ha/ha_k8s_dnsrr/k8s_dnsrr/crictl_pods
   :language: bash

- 可以指定某个pods检查::

   crictl pods --name kube-apiserver-z-k8s-m-1

- 可以按照label列出

参考
======

- `Debugging Kubernetes nodes with crictl <https://kubernetes.io/docs/tasks/debug-application-cluster/crictl/>`_
