.. _fedora_dev_c:

==========================
Fedora环境开发C应用
==========================

Fedora提供了GCC和CLANG的支持

GCC
======

- 安装gcc:

.. literalinclude:: fedora_dev_c/dnf_gcc
   :caption: 安装gcc

编译:

.. literalinclude:: fedora_dev_c/gcc_compile
   :caption: gcc编译程序

如果需要在64位Fedora上编译32位执行程序，则还需要安装32位兼容库:

.. literalinclude:: fedora_dev_c/dnf_32bit
   :caption: 安装32位编译兼容库

编译32位程序:

.. literalinclude:: fedora_dev_c/gcc_compile_32
   :caption: gcc编译32位程序

CLANG
=======

- 安装clang

.. literalinclude:: fedora_dev_c/dnf_clang
   :caption: 安装CLANG

编译:

.. literalinclude:: fedora_dev_c/clang_compile
   :caption: clang编译程序


参考
======

- `Fedora developer: C <https://developer.fedoraproject.org/tech/languages/c/c_installation.html>`_
