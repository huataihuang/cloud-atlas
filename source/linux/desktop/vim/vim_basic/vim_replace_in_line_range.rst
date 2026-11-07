.. _vim_replace_in_line_range:

=============================
vim在指定行范围内替换
=============================

今天在编写程序时想要 **替换光标所在行以及下面2行(共计3行)的某个字符** (案例是将 ``name`` 替换为 ``full_name`` ) ，替换前:

.. literalinclude:: vim_replace_in_line_range/before.py
   :language: python
   :caption: 替换前的代码
   :emphasize-lines: 4-6

替换后:

.. literalinclude:: vim_replace_in_line_range/after.py
   :language: python
   :caption: 替换后的代码
   :emphasize-lines: 4-6

使用指令:

.. literalinclude:: vim_replace_in_line_range/command
   :caption: 替换命令

命令解析:

- ``.`` 表示当前行
- ``,`` 表示"从...到"
- ``.+2`` 表示从当前行+2行
- 那么推算下来 ``.,.+2`` 就表示 **一共3行**
- ``s`` 表示subsitute(替换)
- ``\<`` 和 ``\>`` 表示 **精确匹配单词(Word boundaries)** 防止把其他包含 ``name`` 这四个字母的更长的字符串也误改了
- ``g`` 表示global(全局)，也就是这3行中多次出现的 ``name`` 字符串全部被替换。如果不加 ``g`` 每行就只会替换第一个遇到的 ``name`` 字符串
