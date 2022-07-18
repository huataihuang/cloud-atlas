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
   :caption: crictl pods 列出主机上的pod

- 可以指定某个pods检查::

   crictl pods --name kube-apiserver-z-k8s-m-1

- 列出所有本地镜像::

   crictl images

显示类似:

.. literalinclude:: ../deployment/bootstrap_kubernetes_ha/ha_k8s_dnsrr/k8s_dnsrr/crictl_images
   :language: bash
   :caption: crictl pods 列出主机上的镜像

使用 ``crictl images -a`` 还可以进一步显示完整的镜像ID( ``sha256`` 签名 )

- 列出主机上容器(这个命令类似 :ref:`docker` 的 ``docker ps -a`` : 注意是所有容器，包括了运行状态和停止状态的所有容器 )::

   crictl ps -a

显示输出:

.. literalinclude:: ../deployment/bootstrap_kubernetes_ha/ha_k8s_dnsrr/k8s_dnsrr/crictl_containers
   :language: bash
   :caption: crictl pods 列出主机上的容器

如果只需要查看正在运行的容器(不显示停止的容器)，则去掉 ``-a`` 参数

- 执行容器中的命令( 类似 ``docker`` 或者 ``kubectl`` 提供的 ``exec`` 指令，直接在容器内部运行命令 )::

   crictl exec -it fd65e2a037600 ls

举例显示::

   bin  boot  dev  etc  go-runner  home  lib  lib64  media  mnt  opt  proc  root  run  sbin  srv  sys  tmp  usr  var

但是，并不是所有容器都可以执行，例如上文中只有 ``kube-proxy-vwqsn`` 这个pod提供都容器执行成功；而我尝试对 ``kube-apiserver-z-k8s-m-1`` 等对应容器执行 ``ls`` 命令都是失败::

   crictl exec -it 901b1dc06eed1 ls

提示不能打开 ``/dev/pts/0`` 设备::

   FATA[0000] execing command in container: Internal error occurred: error executing command in container: failed to exec in container: failed to start exec "3152d5e5f78f25a91d5e2a659c6e8036bf07978dbb8db5c95d1470089b968c9d": OCI runtime exec failed: exec failed: unable to start container process: open /dev/pts/0: operation not permitted: unknown

为何在容器内部没有 ``/dev/pts/0`` 设备？ (我暂时没有找到解决方法)

- 检查容器日志(这里检查 apiserver 日志)::

   crictl logs 901b1dc06eed1

可以看到容器的详细日志

并且可以指定最后多少行日志，例如查看最后20行日志::

   crictl logs --tail=20 901b1dc06eed1



参考
======

- `Debugging Kubernetes nodes with crictl <https://kubernetes.io/docs/tasks/debug-application-cluster/crictl/>`_
