.. _here_document:

===================
here document
===================

.. note::

   在很多shell场合中，我们需要根据模版来替换一些变量。我曾经做过很多次使用 ``sed`` 完成变量替换。但是， :ref:`priv_deploy_etcd_cluster_with_tls_auth` 时，我突然意识到，实际上SHELL实际上早已内置了变量替换功能，只是我一直没有意识到(虽然已经使用过很多次)，那就是 ``here document`` 。这里我来总结一下 ``here document`` 并说明如何使用这个变量替换。

什么是Here Document
=====================

``Here Document`` 是Linux Shell 中的一种特殊的重定向方式，它的基本的形式如下::

    cmd << delimiter
       Here Document Content
    delimiter

它的作用就是将两个 ``delimiter`` (分隔符) 之间的内容(Here Document Content 部分) 传递给cmd 作为输入参数。比如在终端中输入 ``cat << EOF``  ，系统会提示继续进行输入，输入多行信息再输入EOF，中间输入的信息将会显示在屏幕上。

**注意** :

- ``EOF`` 只是一个标识而已，可以替换成任意的合法字符
- 作为结尾的delimiter一定要顶格写，前面不能有任何字符
- 作为结尾的delimiter后面也不能有任何的字符（包括空格）
- 作为起始的delimiter前后的空格会被省略掉

Here Document 不仅可以在终端上使用，在shell 文件中也可以使用，例如下面的 ``here.sh`` 文件::

   cat << EOF > output.sh
   echo "hello"
   echo "world"
   EOF

使用 ``sh here.sh`` 运行这个脚本文件，会得到 ``output.sh`` 这个新文件，里面的内容如下::

   echo "hello"
   echo "world"

通常可以在一个shell脚本中采用上述方法生成新的脚本，这样就可以拆分脚本到多个子脚本进行不同的功能实现

delimiter 与变量
==================

.. note::

   ``关键点`` 来了

可以看到上文中我提到了采用 ``here document`` 来形成新的脚本，事实上我也经常这样做。但是，既然是脚本就会使用变量，那么我们把上面的那段 ``here.sh`` 脚本修改成使用变量会如何呢::

   cat << EOF > output.sh
   echo "This is output"
   ehco $1
   EOF

此时执行::

   ./here.sh HereDocument

则此时可以看到变量 ``$1`` 被展开，也就是最后形成的 ``output.sh`` 内容如下::

   echo "This is output"
   echo HereDocument

问题来了，如果我就是想最后生成的脚本 ``output.sh`` 是::

   echo "This is output"
   echo $1

该怎么搞呢？难道我运行  ``here.sh`` 脚本不传递参数就可以么？我们来试试  ``./here.sh`` ，再看一下生成的 ``output.sh`` 脚本内容::

   echo "This is output"
   echo

哦，因为没有传递参数 ``$1`` 是空的，生成的新脚本 ``output.sh`` 展开了变量，只给我留下了一行 ``echo`` 。这不符合我的预想

**如果不想展开变量** 可以在 ``delimiter`` 的前后添加 ``"`` 来实现，也就是 ``here.sh`` 脚本修改成::

   cat << "EOF" > output.sh   #注意引号
   echo "This is output"
   echo $1
   EOF

则再次执行 ``./here.sh`` ，就会看到生成的 ``outpush.sh`` 脚本内容::

  echo "This is output"
  echo $1

.. note::

   实际案例请参考 :ref:`priv_deploy_etcd_cluster_with_tls_auth`

参考
======

- `linux shell 的here document 用法 (cat << EOF) <http://my.oschina.net/u/1032146/blog/146941>`_
- `How does cat << EOF work in bash? <http://stackoverflow.com/questions/2500436/how-does-cat-eof-work-in-bash>`_
