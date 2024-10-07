.. _minikube_deploy_app:

===========================
使用Minikube集群部署应用
===========================

Kubernetes将计算机的高可用集群作为一个整体来运行，允许你部署容器化应用到集群中而不需要指定明确到主机。这种情况下，应用程序需要被打包成和与主机无关的容器化部署模式。Kubernetes会在集群内高效地自动化分发和调度应用程序容器。

.. note::

   在 :ref:`install_run_minikube` 中，我们构建的单节点minikube即是一个最小的集群，真实环境的Kubernetes集群部署要远复杂得多。这里我们开始使用这个集群来部署应用测试。

集群概念
==========

.. figure:: ../../_static/kubernetes/kubernetes_cluster.svg

- ``master``

master节点是负责集群所有活动的协调，例如调度应用程序，维护应用程序最终状态一致性(desired state)，应用程序伸缩，以及滚动升级。

- ``node``

每个node节点都运行一个 ``kubelet`` 代理程序，用于管理节点以及和Kubernetes master通讯。节点也安装了用于操作容器的工具，例如Docker或rkt。一个用于生产环境的Kubernetes集群至少需要3个node节点。

但你在kubernetes中部署应用时，你是和master节点进行交互以启动应用程序的容器。master节点会将容器调度到集群的node节点。 ``node节点和master节点之间通讯使用Kubernetes API`` ，也就是master对外暴露的API接口提供的。用户虽然使用的是 ``kubectl`` 命令行工具，实际也是调用 Kubernetes API和集群进行交互。

.. note::

   Kubernetes集群可以部署在物理主机上也可以部署在虚拟机中，两种方案各有利弊：

   - 直接部署在物理主机上则硬件性能损失最小，并且由于简化了部署层次（没有虚拟化层），降低了故障排查的链路复杂度。
   - 但是直接部署在物理主机上，应用隔离只有通过容器技术进行安全隔离，安全性难以得到保障。

   - 部署在虚拟机内部的Kubernetes自然获得了虚拟化技术良好的安全隔离，并且得到了很多成熟的虚拟化技术增强，例如虚拟化技术支持热迁移，对于上层容器几乎感觉不到虚拟化底层解决了很多硬件上的异常和维护。
   - 但是虚拟机中部署Kubernetes带了了很大的虚拟化开销，特别是没有得到良好优化的虚拟化部署会消耗大量的硬件资源，使得最终用户的应用性能降低。并且，引入虚拟化层带来了维护上的复杂度和维护成本。

创建集群
===========

- 检查集群版本::

   kubectl version

上述检查版本命令会输出客户端和服务器端版本，当然有可能两者有版本差异::

   Client Version: version.Info{Major:"1", Minor:"14", GitVersion:"v1.14.1", GitCommit:"b7394102d6ef778017f2ca4046abbaa23b88c290", GitTreeState:"clean", BuildDate:"2019-04-08T17:11:31Z", GoVersion:"go1.12.1", Compiler:"gc", Platform:"darwin/amd64"}
   Server Version: version.Info{Major:"1", Minor:"14", GitVersion:"v1.14.3", GitCommit:"5e53fd6bc17c0dec8434817e69b04a25d8ae0ff0", GitTreeState:"clean", BuildDate:"2019-06-06T01:36:19Z", GoVersion:"go1.12.5", Compiler:"gc", Platform:"linux/amd64"}

为了检查集群详细信息，可以使用 ``cluster-info`` 指令::

   kubectl cluster-info

详细信息则使用命令::

   kubectl cluster-info dump

输出的json格式可以查看到集群详细信息，包括每个pod的镜像信息。

- 检查集群节点::

   kubectl get nodes

输出显示::

   NAME       STATUS   ROLES    AGE   VERSION
   minikube   Ready    master   23h   v1.14.3

可以看到只有一个节点，状态是 ``Ready`` 表示可以接受应用程序部署。

创建部署
===========

在Kubernetes部署应用，即创建一个Kubernetes ``Deployment`` 配置。Deployment将指令Kubernetes如何创建和更新应用的实例。一旦创建了一个部署，Kubernetes master将调度指定的应用实例到集群的独立节点。

Kubernetes是采用最终一致性方式来维护系统的。一旦应用实例创建，Kubernetes Deployment Controller就持续监控这些实例。如果运行实例的主机宕机或者被删除，Deployment Controller就用集群中其他节点上的实例来替代故障的实例。这种机制提供了处理服务器故障或维护态情况下的自愈机制。

部署Kubernetes的应用
-----------------------

.. figure:: ../../_static/kubernetes/deployment_application.svg

当创建一个Deployment时，需要指定应用程序使用的容器镜像，以及需要运行的副本数量。此外，可以在部署之后update你的deployment，随时可以修改配置信息。

.. note::

   我这里采用的一个案例是部署Ubuntu容器，目的是能够实现一个基础的开发工作环境。同时为后续部署持续集成环境做准备。

   参考 `Fire up an interactive bash Pod within a Kubernetes cluster <https://gc-taylor.com/blog/2016/10/31/fire-up-an-interactive-bash-pod-within-a-kubernetes-cluster>`_

- 创建ubuntu实例pod::

   kubectl run my-dev --rm -i --tty --image ubuntu -- bash

输出提示::

   kubectl run --generator=deployment/apps.v1 is DEPRECATED and will be removed in a future version. Use kubectl run --generator=run-pod/v1 or kubectl create instead.

.. note::

   参数解析:

   - ``my-dev`` 是创建的Deployment的名字，通常 pod 名字就是Deploymentin名字加上一个随机has或者ID
   - ``--rm`` 当detach时候删除所有创建的资源。这样当我们退出会话是，会清理掉Deployment和Pod
   - ``-i/--tty`` 提供一个交互会话
   - ``--`` 不限制kubectl运行参数的结束，以便传递可能参数(bash)
   - ``bash`` 覆盖默认当容器 ``CMD`` ，这样就最后能够加载bash作为容器的命令

- 检查我们创建的 Deployment ::

   kubectl get deployments

输出显示::

   NAME     READY   UP-TO-DATE   AVAILABLE   AGE
   my-dev   1/1     1            1           63m

.. note::

   当 Pod 创建并运行，pod 是运行在Kubernetes内部的，并且运行在一个私有并且隔离的网络中。默认情况下，pod可以被相同的kubernetes集群内的其他pod和service访问，但是不能被外部网络访问。此时我们使用 ``kubectl`` 命令实际上是和应用程序的API endpoint 通讯交互。

- ``kubectl proxy``

``kubectl`` 提供了一个代理能够将通讯转发到集群范围到私有网络，所以，我们在另外一个终端窗口执行 ``kubectl proxy`` 命令（注意不要 ctrl-c 终止) ，此时就提供了一个直接从终端访问API的代理，端口 8001 。

例如，以下命令可以检查版本::

   curl http://localhost:8001/version

输出显示::

   {
     "major": "1",
     "minor": "14",
     "gitVersion": "v1.14.3",
     "gitCommit": "5e53fd6bc17c0dec8434817e69b04a25d8ae0ff0",
     "gitTreeState": "clean",
     "buildDate": "2019-06-06T01:36:19Z",
     "goVersion": "go1.12.5",
     "compiler": "gc",
     "platform": "linux/amd64"
   }

这个输出信息实际上就是和 ``kubectl version`` 命令输出的服务器端版本信息是一致的。这说明 ``kubectl proxy`` 打通了到API入口，可以通过REST方式获取到Kubernetes信息。


- 检查刚才创建的pod（默认只显示 ``default`` 这个namespace）::

   kubectl get pods

显示输出::

   NAME                    READY   STATUS    RESTARTS   AGE
   my-dev-558d6cdd-4bnxq   1/1     Running   0          19m


   

- 登陆pod内部shell::

   kubectl -n default exec -ti my-dev-558d6cdd-4bnxq sh

.. note::

   - ``-t/--tty`` 表示开启 tty 终端
   - ``-i`` 表示交互

.. note::

   根据 Docker Hub 提供的 `Ubuntu Docker官方镜像 <https://hub.docker.com/_/ubuntu>`_ 说明，默认不指定版本，即为 ``ubuntu:latest`` ，该版本指向的是最新的LTS版本，即 18.04 bionic 。通过上述命令登陆到pod容器内部检查版本 ``cat /etc/lsb-release`` 可以看到::

      DISTRIB_ID=Ubuntu
      DISTRIB_RELEASE=18.04
      DISTRIB_CODENAME=bionic
      DISTRIB_DESCRIPTION="Ubuntu 18.04.2 LTS"

   现在我们可以在容器内部做系统升级，并且安装我们需要的软件包::

      apt update
      apt upgrade
      apt install vim

   注意，默认的ubuntu image是最小化的安装，设置的locale是 POSIX ，通常我们需要修订locale::

      apt-get update && apt-get install -y locales && rm -rf /var/lib/apt/lists/* \
          && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

- 访问容器服务

当使用 ``kubectl proxy`` 架起了到kubernetes内部私有网络的代理通道以后，我们还可以直接访问容器的服务端口。

这里举例，现在容器内部安装NGINX服务::

   apt -y install nginx

   # 创建hello world页面
   cat << EOF > /var/www/html/index.html
   <html>
   <header><title>MiniKube</title></header>
   <body>
   Hello world
   </body>
   </html>
   EOF

   # 启动nginx
   /etc/init.d/nginx start

.. note::

   注意这里有一个nginx日志错误 ``"socket() [::]:80 failed (97: Address family not supported by protocol)``

   这是因为 /etc/nginx/sites-enabled/default 配置默认有一行监听 IPv6 地址的设置需要注释掉::

      #listen [::]:80 default_server;

获得pod名字，这里就是 ``my-dev-558d6cdd-4bnxq`` ::

   export POD_NAME=$(kubectl get pods -o go-template --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}')
   echo $POD_NAME

输出变量 ``$POD_NAME`` 内容如下::

   my-dev-558d6cdd-4bnxq

开启另外一个终端窗口，运行 proxy ::

   kubectl proxy

返回前一个终端窗口（即获得 ``POD_NAME=my-dev-558d6cdd-4bnxq`` 窗口)执行以下命令验证是否能够访问容器中运行的nginx初始页面::

   curl http://localhost:8001/api/v1/namespaces/default/pods/$POD_NAME/proxy/

此时屏幕显示内容就是我们刚才在容器内部生成的 ``/var/www/html/index.html`` 内容::

   <html>
   <header><title>MiniKube</title></header>
   <body>
   Hello world
   </body>
   </html>

这证明，通过 ``kubectl proxy`` 我们可以访问Kubernetes内部私有网络，并且我们刚才部署的Nginx运行环境已经正常工作。

自定义镜像
============

.. note::

   请注意，我的案例和 `Google提供的在线教程 <https://kubernetes.io/docs/tutorials/>`_ 不同，我采用了从 `Ubuntu Docker 官方镜像 <https://hub.docker.com/_/ubuntu>`_ 从头开始定制镜像内容，所以初始的 ``my-dev`` 容器已经做了一定的内容修改（ 相当于自己做了一个和Google案例相同的容器），这样就需要把容器转换（存储）成自定义镜像，然后通过自定义镜像来重新部署应用。

上述自己定制的Pod ``my-dev`` 需要制作成镜像，以便能够继续下一步试验。比较简单的方式是把自定义镜像推送到Docker Hub公共镜像服务器上（需要Docker Hub账号），但是更好的方法是

参考
========

- `Using kubectl to Create a Deployment <https://kubernetes.io/docs/tutorials/kubernetes-basics/deploy-app/deploy-intro/>`_
