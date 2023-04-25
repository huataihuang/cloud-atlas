.. _config_calicoctl_connect_etcd:

===========================================
配置 ``calicoctl`` 连接 ``etcd`` 数据存储
===========================================

.. note::

   在最新版本的Calico中，提供了Calico API Server，所以可以直接使用 :ref:`kubectl` 来取代 ``calicoctl`` 维护 ``calico`` 网络，除了少数命令才需要使用 ``calicoctl`` 

使用 ``~/.kube/config`` 连接
=================================

`install Calico on Kubernetes <https://docs.projectcalico.org/v3.3/getting-started/kubernetes/installation/calico>`_ 默认使用Kubernetes datastore(采用 ``etcdv3`` )。此时你的 ``calicoctl`` 配置文件位于 ``/etc/calico/calicoctl.cfg`` :

.. literalinclude:: config_calicoctl_connect_etcd/calicoctl.cfg
   :language: yaml
   :caption: ``/etc/calico/calicoctl.cfg``

然后就可以直接使用 ``calicoctl get nodes`` 检查系统

参考
======

- `Configure calicoctl to connect to an etcd datastore <https://docs.tigera.io/calico/latest/operations/calicoctl/configure/etcd>`_
- `How to let calico use K8s etcd? <https://stackoverflow.com/questions/53368054/how-to-let-calico-use-k8s-etcd>`_
