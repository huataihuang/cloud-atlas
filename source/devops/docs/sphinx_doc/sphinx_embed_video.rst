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

.. _readthedocs_fail_import_sphinxcontrib.video:

Read the Docs build失败: ``Could not import extension sphinxcontrib.video``
=============================================================================

最近在引入 :ref:`sphinx_embed_video` 和 :ref:`sphinx_embed_youtube`  到我的 Sphinx 项目，我在 ``source`` 目录下的 ``requirements.txt`` 加入了:

.. literalinclude:: ../../../requirements.txt
   :caption: requirements.txt 加入模块
   :emphasize-lines: 6,7

但是我发现在 Read the Docs 平台，最近的build失败，提示错误如下:

.. literalinclude:: sphinx_embed_video/readthedocs_build_fail_output
   :caption: Read the Docs 平台Build失败输出信息
   :emphasize-lines: 23,26

这里导入 ``sphinxcontrib.video`` 触发了 ``sphinx.util.docutils`` 无法导入 ``SphinxTranslator`` 模块。

我在自己的本地电脑 ``Python 3.10.6`` 环境( Ubuntu 22.04 )构建的 :ref:`virtualenv` 没有遇到问题，使用到的模块版本::

   docutils                      0.18.1
   sphinxcontrib-video           0.1.1
   Sphinx                        6.1.3

Read the Docs 使用的 ``Sphinx`` 是 v1.8.6，类似问题在之前遇到过，主要是需要 `RTD eproducible Builds <https://docs.readthedocs.io/en/stable/guides/reproducible-builds.html>`_




参考
====

- `sphinxcontrib-video: Quickstart <https://sphinxcontrib-video.readthedocs.io/en/latest/quickstart.html>`_
