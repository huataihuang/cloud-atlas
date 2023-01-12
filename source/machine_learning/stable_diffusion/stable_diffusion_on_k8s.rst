.. _stable_diffusion_on_k8s:

===================================
在Kubernetes部署Stable Diffusion
===================================

在 :ref:`kubernetes` 上部署 :ref:`stable_diffusion_infra` (包括 `Stable Diffusion web UI <https://github.com/Sygil-Dev/sygil-webui>`_ 和 自动模型获取)，可以快速完成一个基于 :ref:`nvidia_gpu` (我使用 :ref:`tesla_p10` )的 :ref:`machine_learning` 案例。此外，我的部署在 :ref:`priv_cloud_infra` 构建的 :ref:`ovmf_gpu_nvme` 虚拟化，也验证了云计算方案。

功能
=======

- 自动模型获取
- 结合 :ref:`nvidia_gpu_operator` ，采用 :ref:`cuda` 库，具有多功能交互UI
- GFPGAN 用于人脸重建，RealESRGAN 用于超采样
- 文本倒置(Textual Inversion)

参考
======

- `Stable Diffusion on Kubernetes with Helm <https://github.com/amithkk/stable-diffusion-k8s>`_
