.. _install_kubeflow_single_command:

==================================
单条命令安装kubeflow
==================================

准备工作
=========

- 使用默认 :ref:`k8s_storage` : Provisioner种类其实不多，我考虑使用以下几种类型:

  - :ref:`cephfs`
  - :ref:`linux_iscsi`
  - :ref:`nfs`
  - :ref:`ceph_rbd`
  - :ref:`k8s_local`

- :ref:`kustomize` 5.0.3 以上:

.. literalinclude:: ../deploy/kustomize/install_kustomize_script
   :caption: 官方二进制安装脚本执行(需要非常畅通的网络)，在当前目录下对应OS的 ``kustomize``

- ``kubectl``

安装
========

- clone下仓库并进入 ``apps`` 目录:

.. literalinclude:: install_kubeflow_single_command/install_kubeflow
   :language: bash
   :caption: 单条命令安装kubeflow

.. note::

   安装是如此简洁，令人击节赞叹...我厂的软件交付...

- 完成安装后，可能需要等待一些时间让所有的pods就绪，可以通过以下命令来确认:

.. literalinclude:: install_kubeflow_single_command/check_kubeflow
   :language: bash
   :caption: 检查是否所有安装的 ``kubeflow`` 相关Pods就绪

.. note::

   我在 :ref:`y-k8s` 部署的虚拟机中采用了极小化的虚拟磁盘，遇到一个尴尬的问题就是 :ref:`node_pressure_eviction` ，也就是磁盘空间不足导致运行Pod被驱逐。在上述Pods检测就绪发现存在问题时，通过 :ref:`ceph_extend_rbd_drive_with_libvirt_xfs` 实现扩容解决(离线扩展方式，并且将 ``/var/lib/docker`` 迁移到 ``/var/lib/containerd`` )

需要注意，采用这种简单的部署方式，可能仅适用于测试环境。只少我看到的 ``deployments`` 都是单副本，没有提供冗余。后续我再仔细研究一下。

异常排查
=========

在解决了 ref:`y-k8s` 集群的磁盘空间不足问题之后，我清理了 ``ContainerStatusUnknown`` 的pod，然后按照上文依次检查相关 namespace 中pod是否正常运行。

``oidc-authservice`` pending
------------------------------

- 检查 ``kubectl get pods -n istio-system`` 输出显示 ``oidc-authservice-0`` 处于 ``pending`` 状态，检查 ``kubectl -n istio-system describe pods oidc-authservice-0`` 输出如下:

.. literalinclude:: install_kubeflow_single_command/oidc-authservice_pending.yaml
   :language: yaml
   :caption: ``describe pods oidc-authservice-0`` 可以看到调度失败原因是没有对应 ``pvc``
   :emphasize-lines: 33,48

- 检查PVC: ``kubectl -n istio-system get pvc`` 可以看到 ``authservice-pvc`` 处于 ``Pending`` ，则检查 ``kubectl -n istio-system get pvc authservice-pvc -o yaml`` 输出如下:

.. literalinclude:: install_kubeflow_single_command/authservice-pvc.yaml
   :language: yaml
   :caption: ``get pvc authservice-pvc`` 

考虑到简单化部署，我采用 :ref:`zfs` 来实现 NFS 输出




参考
=====

- `Kubeflow Manifests: Install with a single command <https://github.com/kubeflow/manifests#install-with-a-single-command>`_
