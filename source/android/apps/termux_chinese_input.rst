.. _termux_chinese_input:

======================
Termux中文输入
======================

刚开始使用 ``termux`` 终端的时候，我遇到一个非常奇怪的困扰: 无法在手机终端输入中文

- 简单来说就是，Android操作系统的Gboard(Google输入法程序)已经切换成 ``中文(简体)拼音`` ，但是进入Termux交互界面的时候却发现键盘只能输入英文
- 我购买的外接 :ref:`ms_universal_foldable_kb` 也同样存在这个问题，切换中文输入在其他Andorid应用工作正常，一旦切换到Termux，则只能输入英文

我甚至以为 ``termux`` 就是不支持输入法的程序，一度灰心得想要找一个Android code editor来取代 ``termux`` 中的 :ref:`nvim` (幸好没有)。不过，搜索了一下，有人在 `termux下gboard中文输入法在vim中的应用 <https://richfan.github.io/2019/02/08/2019-02-08-termux-gboard-vim/>`_ 提供了解决提示（虽然只有一句话，但是解决了我的问题，非常感谢原作者的分享）:

按住 ``termux`` 的快捷键条(也就是终端屏幕下方的一些 ``ESC`` ``CTRL`` 等软按键组成的条带)，然后向左滑动，当这个快捷键条变成空白条的时候，就可以正常输入中文了。

.. note::

   `muyinliu <https://github.com/muyinliu>`_ ( `Hello，Termux <https://tonybai.com/2017/11/09/hello-termux/>`_ 作者)推荐在中英文混合显示环境中使用字体 ``CodeNewRomanNerdFontMono-Regular.otf`` ，是 Nerd Fonts 中的一种字体（所以也支持很多图标相关的字符）。

   该字体可以从 `Nerd Fonts Downloads <https://www.nerdfonts.com/font-downloads>`_ 下载: 关键词 ``CodeNewRoman``

   感谢 **muyinliu** 提供的建议

参考
===========

- `termux下gboard中文输入法在vim中的应用 <https://richfan.github.io/2019/02/08/2019-02-08-termux-gboard-vim/>`_
