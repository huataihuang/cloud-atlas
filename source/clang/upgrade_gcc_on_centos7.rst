.. _upgrade_gcc_on_centos7:

===========================
升级CentOS 7 GCC
===========================

:ref:`build_pcm` 使用了 `simdjson(Github) <https://github.com/simdjson/simdjson>`_ ，而 ``simdjson`` 需要使用现代化的编译器(LLVM clang 6 or better, GNU GCC 7.4 or better, Xcode 11 or better)。在CentOS 7环境，默认的 gcc 4.8.5 无法 :ref:`build_pcm` ，所以升级

从 `gcc mirror sites <https://gcc.gnu.org/mirrors.html>`_ 找一个最近的镜像网站，下载 10.5 版本

- 编译准备:

.. literalinclude:: upgrade_gcc_on_centos7/prepare_build_gcc
   :caption: 编译gcc准备(安装编译依赖)

- 编译安装gcc:

.. literalinclude:: upgrade_gcc_on_centos7/build_gcc
   :caption: 编译gcc

参考
======

- `build gcc from source on centos 7 <https://www.jwillikers.com/build-gcc-from-source-on-centos-7>`_
