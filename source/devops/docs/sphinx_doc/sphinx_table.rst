.. _sphinx_table:

===================
Sphinx表格
===================

使用reStructured Text和Sphinx，可以有多种方法创建表格。在文档中使用表格，可以表现复杂的信息。

列表表格指令(List Table Directive)
=====================================

``.. list-table::`` 指令就是将常规的 ``list`` 转换成表格，每个表格有一定的列，以及指定表格列宽度的tag。

为了恰当地格式化，星号 ``*`` 标记每行必须是垂直对齐(align vertically)，而连字符 ``-`` 则表示每一列也要对齐。空白的单元必须记录，所以一行中每个列都需要标记，即使这个单元没有内容::

   .. list-table:: Title
      :widths: 25 25 50
      :header-rows: 1
   
      * - Heading row 1, column 1
        - Heading row 1, column 2
        - Heading row 1, column 3
      * - Row 1, column 1
        -
        - Row 1, column 3
      * - Row 2, column 1
        - Row 2, column 2
        - Row 2, column 3

则显示如下

.. list-table:: Title
   :widths: 25 25 50
   :header-rows: 1

   * - Heading row 1, column 1
     - Heading row 1, column 2
     - Heading row 1, column 3
   * - Row 1, column 1
     -
     - Row 1, column 3
   * - Row 2, column 1
     - Row 2, column 2
     - Row 2, column 3

CSV文件
===========

通常使用Excel比RST语法更容易创建表格，所以你可使用Excel将表格保存成CSV文件，然后在Sphinx的reStructured Text文件中引用这个CSV文件，就能够展示表格。

要使用CSV文件，则使用 ``.. csv-table::`` 指令，对于列宽度，则制定百分比(但是不需要 ``%`` 符号)，对于行头，则通常使用1::

   .. csv-table:: CSV案例展示
      :file: csv_example.csv
      :widths: 30, 30, 40
      :header-rows: 1

``csv_example.csv`` 文件内容:

.. literalinclude:: csv_example.csv
   :language: bash
   :linenos:
   :caption:

以上代码案例显示效果：

.. csv-table:: CSV案例展示
   :file: csv_example.csv
   :widths: 30, 30, 40
   :header-rows: 1

模拟表格
==========

- 还有一种简化表格，非常类似markdown所使用的表格方式::

   =====================  ======================================================
   参数                   说明
   =====================  ======================================================
   ``x``                  告诉tar解压缩
   ``-C <directory>``     tar在解压缩之前先进入指定 ``<directory>`` 目录
   ``--numeric-owner``    tar恢复文件的owner帐号数字，不匹配恢复系统的用户名帐号
   =====================  ======================================================

展现效果如下:

=====================  ======================================================
参数                   说明
=====================  ======================================================
``x``                  告诉tar解压缩
``-C <directory>``     tar在解压缩之前先进入指定 ``<directory>`` 目录
``--numeric-owner``    tar恢复文件的owner帐号数字，不匹配恢复系统的用户名帐号
=====================  ======================================================

Read the Docs Sphinx theme表格wrap
=====================================

Read the Docs Sphinx theme 有一个bug会导致表格单元中的文字不能换行，这导致出现带有水平滚动条的非常宽的表格。

可以通过定义CSS override来修复这个问题：

- 在文档源码目录下 ``_static`` 子目录下创建一个 ``theme_overrides.css`` :

.. literalinclude:: ../../../_static/theme_overrides.css
   :language: css
   :linenos:

- 修改文档源代码目录下 ``conf.py`` 配置文件添加如下配置选项:

.. literalinclude:: sphinx_table/conf.py
   :caption: 在 ``conf.py`` 配置文件设置CSS override

- 然后重新build文档，这样看到的文档表格文字就能自动换行。

参考
======

- `sublime and sphinx guide - Use Table <https://sublime-and-sphinx-guide.readthedocs.io/en/latest/tables.html>`_
- `Table width fix for Read the Docs Sphinx theme <https://rackerlabs.github.io/docs-rackspace/tools/rtd-tables.html>`_ 
