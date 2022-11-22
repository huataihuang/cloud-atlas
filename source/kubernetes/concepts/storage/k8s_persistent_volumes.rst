.. _k8s_persistent_volumes:

========================
Kubernetes持久化存储卷
========================

持久卷类型
============

由于 Kubernetes 发展快速(向后兼容性较差)，实际上很多早期支持的持久卷已经在当前版本或未来版本放弃支持，所以如果你要部署Kubernetes集群的持久化存储，务必参考官方文档，确保未来及长期稳定运维!!!

Kubernetes目前支持插件(当前推荐):

- cephfs - CephFS volume : :ref:`cephfs`
- csi - 容器存储接口 (CSI)
- fc - Fibre Channel (FC) 存储
- hostPath - HostPath 卷 （仅供单节点测试使用；不适用于多节点集群；请尝试使用 local 卷作为替代）
- iscsi - iSCSI (SCSI over IP) 存储: 可以采用 :ref:`zfs` 构建 :ref:`zfs_iscsi`
- local - 节点上挂载的本地存储设备
- nfs - 网络文件系统 (NFS) 存储: 可以采用 :ref:`zfs_nfs`
- rbd - Rados 块设备 (RBD) 卷: :ref:`ceph_rbd`

已经废弃的持久卷(当前可能支持，但未来发行版移除支持，不建议使用):

- awsElasticBlockStore - AWS 弹性块存储（EBS） （于 v1.17 弃用）
- azureDisk - Azure Disk （于 v1.19 弃用）
- azureFile - Azure File （于 v1.21 弃用）
- cinder - Cinder（OpenStack 块存储）（于 v1.18 弃用）
- flexVolume - FlexVolume （于 v1.23 弃用）
- gcePersistentDisk - GCE Persistent Disk （于 v1.17 弃用）
- glusterfs - Glusterfs 卷 （于 v1.25 弃用）: 我之前有一个实践 :ref:`k8s_gluster`
- portworxVolume - Portworx 卷 （于 v1.25 弃用）
- vsphereVolume - vSphere VMDK 卷 （于 v1.19 弃用）


参考
=======

- `Kubernetes文档>>概念>>存储>>持久卷 <https://kubernetes.io/zh-cn/docs/concepts/storage/persistent-volumes/>`_
