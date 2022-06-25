.. _docker_systemd:

==========================
Docker systemd进程管理器
==========================

在容器环境中，最佳的实践方式是采用完全轻量级的只运行应用进程的每个容器一个应用进程的模式。但是，很多情况下，我们依然会需要采用 :ref:`systemd` 来实现以下功能:

- 多服务容器

很多在虚拟机云计算中部署的多服务应用程序，当前逐步迁移到容器中运行。由于架构复杂等原因，可能不会容易拆解成每个容器运行一个服务进程的理想模式。此时可以采用systemd作为进程管理器，继续沿用虚拟机部署方式。

- Systemd unit

很多应用服务是通过虚拟机中的systemd管理进程的，使用了systemd unit配置文件，这种部署方式非常清晰定义了服务运行方式，而不太容易改造成Docker容器的init服务运行。

- Systemd作为进程管理器优势

systemd提供了处理服务器进程的重启和起停等管理功能，比任何其他进程管理器更为稳定和经过实践验证

不过，systemd也因为其设计架构原因，会沿用其 systemd/journald 来控制容器的输出，而这个容器的输出对于 :ref:`kubernetes` 和 :ref:`openshift` 设计架构是需要直接将日志输出到标准输出stdout和stderr。所以，如果你希望通过Kubernetes和OpenShift这样的调度系统来管理容器，在需要谨慎使用基于systemd的容器。并且，Docker和 :ref:`docker_moby` 社区都不建议在容器中运行systemd。

Docker容器中的systemd
=======================

由于docker容器通常只运行一个进程，当需要多个服务进程时，可以使用 :ref:`docker_compose` 来配置启动多个容器服务器来实现。所以，默认情况下docker并不需要 :ref:`systemd` 来监视多个服务，这样默认关闭 systemd 不仅简化了部署也增强了安全性(不同容器可以隔离服务)。

配置要点:

- 在Docker容器中，默认的PID 1进程是作为容器的 ``Entrypoint`` 指定的，通常是一个 ``bash`` ，但是我们要使用 ``systemd`` 

- systemd需要 ``CAP_SYS_ADMIN`` 能力( ``当前运行systemd已经不再需要指定这个参数，但是如果要在容器内部使用NFS，即 mount.nfs 还是需要启用这个能力`` ):

Docker默认在非特权容器( ``non privileged container`` )中关闭了这个能力。也就是说，如果需要在 ``privileged`` 容器中才能运行systemd，这样的特权容器不会过滤掉任何能力。

  - (注：现在2020年不需要)现在Docker的补丁允许在docker容器中添加能力，这样就不需要在特权模式下运行容器，只需要简单添加一个 ``CAP_SYS_ADMIN`` 能力就可以了

- systemd需要能够在容器中查看cgroup文件系统

  - 需要通过卷挂载方式将cgroup文件系统添加到容器中(在容器中的systemd只能读取系统的cgroup)::

     -v /sys/fs/cgroup:/sys/fs/cgroup:ro

- tmpfs (unprivileged模式):

为了安全性，现在Docker运行systemd建议运行在unprivileged模式，此时就可以让systemd使用 ``tmpfs`` ，所以应该映射 ``tmpfs`` 到 ``/tmp`` ，映射 ``/run`` 到 ``/run/lock``

- 指定 ``sysinit.target`` 作为默认unit来启动，而不是启动 ``multi-user.target`` 或其他运行级别，因为你不会在容器内启动图形

- 如果要在容器内运行基于 ``fuse`` 到软件，需要bind mount ``/sys/fs/cgroup``

.. _fedora_systemd_in_docker:

Fedora 34 systemd in Docker Container
--------------------------------------

.. note::

   在2021年10月时候，我发现Fedora 34官方已经去除了镜像中的systemd软件包( 只安装了 ``systemd-libs`` )，如果Dockerfile中没有加上 ``dnf -y install systemd`` 则运行容器出现报错::

      docker: Error response from daemon: failed to create shim: OCI runtime create failed: container_linux.go:380: starting container process caused: exec: "/usr/sbin/init": stat /usr/sbin/init: no such file or directory: unknown.

   对比KVM虚拟机中systemd，可以看到::

      $ ls -lh /sbin/init
      lrwxrwxrwx 1 root root 20 Sep  7 18:37 /sbin/init -> /lib/systemd/systemd

      $ ls -lh /usr/sbin/init
      lrwxrwxrwx 1 root root 20 Sep  7 18:37 /usr/sbin/init -> /lib/systemd/systemd

   所以缺少 ``/usr/sbin/init`` 其实就是 ``systemd`` 软件包没有安装

   先使用常规 ``/usr/bin/bash`` 运行容器命令::

      docker run --name fedora -d -ti fedora /usr/bin/bash

   然后登陆到系统中检查::

      docker attach fedora

Fedora 34官方镜像没有包含 :ref:`systemd` ，所以需要Dockerfile增加安装步骤

.. literalinclude:: docker_systemd/fedora-systemd.dockerfile
   :language: dockerfile
   :linenos:
   :caption: fedora-systemd.dockerfile

::

   docker build -t local:fedora34-systemd .
   docker run --name fedora34 -d -it local:fedora34-systemd

- 这里Dockerfile的最后倒数第二行尝试配置的bind mount ``/sys/fs/cgroup`` 和 tmpfs mount ``/tmp`` 等卷
- ``ENV container docker`` 提供了容器内环境变量 ``container=docker`` ，容器内运行的 ``systemd`` 需要根据这个环境变量来判断知道自身运行在容器中，才能使得systemd能够在容器中正常运行。

但是，启动失败，用 ``docker logs fedora34`` 看到报错::

   Failed to mount cgroup at /sys/fs/cgroup/systemd: Operation not permitted
   [!!!!!!] Failed to mount API filesystems.
   Exiting PID 1...

既然是权限不足，那么运行时添加 ``--privileged=true`` 是否可以解决？

::

   docker run --privileged=true --name fedora34 -d -it local:fedora34-systemd

这次的报错日志显示没有 cgroup ::

   systemd v248.7-1.fc34 running in system mode. (+PAM +AUDIT +SELINUX -APPARMOR +IMA +SMACK +SECCOMP +GCRYPT +GNUTLS +OPENSSL +ACL +BLKID +CURL +ELFUTILS +FIDO2 +IDN2 -IDN +IPTC +KMOD +LIBCRYPTSETUP +LIBFDISK +PCRE2 +PWQUALITY +P11KIT +QRENCODE +BZIP2 +LZ4 +XZ +ZLIB +ZSTD +XKBCOMMON +UTMP +SYSVINIT default-hierarchy=unified)
   Detected virtualization docker.
   Detected architecture x86-64.
   
   Welcome to Fedora 34 (Container Image)!
   
   Cannot determine cgroup we are running in: No medium found
   Failed to allocate manager object: No medium found
   [!!!!!!] Failed to allocate manager object.
   Exiting PID 1...

这表明 ``cgoup`` 没有正确映射进入容器。看来 ``Dockerfile`` 中的::

   VOLUME [ "/sys/fs/cgroup", "/tmp", "/run" ]

- 通过以下 ``docker run`` 命令参数明确 ``bind mount`` 则成功成功运行::

   docker run -tid -p 1222:22 --hostname fedora34 --name fedora34 \
        --entrypoint=/usr/lib/systemd/systemd \
        --env container=docker \
        --mount type=bind,source=/sys/fs/cgroup,target=/sys/fs/cgroup \
        --mount type=bind,source=/sys/fs/fuse,target=/sys/fs/fuse \
        --mount type=tmpfs,destination=/tmp \
        --mount type=tmpfs,destination=/run \
        --mount type=tmpfs,destination=/run/lock \
        local:fedora34-systemd --log-level=info --unit=sysinit.target

.. warning::

   也就是说，现在必须在 Dockerfile 中明确进行 ``bind mount`` cgroup 才能正确运行systemd，否则就需要在 ``docker run`` 命令中传递 ``--mount type=bind`` 参数(这样的命令太复杂)。

   为了能够更轻松运行systemd，我还是需要探索如何把 ``bind mount`` 明确在Dockerfile中配置的方法。见下文 ``buildkit的Dockerfile``

buildkit的Dockerfile
~~~~~~~~~~~~~~~~~~~~~~

上述通过显式传递 ``--mount type=bind,source=/sys/fs/cgroup,target=/sys/fs/cgroup`` 参数运行 ``docker run`` 命令虽然能够解决systemd运行问题，但是命令参数过于复杂，使用不便。所以，需要转换成 Dockerfile 配置才能方便运行。不过，对于挂载不同类型的卷，需要使用 :ref:`buildkit` 来实现，参考 `Dockerfile frontend syntaxes <https://github.com/moby/buildkit/blob/master/frontend/dockerfile/docs/syntax.md>`_ 改造Dockerfile

- 首先，对于Docker v18.09或更高版本，在环境变量设置::

   export DOCKER_BUILDKIT=1

来激活客户端的BuildKit。建议直接在 ``~/.bashrc`` 中添加这个配置项。

- 然后修订Dockerfile:

.. literalinclude:: docker_systemd/fedora-systemd_buildkit.dockerfile
   :language: dockerfile
   :linenos:
   :caption: fedora-systemd_buildkit.dockerfile

- 执行构建::

   docker build -t local:fedora34-systemd .

注意，我最初配置行类似::

   RUN --mount type=bind,source=/sys/fs/cgroup,target=/sys/fs/cgroup \
       --mount type=bind,source=/sys/fs/fuse,target=/sys/fs/fuse \
       ...

但是会报错::

   => ERROR [stage-0 2/2] RUN --mount=type=bind,source=/sys/fs/cgroup,target=/sys/fs/cgroup,ro     --mount=type=bind,source=/sys/fs/fuse,target=/sys/fs/fuse,ro     --mount=type  0.0s
   ------
   > [stage-0 2/2] RUN --mount=type=bind,source=/sys/fs/cgroup,target=/sys/fs/cgroup,ro     --mount=type=bind,source=/sys/fs/fuse,target=/sys/fs/fuse,ro     --mount=type=tmpfs,target=/tmp     --mount=type=tmpfs,target=/run     --mount=type=tmpfs,target=/run/lock     dnf -y update && dnf -y install systemd && dnf clean all:
   ------
   failed to compute cache key: "/sys/fs/cgroup" not found: not found

上述报错通常是 ``COPY`` 命令报错，一般是没有把需要复制的文件准备好。在网上很多类似的报错，都是因为没有在当前目录下准备好文件导致的。看来这个挂载，如果使用 ``source`` 是从当前目录下开始的bind。修订::

   RUN --mount=type=bind,source=/sys/fs/cgroup,target=/sys/fs/cgroup \
    --mount=type=bind,source=/sys/fs/fuse,target=/sys/fs/fuse \
   ...

改成::

   RUN --mount=type=bind,target=/sys/fs/cgroup \
    --mount=type=bind,target=/sys/fs/fuse \
   ...

就不再报错

- 再次执行::

   docker build -t local:fedora34-systemd -f Dockerfile .

成功

- 运行::

   docker run --name fedora34-systemd -d -it local:fedora34-systemd
   
但是容器没有运行起来

- 排查::

   docker logs 8a79a424e8e7

可以看到::

   Failed to mount tmpfs at /run: Operation not permitted
   [!!!!!!] Failed to mount API filesystems.
   Exiting PID 1...

- 加上 ``--privileged=true`` 参数可以运行 (参考 `Docker (CentOS 7 with SYSTEMCTL) : Failed to mount tmpfs & cgroup <https://stackoverflow.com/questions/36617368/docker-centos-7-with-systemctl-failed-to-mount-tmpfs-cgroup>`_ ) ::

   docker run --privileged=true --name fedora34-systemd -d -it local:fedora34-systemd

这说明 ``--privileged=true`` 是关键，挂载 cgroup 和 tmp 卷需要这个权限。

然后就可以看到容器运行::

   docker ps

显示输出::

   CONTAINER ID   IMAGE                    COMMAND                  CREATED         STATUS        PORTS                     NAMES
   5ba415c8fcbe   local:fedora34-systemd   "/usr/lib/systemd/sy…"   2 seconds ago   Up 1 second   22/tcp, 80/tcp, 443/tcp   fedora34-systemd

.. note::

   使用 ``systemd`` 启动后，登陆需要密码账号，不再是 ``/bin/bash`` ，所以还需要增加账号添加步骤。详细配置见 :ref:`docker_studio`

.. note::

   实际上 ``/sys/fs/cgroup`` 挂载成 ``ro`` 只读就可以，只需要将 ``/sys/fs/cgroup/systemd`` 挂载成读写就能正确运行。详见 `Running systemd in a non-privileged container <https://developers.redhat.com/blog/2016/09/13/running-systemd-in-a-non-privileged-container#>`_

systemd运行总结
-----------------

- Docker需要传递环境变量 ``container=docker`` 给容器内部才能使得 ``systemd`` 知道自己运行在容器中
- 必须明确挂载 ``/sys/fs/cgroup`` (从物理主机 bind mount ``/sys/fs/cgroup`` 文件系统) 才能使得 ``systemd`` 运行

  - 如果是 ``docker run`` 明确的挂载参数方式，则不需要 ``--privileged=true`` 运行参数
  - 如果是 ``Dockerfile`` 配置 ``bind`` 和 ``tmpfs`` 挂载 ( 使用 :ref:`buildkit` ) ，则需要在 ``docker run`` 时传递 ``--privileged=true`` 运行参数

- bind mount ``/sys/fs/fuse`` 不是必须的，但是可以避免很多依赖fuse运行的软件问题
- systemd 希望在随时随地都使用 ``tmpfs`` ，但是如果运行在 ``unprivileged`` (非特权) 模式就不能随时随地挂载 ``tmpfs`` ，所以需要预先挂载 ``tmpfs`` 到 ``/tmp`` , ``/run`` 和 ``/run/lock``
- 由于你实际上不希望在容器内部启动任何图形应用，所以需要在最后指定 ``sysinit.target`` 作为 default unit 来启动，而不是使用 ``multi-user.target`` 或其他模式

Docker容器运行systemd实践
==========================

.. note::

   以下部分是去年(2020)的探索，当时的解决方法就是通过 ``docker run`` 时明确传递 ``--mount type=bind,source=/sys/fs/cgroup,target=/sys/fs/cgroup`` 才正确运行起 systemd 。不过，当时并没有探索 Buildkit ，现在(2021)补全了上面的Dockerfile方法。

CAP_SYS_ADMIN 和 cgroupfs
--------------------------

我们在 :ref:`dockerfile` 中介绍了如何 ``docker build`` 一个CentOS或Ubuntu系统，当时我的实践是在容器中运行 ``sshd`` ，现在我们则构建一个运行systemd的容器。

- 首先我们用以下 ``Dockerfile`` 构建一个CentOS 8系统

.. literalinclude:: docker_systemd/centos8
   :language: bash
   :linenos:

执行命令::

   docker build -t local:centos8 .

- 然后我们运行容器，为了对比，我们这里使用常规启动命令，不启动systemd::

   docker run -tid -p 1122:22 --hostname centos8-tini --name centos8-tini local:centos8    

- 启动容器后，我们连接到容器 ``centos8-tini`` 控制台进行检查::

   docker exec -it centos8-tini /bin/bash

- 在当前容器中，使用 ``ps aux | grep systemd`` 看不到systemd进程，并且执行 ``systemctl`` 命令显示如下::

   System has not been booted with systemd as init system (PID 1). Can't operate.
   Failed to connect to bus: Host is down

并且，通过 ``top`` 命令可以看到这个容器中的 PID 1 进程是 ``bash``

- 现在我们启动一个新的运行systemd的容器，注意，参数中增加了 ``--cap-add SYS_ADMIN`` 赋予 ``CAP_SYS_ADMIN`` 能力，并且将主机的cgroup文件系统只读映射到容器内部::

   docker run -tid -p 1222:22 --hostname centos8-systemd --name centos8-systemd -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
     --cap-add=sys_admin local:centos8 /sbin/init

注意， ``docker run`` 命令最后的执行命令是 ``/sbin/init`` ，在容器中，这个 ``/sbin/init`` 是软链接到 ``/lib/systemd/systemd`` 进程管理器::

   # ls -lh /sbin/init
   lrwxrwxrwx 1 root root 22 Dec 17 23:31 /sbin/init -> ../lib/systemd/systemd

- 我们连接到这个运行systemd的容器 ``centos8-systemd`` ::

   docker exec -it centos8-systemd /bin/bash

然后检查发现 ``systemd`` 并没有启动，这是为何呢？

systemd container interface
------------------------------

要允许systemd(以及系列程序)能够感知到自己运行在一个容器中，需要在容器运行的PID 1进程上设置 ``$container`` 环境变量，这样systemd unit配置文件中的 ``ConditionVirtualization=`` 设置才能工作。例如设置环境 ``container=lxc-libvirt`` 。

所以我们需要删除掉上述错误的容器 ``centos8-systemd`` ，然后重建一次，这次我们带上环境变量 ``container=docker`` ::

   docker stop centos8-systemd
   docker rm centos8-systemd

   docker run -tid -p 1222:22 --hostname centos8-systemd --name centos8-systemd -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
     --cap-add SYS_ADMIN --env container=docker local:centos8 /sbin/init

不过上述方式依然不能正确启动 ``systemd`` ，我们再进行下一步优化

tmpfs / fuse / sysinit.target
------------------------------

- 综合各个要点，我们按照以下方式重新启动::

   docker stop centos8-systemd
   docker rm centos8-systemd

   docker run -tid -p 1222:22 --hostname centos8-systemd --name centos8-systemd \
     --entrypoint=/usr/lib/systemd/systemd \
     --env container=docker \
     --mount type=bind,source=/sys/fs/cgroup,target=/sys/fs/cgroup \
     --mount type=bind,source=/sys/fs/fuse,target=/sys/fs/fuse \
     --mount type=tmpfs,destination=/tmp \
     --mount type=tmpfs,destination=/run \
     --mount type=tmpfs,destination=/run/lock \
       local:centos8 --log-level=info --unit=sysinit.target

以上方法就是在当前(2020年)在容器内运行 systemd 的实践方法。

==============

如果需要在容器内运行 ``ntpd`` 服务，则需要添加 ``--cap-add=SYS_TIME`` 。

- 最终完成后，在容器内部，你可以通过 ``ps aux | grep systemd`` 看到如下进程::

   root           1  2.3  0.4  21568  9044 ?        Ss   11:36   0:00 /usr/lib/systemd/systemd --log-level=info --unit=sysinit.target
   root          25  1.6  0.3  27136  6528 ?        Ss   11:36   0:00 /usr/lib/systemd/systemd-journald

- 在容器内检查文件系统 ``df -h`` 可以看到如下输出，显示挂载了tmpfs以及cgroup::

   Filesystem      Size  Used Avail Use% Mounted on
   overlay         117G   11G  102G  10% /
   tmpfs            64M     0   64M   0% /dev
   shm              64M     0   64M   0% /dev/shm
   tmpfs           925M  8.1M  917M   1% /run
   tmpfs           925M     0  925M   0% /tmp
   tmpfs           925M     0  925M   0% /run/lock
   /dev/mmcblk0p2  117G   11G  102G  10% /etc/hosts
   tmpfs           925M     0  925M   0% /sys/fs/cgroup
   tmpfs           925M     0  925M   0% /proc/asound
   tmpfs           925M     0  925M   0% /proc/scsi
   tmpfs           925M     0  925M   0% /sys/firmware

- 在容器内部我们使用 ``top`` 命令可以看到PID 1进程是 ``systemd`` ::

   top - 11:59:23 up 34 days,  1:53,  0 users,  load average: 1.53, 1.18, 1.06
   Tasks:   4 total,   1 running,   3 sleeping,   0 stopped,   0 zombie
   %Cpu(s):  6.3 us,  6.6 sy,  0.0 ni, 86.8 id,  0.2 wa,  0.0 hi,  0.2 si,  0.0 st
   MiB Mem :   1848.2 total,     52.3 free,   1015.1 used,    780.8 buff/cache
   MiB Swap:      0.0 total,      0.0 free,      0.0 used.    851.7 avail Mem
   
       PID USER      PR  NI    VIRT    RES    SHR S  %CPU  %MEM     TIME+ COMMAND
         1 root      20   0   21820   9112   7160 S   0.0   0.5   0:00.74 systemd
        25 root      20   0   27148   6768   5832 S   0.0   0.4   0:00.32 systemd-journal
        30 root      20   0    3876   3048   2568 S   0.0   0.2   0:00.14 bash
       103 root      20   0    9104   3324   2788 R   0.0   0.2   0:00.02 top

安装ssh服务和制作镜像
======================

- 既然我们已经实现了将systemd作为进程管理器，显然我们可以像传统的VM一样，在容器中部署多个服务，例如，之前我实践过 :ref:`docker_ssh` 是借助了Docker执行 ``/    bin/bash -c "/usr/sbin/sshd && /bin/bash"`` 方法，显然原先的方法不优雅。现在我们有了完整的systemd进程管理器，就可以部署sshd服务了。

  - 在容器内部执行ssh安装::

     dnf install openssh-server

  - 启动sshd服务::

     systemctl start sshd

  - 激活sshd服务::

     systemctl enable sshd

  - 为方便使用，建议同时安装ssh客户端::

     dnf install openssh-clients

- 制作镜像::

   docker commit centos8-systemd-sshd
   docker tag centos8-systemd-sshd huataihuang/centos8-systemd-sshd
   docker login
   docker push huataihuang/centos8-systemd-sshd

.. note::

   上述命令采用了 :ref:`docker_run` 中案例方法，将我制作的镜像推送的Docker Hub的huataihuang账号下，以便后续通过以下方法随时运行新容器::

      docker run -p 1122:22 -d huataihuang/centos8-systemd-sshd --hostname myserver --name myserver

Dockerfile构建systemd+sshd
===========================

dockerfile构建
------------------

- 在工作目录下创建以下 ``centos8-systemd-sshd`` 作为Dockerfile ，并在目录下存放一个用于 admin 用户的公钥文件 ``authorized_keys``

.. literalinclude:: docker_systemd/centos8-systemd-sshd.dockerfile
   :language: bash
   :linenos:

- 执行以下命令构建镜像::

   docker build -f centos8-systemd-sshd -t local:centos8-systemd-sshd .

- 执行以下命令创建运行systemd的容器::

   docker run -itd -p 1122:22 --hostname centos8-ssh --name centos8-ssh \
     --cap-add=sys_admin \
     --entrypoint=/usr/lib/systemd/systemd \
     --env container=docker \
     --mount type=bind,source=/sys/fs/cgroup,target=/sys/fs/cgroup \
     --mount type=bind,source=/sys/fs/fuse,target=/sys/fs/fuse \
     --mount type=tmpfs,destination=/tmp \
     --mount type=tmpfs,destination=/run \
     --mount type=tmpfs,destination=/run/lock \
       local:centos8-systemd-sshd --log-level=info --unit=sysinit.target

.. note::

   完成后运行的容器已经启动了systemd，并且已经准备好了sshd运行环境，包括创建了 ``admin`` 账号。不过，目前我遇到问题还有可能需要手工启动一次sshd以及删除 ``/var/run/nologin`` 。

buildkit构建
-------------------------

- 如果你安装使用 :ref:`buildkit` ，则可以使用以下 Dockerfile

.. literalinclude:: docker_systemd/centos8-systemd-sshd.buildkit
   :language: dockerfile
   :linenos:

执行以下命令构建镜像::

   buildctl build \
       --frontend=dockerfile.v0 \
       --local context=. \
       --local dockerfile=. 

使用 ``bulidkit`` 提供了不同的卷挂载命令，在前文Fedora镜像制作中，使用并简单做了介绍。

podman
========

Red Hat公司开发了另外一个符合OCI规范的容器和pods管理工具 :ref:`podman` ( `GitHub podman <https://github.com/containers/podman>`_ )。这个工具也直接支持在容器中运行systemd ( `How to run systemd in a container <https://developers.redhat.com/blog/2019/04/24/how-to-run-systemd-in-a-container/>`_ )

参考
======

- `Running systemd inside a docker container (arch linux) <https://serverfault.com/questions/607769/running-systemd-inside-a-docker-container-arch-linux>`_ - 当前2020年，这篇解决方案最准确，并且2021年更新还介绍 `David Walsh @ REDHAT blog <https://developers.redhat.com/blog/author/rhatdan/>`_ 提供了很多有用的信息，特别是挂载 cgroup 的方法 
- `Docker and systemd <https://medium.com/swlh/docker-and-systemd-381dfd7e4628>`_
- `systemd - The Container Interface <https://systemd.io/CONTAINER_INTERFACE/>`_
- `Start service using systemctl inside docker conatiner <https://stackoverflow.com/questions/46800594/start-service-using-systemctl-inside-docker-conatiner>`_
- `How to run systemd in a container <https://developers.redhat.com/blog/2019/04/24/how-to-run-systemd-in-a-container/>`_
- `Running systemd within a Docker Container <https://developers.redhat.com/blog/2014/05/05/running-systemd-within-docker-container>`_
