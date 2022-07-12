.. _cilium_startup:

=================
cilium快速起步
=================

首先需要有一个kubernetes集群，类似我在 :ref:`k8s_dnsrr` 初始化了集群管控节点，但是无法启动容器，需要首先安装网络组件

- 安装cilium cli:

.. literalinclude:: cilium_startup/cilium_cli_install
   :language: bash
   :caption: 安装cilium cli

- 安装::

   cilium install

.. note::

   上述安装是简化版，如果采用扩展etcd(外部)，则按照 :ref:`cilium_install_with_external_etcd`

参考
======

- `cilium Quick Installation <https://docs.cilium.io/en/stable/gettingstarted/k8s-install-default/>`_
