.. _introduce_asciinema:

=====================
asciinema简介
=====================

asciinema是一个非常巧妙并且对于使用终端维护服务器的工作者非常有用的工具，它的作用就是记录终端中交互的操作，然后提供记录回放(不仅可以本地回放也可以共享到服务器上回放):

- 非常酷的功能: 不是截图、不是录屏，完全是字符的输入输出
- 可以将终端操作分享给别人学习参考，例如，在撰写自己的 :ref:`cloud_atlas` ，可以把自己的终端操作生动地展示给每一个访问我网站的人

`asciinema.org <https://asciinema.org>`_ 开发的asciinema提供了一个开源终端会话记录和通过web分享的解决方案，并且其服务器 `asciinema-server <https://github.com/asciinema/asciinema-server>`_ 也是开源软件，用户可以部署自己企业内部的终端会话共享服务。当然，如果是完全开放的记录，也可以通过公共的asciinema服务器对外展示。

asciienma项目通过以下3个组件来工作：

- 命令行记录终端会话内容 ``asciinema``
- asciinema.org网站提供的API - 提供分享托管
- javascript播放器 - 重放会话



asciinema工作原理
===================

当你使用 ``ssh`` ``screen`` 或者 ``script`` 命令时，这些命令实际上都使用了UNIX系统的 ``pseudo-terminal`` 功能。

所谓 ``pseudo-terminal`` (伪终端) 也称为 ``PTY`` ``pseudotty`` ，是一对 ``pseudo-devices`` ，其中slave端模拟一个硬件文本终端设备，而另一端master则提供一个终端模拟进程来控制slave。

终端模拟器接口在用户和shell之间按照以下方式工作：


使用方法简介
=============


参考
======

- `asciinema How it works <https://asciinema.org/docs/how-it-works>`_
