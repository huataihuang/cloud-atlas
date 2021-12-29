.. _intro_kubevirt:

===========================
KubeVirt虚拟机管理器简介
===========================

传统上KVM虚拟机的管理器采用 :ref:`libvirt` 实现，并且libvirt也扩展延伸能够管理docker容器。相反，kubernetes作为容器管理器，也能够通过扩展KubeVirt实现管理虚拟机资源（即 ``VM`` 类型），这样可以满足在容器作为主要集群应用运行调度模式下，补充虚拟化技术实现不同内核、混合操作系统（例如运行Windows）的业务场景。

Platform9和KubeVirt
====================

`Platform9 <https://platform9.com/>`_ 是一家混合云管理平台公司，提供云原生结合传统虚拟化云计算的混合管理平台。随着Kubernetes快速崛起，在应用部署生命周期管理中具有优势，但是虚拟化云计算依然是提供公有云和私有云的基础平台，具有成熟的架构和实现。不论是 Kubernetes 还是 :ref:`openstack` ，都是非常复杂的 IaaS
平台，企业部署都有很高的技术门槛和成本。Platform9提供了服务简化，通过其SaaS平台，可以在AWS,Azure,GCP之上构建，也可以采用 OpenStack 作为底座来构建。

为了能够让熟悉Kubernetes的企业用户能够顺畅使用底层虚拟化，Platform9开发并开源了 KubeVirt ，提供容器和虚拟机同时运行在裸金属服务器上，避免开发人员二选一，或者需要管理两套完全独立的技术堆栈(Kubernetes和Openstack)。

.. note::

   Red Hat主导开开发的 :ref:`openshift` 也基于 KubeVirt 来将支持的VM作为一个容器来管理。在 OpenShift 4.4 中采用了基于 :ref:`tekton` 实现DevOps pipeline 以及 基于KubeVirt 实现OpenShift虚拟化。

参考
========

-  
