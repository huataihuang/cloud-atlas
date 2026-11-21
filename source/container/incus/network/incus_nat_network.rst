.. _incus_nat_network:

============================
Incus NAT 网络
============================

Incus默认是用NAT网络，当 :ref:`incus_startup` 实践默认建立的 ``incusbr0`` 就是NAT网络，所以看到容器和VM的网段 ``10.0.55.0/24`` (默认网关是 ``10.0.55.1`` )。使用非常方便，但是也使得外部要访问容器/虚拟机的服务时，需要使用端口映射(DNAT) 或者通过 :ref:`ssh_proxyjump` 访问SSH服务。

环境
======

- :ref:`incus_debian_vm` 虚拟机IP地址 ``10.0.55.83``

从外部机器 SSH(端口转发)
===========================

外部机器无法直接路由到 ``10.0.55.x`` ，需要在 host 上做 DNAT:

.. literalinclude:: incus_nat_network/iptables_nat
   :caption: 端口转发到NAT网络上虚拟机SSH服务

现在就能够通过外部主机访问Host主机的 ``2222`` 端口来访问到虚拟机 ``debian13-dev`` 的SSH服务

参考
======

- :ref:`podman_compose_ollama_nvidia_a2` 运行 ``qwen3.8:27b-q8_0`` 模型
