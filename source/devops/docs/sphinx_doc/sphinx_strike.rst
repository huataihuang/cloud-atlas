.. _sphinx_strike:

=============================
Sphinx扩展文本划线(表示删除)
=============================

我在撰写Sphinx的文档时候，因为随着实践深入和眼界开阔，很多方案会和最初想法不同。但是，对于一个技术方案的演进，总是希望能够留下发展痕迹以便能够说明缘由启发未来。所以，我想能够在Sphinx中使用 ``strikethrough`` 功能，即在文本中间划线表示这个方法或者思路已经被取消。

不过，Sphinx的原生没有提供 ``strikethrough`` ，我采用 `sphinxnotes-strike: Sphinx extension for HTML strikethrough text support <https://sphinx-notes.github.io/strike/>`_ 方法。

role实现
=========

我实践了下来，发现 `reStructuredText 学习笔记: 使用 default role 扩展 reStructuredText 的功能 <http://notes.tanchuanqi.com/tools/reStructuredText.html#default-role>`_ 是最方便和可靠实现富文本方式::

   .. role:: raw-html(raw)
      :format: html
      .. default-role:: raw-html

   `<U>` 下划线 `</U>` 、 `<S>` 删除线 `</S>`

生成效果如下:

.. role:: raw-html(raw)
   :format: html
.. default-role:: raw-html

`<U>` 下划线 `</U>` 、 `<S>` 删除线 `</S>`

sphinxnotes-strike(暂未成功)
==============================

.. note::

   `sphinxnotes-strike: Sphinx extension for HTML strikethrough text support <https://sphinx-notes.github.io/strike/>`_ 方法似乎很好，但我没有实践成功，待后续学习

安装
---------

- 下载安装Python Package::

   pip install sphinxnotes-strike

- 配置项目的 ``conf.py`` 添加::

   extensions = [
             # …
             'sphinxnotes.strike',
             # …
             ]

使用
---------

- 可以使用 ``strike`` 角色来添加 ``strikethrough`` ::

   :strike:`Sphinx`

效果:

:strike:`Sphinx`

- 也可以使用 ``del`` 角色::

   :del:`Sphinx`

效果:

:del:`Sphinx`

参考
======

- `sphinxnotes-strike: Sphinx extension for HTML strikethrough text support <https://sphinx-notes.github.io/strike/>`_
- `ReST strikethrough <https://stackoverflow.com/questions/6518788/rest-strikethrough>`_
- `reStructuredText 学习笔记 <http://notes.tanchuanqi.com/tools/reStructuredText.html>`_ 非常详细和生动的学习笔记，值得使用sphinx的初学者学习，强烈推荐
