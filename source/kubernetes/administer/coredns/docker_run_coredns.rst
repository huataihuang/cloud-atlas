.. _docker_run_coredns:

=============================
Docker运行CoreDNS
=============================

除了在Kubernetes部署时通过 ``kubeadm`` 自动完成CoreDNS部署，也可以通过 :ref:`docker` 来运行独立的CoreDNS。这种场景通常是为了解决一些特定场景的独立部署。

CoreDNS是一个无状态的内存indexer，当和Kubernetes结合使用时，可以在启动时指定Kubernetes apiserver，此时CoreDNS会从apiserver拉取service记录，并构建DNS记录。所以可以将CoreDNS视为一个类似于 :ref:`dnsmasq` 的特定实现(对啊，dnsmasq启动时不是从本机 ``/etc/hosts`` 加载记录来构建DNS记录么)。

- 使用以下命令可以轻易运行一个结合Kubernetes的CoreDNS容器(假设 apiserver 和 coredns 运行在同一个管控服务器):

.. literalinclude:: docker_run_coredns/docker_coredns
   :language: bash
   :caption: 使用 :ref:`docker` 运行一个基于 :ref:`kubernetes` 的 CoreDNS

.. warning::

   `docker run` 只映射了 ``TCP 53`` ，所以需要配置 :ref:`k8s_node-local-dns_force_tcp`

参考
=======

- `Damn I Love Docker: Local DNS With CoreDNS <https://ragingtiger.github.io/2020/01/03/docker-local-dns/>`_
- `Running CoreDNS as a DNS Server in a Container <https://dev.to/robbmanes/running-coredns-as-a-dns-server-in-a-container-1d0>`_
