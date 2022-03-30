.. _mini_k3s_deploy:

===============
微型k3s部署
===============

.. note::

   我尚未完成 :ref:`pi_1` 上部署 :ref:`k3s` ，目前先完成 :ref:`pi_4` 上 :ref:`pi_k3s_deploy` ，后续再继续完成本文实践

在 :ref:`pi_1` 上完成了 :ref:`mini_k3s_prepare` 和 :ref:`build_k3s` 之后开始部署

准备
==========

- 安装 ``cni-plugins`` 和 ``iptables`` ::

   apk add --no-cache cni-plugins iptables
   export PATH=/usr/libexec/cni:$PATH

.. note::

   必须安装 ``cni-plugin`` 否则执行 k3s 可能报错::

      ERRO[0816] failed to find host-local: exec: "host-local": executable file not found in $PATH

   我发现该文件实际安装目录是 ``/usr/libexec/cni`` ，所以上文采用了 ``export PATH=/usr/libexec/cni:$PATH``

- 为了能够启动时设置好该路径，执行以下命令添加到启动环境中::

   echo -e '#!/bin/sh\nexport PATH=/usr/libexec/cni:$PATH' > /etc/profile.d/cni.sh

k3s官方安装方法(失败)
=======================

- ``k3s`` 将安装过程极简化，可以通过 `k3s releases <https://github.com/rancher/k3s/releases/>`_ 看到 ``k3s`` 提供了不同平台的二进制执行程序，对于ARM平台，有64位 (arm64) 和32位 (armhf)。可以手工下载，或者简单通过官方脚本进行安装::

   curl -sfL https://get.k3s.io | sh -

提示信息:

.. literalinclude:: mini_k3s_deploy/get.k3s.io_output
   :language: bash
   :caption: 执行 curl -sfL https://get.k3s.io | sh - 输出信息

我遇到一个问题，就是看上去 ``k3s`` 已经启动，并且::

   $ sudo service k3s status
    * status: started

但是实际上容器并未运行，执行 ``docker ps`` 输出是空白

按照官方文档，应该有一个 ``/etc/rancher/k3s/k3s.yaml`` 作为 kubeconfig 文件，并且自动启动服务；此外，在 ``/var/lib/rancher/k3s/server/node-token`` 创建了 ``K3S_TOKEN`` ，这个token用于传递参数来安装工作接待你

原因是？

- 手工初始化集群::

   K3S_TOKEN=SECRET k3s server --cluster-init

执行上述手工初始化就看到报错了::

   Illegal instruction

非法指令 :ref:`arm_illegal_instruction` 

.. note::

   后续我准备自己编译 :ref:`k3s` 来实现 :ref:`pi_1` 部署，待继续实践

- 卸载(后续重新实践)::

   sudo k3s-uninstall.sh

使用 :ref:`build_k3s` 进行部署
===============================

对于我所使用的 :ref:`pi_1` 由于是 :ref:`armv6` 微架构，无法直接使用官方提供的执行软件包 ( ``armv7`` )，所以，我采用自行 :ref:`build_k3s` 来获得执行包。经过一番折腾，终于在 ``树莓派1b+`` (512MB内存) 上完成编译，编译一次耗时约12小时。

执行程序
----------

我一共有3个 :ref:`pi_1` ，配分角色见 :ref:`edge_cloud_infra` 

- 将编译后的 ``dist/artifacts/k3s-armhf`` 复制到3台 :ref:`pi_1` ``/usr/bin`` 目录下 ``k3s`` (确保该文件是可执行模式)::

   scp dist/artifacts/k3s-armhf root@192.168.10.10:/usr/local/bin/k3s

- 在每个主机节点上验证一下是否可以执行::

   k3s --version

可以看到::

   k3s version v1.23.5-rc2+k3s1 (d25ae8fb)
   go version go1.17.5

第一个master节点
-------------------

.. note::

   `Running K8s on ARM <https://nicks-playground.net/posts/2020-03-21-running-k8s-on-arm/>`_ 使用了基于SSH进行快速部署的 `alexellis / k3sup <https://github.com/alexellis/k3sup>`_ 开源项目，原理是通过SSH在服务器上安装K3S，可以借鉴学习。

K3S通过脚本可以自动安装( ``curl -sfL https://get.k3s.io | sh -`` )，这个脚本提供了很多环境参数可以方便调整，例如，可以跳过下载二进制程序(我已经完成)::

   curl -sfL https://get.k3s.io | INSTALL_K3S_SKIP_DOWNLOAD=true sh -

安装过程提示::

   [INFO]  Skipping k3s download and verify
   [INFO]  Skipping installation of SELinux RPM
   [INFO]  Creating /usr/local/bin/kubectl symlink to k3s
   [INFO]  Creating /usr/local/bin/crictl symlink to k3s
   [INFO]  Creating /usr/local/bin/ctr symlink to k3s
   [INFO]  Creating killall script /usr/local/bin/k3s-killall.sh
   [INFO]  Creating uninstall script /usr/local/bin/k3s-uninstall.sh
   [INFO]  env: Creating environment file /etc/rancher/k3s/k3s.env
   [INFO]  openrc: Creating service file /etc/init.d/k3s
   [INFO]  openrc: Enabling k3s service for default runlevel
   [INFO]  openrc: Starting k3s
    * Caching service dependencies ...                                                                                                                              [ ok  ]
   mount: mounting cpu on /sys/fs/cgroup/cpu failed: Resource busy
   mount: mounting cpuacct on /sys/fs/cgroup/cpuacct failed: Resource busy
   mount: mounting blkio on /sys/fs/cgroup/blkio failed: Resource busy
   mount: mounting memory on /sys/fs/cgroup/memory failed: Resource busy
   mount: mounting devices on /sys/fs/cgroup/devices failed: Resource busy
   mount: mounting freezer on /sys/fs/cgroup/freezer failed: Resource busy
   mount: mounting net_cls on /sys/fs/cgroup/net_cls failed: Resource busy
   mount: mounting perf_event on /sys/fs/cgroup/perf_event failed: Resource busy
   mount: mounting net_prio on /sys/fs/cgroup/net_prio failed: Resource busy
   mount: mounting pids on /sys/fs/cgroup/pids failed: Resource busy
    * Starting k3s ...                                                                                                                                              [ ok  ]

但是存在问题，实际上 ``k3s`` 启动失败， ``ps aux | grep k3s`` 只看到一个 ``supervise-daemon`` 进程::

   2405 root      0:00 supervise-daemon k3s --start --stdout /var/log/k3s.log --stderr /var/log/k3s.log --pidfile /var/run/k3s.pid --respawn-delay 5 --respawn-max 0 /usr/local/bin/k3s -- server

实际上执行 ``kubectl`` 依然出现 ``Illegal instruction`` ::

   $ kubectl --version
   Illegal instruction

待排查...

参考
========

- `k3s bootstrap on Alpine Linux <https://d-heinrich.medium.com/k3s-bootstrap-on-alpine-linux-c207c85c3f3d>`_
- `Install k3s on Alpine Linux <https://gist.github.com/ruanbekker/fcc906bdcb2fed5937f7ce73a97e1001>`_
- `Running K8s on ARM <https://nicks-playground.net/posts/2020-03-21-running-k8s-on-arm/>`_
- `K3S Installation Options <https://rancher.com/docs/k3s/latest/en/installation/install-options/>`_
