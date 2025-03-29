.. _install_nvidia_container_toolkit_for_docker:

============================================
为Docker安装NVIDIA Container Toolkit
============================================

准备工作
===========

在部署NVIDIA Container Toolkit之前

- 首先 :ref:`install_nvidia_linux_driver_in_ovmf_vm` (比较波折，请参考我的实践记录)

- 检查系统确保满足:

  - NVIDIA Linux drivers 版本 >= 418.81.07
  - 内核要求 > 3.10
  - Docker >= 19.03
  - NVIDIA GPU架构 >= Kepler

:ref:`docker`
===================

- 使用Docker官方脚本安装Docker-CE:

.. literalinclude:: ../../docker/startup/install_docker_linux/install_docker_ce_by_script
   :language: bash
   :caption: 使用Docker官方安装脚本安装Docker-CE

待续...

参考
========

- `NVIDIA Cloud Native Documentation: Installation Guide >> Docker <https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html#docker>`_
