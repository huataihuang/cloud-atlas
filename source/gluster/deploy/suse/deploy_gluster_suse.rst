.. _deploy_gluster_suse:

=======================
在SUSE中部署GlusterFS
=======================

部署方案
=========

:ref:`suse_linux` 作为主要的企业级Linux发行版，不仅在欧洲应用广泛，也在中国的金融、运营商和电力等关键领域得到采用。本文采用模拟多磁盘服务器构建GlusterFS集群:

- :ref:`install_opensus_leap` 作为基础操作系统( 运行在 :ref:`priv_cloud_infra` )

在生产系统中，需要平衡不同操作系统的服务端和客户端搭配:

- 服务器端采用RHEL/CentOS7 ，客户端擦用 :ref:``
