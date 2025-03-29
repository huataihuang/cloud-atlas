.. _termux_background_running:

=====================
保持Termux后台运行
=====================

我在使用 Termux 作为移动工作平台时，使用 ``tmux`` 和 ``screen`` 在后台持续运行一些交互操作，例如撰写文档和开发程序。此外 :ref:`termux_nginx` 提供了撰写 :ref:`sphinx_doc` 以及 :ref:`mkdocs` 极佳平台，因为能够随时随地连接到手机平台撰写文档，同时进行浏览阅读。

不过，在Android手机中运行Termux，会发现切换到后台运行时，很容易因为系统内存不足而被 ``sleep`` 甚至杀死。这对于我需要随时回到之前的工作环境非常长不利。

对于所有移动操作系统，为了节约电能消耗，都采用了类似的后台技术: 当应用切换到后台，如果长时间在后台，就会被系统作为电能节约优化掉。但是，对于我这种需要持续运行，不希望被系统杀死的应用，则需要配置 ``Unrestricted`` 特性:

- 在Android系统的 ``Settings`` 中找到 ``Apps`` 项，然后找到 ``Termux`` 这个应用
- 点击 ``Battery`` (配置)，在 ``Mange battery usage`` 选项中选择:

  - ``Unrestricted`` : Allow battery usage in background without restrictions. May use more battery.

这样Termux在后台运行不会被杀死。

参考
======

- `How to prevent apps from 'sleeping' in the background on Android <https://www.androidpolice.com/prevent-apps-from-sleeping-in-the-background-on-android/>`_
