.. _nerdctl:

================
nerdctl
================

nerdctl 是 ``containerd`` 子项目，提供Docker兼容的CLI命令:

- 类似 :ref:`docker` 的交互方式
- 支持Docker Compose
- 支持rootless模式
- 支持 lazy-pulling (例如 :ref:`estargz_lazy_pulling` )
- 支持加密镜像
- 支持P2P镜像分发 ( :ref:`ipfs` )
- 支持容器镜像签名和验证

安装
======

- 从 `nerdctl releases <https://github.com/containerd/nerdctl/releases>`_ 下载软件包::

   tar xfz nerdctl-0.22.0-linux-amd64.tar.gz
   sudo mv nerdctl /usr/bin/

官方下载有两种软件包:

  - Minimal (nerdctl-0.22.0-linux-amd64.tar.gz): nerdctl only
  - Full (nerdctl-full-0.22.0-linux-amd64.tar.gz): Includes dependencies such as containerd, runc, and CNI

我安装的是Minimal版本，其他组件按需各自安装

快速起步
============

- 有root权限方式::

   sudo systemctl enable --now containerd
   sudo nerdctl run -d --name nginx -p 80:80 nginx:alpine

.. note::

   由于我是安装了 :ref:`containerd` 服务，是通过root模式运行的，所以后续操作以这个root权限方式为准。也就是后续 ``nerdctl`` 命令操作都是使用 ``sudo nerdctl`` 

这里我遇到一个报错，显示GFW阻挡了镜像下载::

   FATA[0016] failed to copy: httpReadSeeker: failed open: failed to do request: Get "https://production.cloudflare.docker.com/registry-v2/docker/registry/v2/blobs/sha256/b6/b692a91e4e1582db97076184dae0b2f4a7a86b68c4fe6f91affa50ae06369bf5/data?verify=1660148606-x7zt9HGf2yYAnJhu906wV%2FXXVwA%3D": net/http: TLS handshake timeout

通过配置 :ref:`docker_proxy` 环境变量::

   export HTTP_PROXY=http://192.168.6.200:3128/
   export HTTPS_PROXY=http://192.168.6.200:3128/

然后再次执行就能正常下载镜像并运行容器。此时检查::

   sudo nerdctl ps

可以看到本地运行了容器(类似docker)::

   CONTAINER ID    IMAGE                             COMMAND                   CREATED               STATUS    PORTS                 NAMES
   71696cbb5444    docker.io/library/nginx:latest    "/docker-entrypoint.…"    About a minute ago    Up        0.0.0.0:80->80/tcp    nginx

.. note::

   直接使用 ``nerdctl run`` 是在本地运行容器，没有运行在Kuberntes集群，所以不需要使用 ``-n k8s.io``

- 无root权限方式(端口1024以上)::

   containerd-rootless-setuptool.sh install
   nerdctl run -d --name nginx -p 8080:80 nginx:alpine

容器探索
-----------

我在下文尝试通过 :ref:`buildkit` 构建镜像遇到容器内部不能通网络的问题，所以，我返回来先验证官方镜像是否能够正常运行，并排查网络

- 进入 ``nginx`` 容器::

   sudo nerdctl exec -it nginx /bin/bash

验证可以进入容器内部，不过此时容器内部缺少很多网络排查工具，甚至都没有提供ps命令

检查发现，原来默认 ``nginx:lastest`` 镜像是基于 :ref:`ubuntu_linux` ，可以使用 :ref:`apt` ，并且能够通internet。这就好办了，安装工具::

   apt update
   apt upgrade
   apt install iproute2

- 检查::

   ip link

显示::

   ...
   2: eth0@if13: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DEFAULT group default
       link/ether 16:4f:d5:8c:e0:86 brd ff:ff:ff:ff:ff:ff link-netnsid 0

- 路由::

   ip route

显示::

   default via 10.4.0.1 dev eth0
   10.4.0.0/24 dev eth0 proto kernel scope link src 10.4.0.2

为什么容器内部默认就能够连接外网呢？这明显就是类似 :ref:`docker` 的NAT网络么

- 在物理主机上检查::

   brctl show

果然可以看到 ``nerdctl`` 启动了一个交换网络::

   bridge name     bridge id               STP enabled     interfaces
   nerdctl0                8000.d20bcb07c7c8       no              veth482da55d

实践:镜像
============

``nerdctl`` 对镜像的制作是采用 :ref:`buildkit` 实现的，请先安装 ``buildkit`` 并运行 ``buildkitd`` 服务进程

.. literalinclude:: ../../../docker/moby/buildkit/buildkit_startup/buildkitd
   :language: bash
   :caption: 使用root身份运行buildkitd，启动后工作在前台等待客户端连接

- 我这里采用 :ref:`dockerfile` 的 ``centos8-ssh`` :

.. literalinclude:: ../../../docker/admin/dockerfile/centos8-ssh
   :language: dockerfile
   :caption: CentOS 8的Dockerfile，包括ssh安装

执行以下命令构建:

.. literalinclude:: nerdctl/nerdctl_build
   :language: bash
   :caption: nerdctl build构建容器镜像

此时提示信息:

.. literalinclude:: nerdctl/nerdctl_build_fail_output
   :language: bash
   :caption: nerdctl build构建容器镜像的输出信息
   :emphasize-lines: 17-18

.. note::

   需要注意 ``buildkitd.toml`` 配置默认的 ``namespace`` 是 ``k8s.io`` 标识针对 Kubernetes，这也是我最初不知道的要点。我刚开始还奇怪 ``nerdctl images`` 为何总是空的，原来正确方法是::

      nerdctl -n k8s.io images

   这样才能看到Kubernetes集群中的镜像

在上述报错信息的同时， ``buildkitd`` 控制台也输出了报错信息::

   ERRO[2022-08-10T22:58:40+08:00] /moby.buildkit.v1.Control/Solve returned error: rpc error: code = Unknown desc = process "/bin/sh -c dnf -y update" did not complete successfully: exit code: 1

我以为 ``buildkit`` 默认想去连接 ``docker0`` 这个本地NAT网络，但是上文可以看到，只安装 ``nerdctl`` 只创建了 ``nerdctl0`` 命名的NAT网络。该如何配置 ``buildkit`` 去使用指定的 ``bridge`` 呢？

虽然我的节点位于Kubernetes中，并且安装了 :ref:`cilium` ，看起来网络配置不正确

``唉，瞎猜不是好习惯，我后来才发现我根本没有仔细看报错信息`` 实际是Docker的centos8镜像中默认仓库配置问题: 上面提示不是已经说了是 ``repo 'appstream'`` mirrorlist错误么?

我尝试通过 ``sudo buildkitd --oci-worker=false --containerd-worker=true`` 运行 ``buildkitd`` （指定使用containerd worker) ，但是依然没有解决这个问题

但是，我注意到 ``buildkitd`` 的终端输出信息显示:

.. literalinclude:: nerdctl/nerdctl_build_fail_output_dnsmasq
   :language: bash
   :caption: nerdctl build失败，显示使用了 systemd-resolve
   :emphasize-lines: 8

等等，怎么会因为检测到DNS服务，就自说自话使用了 ``/run/systemd/resolve/resolv.conf`` 作为本地解析器配置？

检查了一下主机，确实运行了 ``systemd-resolved`` ，配置文件 ``/run/systemd/resolve/resolv.conf`` 内容也没有错::

   nameserver 192.168.6.200
   search staging.huatai.me

我在 ``192.168.6.200`` 上运行的 DNSmasq ，修订配置添加 ``log-queries`` (开启DNS查询日志)，然后重启dnsmasq，再次执行 ``nerdctl build`` ，观察DNS服务器端是否收到查询请求: 确实收到了DNS查询

**我发现我犯了一个低级错误** ::

   #0 1.355 CentOS Linux 8 - AppStream                       66  B/s |  38  B     00:00
   #0 1.366 Error: Failed to download metadata for repo 'appstream': Cannot prepare internal mirrorlist: No URLs in mirrorlist

参考 `Error: Failed to download metadata for repo 'appstream': Cannot prepare internal mirrorlist: No URLs in mirrorlist <https://stackoverflow.com/questions/70963985/error-failed-to-download-metadata-for-repo-appstream-cannot-prepare-internal>`_ 很简单，CentOS已经走到了生命尽头，需要切换到 ``stream`` 版本才能正常工作，所以Docker官方镜像已经无法直接使用 ::

   CentOS 8 reached EOL on 2021-12-31

.. figure:: ../../../_static/kubernetes/deployment/bootstrap_kubernetes_ha/ha_k8s_dnsrr/marmot.gif

- 修复的方法是采用在Dockerfile中增加切换 ``CentOS Stream 8`` :

.. literalinclude:: ../../../docker/admin/dockerfile/centos-stream-8-ssh
   :language: dockerfile
   :caption: CentOS Stream 8(取代已经 EOL CentOS 8)的Dockerfile，包括ssh安装
   :emphasize-lines: 33-34

- 然后执行:

.. literalinclude:: nerdctl/nerdctl_build_centos-stream-8-ssh
   :language: bash
   :caption: nerdctl build构建容器镜像centos-stream-8-ssh

- 然后运行::

   sudo nerdctl run -it -p 1122:22 --hostname centos-stream-8 --name centos-stream-8 local:centos-stream-8-ssh

现在就可以ssh进入容器了::

   ssh admin@192.168.6.101 -p 1122

但是，使用 ``nerdctl run -it`` 命令启动，不能退出，一旦退出容器也就终止了。此时再次执行 ``nerdctl start centos-stream-8`` 会报错::

   failed to create shim task: OCI runtime create failed: runc create failed: cannot allocate tty if runc will detach without setting console socket: unknown

实际上 ``nerdctl`` 有一个参数 ``-d`` 可以启动时直接放到后台运行::

   sudo nerdctl run -d -p 1122:22 --hostname centos-stream-8 --name centos-stream-8 local:centos-stream-8-ssh

nerdctl结合Kubernetes
=========================

``nerdctl`` 可以直接为本地Kubernetes构建镜像而无需registry:

- 这里采用 :ref:`containerd_centos_systemd` 实践验证通过的 ``Dockerfile`` :

.. literalinclude:: containerd_centos_systemd/centos-stream-8-systemd
   :language: dockerfile
   :caption: CentOS Stream 8 启用systemd(正确)

- 执行以下命令为Kuberntes构建镜像:

.. literalinclude:: nerdctl/nerdctl_build_for_kubernetes
   :language: bash
   :caption: nerdctl build为本地Kubernetes构建镜像

- 现在通过 ``nerdctl`` 命令可以检查到新生成到镜像::

   sudo nerdctl -n k8s.io images

显示::

   REPOSITORY                            TAG        IMAGE ID        CREATED          PLATFORM       SIZE         BLOB SIZE
   ...
   centos-stream-8-systemd               latest     758665d16a77    5 minutes ago    linux/amd64    705.0 MiB    282.0 MiB
   ...

- 然后在Kubernetes集群生成pod:

.. literalinclude:: nerdctl/kubectl_apply_nerdctl_build_for_kubernetes
   :language: bash
   :caption: 执行kubeclt apply 将 nerdctl build为本地Kubernetes构建镜像 生成可运行pod

.. note::

   对于 :ref:`containerd_centos_systemd` ，需要采用 :ref:`k8s_privileged_pod`

此时提示::

   pod/centos-stream-8 created

- 但是，此时检查并不一定会看到pod运行了::

   kubectl get pods

显示::

   NAME              READY   STATUS              RESTARTS   AGE
   centos-stream-8   0/1     ErrImageNeverPull   0          3m7s

这是因为没有使用  :ref:`docker_registry` ，需要将镜像导入到每个调度到的节点上才能启动。

- 检查新创建的pod调度到哪个节点::

   $ kubectl get pods -o wide
   NAME              READY   STATUS              RESTARTS   AGE     IP           NODE        NOMINATED NODE   READINESS GATES
   centos-stream-8   0/1     ErrImageNeverPull   0          4m41s   10.0.4.224   z-k8s-n-2   <none>           <none>

我们需要使用类似 ``docker save`` 的命令来导出镜像，复制到该节点::

   sudo nerdctl save centos-stream-8-systemd > centos-stream-8-systemd.tar

- 然后在目标节点 ``z-k8s-n-2`` 上导入这个镜像::

   sudo nerdctl -n k8s.io load < centos-stream-8-systemd.tar

完成后再次检查集群::

   kubectl get pods -o wide

就可以看到pod容器正常运行了::

   NAME              READY   STATUS    RESTARTS   AGE   IP           NODE        NOMINATED NODE   READINESS GATES
   centos-stream-8   1/1     Running   0          17m   10.0.4.224   z-k8s-n-2   <none>           <none>

不过，此时运行的容器网络还没有配置好，所以从外部还不能 ``ssh`` 登陆这个容器。但是，容器内部是可以访问外部的，例如，我们可以通过 ``kubectl exec`` 登陆到容器的内部检查::

   kubectl exec -it centos-stream-8 -- /bin/bash

检查容器内部::

   [root@centos-stream-8 /]# df -h
   Filesystem      Size  Used Avail Use% Mounted on
   overlay         9.4G  2.3G  7.1G  24% /
   tmpfs            64M     0   64M   0% /dev
   /dev/vda2       6.3G  4.2G  2.2G  67% /etc/hosts
   /dev/vdb1       9.4G  2.3G  7.1G  24% /etc/hostname
   shm              64M     0   64M   0% /dev/shm
   tmpfs           2.0G  8.1M  2.0G   1% /run
   [root@centos-stream-8 /]# ip addr
   1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
       link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
       inet 127.0.0.1/8 scope host lo
          valid_lft forever preferred_lft forever
       inet6 ::1/128 scope host
          valid_lft forever preferred_lft forever
   14: eth0@if15: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
       link/ether 4a:a2:3f:b5:da:ae brd ff:ff:ff:ff:ff:ff link-netnsid 0
       inet 10.0.4.224/32 scope global eth0
          valid_lft forever preferred_lft forever
       inet6 fe80::48a2:3fff:feb5:daae/64 scope link
          valid_lft forever preferred_lft forever 

可以在内部安装软件包::

   dnf install net-tools -y

检查路由::

   # netstat -rn
   Kernel IP routing table
   Destination     Gateway         Genmask         Flags   MSS Window  irtt Iface
   0.0.0.0         10.0.4.25       0.0.0.0         UG        0 0          0 eth0
   10.0.4.25       0.0.0.0         255.255.255.255 UH        0 0          0 eth0

检查容器内部进程::

   top

显示::

   top - 22:48:00 up 37 days, 47 min,  0 users,  load average: 0.02, 0.03, 0.00
   Tasks:   6 total,   1 running,   5 sleeping,   0 stopped,   0 zombie
   %Cpu(s):  2.3 us,  1.0 sy,  0.0 ni, 96.7 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st
   MiB Mem :   3929.8 total,    537.3 free,    438.8 used,   2953.6 buff/cache
   MiB Swap:      0.0 total,      0.0 free,      0.0 used.   3191.6 avail Mem
   
       PID USER      PR  NI    VIRT    RES    SHR S  %CPU  %MEM     TIME+ COMMAND
         1 root      20   0   90104  10248   8236 S   0.0   0.3   0:00.21 systemd
        28 root      20   0   87388   8360   7508 S   0.0   0.2   0:00.13 systemd-journal
        35 dbus      20   0   54108   4124   3696 S   0.0   0.1   0:00.00 dbus-daemon
        36 root      20   0   76628   7280   6372 S   0.0   0.2   0:00.00 sshd
        39 root      20   0   15104   3824   3252 S   0.0   0.1   0:00.07 bash
       103 root      20   0   52080   4360   3712 R   0.0   0.1   0:00.00 top

接下来，我们需要配置 :ref:`ingress` 对外暴露SSH服务，在 :ref:`cilium` 中， 内置的 :ref:`cilium_k8s_ingress` 采用 ``Envoy`` 实现

也可以采用多种 :ref:`ingress_controller` ，例如我准备部署:

- :ref:`nginx_ingress`
- :ref:`haproxy_ingress`
- :ref:`istio_ingress`

简单的NodePort输出验证
=======================

.. note::

   参考 :ref:`cilium_kubeproxy_free` 验证方法，将ssh服务输出到集群

- 首先为前面创建的 ``centos-stream-8`` 添加标签::

   kubectl label pods centos-stream-8 run=dev

添加了 ``run=dev`` 标签之后，就可以配置服务

现在我们检查 ``run=dev`` 标签的pods::

   kubectl get pods -l run=dev -o wide

显示::

   NAME              READY   STATUS    RESTARTS   AGE    IP           NODE        NOMINATED NODE   READINESS GATES
   centos-stream-8   1/1     Running   0          2d2h   10.0.4.224   z-k8s-n-2   <none>           <none>

- 为实例创建NodePort :ref:`kubernetes_services` ::

   kubectl expose pods centos-stream-8 --type=NodePort --port=22

此时提示::

   service/centos-stream-8 exposed

注意如果没有标签的pods是无法输出，会报错(这也是为何前面需要先给pod添加标签的原因，因为kubernetes输出服务端口是根据labels确定的)::

   error: couldn't retrieve selectors via --selector flag or introspection: the pod has no labels and cannot be exposed

- 检查输出的NodePort服务::

   kubectl get svc centos-stream-8

显示::

   NAME              TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
   centos-stream-8   NodePort   10.111.120.89   <none>        22:30134/TCP   106s

- 同样，我们再次检查 ``cilium service list`` ::

   kubectl -n kube-system exec ds/cilium -- cilium service list

输出就有::

   ...
   16   10.111.120.89:22      ClusterIP      1 => 10.0.4.224:22
   17   192.168.6.102:30134   NodePort       1 => 10.0.4.224:22
   18   0.0.0.0:30134         NodePort       1 => 10.0.4.224:22

现在我们就可以访问::

   ssh admin@192.168.6.102 -p 30134

登陆到容器内部进行运维

参考
======

- `nerdctl: Docker-compatible CLI for containerd <https://github.com/containerd/nerdctl>`_
- `Rancher desktop: Working with Images <https://docs.rancherdesktop.io/tutorials/working-with-images>`_
- `Rancher Desktop and nerdctl for local K8s dev <https://itnext.io/rancher-desktop-and-nerdctl-for-local-k8s-dev-d1348629932a>`_
