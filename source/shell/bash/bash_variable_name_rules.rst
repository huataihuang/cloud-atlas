.. _bash_variable_name_rules:

========================
Bash变量命名规则
========================

偶然发现我之前撰写的文档中，设置一个bash变量，使用了 ``-`` (减号)::

   mon-id="z-b-data-2"

我当时没有注意(可能也没有验证)，今天重复操作步骤的时候提示报错::

   -bash: mon-id=a-b-data-2: command not found

WHAT?

不就是简单的变量赋值么?

难道我的环境有问题(我一时还没有意识到之前的错误)，所以，尝试 ``export`` ::

   export mon-id="z-b-data-2"

提示错误::

   -bash: export: `mon-id=z-b-data-2': not a valid identifier

过一会，我才意识到之前的变量命名问题...

我一般在shell中使用变量命名都使用下划线 ``_`` 连接单词，但是不知道那次为何会使用了减号 ``-`` 。一般也很少改变编程风格，所以倒是没有注意居然有这种报错: 也就是变量名中如果有减号 ``-`` ，BASH会把它解释为命令而不是变量!!!

简单复习一下BASH的变量命名规则:

- 可以使用驼峰命名方法，例如 ``MonId``

- 可以使用下划线 ``_`` 但不能使用减号 ``-`` ，例如 ``mod_id``

- 可以混合数字，例如 ``mod_id_3`` 或者 ``mod_id3``

参考
=========

- `Bash Variable Name Rules: Legal and Illegal <https://linuxhint.com/bash-variable-name-rules-legal-illegal/>`_
