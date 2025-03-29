.. _amd_rocm_gpu_in_kvm:

========================
在KVM中使用AMD ROCm GPU
========================

当前我使用的MacBook Pro是2018年版本，支持完善的Intel虚拟化技术，并且内建了一块独立GPU: ``AMD Radeon Pro 555X 4 GB`` ，我的目标是在Linux的kvm虚拟化中使用这块GPU实现machine learning。

参考
=======

- `AMD ROCm GPU support for TensorFlow <https://medium.com/tensorflow/amd-rocm-gpu-support-for-tensorflow-33c78cc6a6cf>`_
- `Try Deep Learning in Python now with a fully pre-configured VM <https://medium.com/@ageitgey/try-deep-learning-in-python-now-with-a-fully-pre-configured-vm-1d97d4c3e9>`_
