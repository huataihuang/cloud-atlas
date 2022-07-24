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

运行pod sandbox
==================

使用 ``crictl`` 运行pod sandobx可以用来debug容器运行时。

- 创建 ``pod-config.json`` 

.. literalinclude:: crictl/pod-config.json
   :language: json
   :caption: pod-config.json

- 执行以下命令运行sandbox::

   crictl runp pod-config.json

.. note::

   - ``crictl runp`` 表示运行一个新pod(Run a new pod)
   - ``crictl run`` 表示在一个sandbox内部运行一个新容器(Run a new container inside a sandbox)

我遇到报错::

   E0719 20:50:53.394867 2319718 remote_runtime.go:201] "RunPodSandbox from runtime service failed" err="rpc error: code = Unknown desc = failed to create containerd task: failed to create shim task: OCI runtime create failed: runc create failed: expected cgroupsPath to be of format \"slice:prefix:name\" for systemd cgroups, got \"/k8s.io/81805934b02f89c87f1babefc460beb28679e184b777ebb8082942c3776a8d5b\" instead: unknown"
   FATA[0001] run pod sandbox: rpc error: code = Unknown desc = failed to create containerd task: failed to create shim task: OCI runtime create failed: runc create failed: expected cgroupsPath to be of format "slice:prefix:name" for systemd cgroups, got "/k8s.io/81805934b02f89c87f1babefc460beb28679e184b777ebb8082942c3776a8d5b" instead: unknown

.. note::

   `Configuring a cgroup driver: Migrating to the systemd driver <https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/configure-cgroup-driver/#migrating-to-the-systemd-driver>`_ 提到将就节点转为使用 ``systemd`` driver，这个步骤是在节点加入是完成

排查无法运行pod
-------------------

参考 `Impossible to create or start a container after reboot (OCI runtime create failed: expected cgroupsPath to be of format \"slice:prefix:name\" for systemd cgroups, got \"/kubepods/burstable/...") #4857 <https://github.com/containerd/containerd/issues/4857>`_ :

原因是 ``kubelet`` / ``crictl`` / ``containerd`` 所使用的 cgroup 驱动不一致导致的: 有两种 cgroup 驱动，一种是 ``cgroupfs cgroup driver`` ，另一种是 ``systemd cgroup driver`` ：

- 我在 :ref:`prepare_z-k8s` 时采用了 ``cgroup v2`` (通过 :ref:`systemd` )，同时在 :ref:`containerd_systemdcgroup_true` ，这样 :ref:`containerd` 就会使用 ``systemd cgroup driver``
- :ref:`kubeadm-config` 默认已经激活了 ``kubelet`` 使用 ``systemd cgroup driver`` （从 Kubernetes 1.22 开始，默认 ``kubelet`` 就是使用 ``systemd cgroup driver`` 无需特别配置: 这点可以通过 ``kubectl edit cm kubelet-config -n kube-system`` 查看，可以看到集群当前配置就是 ``cgroupDriver: systemd``

  - 如果kubelet确实没有使用 ``systemd`` 的 ``cgroup`` 的话，可以参考 `Update the cgroup driver on all nodes <https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/configure-cgroup-driver/#update-the-cgroup-driver-on-all-nodes>`_ 方法进行修订

- 但是 ``crictl`` 默认配置没有采用 ``systemd cgroup driver`` ，可以通过以下命令检查::

   crictl info | grep system

可以看到输出::

            "SystemdCgroup": true
    "systemdCgroup": false,

``crictl info`` 显示信息错误，这个异常可以参考 `crictl info get wrong container runtime cgroupdrives when use containerd. #728 <https://github.com/kubernetes-sigs/cri-tools/issues/728>`_ ，但是这个bug应该在 `Change the type of CRI runtime option #5300 <https://github.com/containerd/containerd/pull/5300>`_ 已经修复

我仔细看了以下 ``crictl info | grep systemd`` 输出，发现有2个地方和cgroup有关::

            "SystemdCgroup": true
    "systemdCgroup": false,

为何一个是 ``true`` 一个是 ``false``

检查 ``/etc/containerd/config.toml`` 中也有几处和 ``systemdCgroup`` 有关::

   [plugins]
     ...
     [plugins."io.containerd.grpc.v1.cri"]
       ...
       systemd_cgroup = false
       ...
     ...
       [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
         ...
         SystemdCgroup = true

修订 containerd 配置 systemd_cgoup(失败,无需特别配置)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

我尝试修改上面 ``systemd_cgroup = false`` 改为 ``systemd_cgroup = true`` ，结果重启 ``containerd`` 就挂掉了，节点 NotReady。

检查 ``containerd`` 的服务状态显示::

   Jul 19 23:28:15 z-k8s-n-1 containerd[2321243]: time="2022-07-19T23:28:15.548636577+08:00" level=info msg="loading plugin \"io.containerd.tracing.processor.v1.otlp\"..." type=io.containerd.tracing.processor.v1
   Jul 19 23:28:15 z-k8s-n-1 containerd[2321243]: time="2022-07-19T23:28:15.548669143+08:00" level=info msg="skip loading plugin \"io.containerd.tracing.processor.v1.otlp\"..." error="no OpenTelemetry endpoint: skip plugin" type=io.containerd.tracing.processor.v1
   Jul 19 23:28:15 z-k8s-n-1 containerd[2321243]: time="2022-07-19T23:28:15.548696451+08:00" level=info msg="loading plugin \"io.containerd.internal.v1.tracing\"..." type=io.containerd.internal.v1
   Jul 19 23:28:15 z-k8s-n-1 containerd[2321243]: time="2022-07-19T23:28:15.548761787+08:00" level=error msg="failed to initialize a tracing processor \"otlp\"" error="no OpenTelemetry endpoint: skip plugin"
   Jul 19 23:28:15 z-k8s-n-1 containerd[2321243]: time="2022-07-19T23:28:15.548852549+08:00" level=info msg="loading plugin \"io.containerd.grpc.v1.cri\"..." type=io.containerd.grpc.v1
   Jul 19 23:28:15 z-k8s-n-1 containerd[2321243]: time="2022-07-19T23:28:15.549391266+08:00" level=warning msg="failed to load plugin io.containerd.grpc.v1.cri" error="invalid plugin config: `systemd_cgroup` only works for runtime io.containerd.runtime.v1.linux"
   Jul 19 23:28:15 z-k8s-n-1 containerd[2321243]: time="2022-07-19T23:28:15.549774946+08:00" level=info msg=serving... address=/run/containerd/containerd.sock.ttrpc
   Jul 19 23:28:15 z-k8s-n-1 containerd[2321243]: time="2022-07-19T23:28:15.549940533+08:00" level=info msg=serving... address=/run/containerd/containerd.sock

此时也无法执行 ``crictl ps`` ，提示错误::

   E0722 09:59:01.808419 2346431 remote_runtime.go:536] "ListContainers with filter from runtime service failed" err="rpc error: code = Unimplemented desc = unknown service runtime.v1alpha2.RuntimeService" filter="&ContainerFilter{Id:,State:&ContainerStateValue{State:CONTAINER_RUNNING,},PodSandboxId:,LabelSelector:map[string]string{},}"
   FATA[0000] listing containers: rpc error: code = Unimplemented desc = unknown service runtime.v1alpha2.RuntimeService

.. note::

   我仔细核对 ``containerd`` 配置 ``config.toml`` ，其实有2个地方配置 ``systemd cgroup driver`` ，之前在 :ref:`prepare_z-k8s` 参考官方文档仅修订一处

参考 `deprecated (?) systemd_cgroup still printed by "containerd config default" #4574 <https://github.com/containerd/containerd/issues/4574>`_ :

- containerd 1.3.7 已经不再支持 ``io.containerd.grpc.v1.cri`` 这个插件配置成 ``systemd_cgroup = true`` ，也就是如此操作是失败的::

   containerd config default > /etc/containerd/config.toml
   sed -i -e 's/systemd_cgroup = false/systemd_cgroup = true/' /etc/containerd/config.toml
   启动 containerd 失败报错:
   Jul 19 23:28:15 z-k8s-n-1 containerd[2321243]: time="2022-07-19T23:28:15.549391266+08:00" level=warning msg="failed to load plugin io.containerd.grpc.v1.cri" error="invalid plugin config: `systemd_cgroup` only works for runtime io.containerd.runtime.v1.linux"

- 配置方法需要参考 `how to configure systemd cgroup with 1.3.X #4203 的comment <https://github.com/containerd/containerd/issues/4203#issuecomment-651532765>`_ ，原来Kubernetes官方文档是正确的，现在配置 ``io.containerd.runc.v2`` 确实如 :ref:`install_containerd_official_binaries` 中配置的:

.. literalinclude:: ../container_runtimes/containerd/install_containerd_official_binaries/config.toml_runc_systemd_cgroup
   :language: bash
   :caption: 配置containerd的runc使用systemd cgroup驱动

- 另外一个 `how to configure systemd cgroup with 1.3.X #4203 的另一个comment <https://github.com/containerd/containerd/issues/4203#issuecomment-777950814>`_ 说明了有2个 ``systemd_cgroup`` 值：

  - `systemd_cgroup <https://github.com/containerd/cri/blob/c8dba73eaefb1b9e91df0cb5f23dc3b275d85827/pkg/config/config.go#L213>`_ 是用于 shim v1 的配置，当 shim v1 废弃以后将会移除。也就是说，现在使用 containerd 不再需要修订这个配置
  - `systemdCgroup <https://github.com/containerd/containerd/blob/269548fa27e0089a8b8278fc4fc781d7f65a939b/runtime/v2/runc/options/oci.pb.go#L45>`_ 是现在真正需要调整当v2版本配置，对应当是 ``[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]``

**看起来不需要修改 containerd 的 config.toml 配置**

.. note::

   参考 `config.toml SystemdCgroup not work #4900 讨论 <https://github.com/containerd/containerd/issues/4900>`_ 验证containerd是否使用 ``systemd cgroups`` 不要看 ``crictl info`` 输出，这个输出非常让人困惑。

   正确方法是查看 ``systemctl status containerd`` 可以看到启动的服务显示::

      CGroup: /system.slice/containerd.service
              ├─2306099 /usr/local/bin/containerd-shim-runc-v2 -namespace k8s.io -id 2cd1b6245
              ├─2306139 /usr/local/bin/containerd-shim-runc-v2 -namespace k8s.io -id c380743d5
              └─2346698 /usr/local/bin/containerd

   此外检查 ``systemd-cgls`` 输出，就可以看到容器都是位于 ``systemd`` 的 ``cgroups`` 之下，这就表明正确使用了 ``systemd cgroups``
      

创建容器
==========

- 下载busybox镜像::

   crictl pull busybox

显示::

   Image is up to date for sha256:62aedd01bd8520c43d06b09f7a0f67ba9720bdc04631a8242c65ea995f3ecac8

- 创建 pod 配置:

.. literalinclude:: crictl/pod-config.json
   :language: json
   :caption: pod-config.json

.. literalinclude:: crictl/container-config.json
   :language: json
   :caption: container-config.json

- 创建::

   crictl create f84dd361f8dc51518ed291fbadd6db537b0496536c1d2d6c05ff943ce8c9a54f container-config.json pod-config.json

这里的字串是之前创建 sandbox返回的

   

参考
======

- `Debugging Kubernetes nodes with crictl <https://kubernetes.io/docs/tasks/debug-application-cluster/crictl/>`_
- `how to configure systemd cgroup with 1.3.X #4203 <https://github.com/containerd/containerd/issues/4203>`_ containerd新版支持systemd cgroup配置方法
