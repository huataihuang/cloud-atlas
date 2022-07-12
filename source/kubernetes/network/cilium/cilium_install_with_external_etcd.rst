.. _cilium_install_with_external_etcd:

=========================
在扩展etcd环境安装cilium
=========================

:ref:`cilium_startup` 介绍了快速安装cilium的方法，但是只是适合比较简单环境，即采用堆叠etcd模式环境，而在采用外部独立etcd集群，则需要做一些调整，把 ``etcd`` 集群配置传递给cilium安装程序

参考
======

- `cilium Getting Started Guides: Installation with external etcd <https://docs.cilium.io/en/stable/gettingstarted/k8s-install-external-etcd/>`_
