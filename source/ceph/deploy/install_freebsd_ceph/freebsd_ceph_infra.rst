.. _freebsd_ceph_infra:

=======================
FreeBSD云计算Ceph架构
=======================

作为 :ref:`bsd_cloud_infra` 架构的底层分布式存储:

- 采用 :ref:`thin_jail` 来模拟Ceph多节点
- 为上层 :ref:`bsd_cloud_infra` / :ref:`bsd_cloud_bhyve_infra` 提供支持

.. note::

   我最初想要在FreeBSD构建一个类似我之前在Linux的 :ref:`kvm` 环境部署的 :ref:`ovmf_gpu_nvme` ，也就是运行3个 :ref:`bhyve` 虚拟机来构建Ceph集群。不过，由于我攒机的小型服务器 :ref:`pcie` 插槽有限需要全部用于 :ref:`nvidia_gpu` ，最多只能分配2个 :ref:`nvme` ，所以我考虑仅仅作为一个模拟演练，缩小Ceph使用的磁盘(分区)，并且也演练 :ref:`gluster` ，仅用来验证方案。

   :ref:`llm` 数据量巨大，我没有经费来购买3个副本的存储空间(Ceph)，所以会直接采用 :ref:`zfs` 存储提供给Linux bhyve 虚拟机加载。

   对于数据实际存储有安全性要求的，我将采用3个 :ref:`pi_5` 来构建 :ref:`ceph` 和 :ref:`gluster` ，存储实际需要确保安全性的数据。

Ceph on FreeBSD当前的实现是基于 :ref:`zfs` pools:

- 所有Ceph数据创建在 ``/var/lib/ceph``
- 日志文件存储在 ``/var/log/ceph``
- PID文件存储在 ``/var/log/run``
- 每个 ``OSD`` 需要分配 **一个 ZFS pool** (也就是说，至少需要准备3个物理分区，每个物理分区创建一个ZFS pool，并分配给一个PSD)

.. warning::

   我最初考虑使用轻量级的 :ref:`vnet_jail` 来模拟构建Ceph on FreeBSD，但是 :ref:`zfs-jail` 仅能够访问 ``dataset`` ，即不能直接访问 ``zpool`` : 这对部署Ceph是一个冲突，所以可能不得不构建 ``bhyve`` 虚拟机来部署。

参考
======

- `Ceph docs: Ceph Internals » FreeBSD Implementation details <https://docs.ceph.com/en/quincy/dev/freebsd/>`_
- `NLUUG 2017NJ: Willem Jan Withagen -- Ceph on FreeBSD <https://www.youtube.com/watch?v=_Eguk4wOKx8>`_ YouTube上的一个分享，可以了解Ceph在FreeBSD上的业界情况(2017年)
