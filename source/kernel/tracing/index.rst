.. _linux_tracing:

=================================
Linux内核追踪
=================================

作为Linux系统运维人员，会遇到各种线上性能问题和异常故障，需要通过Linux内核debug方式，通过蛛丝马迹找寻出异常根源。

近期在排查生产环境的性能问题，我准备系统整理一下以前在阿里云工作时积累的内核debug文档，并在此基础上做一进步探索

.. toctree::
   :maxdepth: 1

   sysrq.rst
   find_high_sys_process.rst
   debug_high_sys_process.rst
   debug_d_process.rst
   bad_rip_value.rst
   debug_system_crash.rst
   kdump/index

.. only::  subproject and html

   Indices
   =======

   * :ref:`genindex`
