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

使用crictl
==============

``crictl`` 命令默认连接到 ``unix:///var/run/dockershim.sock`` 如果要连接到其他runtimes，需要设置 endpoint:

- 可以通过命令行参数 ``--runtime-endpoint`` 和 ``--image-endpoint``
- 可以通过设置环境变量 ``CONTAINER_RUNTIME_ENDPOINT`` 和 ``CONTAINER_RUNTIME_ENDPOINT``
- 可以通过配置文件的endpoint设置 ``--config=/etc/crictl.yaml``

当前配置为 ``/etc/crictl.yaml`` ::

   runtime-endpoint: unix:///var/run/dockershim.sock
   image-endpoint: unix:///var/run/dockershim.sock
   timeout: 10
   debug: true

crictl命令案例
==============

- 列出pods::

   crictl pods



参考
======

- `Debugging Kubernetes nodes with crictl <https://kubernetes.io/docs/tasks/debug-application-cluster/crictl/>`_
