.. _ai_exporter_in_chrome:

=============================
Chrome插件AI Exporter
=============================

我在使用gemini时发现，由于 Gemini 采用了懒加载（Lazy Loading）机制，为了节省浏览器内存，它只会渲染和保持你当前滚动到的那一小段页面的 DOM 节点，而把很久之前的对话内容从前端页面里暂时“卸载”或隐藏掉。所以如果你不手动往上滚动到开头，那么使用 :ref:`obsidian` 的 Web Clipper时就会发现，无法抓取完整的chat会话。

一种比较土的解决方法是自己手工滚动浏览器窗口，达到最高位置，这样完整的页面就能提供Obsidian抓取。但是这个过程非常乏味，并且加载内容非常缓慢，几乎就是不可能的任务。

好在  `AI Exporter: Save Claude,ChatGPT,Gemini to PDF, Docs, MD and More <https://chromewebstore.google.com/detail/ai-exporter-save-claudech/kagjkiiecagemklhmhkabbalfpbianbe>`_ 插件非常强悍，提供了一个 ``Custom Export`` 功能，点击以后就会启动一个新的插件页面并加载当前chat中所有的会话来回，该插件的 **底层 DOM 抓取引擎** 会强迫浏览器后台去唤醒和加载那些因为懒加载（Lazy Loading）而被隐藏的历史节点。

这样就能够完整下载chat内容，并进行review和整理。

.. note::

   Gemini 自带的“分享”功能其实是 **唯一能真正触及后端服务器完整历史** 的途径，但是这个分享实际上是Google的后台用户操作日志导出，所以是按照时间线来排列。可以理解成实际上是spark系统记录的用户日志，可以根据google应用系统名进行查询。但这非常不方便使用，因为完全打乱了chat的线索。

.. note::

   另外一种变相的下载会话方法是使用 Google Tackout 官方导出，但是这个方法是Google的后台用户操作日志导出，所以是按照时间线来排列。但是打乱了chat的线索.

参考
======

- gemini
