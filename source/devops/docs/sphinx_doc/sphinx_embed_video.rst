.. _sphinx_embed_video:

===================
Sphinx文档嵌入视频
===================

和 :ref:`sphinx_embed_youtube` 类似， `sphinxcontrib-video <https://github.com/sphinx-contrib/video>`_ 提供了将视屏嵌入 :ref:`sphinx_doc` 的能力。

- 安装 `sphinxcontrib-video <https://github.com/sphinx-contrib/video>`_ 插件::

   pip install sphinxcontrib-video

- 然后修改 ``source/conf.py`` :

.. literalinclude:: sphinx_embed_youtube/conf.py
   :language: python
   :caption: ``source/conf.py`` 增加 ``sphinxcontrib.video`` 扩展配置
   :emphasize-lines: 7

- 然后在文档中直接使用如下代码::

     .. video:: ../../../_static/devops/docs/sphinx_doc/ssngsjzr.mp4

就可以看到我使用 :ref:`yt-dlp` 从YoutTube下载的 **《杀死那个石家庄人》--万能青年旅店 影视混剪MV** (我选择了一个小规格mp4作为演示， **墙裂推荐** 观看YouTube原高清视频 `《杀死那个石家庄人》-- 万能青年旅店 影视混剪MV <https://www.youtube.com/watch?v=npHbCnf-Lpk&list=PLnqzKl0S_xnl8xgGJxWKDPuFrgafqSEfo&index=3>`_ )

.. video:: ../../../_static/devops/docs/sphinx_doc/ssngsjzr.mp4

.. note::

   我验证了YouTube下载的 ``.3gp`` 视频( VCODEC 是 ``mp4v.20.3`` )，在嵌入到Sphinx文档中只有声音播放没有视频图像

参考
====

- `sphinxcontrib-video: Quickstart <https://sphinxcontrib-video.readthedocs.io/en/latest/quickstart.html>`_
