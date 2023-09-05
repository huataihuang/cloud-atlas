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

我最初以为这是一个简单的 :ref:`k8s_pvc_pv_bind` (类似我之前实践过的 :ref:`kube-prometheus-stack_persistent_volume` ) ，想正好实践一下 :ref:`zfs_nfs` 输出为 :ref:`k8s_nfs` 。

但是仔细检查这个 ``authservice-pvc`` 就会发现和 ``pv/pvc`` 的静态配置有所不同: ``authservice-pvc`` 并没有提供 ``storageClassName`` 来对应绑定 ``pv`` 和 ``pvc`` 。也就是说，这里的实现是 :ref:`k8s_dynamic_volume_provisioning` 。

如果我不是在云计算厂商的平台部署(通常云厂商会提供 :ref:`k8s_csi` ，并且只要配置好 :ref:`admission_plugins_DefaultStorageClass` 就能无需指定 ``sc`` storage class直接创建存储pv )，就必须自己部署实现:

  - :ref:`openebs`
  - :ref:`ceph-csi`

然后通过指定 :ref:`admission_plugins_DefaultStorageClass` 实现为 ``kubeflow mainfest`` 提供 :ref:`k8s_dynamic_volume_provisioning`


参考
=====

- `Kubeflow Manifests: Install with a single command <https://github.com/kubeflow/manifests#install-with-a-single-command>`_
