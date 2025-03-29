.. _sponge:

===============
sponge
===============

``sponge`` 英文意思是 ``海绵`` ，有一个著名的动画 `海绵宝宝 SpongeBob <https://movie.douban.com/subject/1456579/>`_ :

.. figure:: ../../_static/shell/utils/SpongeBob.jpg

   著名动画 「海绵宝宝 SpongeBob」

``sponge`` 工具命令包含在 ``moreutils`` 软件包中，通常在 :ref:`ubuntu_linux` 需要单独安装:

.. literalinclude:: sponge/apt_install_moreutils
   :caption: 在 :ref:`ubuntu_linux` 中通过安装 ``moreutils`` 获得 ``sponge`` 工具

为什么叫 ``sponge`` (海绵)呢? 原因是这个工具提供了类似 ``soak up`` (吸干) 功能:

使用 ``sponge``
===================

``sponge`` 命令没有任何命令选项，唯一接受的参数是一个文件名: 例如，你可以输入 ``sponge newfile.txt`` 。

回车以后，你会看到终端等待你输入，你可以输入任意行内容，直到你按下 ``ctrl+d`` ( **EOF** ) 表示结束输入。

接下来，你就会在当前目录看到一个文件 ``newfile.txt`` ，内容就是你刚才在屏幕终端输入的内容。

那么，你会问，这有什么用处，我不能用 ``shell重定向`` 来实现同样的功能么?

``sponge`` 命令 vs ``shell重定向``
====================================

``sponge`` 命令的真正威力是结合管道 ``pipe`` 来使用

- 以下是一个简单 ``sponge`` 和 ``shell重定向`` 案例:

.. literalinclude:: sponge/sponge_vs_shell_redirection
   :language: bash
   :caption: ``sponge`` 和 ``shell重定向`` 案例

粗看似乎没有区别...

如果你经常编写shell，就会知道，当一个重定向( ``redirect`` )打开一个文件写入，然后又从 ``stream`` 流读取内容到重定向管道，就会破坏文件:

.. literalinclude:: sponge/grep_file_example
   :language: bash
   :caption: ``grep`` 一个文件的案例

可以看到 ``grep -v '^#'`` 可以过滤出文件中没有 ``#`` 注释的内容

但是，如果把上面 ``grep`` 输出到标准输出(终端)的内容再重定向到被过滤文件的自身，就会看到文件内容完全被清空了(并不是像你想象的那样去除#注释，保留正式内容):

.. literalinclude:: sponge/grep_file_redirect_itself
   :language: bash
   :caption: ``grep`` 一个文件又重定向回这个文件自身会清空文件
   :emphasize-lines: 2,4

所以，很多时候对上述情况，我们会采用一个中间临时文件来存储 ``grep`` 过滤中间结果，处理外后再复制回源文件:

.. literalinclude:: sponge/grep_file_tmp
   :language: bash
   :caption: ``grep`` 内容到临时文件，再将处理后文件复制回源文件

很麻烦，不是么？

现在有请 ``sponge`` 出场:

.. literalinclude:: sponge/grep_file_pipe_sponge
   :language: bash
   :caption: 使用管道结合 ``sponge`` 可以重定向回源文件而且不破坏内容

参考
======

- `Linux Sponge - Soak Up Standard Input and Write to a File <https://www.putorius.net/linux-sponge-soak-up-standard-input-and-write-to-a-file.html>`_
