.. _k8s_numa_arch:

===========================
Kubernetes NUMA实现架构
===========================

当Kubernetes部署到裸金属服务器(直接物理主机，非 :ref:`kvm` 虚拟机环境)

参考
=====

- `Topology Aware Scheduling in Kubernetes Part 1: The High Level Business Case <https://cloud.redhat.com/blog/topology-aware-scheduling-in-kubernetes-part-1-the-high-level-business-case>`_
- `Topology Awareness in Kubernetes Part 2: Don’t we already have a Topology Manager? <https://cloud.redhat.com/blog/topology-awareness-in-kubernetes-part-2-dont-we-already-have-a-topology-manager>`_
- `Topology Management - Implementation in Kubernetes Technology Guide <https://builders.intel.com/docs/networkbuilders/topology-management-implementation-in-kubernetes-technology-guide.pdf>`_ Intel技术手册
- `Control Topology Management Policies on a node <https://kubernetes.io/zh/docs/tasks/administer-cluster/topology-manager/>`_ kubernetes官方文档，有中文版
- `Utilizing the NUMA-aware Memory Manager <https://kubernetes.io/docs/tasks/administer-cluster/memory-manager/>`_ kubernetes官方文档，有中文版
