.. _jetson_pycuda:

=======================
Jetson Nano安装pycuda
=======================

- 安装pip::

   apt install python3-pip

- 安装pycuda::

   pip3 install pycuda

报错::

   In file included from src/cpp/cuda.cpp:4:0:
   src/cpp/cuda.hpp:14:10: fatal error: cuda.h: No such file or directory
    #include <cuda.h>
             ^~~~~~~~
   compilation terminated.
   error: command 'aarch64-linux-gnu-gcc' failed with exit status 1

   ----------------------------------------
   Failed building wheel for pycuda

实际上CUDA的头文件已经安装在 ``/usr/local/cuda/targets/aarch64-linux/include/`` ，需要让编译make能够找到这些头文件。参考 `src/cpp/cuda.hpp:14:10: fatal error: cuda.h: No such file or directory <https://stackoverflow.com/questions/52195608/src-cpp-cuda-hpp1410-fatal-error-cuda-h-no-such-file-or-directory>`_ ，在 ``/etc/profile`` 中添加::

   export CUDA_HOME=/usr/local/cuda
   export CPATH=${CUDA_HOME}/include:${CPATH}
   export LIBRARY_PATH=${CUDA_HOME}/lib64:$LIBRARY_PATH

这里使用了 ``CPATH`` 变量而不是 ``C_INCLUDE_PATH`` ，因为这是一个更为通用的路径输出。我测试了使用 ``C_INCLUDE_PATH`` 报错依旧，似乎对于编译c++的 ``.cpp`` 应该使用 ``CPATH`` 。

参考
=======

- `pycuda installation failure on jetson nano <https://forums.developer.nvidia.com/t/pycuda-installation-failure-on-jetson-nano/77152>`_
- `PyCUDA官方文档 <https://documen.tician.de/pycuda/>`_
- `Setting up PyCUDA on Ubuntu 18.04 for GPU programming with Python <https://medium.com/leadkaro/setting-up-pycuda-on-ubuntu-18-04-for-gpu-programming-with-python-830e03fc4b81>`_ 这篇文档提供了快速验证pycuda的方法
