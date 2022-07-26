.. _cpu_frequency_governor:

======================
CPU频率调节器
======================

cpufreq governor
===================

- 检查 cpufreq governor :

.. literalinclude:: cpu_frequency_governor/cpupower_frequency-info
   :language: bash
   :caption: cpupower frequency-info 命令检查CPU主频伸缩策略

.. note::

   Ubuntu系统需要安装 ``linux-tools-common`` 软件包，然后执行 ``cpupower`` 命令会提示你按照内核版本安装对应工具包，例如我当前运行内核 ``5.4.0-121-generic`` ，提示安装 ``linux-tools-5.4.0-121-generic``

在我的 :ref:`hpe_dl360_gen9` 服务器上，输出案例:

.. literalinclude:: cpu_frequency_governor/cpupower_frequency-info_output
   :language: bash
   :caption: cpupower frequency-info 命令输出案例


参考
======

- `arch linux: CPU frequency scaling <https://wiki.archlinux.org/title/CPU_frequency_scaling>`_
