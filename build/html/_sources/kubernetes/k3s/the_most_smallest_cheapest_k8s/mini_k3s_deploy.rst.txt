.. _mini_k3s_deploy:

===============
微型k3s部署
===============

在 :ref:`pi_1` 上完成了 :ref:`mini_k3s_prepare` 就可以开始部署

.. note::

   在 :ref:`pi_1` 我尚未完成实践

安装k3s
==========

- 安装 ``cni-plugins`` 和 ``iptables`` ::

   apk add --no-cache cni-plugins
   export PATH=/usr/libexec/cni:$PATH
   apk add iptables

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

参考
========

- `k3s bootstrap on Alpine Linux <https://d-heinrich.medium.com/k3s-bootstrap-on-alpine-linux-c207c85c3f3d>`_
- `Install k3s on Alpine Linux <https://gist.github.com/ruanbekker/fcc906bdcb2fed5937f7ce73a97e1001>`_
