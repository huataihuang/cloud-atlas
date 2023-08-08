.. _ps:

=======================
ps进程检查工具
=======================

``ps`` 输出字段
====================

Linux/Unix 通常采用 System V ( ``ps -elf`` ) 或 BSD ( ``ps alx`` ) 风格 ``ps``

.. note::

   :ref:`ubuntu_linux` 使用 ``ps -elf`` 或 ``ps alx`` 都可以工作，但是输出字段有细微差异

   似乎 ``ps -elf`` 更为适合(输出字段中有 ``C`` 表明CPU使用率)

后续再学习


参考
======

- `About the output fields of the ps command in Unix <https://kb.iu.edu/d/afnv>`_ 非常清晰的 ``ps -o`` 参数字段快速查询，建议参考
