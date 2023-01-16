.. _mobile_cloud_x86_zfs:

=========================
X86移动云ZFS
=========================

在我使用的 :ref:`apple_silicon_m1_pro` MacBook Pro，我期望构建完全虚拟化的多服务器集群架构。对于底层存储，希望在一个 卷管理 上构建出存储给虚拟机使用。

有两种候选文件系统:

- :ref:`zfs`
- :ref:`btrfs`

经过实践探索( :ref:`archlinux_zfs-dkms` )， :ref:`asahi_linux` 内核激进采用v6.1，尚未得到 ``OpenZFS`` 支持，所以

- 在 :ref:`apple_silicon_m1_pro` MacBook Pro 采用 :ref:`btrfs`
- 在 X86_64 的 Macbook Pro 2013 采用 :ref:`zfs`

.. note::

   虽然没有如我最初规划的那样采用最先进稳定的 :ref:`zfs` 作为底层文件系统，非常遗憾。不过，我觉得ZFS方案还是非常适合生产环境以及个人系统使用，如果能够得到内核以及发行版稳定支持，采用ZFS可以帮助我们充分利用存储容量和性能，也为企业级部署提供经验支持。

   希望今后社区技术演进后能够再作挑战。

存储构想
==========

我考虑采用 :ref:`zfs` 来构建物理主机的文件系统:

- 通过ZFS卷作为虚拟机的磁盘( :ref:`libvirt` 已经支持ZFS卷 )
- 采用3个虚拟机构建 :ref:`ceph` (边缘云计算架构Linaro已经完全基于 :ref:`openstack` 和 :ref:`ceph` )
- 在 :ref:`ceph` 基础上构建 :ref:`openstack` 和 :ref:`kubernetes`


