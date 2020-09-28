.. _decode_k8s_self_healing:

====================
解码Kubernetes自愈
====================

虽然Kubernetes提供了应用的自愈(pod self-healing)，但是除了管控节点(master)，计算工作节点并没有提供自身修复能力。也就是说，如果要构建可一个高可靠的Kubernetes集群，需要实现工作节点的自我修复，需要结合第三方解决方案。

比较理想的状态是结合虚拟化云计算：虚拟化云计算提供了自动修复(热迁移或者迅速重建完全一致的虚拟机)，这样可以实现Kubernetes节点的自愈。对于Kubernetes来说，其底层架构就是完全可靠的基础架构。

.. note::

   仔细思考一下，Kubernetes确实只聚焦在应用的高可用上，随时会为失败的应用程序拉起一个应用副本。但是Kubernetes并没有解决自身节点的高可用，仅仅是将node标记为 ``NotReady`` 。

   而底层提供自动化自愈架构，我们称之为 ``provision`` (供应商)，提供Kubernetes故障节点的自动下线，修复，自动上线功能。

要达到集群自愈，需要基础架构在Kubernetes之前实现可用且可自愈，这样的基础架构才能保障上层的Kubernetes始终平稳运行。通常这种基础架构由云计算来实现，例如VMware或者 :ref:`openstack` 。

Kublr这样的平台提供了原生的基础架构和能力来自动提供，伸缩和修复。自动伸缩的能力可以自动设置每个节点、worker和master。它提供了基础架构可以在虚拟机宕机时自动恢复成另一个虚拟机。Kublr也同时监控所有事件确保替换的虚拟机能够自动启动并重新连接到Kubernetes集群，不需要任何人工干预。

上述主机实例，不论是虚拟机还是物理服务器，对于Kublr都是相同的处理方式，即在服务器节点运行Kublr agent，来确保每个节点都运行在指定状态。agent监控节点以及节点上的组件确保组件正常工作，同时确保工作节点(worker)和管控节点(master)能安全通讯以及不同组件安全连接。

参考
=====

- `Decoding the Self-Healing Kubernetes <https://devops.com/decoding-the-self-healing-kubernetes/>`_
- `Decoding the Self-Healing Kubernetes:Step by Step <https://www.msystechnologies.com/blog/decoding-the-self-healing-kubernetes-step-by-step-2/>`_
- `Reliable, Self-Healing Kubernetes Explained <https://kublr.com/blog/reliable-self-healing-kubernetes-explained/>`_
- `True reliability requires self-healing nodes and infrastructure management <https://jaxenter.com/kubernetes-self-healing-nodes-163501.html>`_
