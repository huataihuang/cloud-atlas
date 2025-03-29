.. _sphinx_embed_audio:

===========================
Sphinx文档嵌入音频
===========================

我在听歌的时候，突然想到，既然 :ref:`sphinx_embed_youtube` 和 :ref:`sphinx_embed_video` 能够嵌入视频，那么怎样能够嵌入音频呢？

答案是使用 ``raw`` 直接嵌入 ``HTML`` :

.. literalinclude:: sphinx_embed_audio/sphinx_doc_raw_html
   :language: html
   :caption: 通过 ``raw`` 指令可以在Sphinx文档中嵌入任意html代码，也包括音频文件

这里嵌入一首我非常喜欢的 **陈一发儿** 演唱 「Landing Guy」

.. raw:: html

   <audio controls="controls">
         <source src="../../../_static/devops/docs/sphinx_doc/landing_guy_chenyifaer.m4a" type="audio/mpeg">
         Your browser does not support the <code>audio</code> element. 
   </audio>

( 发姐自信点评 ``相信各位格莱美都听出来了，这首歌里我唱了三个音轨，主音，低音，气声。（可以说是very专业了）`` )

.. note::

   音频文件采用 :ref:`yt-dlp` 从YouTube视频 `Landing Guy—刘昊霖 (Cover by 陈一发儿 ) <https://www.youtube.com/watch?v=tSHb6acXMj8>`_ 下载

   .. youtube:: tSHb6acXMj8

   由于 **社会主义铁拳** 封杀了 ``陈一发儿`` ，直到今天墙内依然无法在直播和娱乐平台看到这个名字。

   但是总有粉丝会上传一些漏网视频(居然只能冠以 ``辣个女人`` ，尼玛，又不是伏地魔，连名字都不能提么？)

   如果你翻不了墙，或许可以在百度百科上欣赏到搬运的这首 

   `Landing Guy—刘昊霖 (Cover by辣个女人 ) <https://baike.baidu.com/video?secondId=73547327>`_ 

   **应该是全网演绎最好的版本了**

参考
======

- `Is it possible to embed an audio file in the html output of the Sphinx documentation tool? <https://stackoverflow.com/questions/54822826/is-it-possible-to-embed-an-audio-file-in-the-html-output-of-the-sphinx-documenta>`_
