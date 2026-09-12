.. _foot_font:

====================
Foot终端字体配置
====================

.. note::

   本文实践参考 gemini ，但是我感觉优化效果不太明显，甚至我感觉 :ref:`foot` 实践记录就已经足够，所以我最终还是采用 :ref:`foot` 笔记方法。

我在 :ref:`alpine_sway_mba11_late_2010` 完成基础中文环境安装以后，希望调整 :ref:`foot` 配置思源等宽黑体（Noto Sans Mono CJK SC），这样在终端中编辑中文文档会美观舒适很多。

``foot`` 会加载位于 ``$XDG_CONFIG_HOME/foot/foot.ini``` 配置文件(默认就是 ``$HOME/.config/foot/foot.ini`` )。一般是将模板配置文件从 ``/etc/xdg/foot/foot.ini`` 复制过来进行修改，修订的配置项会覆盖
默认配置而达到修改目标。

.. literalinclude:: foot/cp_foot.ini
   :caption: 复制 ``foot.ini`` 模板

配色
=======

通过修改 ``foot.init`` 的 ``[colors]`` 段落可以定制foot终端配色。

比较方便的方法是使用已经配置好的的配色themes，发行版可以能在 ``/usr/share/foot/themes`` 中提供了配
色，就可以在 ``foot.init`` 中添加一段 ``[main]`` 来包含这个配色 theme :

.. literalinclude:: foot/theme
   :caption: 修订 ``~/.config/foot/foot.ini`` 设置配色

我从 `GitHub: catppuccin/foot <https://github.com/catppuccin/foot>`_ 下载配色themes文件存放到 ``~/.config/foot/themes/`` 目录下，采用上述方法设置:

.. literalinclude:: foot/theme_mocha
   :caption: 修订 ``~/.config/foot/foot.ini`` 设置配色 ``catppuccin-mocha.ini``

中文字体
==========

- 修订 ``~/.config/foot/foot.ini`` :

.. literalinclude:: foot_font/foot.ini
   :caption: 设置foot使用中文字体

常用调整与验证技巧
------------------------

- 动态调节字号（运行时快捷键）:

  - 放大字号： ``Ctrl + +``
  - 缩小字号： ``Ctrl + -``
  - 恢复默认字号： ``Ctrl + 0``

- 实时重载配置：在 Foot 中按 ``Ctrl + Shift + R`` ，或者直接新开一个 Foot 终端，配置就会立即生效，无需重启 Sway 会话。

- 启动 Foot 终端后，可以在终端内运行以下命令查看 Foot 实际选用的字体文件路径:

.. literalinclude:: foot_font/check_foot_font
   :caption: 检查终端字体

参考
=======

- gemini
