.. _z-k8s_nerdctl:

==================================
Kubernetes集群(z-k8s)使用nerdctl
==================================

在完成 :ref:`z-k8s` 之后，我们需要使用 :ref:`nerdctl` 来完成镜像制作和管理，已经推送镜像到 :ref:`z-k8s_docker_registry` 以实现应用部署

buildkit安装和准备
====================

- 安装 :ref:`nerdctl` (minimal版本，即只安装 ``nerdctl`` ):

.. literalinclude:: ../../kubernetes/container_runtimes/containerd/nerdctl/install_nerdctl
   :language: bash

- 从 `buildkit releases <https://github.com/moby/buildkit/releases>`_ 下载最新 :ref:`buildkit` 解压缩后移动到 ``/usr/bin`` 目录下 :

.. literalinclude:: ../../docker/moby/buildkit/buildkit_startup/install_buildkit
   :language: bash

- 运行(需要先安装和运行 OCI(runc) 和 containerd):

.. literalinclude:: ../../docker/moby/buildkit/buildkit_startup/buildkitd
   :language: bash
   :caption: 使用root身份运行buildkitd，启动后工作在前台等待客户端连接

- 配置 ``/etc/buildkit/buildkitd.toml`` :

.. literalinclude:: ../../docker/moby/buildkit/buildkit_startup/buildkitd.toml
   :language: bash
   :caption: 配置 /etc/buildkit/buildkitd.toml

然后就可以使用 :ref:`nerdctl` 工具执行 ``nerdctl build`` 指令来构建镜像。

使用nerdctl构建镜像
=====================

- 在目录下编辑一个 ``Dockerfile`` 内容如下(另外还要准备一个公钥文件 ``authorized_keys`` 用于镜像中眠密码登陆):

.. literalinclude:: ../../docker/init/docker_systemd/fedora-systemd.dockerfile
   :language: dockerfile
   :caption: fedora官方镜像增加systemd，注释中包含启动方法

- 执行以下命令构建镜像:

.. literalinclude:: z-k8s_nerdctl/nerdctl_build
   :language: bash
   :caption: nerdctl build构建支持systemd的Fedora镜像

- 完成后检查镜像:

.. literalinclude:: z-k8s_nerdctl/nerdctl_images
   :language: bash
   :caption: nerdctl images命令检查刚才生成的支持systemd的Fedora镜像

可以看到刚才生成的镜像:

.. literalinclude:: z-k8s_nerdctl/nerdctl_images_output
   :language: bash
   :caption: nerdctl images命令显示刚才生成的镜像

使用nerdctl在Kubernetes上运行pod容器
======================================

:ref:`nerdctl` 可以直接将镜像推送到 :ref:`z-k8s` 集群中作为pod运行:

- 执行 ``kubectl apply`` 命令在Kubernetes集群 :ref:`z-k8s` 中构建运行pod: 

- 准备 ``z-dev`` 部署配置 ``z-dev-depolyment.yaml`` :

.. literalinclude:: z-k8s_nerdctl/z-dev-depolyment.yaml
   :language: bash
   :caption: z-dev部署配置z-dev-depolyment.yaml，定义了pod输出的3个服务端口 22,80,443

.. note::

   这里我改进了 :ref:`nerdctl` 中的实践，将 ``pod`` 改为 :ref:`workload_resources` 也就是 ``Deployment``

- 执行部署::

   kubectl create namespace z-dev
   kubectl apply -f z-dev-depolyment.yaml

.. note::

   这里还没有 :ref:`k8s_deploy_registry` ，所以需要手工将镜像复制到调度的节点来运行期容器

- 检查当前调度 ``z-dev`` 的节点::

   kubectl -n z-dev get pods -o wide

可以看到::

   NAME                              READY   STATUS     RESTARTS   AGE   IP           NODE        NOMINATED NODE   READINESS GATES
   z-dev                             0/2     Init:0/2   0          9s    <none>       z-k8s-n-4   <none>           <none>

- 需要将镜像导出复制到 ``z-k8s-n-4`` 来运行容器:

.. literalinclude:: z-k8s_nerdctl/nerdctl_save
   :language: bash
   :caption: nerdcrl save保存导出fedora_systemd镜像

- 将保存镜像复制到目标主机 ``z-k8s-n-4`` ::

   scp fedora-systemd.tar z-k8s-n-4:/home/huatai/

- 在 ``z-k8s-n-4`` 服务器上执行以下命令导入镜像:

.. literalinclude:: z-k8s_nerdctl/nerdctl_load
   :language: bash
   :caption: nerdcrl load加载fedora_systemd镜像

- 完成 ``z-k8s-n-4`` 镜像导入后，该节点就能正常运行 ``fedora-systemd`` 镜像的pod，此时::

   kubectl -n z-dev get pods -o wide

就可以看到容器正常运行::

   NAME                              READY   STATUS    RESTARTS   AGE   IP           NODE        NOMINATED NODE   READINESS GATES
   z-dev                             2/2     Running   0          20m   10.0.7.153   z-k8s-n-4   <none>           <none>

.. note::

   此时，虽然我们可以通过::

      kubectl exec -it z-dev -- /bin/bash

   登陆到 ``z-dev`` 系统内部，但是毕竟不如直接ssh方便，而这个容器已经是 :ref:`docker_systemd` 运行了 :ref:`ssh` 。所以，此时我们需要完成 :ref:`z-k8s_cilium_ingress` 才能通过外部网络访问 ``z-dev``

参考
=======

- `Ingress Nginx SSH access and forwarding to Workspace container/pod <https://discuss.kubernetes.io/t/ingress-nginx-ssh-access-and-forwarding-to-workspace-container-pod/14219>`_
- `Exposing two ports in Google Container Engine <https://stackoverflow.com/questions/34502022/exposing-two-ports-in-google-container-engine>`_
