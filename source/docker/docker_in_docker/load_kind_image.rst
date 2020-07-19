.. _load_kind_image:

================================
加载kind镜像
================================

Docker镜像可以通过以下命令加载到集群中::

   kind load docker-image my-custom-image --name cluster-name

此外，镜像打包也可以加载::

   kind load image-archive /my-image-archive.tar

kind镜像加载实战
=================

.. note::

   这里采用的镜像实战是 :ref:`dockerfile` 案例，我们将在kind集群中构架一个基础的自定义ssh服务的CentOS。

- 创建Dockerfile目录 ``docker`` ，然后进入该目录，在该目录下存放 ``centos8-ssh`` 文件



参考
======

- `Kind Quick Start - Loading an Image Into Your Cluster <https://kind.sigs.k8s.io/docs/user/quick-start/>`_
