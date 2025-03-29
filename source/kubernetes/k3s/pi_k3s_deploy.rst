.. _pi_k3s_deploy:

===================
在树莓派上部署K3s
===================

:ref:`k3s` 适合部署在 :ref:`edge_cloud` 环境，在我的实践中采用 :ref:`pi_stack` ，共计有:

- 3台 :ref:`pi_3` 运行 ``server``
- 2台 :ref:`pi_4` (8G内存) 运行 ``agent``
- 1台 :ref:`jetson_nano` 运行 ``agent`` (GPU资源)

部署步骤
==========

- :ref:`prepare_k3s_alpine` 调整 :ref:`alpine_linux` 内核
- :ref:`k3s_ha_etcd` 部署高可用独立运行的 :ref:`etcd` 集群
- :ref:`k3s_install` 通过安装脚本安装k3s，使用扩展etcd
