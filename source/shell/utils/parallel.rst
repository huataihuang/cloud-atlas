.. _parallel:

=====================
parallel
=====================

要想让Linux命令使用所有的CPU内核，我们需要用到GNU ``parallel`` 命令，它让我们所有的CPU内核在单机内做神奇的map-reduce操作，当然，这还要借助很少用到的 ``–pipes`` 参数(也叫做 ``–spreadstdin`` )。这样，你的负载就会平均分配到各CPU上。

bzip2
===========

::

   cat bigfile.bin | bzip2 --best > compressedfile.bz2

改进成::

   cat bigfile.bin | parallel --pipe --recend '' -k bzip2 --best > compressedfile.bz2

grep
========

如果你有一个非常大的文本文件，以前你可能会这样::

   grep pattern bigfile.txt

现在可以改进成::

   cat bigfile.txt | parallel --pipe grep 'pattern'

或者::

   cat bigfile.txt | parallel --block 10M --pipe grep 'pattern'

这第二种用法使用了 ``–block 10M`` 参数，这是说每个内核处理1千万行——你可以用这个参数来调整每个CUP内核处理多少行数据。

awk
========

用awk命令计算一个非常大的数据文件的例子，常规方法::

   cat rands20M.txt | awk '{s+=$1} END {print s}'

可以改进成::

   cat rands20M.txt | parallel --pipe awk \'{s+=\$1} END {print s}\' | awk '{s+=$1} END {print s}'

这个有点复杂：parallel命令中的 ``--pipe`` 参数将cat输出分成多个块分派给awk调用，形成了很多子计算操作。这些子计算经过第二个管道进入了同一个awk命令，从而输出最终结果。第一个awk有三个反斜杠，这是GNU parallel调用awk的需要。

wc
======

想要最快的速度计算一个文件的行数吗？

传统做法::

   wc -l bigfile.txt

现在可以改进成::

   cat bigfile.txt | parallel  --pipe wc -l | awk '{s+=$1} END {print s}'

非常的巧妙，先使用parallel命令 ``mapping`` 出大量的 ``wc -l`` 调用，形成子计算，最后通过管道发送给awk进行汇总。

sed
=======

想在一个巨大的文件里使用sed命令做大量的替换操作吗？

常规做法::

   sed s^old^new^g bigfile.txt

现在可以改进成::

   cat bigfile.txt | parallel --pipe sed s^old^new^g

可以使用管道把输出存储到指定的文件里

并发图像转换
===============

我在 :ref:`sphinx_image` 需要转换图像格式到 ``webp`` ，在stackoverflow上找到一个使用 ``parallel`` 批量转换的巧妙方法记录如下:

- 将目录下大量的 ``webp`` 图像转换成 ``png`` ::

   parallel dwebp {} -o {.}.png

这里 ``{.}` 表示原文件名后缀去除，也就是 ``image.webp`` 转换后的文件名是 ``image.png`` 而不是 ``image.webp.png``

- 如果有大量子目录，则改成::

   find . -name "*.webp" -print0 | parallel -0 dwebp {} -o {.}.png

参考
=====

- `如何利用多核CPU来加速你的Linux命令 — awk, sed, bzip2, grep, wc等 <http://www.vaikan.com/use-multiple-cpu-cores-with-your-linux-commands/>`_
- `GNU Parallel Tutorial <https://www.gnu.org/software/parallel/parallel_tutorial.html>`_
- `Convert WEBP images to PNG by Linux command <https://stackoverflow.com/questions/55161334/convert-webp-images-to-png-by-linux-command>`_
