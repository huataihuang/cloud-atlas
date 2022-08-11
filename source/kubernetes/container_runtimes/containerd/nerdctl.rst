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

实际上 ``nerdctl`` 有一个参数 ``-d`` 可以启动时直接放到后台运行，但是这个参数和 ``-t`` 冲突，暂时不知道如何解决::

   sudo nerdctl run -d -p 1122:22 --hostname centos-stream-8 --name centos-stream-8 local:centos-stream-8-ssh

nerdctl结合Kubernetes
=========================

``nerdctl`` 可以直接为本地Kubernetes构建镜像而无需registry:

.. literalinclude:: nerdctl/nerdctl_build_for_kubernetes
   :language: bash
   :caption: nerdctl build为本地Kubernetes构建镜像

参考
======

- `nerdctl: Docker-compatible CLI for containerd <https://github.com/containerd/nerdctl>`_
- `Rancher desktop: Working with Images <https://docs.rancherdesktop.io/tutorials/working-with-images>`_
- `Rancher Desktop and nerdctl for local K8s dev <https://itnext.io/rancher-desktop-and-nerdctl-for-local-k8s-dev-d1348629932a>`_
