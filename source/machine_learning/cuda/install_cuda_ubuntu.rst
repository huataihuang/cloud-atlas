.. _install_cuda_ubuntu:

==========================
在Ubuntu安装NVIDIA CUDA
==========================

实践记录:

- :ref:`install_nvidia_linux_driver` 物理主机安装CUDA driver
- :ref:`install_nvidia_linux_driver_in_ovmf_vm` 虚拟机内部安装CUDA driver
- :ref:`nvidia_p4_pi_docker` 树莓派ARM架构Ubuntu环境安装CUDA driver成功，但是实践也发现 :ref:`nvidia-driver_pi_os` (Raspberry Pi OS虽然是debian变种，但是实际上无法正常编译安装CUDA驱动) 失败
- :ref:`bhyve_ubuntu_tesla_p4_docker` 在 :ref:`freebsd` 的 :ref:`bhyve` 虚拟化环境中运行Ubuntu，来构建一个运行 :ref:`ollama` 

参考
=====

- `NVIDIA CUDA Installation Guide for Linux <https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html>`_
- `How to Install Nvidia Drivers on Ubuntu 20.04 <https://phoenixnap.com/kb/install-nvidia-drivers-ubuntu>`_
- `How to install the NVIDIA drivers on Ubuntu 20.04 Focal Fossa Linux <https://linuxconfig.org/how-to-install-the-nvidia-drivers-on-ubuntu-20-04-focal-fossa-linux>`_
- `kmhofmann/installing_nvidia_driver_cuda_cudnn_linux.md <https://gist.github.com/kmhofmann/cee7c0053da8cc09d62d74a6a4c1c5e4>`_
