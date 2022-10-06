.. _intro_muvirt:

========================================
μVirt(muVirt) - 基于OpenWrt的微型虚拟化
========================================

μVirt(muVirt) 是一个在OpenWrt上开发的微型虚拟化主机系统，用于提供主机简单的虚拟化网络功能，当前可以工作在64位ARM硬件设备，并且虚拟机兼容 :ref:Wrt上开发的微型虚拟化主机系统，用于提供主机简单的虚拟化网络功能，当前可以工作在64位ARM硬件设备，并且虚拟机兼容 :ref:`linaro` VM系统规范(例如，VM镜像使用UEFI启动)。

.. note::

   我感觉 :ref:`openwrt` 这样专注于边缘计算的开源项目，能够助力很多ARM设备或者微型系统成为边缘计算的主流，所以技术方案值得学习借鉴。

`Simple Virtualization with μVirt (Bonus: Self-contained Kubernetes Clusters) <https://www.crowdsupply.com/traverse-technologies/ten64/updates/simple-virtualization-with-mvirt-bonus-self-contained-kubernetes-clusters>`_ 介绍了在 :ref:`ten64` 硬件环境下构建muVirt虚拟化集群，实现 :ref:`kubernetes` 的方案。虽然Ten64硬件对个人来说较为昂贵，不太可能用来学习实践，但是这个软硬件结合的堆栈架构 `Kubernetes cluster blueprint with Ten64 and μVirt <https://gitlab.com/traversetech/kubeblueprint>`_ 值得借鉴思考。



参考
=======

- `μVirt - really small virtualization <https://gitlab.com/traversetech/muvirt/>`_
