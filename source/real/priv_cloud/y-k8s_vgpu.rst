.. _y-k8s_vgpu:

===================
y-k8s集群vGPU
===================

在构建 :ref:`gpu_k8s` 模拟时，我采用将 Passthrough :ref:`tesla_p10` 重新拆解成多块 :ref:`vgpu` 加入到不同的虚拟机中:

- 模拟构建一个拥有多块GPU的 :ref:`kubernetes` 集群
- 部署多路GPU进行 :ref:`machine_learning`

NVIDIA的 :ref:`vgpu` 技术部署需要多个步骤:

- :ref:`install_vgpu_license_server`
- 在物理主机 ``zcloud`` 上 :ref:`install_vgpu_manager` ( 对于降级卡或者消费级GPU，需要采用 :ref:`vgpu_unlock` 解锁后才能配置 :ref:`vgpu` ) ，完成将拆分后的 ``vGPU`` 分别添加到 ``y-k8s-n-1`` 和 ``y-k8s-n-2``
- 在虚拟机内部 :ref:`install_vgpu_guest_driver`
