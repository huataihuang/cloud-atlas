.. _vim_autocompletion:

=============================
vim Autocompletion(自动完成)
=============================

内置Autocompletion
====================

vim的当前版本内置了autocomplete功能，通过检查当前缓存中可用词汇来实现。注意，这个自动完成功能是大小写敏感的。

vim的autocomplete启用是通过 ``ctrl-n`` 来触发激活，此时会看到一系列提示词汇，反向循环列表则按 ``ctrl-p``

Omnicompletion
===================

:ref:`vimrc` 集成了 :ref:`omnicompletion` 提供编程智能自动完成功能。

supertab
===============

`supertab <https://github.com/ervandew/supertab>`_ 可以使用 ``<Tab>`` 来插入自动完成



参考
======

- `Autocompletion Support in Vim <https://www.baeldung.com/linux/vim-autocomplete>`_
- `How to Select Vim Code Completion for Any Language <https://www.tabnine.com/blog/vim-code-completion-for-any-language/>`_
