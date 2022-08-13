.. _cilium_upgrade:

===================
升级Cilium
===================

Cilium升级前检查
=================

在滚动升级Kubernetes时，Kubernetes会首先终止pod，然后拉取新镜像版本，并最终基于新镜像创建容器。为了降低agent的中断实践并且避免更新过程中出现 ``ErrImagePull`` ，建议预先拉取镜像和进行模拟检查(pre-flight check)。如果采用 :ref:

参考
=======

- `Cilium Upgrade Guide <https://docs.cilium.io/en/stable/operations/upgrade/>`_
