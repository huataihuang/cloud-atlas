.. _edge_pi:

=================
边缘计算树莓派
=================

在 :ref:`edge_cloud_infra` ，构建 :ref:`k3s` 采用:

- :ref:`pi_3` : 管控 / :ref:`pi_4` : 计算

  - :ref:`edge_pi_alpine` 采用 :ref:`alpine_linux` 构建轻量级精简系统，

- :ref:`pi_400` : 瘦客户端轻量级卓明

  - :ref:`edge_pi_os` 采用 :ref:`raspberry_pi_os` 32位版本，力求性能优化
  - 远程访问 :ref:`k3s` 集群计算资源，以及 :ref:`priv_cloud` 构建的计算资源

