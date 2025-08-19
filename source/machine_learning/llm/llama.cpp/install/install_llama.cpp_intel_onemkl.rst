.. _install_llama.cpp_intel_onemkl:

===============================
Intel oneMKL架构安装LLaMA.cpp
===============================

LlaMA可以通过Intel OneAPI来支持 ``avx_vnni`` 指令扩展，不过根据 `Wikipedia: Advanced Vector Extensions <https://en.wikipedia.org/wiki/Advanced_Vector_Extensions>`_ ，这个指令需要 ``Alder Lake`` 微处理器架构(2021年11月的第12代处理器才支持)，看来我的古老 :ref:`xeon_e` / :ref:`xeon_e5` 都无缘尝试这项技术了。有待后续有机会再实践。

参考
======

- `Optimizing and Running LLaMA2 on Intel® CPU <https://www.intel.com/content/www/us/en/content-details/791610/optimizing-and-running-llama2-on-intel-cpu.html>`_
