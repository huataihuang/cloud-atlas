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

   我在 :ref:`y-k8s` 部署的虚拟机中采用了极小化的虚拟磁盘，遇到一个尴尬的问题就是 :ref:`node_pressure_eviction` ，也就是磁盘空间不足导致运行Pod被驱逐。在上述Pods检测就绪发现存在问题时，通过 :ref:`ceph_extend_rbd_drive_with_libvirt_xfs` 实现扩容解决

参考
=====

- `Kubeflow Manifests: Install with a single command <https://github.com/kubeflow/manifests#install-with-a-single-command>`_
