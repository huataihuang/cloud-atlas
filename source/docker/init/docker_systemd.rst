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

Docker容器运行systemd实践
==========================

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

buildkit构建(尚未实践)
-------------------------

- 如果你安装使用 :ref:`buildkit` ，则可以使用以下 Dockerfile

.. literalinclude:: docker_systemd/centos8-systemd-sshd.dockerfile
   :language: bash
   :linenos:

执行以下命令构建镜像::

   buildctl build \
       --frontend=dockerfile.v0 \
       --local context=. \
       --local dockerfile=. 

podman
========

Red Hat公司开发了另外一个符合OCI规范的容器和pods管理工具 podman ( `GitHub podman <https://github.com/containers/podman>`_ )。这个工具也直接支持在容器中运行systemd ( `How to run systemd in a container <https://developers.redhat.com/blog/2019/04/24/how-to-run-systemd-in-a-container/>`_ )

参考
======

- `Running systemd inside a docker container (arch linux) <https://serverfault.com/questions/607769/running-systemd-inside-a-docker-container-arch-linux>`_ - 当前2020年，这篇解决方案最准确
- `Docker and systemd <https://medium.com/swlh/docker-and-systemd-381dfd7e4628>`_
- `systemd - The Container Interface <https://systemd.io/CONTAINER_INTERFACE/>`_
- `Start service using systemctl inside docker conatiner <https://stackoverflow.com/questions/46800594/start-service-using-systemctl-inside-docker-conatiner>`_
- `How to run systemd in a container <https://developers.redhat.com/blog/2019/04/24/how-to-run-systemd-in-a-container/>`_
