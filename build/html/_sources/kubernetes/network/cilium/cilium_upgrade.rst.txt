.. _cilium_upgrade:

===================
升级Cilium
===================

Cilium升级前检查
=================

在滚动升级Kubernetes时，Kubernetes会首先终止pod，然后拉取新镜像版本，并最终基于新镜像创建容器。为了降低agent的中断实践并且避免更新过程中出现 ``ErrImagePull`` ，建议预先拉取镜像和进行模拟检查(pre-flight check)。如果采用 :ref:`cilium_kubeproxy_free` 则需要在升级在生成 ``cilium-preflight.yaml`` 配置文件中指定 Kubernetes API服务器IP地址和端口。

运行pre-flight检查(必须)
=========================

- 由于我已经采用了 :ref:`cilium_kubeproxy_free` 模式，所以我这里执行 :ref:`helm` 的 ``kubeproxy-free`` 模式:

.. literalinclude:: cilium_upgrade/helm_cilium-preflight
   :language: bash
   :caption:  使用Helm运行pre-flight检查(hubeproxy-free模式)

这里可能会遇到无法下载问题::

   Error: INSTALLATION FAILED: failed to download "cilium/cilium" at version "1.12.0"

参考
=======

- `Cilium Upgrade Guide <https://docs.cilium.io/en/stable/operations/upgrade/>`_
