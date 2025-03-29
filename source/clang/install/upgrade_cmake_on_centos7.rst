.. _upgrade_cmake_on_centos7:

=========================
在CentOS 7环境升级CMake
=========================

我在 :ref:`build_pcm` 遇到一个问题，就是编译需要使用 ``cmake`` 3.5以上版本，而CentOS 7全系列使用的是 cmake 2.8

编译
=======

- 编译准备(安装一些编译依赖):

.. literalinclude:: upgrade_cmake_on_centos7/prepare_build_cmake
   :caption: 编译cmake准备

- 编译 cmake 3.26.4

.. literalinclude:: upgrade_cmake_on_centos7/build_cmake
   :caption: 编译cmake
