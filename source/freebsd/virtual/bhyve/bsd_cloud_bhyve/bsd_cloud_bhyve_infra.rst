.. _bsd_cloud_bhyve_infra:

================================
FreeBSD云计算虚拟化bhyve架构
================================

FreeBSD在底层技术上有稳定和靠靠的基础，但是缺乏厂商的硬件支持，所以在一些特定领域很难实现Linux的最新技术:

- :ref:`machine_learning` 领域几乎都是基于 :ref:`cuda` 生态实现，大规模工程实现都是在Linux完成，移植到FreeBSD上几乎不可能(没有厂商支持)
- :ref:`kubernetes` 是现代容器调度的生产级实现，虽然 :ref:`freebsd_jail` 能够实现类似 :ref:`docker` 容器化，但是没有厂商开发调度系统，目前也没有成熟的方案可以将 FreeBSD 节点融入到 :ref:`kubernetes` 集群

上述两个领域是大规模集群的核心技术，FreeBSD目前没有(至少我还没有找到)成熟的对等技术架构。但是，FreeBSD在基础操作系统领域有着深厚的积累，计算、存储、网络都有强大而稳定的实现，所以从技术上依然可以融入现代集群作为基石发挥所长:

- 作为Host系统，结合原生的 :ref:`zfs` 系统构建底层存储

  - :ref:`ceph` 可以在 :ref:`zfs` 上构建分布式存储，可以为 :ref:`kubernetes` 提供持久化卷
  - 虽然我没有足够的部署多机硬件，但是 :ref:`bhyve` 可以在单台服务器上模拟出多个FreeBSD服务器，来构建一个测试环境

- 使用 :ref:`bhyve` 结合 PCI passthrough，可以将一个 :ref:`nvidia_gpu` 透传给Linux虚拟机

  - 虽然FreeBSD难以直接构建 :ref:`machine_learning` 环境，但是借助虚拟化技术，依然可以构建一定规模的Linux集群模拟
  - 在Linux虚拟机中构建大规模 :ref:`kubernetes` 以及 :ref:`machine_learning` 实现
