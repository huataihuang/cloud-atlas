.. _sphinx_embed_youtube:

===========================
Sphinx文档嵌入YouTube视频
===========================

我在撰写 :ref:`cuda_cores_vs._tensor_cores` 时看到参考文档 `Understanding Tensor Cores <https://blog.paperspace.com/understanding-tensor-cores/>`_ 有一个嵌入的YouTube科普视频，我突然想到，我撰写的 :ref:`sphinx_doc` 是否也能实现呢？

答案当然是 **YES**

- 安装 `sphinxcontrib.youtube <https://github.com/sphinx-contrib/youtube>`_ 插件::

   pip install sphinxcontrib-youtube

- 然后修改 ``source/conf.py`` :

.. literalinclude:: sphinx_embed_youtube/conf.py
   :language: python
   :caption: ``source/conf.py`` 增加 ``sphinxcontrib.youtube`` 扩展配置
   :emphasize-lines: 6

- 然后在文档中直接使用如下代码::

   .. youtube:: 7Ce35P5eiTE

就能够看到嵌入的YouTube视频 - 《紫》-Cover by 陈一发儿（电影《悟空传》插曲）

.. youtube:: 7Ce35P5eiTE

参考
=====

- `sphinxcontrib-youtube <https://sphinxcontrib-youtube.readthedocs.io/en/latest/>`_
