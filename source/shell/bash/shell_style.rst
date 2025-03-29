.. _shell_style:

==========================
Shell风格
==========================

我在最近的几次shell开发中，遇到过 :ref:`bash_variable_invalid_hyphen` 问题，这触发我在使用变量时更为谨慎。我在编程时，就在考虑如何将SHELL写得更规范清晰。

正好看到 `Google 开源项目风格指南 <https://zh-google-styleguide.readthedocs.io/en/latest/contents/>`_ 其中有一个篇章是关于 `Shell 风格指南 <https://zh-google-styleguide.readthedocs.io/en/latest/google-shell-styleguide/contents/>`_ ，篇幅不长，阅读以后发现:

- 其实日常编写SHELL的时候，已经不知不觉契合了Google的Shell风格指南(这可能是因为很多开源项目广泛采用，在模仿学习中也就习惯了)
- 但是我自己在编写SHELL的时候，没有强烈的意识去遵循Shell风格指南，所以开发的SHELL风格也在不断变化，有些脚本回头来看确实很丑陋
- Google的Shell风格指南符合很多普遍遵循的风格，所以采用时非常舒畅，可以用接近自己的编程习惯来采纳

.. note::

   我最初只是阅读 "命名约定" ，觉得深得我心。不过，完整阅读摘抄发现原文确实已经非常精炼，几乎是完整复制了。汗...

   多实践，实践可以将风格融入编程习惯中...

Google的使用Shell建议(采纳)
=============================

- 如果工作是 **调用其他工具** 并且做 **少量数据处理** ，建议使用shell快速完成
- 对性能有要求，不要使用 shell
- 需要处理复杂的数据，包括计算和格式化，应该使用 :ref:`python` ( 血泪：曾经编写shell处理大量的数据，随着功能需求增加，越来越难以维护，后期开发成本极高 )
- 编写超过100行的脚本，应该尽早转为 :ref:`python` 重写，越往后重写成本越高

文件扩展名和 ``SUID/SGID``
===========================

- 可执行文件(包括shell)建议没有扩展名(或使用 ``.sh`` 扩展名) : 我今后将不使用扩展名
- 库文件 **必须** 使用 ``.sh`` 作为扩展名，并且设置为 **不可执行** : 库文件不应直接运行，而只能被调用
- 禁止在shell脚本中使用 ``SUID/SGID`` : 存在严重风险

STDOUT vs STDERR
========================

.. note::

   所有错误信息都应该导向 ``STDERR``

推荐采用以下函数(赞)，将错误信息和其他状态信息一起打印出来:

.. literalinclude:: shell_style/stderr.sh
   :language: bash
   :caption: 使用err()函数处理错误信息和状态打印到STDERR

注释
===========

顶层注释
---------

- **每个文件的开头是其文件内容的描述**
- 每个文件 ``必须`` 包含一个顶层注释，对内容进行概述。版权声明和作者信息可选

举例:

.. literalinclude:: shell_style/head.sh
   :language: bash
   :caption: 每个shell文件开头必须包含顶层注释,对内容进行概述

函数注释
-----------

要求:

- 除非函数非常短且功能逻辑明显，否则必须注释
- 任何 **库函数** (反复调用的) 不论长短和复杂性都 ``必须注释``
- 注释必须达到: **无需阅读代码** 就能够学会如何使用你的程序或库函数

所有函数注释必须包含:

- 函数的描述
- 全局变量的使用和修改
- 使用的参数说明
- 返回值，而不是上一条命令运行后默认的退出状态

举例:

.. literalinclude:: shell_style/function_comment.sh
   :language: bash
   :caption: 函数注释案例

实现部分的注释
-----------------

实现部分注释是指代码中间的代码注释，建议:

- 不要注释所有代码
- 对复杂的算法注释
- 对包含技巧、不明显、有趣或者重要的部分进行注释(例如，对特殊数据的特别处理)
- 注释应该是简洁的，代码清晰且常规的部分不需要注释

TODO注释
-----------

- 使用TODO注释临时的、短期解决方案的、或者足够好但不够完美的代码。
- TODOs应该包含全部大写的字符串TODO，接着是括号中你的用户名。
- 最好在TODO条目之后加上 bug或者ticket 的序号。

举例:

.. literalinclude:: shell_style/todo_comment.sh
   :language: bash
   :caption: TODO注释案例

格式
========

缩进
---------

- 缩进两个空格，没有制表符
- 代码块之间使用空行以提升可读性
- 对于已有文件，保持已有的缩进格式

行的长度和长字符串
-----------------------

- 行的最大长度为 ``80`` 个字符
- 对于行长度超过80字符的，尽量使用 :ref:`here_document` 或者切入 ``换行符``

.. note::

   限制行的长度不仅是显示美化也是帮助开发者阅读(过长的代码行使人疲惫)

举例:

.. literalinclude:: shell_style/line.sh
   :language: bash
   :caption: 代码行长度保持不超过80字符的案例

管道
--------

- 如果一行容得下整个管道操作，建议将整个管道操作写在同一行
- 否则，应该将整个管道操作分割成每行一个管道；管道操作的下一部分应该将管道符号放在新的一行并且缩进2个空格
- 对于 ``||`` 和 ``&&`` 逻辑运算符也应该使用这种方式

举例:

.. literalinclude:: shell_style/pipeline.sh
   :language: bash
   :caption: 多个管道操作超出80个字符行限制，分割成多行，每行一个管道操作

循环
-----

- ``; do`` , ``; then`` 应该和 ``if/for/while`` 放在同一行
- ``else`` 单独一行
- 结束语句应该单独一行，并且和开始语句垂直对齐

举例:

.. literalinclude:: shell_style/loop.sh
   :language: bash
   :caption: 循环代码部分的风格举例

case语句
---------

- 使用2个空格缩进可选项
- 在同一行可选项的模式右圆括号之后和结束符 ``;;`` 之前各需要一个空格
- 长可选项或者多命令可选项应该被拆分成多行，模式、操作和结束符 ``;;`` 在不同的行 

举例:

.. literalinclude:: shell_style/case.sh
   :language: bash
   :caption: case代码部分的风格举例

- 如果整个表达式刻度，简单的命令可以跟模式和 ``;;`` 写在同一行: 通常是单字母选项的处理
- 如果单行容不下操作时，模式单独放一行，然后是操作，最后结束符 ``;;`` 也单独一行
- 当操作在同一行是，模式的右括号之后和结束符 ``;;`` 之前应该使用一个空格分隔

举例:

.. literalinclude:: shell_style/simplecase.sh
   :language: bash
   :caption: 简单的单行case代码的风格举例

变量扩展
----------

.. note::

   这里我简化了指南的摘要，我准备尽可能采用统一风格且选择清晰风格:

   以前我写变量，如果变量简单，则直接使用 ``$a`` ，如果变量复杂，则加上 ``{}`` ，例如 ``${var}_file.txt`` 

   为了能够更清晰，今后我写脚本，除 **单字符变量** 其他变量都使用 ``{}``

- 推荐使用 ``${var}`` 而不是 ``$var``
- 单个字符的shell特殊变量或者定位变量不要使用 ``{}`` 括号，其他所有变量建议使用大括号 ``{}``

举例:

.. literalinclude:: shell_style/var.sh
   :language: bash
   :caption: 变量风格举例

引用
---------

- ``" "`` (双引号)引用是扩展变量的， ``' '`` (单引号)引用不带扩展
- 建议引用单词的字符串，而不是命令选项或者路径名
- 千万 ``不要引用整数`` (整数引用后就是字符串了)
- 注意 ``[[`` 中模式匹配的引用规则
- 应该使用 ``$@`` 引用参数，除非有特殊原因需要使用 ``$*``

举例:

.. literalinclude:: shell_style/quota.sh
   :language: bash
   :caption: 引用案例

特性及错误
==================

命令替换
------------

- 应该使用 ``$(command)`` ，不建议使用反引号
- 嵌套的反引号要求用反斜杠转义内部的反引号。而 ``$(command)`` 形式嵌套时不需要改变，而且更易于阅读

举例:

.. literalinclude:: shell_style/command_substitution.sh
   :language: bash
   :caption: 命令替换案例，应该使用 $(command)

test，[和[[
---------------

- 推荐使用 ``[[ ... ]]`` ，而不是 ``[`` , ``test`` , 和 ``/usr/bin/[``
- 在 ``[[`` 和 ``]]`` 之间不会有路径名称扩展或单词分割发生，所以使用 ``[[ ... ]]`` 能够减少错误
- ``[[ ... ]]`` 允许正则表达式匹配，而 ``[ ... ]`` 不允许

举例:

.. literalinclude:: shell_style/test.sh
   :language: bash
   :caption: test测试语句

测试字符串
-------------

- 尽可能使用引用，而不是过滤字符串
- Bash能够在测试中处理空字符串，所以不要使用填充字符，以便代码易于阅读

举例:

.. literalinclude:: shell_style/test_string.sh
   :language: bash
   :caption: test测试字符串

管道导向while循环
--------------------

.. note::

   这段理解需要实践

- 使用过程替换或者for循环，而不是管道导向while循环: 在while循环中被修改的变量是不能传递给父shell的，因为循环命令是在一个子shell中运行的。

- 管道导向while循环中的隐式子shell使得追踪bug变得很困难:

.. literalinclude:: shell_style/bad_pipeline_while.sh
   :language: bash
   :caption: 不建议使用管道导向while循环

- 如果你确定输入中不包含空格或者特殊符号（通常意味着不是用户输入的），那么可以使用一个for循环:

.. literalinclude:: shell_style/for_loop_check_value.sh
   :language: bash
   :caption: 使用for循环命令输出中是否包含值

- 使用过程替换允许重定向输出，但是请将命令放入一个显式的子shell中，而不是bash为while循环创建的隐式子shell:

.. literalinclude:: shell_style/while_read.sh
   :language: bash
   :caption: 使用while循环命令

- 当不需要传递复杂的结果给父shell时可以使用while循环，但是复杂解析建议使用 :ref:`awk` :

.. literalinclude:: shell_style/while_read_simple.sh
   :language: bash
   :caption: 使用while循环命令处理简单结果

算术
=======

- 总是使用 ``((...))`` 或者 ``$((...))`` ，避免使用 ``let`` 或者 ``$[...]`` 或者 ``expr``
- 永远不要使用 ``$[...]`` 语法，以及 ``expr`` 命令或者内建的 ``let``
- ``<`` 和 ``>`` 不在 ``[[ …  ]]`` 表达式中执行数值比较（它们执行字典顺序比较；请参阅测试字符串）。根据偏好，根本不要使用 ``[[ …  ]]`` 进行数字比较，而是使用 ``(( …  ))``
- 建议避免将 ``(( …  ))`` 用作独立语句，否则要警惕其表达式的计算结果为零，例如:

  - 在启用 ``set -e`` 情况下，如 ``set -e; i=0; (( i++ ))`` 会导致shell退出

.. literalinclude:: shell_style/arithmetic.sh
   :language: bash
   :caption: 算术脚本案例


命名约定
========

函数名
----------

- 函数名使用小写字母，并且使用下划线分隔单词( 不要使用 ``-`` ，类似变量不能包含 ``-`` ，风格统一 )
- 使用双冒号 ``::`` 分隔库
- 函数名之后 **必须** 有圆括号； (我准备)不使用(可选的) ``function`` 关键字

  - 当函数名后面存在 ``()`` 时，关键字 ``function`` 是多余的，但是促进了函数的快速识别
  
- 第一个大括号必须和函数名位于同一行，并且函数名和圆括号之间没有空格

举例:

.. literalinclude:: shell_style/function.sh
   :language: bash
   :caption: 函数举例

变量名
-----------

- 变量名的命名方法和函数名一样:小写字母，并使用下划线分隔单词
- 循环的变量名应该和循环的任何变量同样命名

举例:

.. literalinclude:: shell_style/variable.sh
   :language: bash
   :caption: 变量举例

常量和环境变量名
--------------------

- 常量和环境变量名应全部大写，用下划线分隔，声明在文件的顶部

举例:

.. literalinclude:: shell_style/constant_env.sh
   :language: bash
   :caption: 常量和环境变量

- 只读变量应该使用 ``readonly`` 修饰
- 第一次设置就变成常量( 例如通过 ``getopts`` )，则应该立即将其设为只读:

.. literalinclude:: shell_style/readonly_variable.sh
   :language: bash
   :caption: 只读变量

- 在函数中 ``declare`` 不会对全局变量进行操作。所以推荐使用 ``readonly`` 和 ``export`` 来代替

源文件名
-----------

- 文件名使用小写，需要的话使用下划线分隔单词: 例如，使用 ``maketemplate`` 或者 ``make_template`` ，而不是 ``make-template``

只读变量
----------

- 使用 ``readonly`` 或者 ``declare -r`` 来确保变量只读
- 因为全局变量在shell中广泛使用，所以在使用它们的过程中捕获错误是很重要的。当声明了一个变量，希望其只读，那么明确指出。 

举例:

.. literalinclude:: shell_style/readonly_variable_sample.sh
   :language: bash
   :caption: 只读变量举例

使用本地变量
--------------

- 使用 ``local`` 声明特定功能的变量。声明和赋值应该在不同行
- 使用 ``local`` 来声明局部变量以确保其只在函数内部和子函数中可见。这避免了污染全局命名空间和不经意间设置可能具有函数之外重要性的变量。
- 当赋值的值由命令替换提供时，声明和赋值必须分开。因为内建的 ``local`` 不会从命令替换中传递退出码。

举例:

.. literalinclude:: shell_style/local_variable.sh
   :language: bash
   :caption: 本地变量举例

函数位置
-----------

- 将文件中所有的函数一起放在常量下面
- 不要在函数之间隐藏可执行代码
- 只有 ``includes`` ， ``set`` 声明和常量设置可能在函数声明之前完成

主函数main
---------------

- 对于包含至少一个其他函数的足够长的脚本，需要称为 ``main`` 的函数
- 为了方便查找程序的开始，将主程序放入一个称为 ``main`` 的函数，作为最下面的函数
- 文件中最后的非注释行应该是对 main 函数的调用

::

   main "$@"

线性流的短脚本， ``main`` 是矫枉过正，因此是不需要的

调用命令
=========

检查返回值
------------

- 调用命令总是要检查返回值，并给出信息

- 对于非管道命令，使用 ``$?`` 或者直接通过 ``if`` 语句来检查以保持脚本简洁

举例:

.. literalinclude:: shell_style/call.sh
   :language: bash
   :caption: 调用命令必须检查返回值的案例

.. note::

   请注意Google的shell编程案例，对每个命令执行都要判断返回值并做相应处理，否则脚本可能会有异常。这个编程风格非常重要

- Bash 有 ``PIPESTATUS`` 变量，允许检查从管道所有部分返回的代码，如果仅检查整个管道是成功还是失败，可以使用以下方法:

.. literalinclude:: shell_style/check_pipeline.sh
   :language: bash
   :caption: 检查管道是否成功的案例(注意只能知道整个管道的结果)

.. warning::

   只要运行其他任何命令 ``PIPESTATUS`` 就会被覆盖，所以如果要知道管道中发生的错误执行对应操作，一定要在运行管道命令之后立即将 ``PIPESTATUS`` 赋值另一个变量( 注意: ``[`` 是一个会将 ``PIPESTATUS`` 擦除的命令，也就是隐含的 ``test`` ):

.. literalinclude:: shell_style/check_papstatus.sh
   :language: bash
   :caption: 检查管道的PIPESTATUS一定要在管道后立即保存变量，否则检测失效

SHELL内建命令和外部命令
--------------------------

- 如果能使用内部命令，则建议使用内部命令，这样脚本更强健和更具移植性

举例:

.. literalinclude:: shell_style/buildin_external_commands.sh
   :language: bash
   :caption: 内建命令和外部命令案例


参考
=========

- `Shell 风格指南 <https://zh-google-styleguide.readthedocs.io/en/latest/google-shell-styleguide/contents/>`_ 中文版和最新的英文原版有一些差异，以英文原版为准
- `Shell Style Guide <https://github.com/google/styleguide/blob/gh-pages/shellguide.md>`_
- Google在 `Google Style Guide <https://google.github.io/styleguide/>`_ 提供了更为丰富的编程风格指南，如果你有对应语言开发可以直接阅读原文参考
