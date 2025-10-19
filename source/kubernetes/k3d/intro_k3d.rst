.. _intro_k3d:

=======================
k3d简介
=======================

``k3d`` 是在 :ref:`docker` 中运行 :ref:`k3s` (Rancher Lab’s minimal Kubernetes distribution) 的一个轻量级包装。这个工具提供了非常方便的在本地部署单节点或多接点 :ref:`k3s` 集群的方法。和 :ref:`kind` 类似，这是一个非常适合开发测试的Kubernetes环境，和 :ref:`kind` 的区别在于:

- ``k3d`` 底层采用了 :ref:`k3s` ，天然地比使用标准版Kubernetes的 :ref:`kind` 使用资源大为节约，可以在很多性能较弱的设备上运行，例如笔记本电脑
- 对于不需要完整Kubernetes功能的环境， :ref:`k3s` 提供了核心Kubernetes功能，摈弃了很多用不到的扩展，在特定的嵌入式系统 :ref:`raspberry_pi` 集群中有很大优势

我个人的 :ref:`mobile_cloud` 开发环境，后续准备迁移到采用 ``k3d`` 构建，以便能够在一台笔记本上实现云计算开发。

参考
=======

- `k3d overview <https://k3d.io/stable/>`_
