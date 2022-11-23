.. _kind_container_nfs_volume:

=============================
kind容器使用共享NFS卷
=============================

在 :ref:`kind_run_simple_container` 访问共享的NFS可以部署一种共享数据的发布模式:

- 容器内部不需要复制发布的文件，对于静态WEB网站会非常容易实现无状态pod部署
- 数据更新可以在中心化的 :ref:`nfs` 存储上实现，方便 :ref:`devops` 持续部署
