.. _dl360_config_mem:

===============================
HPE DL360 Gen9服务器内存配置
===============================

.. _hpe_dl360_gen9_memory:

HP DL360 Gen9 内存安装
=============================

根据HP的文档 :ref:`hpe_dl360_gen9` 是 4个 Channel ，所以官方文档推荐安装内存条的时候，要按照 ``ABCDEFGHIJKL`` 顺序安装(其实就是先安装白色槽，其次是黑色，最后是绿色)，见下图(参考 `Help with HP DL360 Gen9 memory configuration <https://www.reddit.com/r/homelab/comments/xt37v6/help_with_hp_dl360_gen9_memory_configuration/>`_ )，这样才能确保内存通道均衡:

.. figure:: ../../../../_static/linux/server/hardware/hpe/hpe_dl360_gen9_memory.webp

   HPE DL360 Gen9 内存插槽顺序

安装要点
==========

- :ref:`hpe_dl360_gen9` 是SMP对称双处理器服务器，所以内存必须成对添加(平衡DIMM内存): 也就是按照 ``CPU1[A,B,C,D], CPU2[A,B,C,D]`` 顺序两条 ``AA`` ，两条 ``BB`` 这样依次完成安装
- 每个处理器至少需要一个 DIMM 内存，且只有安装了相应处理器才能安装 DIMM 内存
- 在通道内从负载最重（四列）到负载最轻（单列）填充 DIMM: 通道内负载最重（列数最多的 DIMM）距离处理器最远
- 不要混合使用 RDIMM 或 LRDIMM
- 可以按任意顺序混合使用不同速度的 DIMM；服务器将选择一个通用的最佳速度
- 每个处理器有四 (4) 个内存通道；每台 2 处理器服务器有八 (8) 个通道
- 每个内存通道有三 (3) 个 DIMM 插槽；每台 2 处理器服务器共有二十四 ( ``24`` ) 个插槽

参考
========

- `HPE ProLiant DL360 Gen9 Server - Configuring Memory <https://support.hpe.com/hpesc/public/docDisplay?docId=emr_na-c05241599>`_
- `Help with HP DL360 Gen9 memory configuration <https://www.reddit.com/r/homelab/comments/xt37v6/help_with_hp_dl360_gen9_memory_configuration/>`_
