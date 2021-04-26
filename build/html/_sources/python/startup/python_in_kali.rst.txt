.. _python_in_kali:

==========================
在Kali Linux中使用Python
==========================

在 :ref:`kali_linux` 中，默认系统为了兼容性提供的是Python 2，在终端登陆时会提示::

   We have kept /usr/bin/python pointing to Python 2 for backwards
    compatibility. Learn how to change this and avoid this message:
    ⇒ https://www.kali.org/docs/general-use/python3-transition/

根据官方文档，Kali Linux已经完全切换到 Python 3，所以任何工具如果还使用Python 2就必须转换使用Python 3，或者就被舍弃掉了。

不过，debian将Python 3使用 ``/usr/bin/python3`` 作为解释器入口，如果你的脚本依然使用 ``python2`` 执行包，需要修订解释器，否则会出现报错::

   zsh: /home/kali/test.py: bad interpreter: /usr/bin/python: no such file or directory

这是因为debian并不提供 ``/usr/bin/python`` 作为软链接以避免更新问题。

为避免上述报错，Kali依然提供了默认 Python 2作为解释器，并提供了 ``/usr/bin/python`` 软链接指向 ``python2`` ::

   ➜  ~ ls -lh /usr/bin/python
   lrwxrwxrwx 1 root root 7 Mar  2 19:44 /usr/bin/python -> python2

但是，pip for Python2 (也就是 ``python-pip`` )已经没有了，查看 ``/usr/bin/pip`` 可以看到解释器实际上是 ``/usr/bin/python3`` ，也就是通过 ``pip`` 安装的所有模块都是 ``python3`` 模块。

上述兼容是通过 ``kali-linux-headless`` 建议的 ``python2`` ``python-is-python2`` 和 ``offsec-awae-python2`` 来实现的，所以默认安装。对于用户希望去除python2则可以删除。

切换到Python3
================

- 通过删除 ``python-is-python2`` 可以消除掉上述提示信息::

   sudo apt remove python-is-python2

- 如果你希望转为完全使用Python 3，则安装 ``python-is-python3`` ::

   sudo apt install -y python-is-python3

- 如果你依然希望默认的 ``/usr/bin/python`` 指向 ``python2`` 但是关闭上述警告提示，则可以手工操作::

   mkdir -p ~/.local/share/kali-motd
   touch ~/.local/share/kali-motd/disable-old-python-warning

我的实践
----------

我在 :ref:`kali_linux` 环境中决定完全使用Python 3，所以我执行安装 ``python-is-python3`` ::

   sudo apt install -y python-is-python3
   
这个安装将会卸载掉 ``python-is-python2`` 软件包，安装以后执行 ``python`` 命令可以看到默认python已经是 python 3 了。对于日常运行使用没有影响。

如何运行Python 2脚本
=====================

对于依然是Python 2的脚本，Kali Linux提供了一个 ``offsec-awae-python2`` 兼容包，这样就可以使用 ``pyenv`` 来设置一个完全隔离的Python 2环境，然后使用 pip 来安装相应 模块，请参考 `Using EoL Python versions on Kali <https://www.kali.org/docs/general-use/using-eol-python-versions/>`_
