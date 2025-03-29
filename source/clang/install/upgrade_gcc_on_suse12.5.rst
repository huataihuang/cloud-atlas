.. _upgrade_gcc_on_suse12.5:

==============================
在SuSE 12 SP5中升级gcc
==============================

在 :ref:`build_glusterfs_11_for_suse_12` 遇到需要自己编译 `Userspace RCU <https://liburcu.org/>`_ ，但是这个库编译对Gcc有功能要求，需要支持 C++11 的功能。当前 :ref:`suse_linux` 12 SP5提供的编译工具链版本很低， `SLES 12 Toolchain Update Brings new Developer Tools <https://www.suse.com/c/sles-12-toolchain-update-brings-new-developer-tools/>`_ 说明了SUSE公司在2018年为SLES12系列发布了 GCC 7，带来了C++17支持。不过，这个Toolchain升级是通过 ``SUSE Linux Enterprise Server subscription``
提供的，感觉也比较麻烦。所以，我准备自己完成类似 :ref:`upgrade_gcc_on_centos7` 实现GCC升级。

从 `gcc mirror sites <https://gcc.gnu.org/mirrors.html>`_ 找一个最近的镜像网站，下载 10.5 版本

- 编译准备:

.. literalinclude:: upgrade_gcc_on_suse12.5/prepare_build_gcc
   :caption: 编译gcc准备(安装编译依赖)

- 编译安装gcc:

.. literalinclude:: upgrade_gcc_on_centos7/build_gcc
   :caption: 编译gcc
