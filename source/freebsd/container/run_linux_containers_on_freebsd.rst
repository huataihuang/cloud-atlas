.. _run_linux_containers_on_freebsd:

=================================
在FreeBSD上运行Linux容器
=================================

.. note::

   可以在 :ref:`macos` 上通过 :ref:`lima` 来运行FreeBSD虚拟机

   但是在FreeBSD上可能更自由，所以有了本文的实践

一些想法
==========

- 如果能够通过 Linux emulation 运行 ``runj`` 来实现在 :ref:`freebsd_jail` 中运行Docker容器以及网络，那么就有可能直接运行 :ref:`kind` ，而不需要 :ref:`bhyve` 来虚拟化(可以降低主机资源消耗)
- 实在不行还是可以通过运行一个 :ref:`bhyve` 虚拟机来运行 :ref:`kind` ，虽然比较挫，但是 :ref:`kind` 也是通过这种方式运行在 :ref:`macos` 上的
- 可以找到通过 :ref:`bhyve` 运行多个虚拟机来部署 :ref:`kubernetes` 的案例:

  - `Deploy Kubernetes cluster on FreeBSD/bhyve (CBSD) <https://www.bsdstore.ru/en/articles/cbsd_k8s_part1.html>`_
  - `Kubernetes on FreeBSD with Linux worker nodes and Cilium <https://medium.com/@norlin.t/kubernetes-on-freebsd-with-linux-worker-nodes-and-cilium-a87c50daef03>`_

参考
=====

- `Fun with FreeBSD: Run Linux Containers on FreeBSD <https://productionwithscissors.run/2022/09/04/containerd-linux-on-freebsd/>`_
- `Docker-style networking for FreeBSD jails with runj <https://samuel.karp.dev/blog/2022/12/docker-style-networking-for-freebsd-jails-with-runj/>`_
