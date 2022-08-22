.. _cilium_service_mesh_arch:

=========================
Cilium Service Mesh架构
=========================

Cilium 1.12 于2022年7月20日发布，在 Service Mesh 上有很多增强，特别是提供了全新的 ``eBPF native + envoy sidecar-free`` 架构支持多种控制平面选项。Cilium 1.12对现有基于sidecar模式 :ref:`istio` 做出了补充，也深度集成到Cilium架构。

.. figure:: ../../../../_static/kubernetes/network/cilium/service_mesh/cilium_new_service_mesh.png
   :scale: 50

企业级Service Mesh
====================

随着企业级Service Mesh兴起，企业级网络需要服务网格(service mesh)不仅是WEB扩展应用，而是要求将Kubernetes网络/CNI层和Service Mesh层紧密结合，并且创造出新的结合两者的层次:

.. figure:: ../../../../_static/kubernetes/network/cilium/service_mesh/enterprise_grade_service_mesh.png
   :scale: 50

参考
======

- `Cilium Service Mesh – Everything You Need to Know <https://isovalent.com/blog/post/cilium-service-mesh/>`_
- `Cilium 1.12 – Ingress, Multi-Cluster, Service Mesh, External Workloads, and much more <https://isovalent.com/blog/post/cilium-release-112/>`_
