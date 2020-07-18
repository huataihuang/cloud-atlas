.. _container_live_restore:

====================================
Docker daemon停止时保持容器运行
====================================

默认情况下，当Docker daemon终止时，它会停止掉运行的容器。但是，在生产系统上，显然不能这样操作，因为服务升级是非常常见的操作，动辄重启容器是业务无法接受的。从Docker Engine 1.12开始，可以配置daemon在其停止的时候依然保持容器运行。这种功能能称为 ``live restore`` ，这个 ``live restore`` 选项降低了容器downtime，即使daemon出现了crash，升级或计划的停止。

激活live restore
=====================
