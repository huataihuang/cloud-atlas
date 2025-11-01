.. _alpine_docker:

===========================
Alpine Linux运行Docker
===========================

安装
======

- 使用 :ref:`alpine_apk` 添加 ``Community`` 仓库，然后执行以下命令安装docker :

.. literalinclude:: alpine_docker/install_docker
   :caption: 安装docker

- 将自己的账号加入到 ``docker`` 组::

   addgroup huatai docker

- 启动Docker服务 - 参考 :ref:`openrc` :

.. literalinclude:: alpine_docker/docker_openrc
   :language: bash
   :caption: openrc 添加和启动 docker服务

.. note::

   我没有安装 ``docker-compose`` ，后续容器编排主要采用 :ref:`k3s`

隔离容器
===========

执行以下命令添加 ``dockremap`` :

.. literalinclude:: alpine_docker/dockremap
   :language: bash
   :caption: 添加dockremap(安全配置)

此时生成的 ``/etc/subuid`` 内容::

   dockremap:101:65536

``/etc/subgid`` 内容::

   dockremap:65533:65536

- 然后在 ``/etc/docker/daemon.json`` 中添加::

   {  
       "userns-remap": "dockremap"
   } 

此外，可以虑考虑添加::

       "experimental": false,
       "live-restore": true,
       "ipv6": false,
       "icc": false,
       "no-new-privileges": false

详细的配置参数参考 `Docker docs Reference / Command-line reference / Daemon CLI(dockerd) Daemon configuration file <https://docs.docker.com/engine/reference/commandline/dockerd/#daemon-configuration-file>`_

我实际采用配置:

.. literalinclude:: alpine_docker/daemon.json
   :language: json
   :caption: alpine 运行docker的 /etc/docker/daemon.json

alpine的Docker容器资源限制配置
================================

- 执行 ``docker info`` 检查配置，可能会看到::

   WARNING: No memory limit support
   WARNING: No swap limit support
   WARNING: No kernel memory TCP limit support
   WARNING: No oom kill disable support

这个问题在 `ruanbekker/k3s_on_alpine.md <https://gist.github.com/ruanbekker/fcc906bdcb2fed5937f7ce73a97e1001>`_ 提供了处理方法

此外，之前我在 :ref:`arm_k8s_deploy` 也遇到同样问题，处理方法请参考该文档。不过在 :ref:`arm_k8s_deploy` 采用了 :ref:`systemd` 所支持的 :ref:`cgroup_v2` : `Docker Engine 20.10 Released: Supports cgroups v2 and Dual Logging <https://www.infoq.com/news/2021/01/docker-engine-cgroups-logging/>`_

- 执行cgroup的fs挂载配置:

.. literalinclude:: alpine_docker/cgroup_fstab
   :language: bash
   :caption: 配置cgroup的fs挂载配置 /etc/fstab

- 创建 ``/etc/cgconfig.conf`` :

.. literalinclude:: alpine_docker/create_cgconfig.conf
   :language: bash
   :caption: 创建 /etc/cgconfig.conf

- 如果系统使用 :ref:`alpine_bootloader` ``Syslinux`` (名字是 ``extlinux`` ) 则修订内核参数::

   sed -i 's/default_kernel_opts="pax_nouderef quiet rootfstype=ext4"/default_kernel_opts="pax_nouderef quiet rootfstype=ext4 cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory"/g' /etc/update-extlinux.conf

.. note::

   我的系统没有找到 ``/etc/update-extlinux.conf`` ，仔细核对之后我发现实际上默认安装 :ref:`alpine_without_bootloader` 

不过，我的 :ref:`alpine_install_pi_usb_boot` 没有使用bootloader，所以直接修订 ``/media/sda1/cmdline.txt`` 添加:

.. literalinclude:: alpine_docker/cmdline.txt
   :language: bash
   :caption: /media/sda1/cmdline.txt 添加内核参数

完整配置如下::

   modules=loop,squashfs,sd-mod,usb-storage quiet console=tty1 root=/dev/sda2 cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory

然后重启系统，然后再次执行 ``docker info`` 就不会出现上述报错

blkio 资源限制报错
===================

我在 :ref:`pi_3` 上使用 TF卡作为存储，同样的安装和部署，发现 ``docker info`` 有如下WARNING::

   WARNING: No blkio throttle.read_bps_device support
   WARNING: No blkio throttle.write_bps_device support
   WARNING: No blkio throttle.read_iops_device support
   WARNING: No blkio throttle.write_iops_device support

由于 :ref:`alpine_docker` 使用的是 :ref:`docker_20.10` ，支持 :ref:`cgroup_v2` ，我在想是否可以通过转换操作系统 cgroup v1 到 v2 来解决这个问题？

参考
======

- `alpine linux wiki: Docker <https://wiki.alpinelinux.org/wiki/Docker>`_
- `ruanbekker/k3s_on_alpine.md <https://gist.github.com/ruanbekker/fcc906bdcb2fed5937f7ce73a97e1001>`_
