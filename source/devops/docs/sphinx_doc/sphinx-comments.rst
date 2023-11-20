.. _sphinx-comments:

======================
sphinx-comments
======================

我在折腾 :ref:`cn_samsung_galaxy_watch_4_wich_android` ，意外发现 `非国行的Android不能使用国行的Watch4？不指望三星，自力更生完美解决 <https://blog.xuegaogg.com/posts/1931/>`_ 博主 `雪糕博客 <https://blog.xuegaogg.com/>`_ 使用了 `utterances <https://utteranc.es/>`_ 作为 :ref:`hugo` 的评论系统，非常巧妙和灵活:

- 依靠稳定的 GitHub issues 作为数据存储，背靠大树好乘凉: GitHub可靠性和稳定性肯定比自建博客评论系统要稳定多了
- 虽然GitHub已经被墙，但是作为纯技术博客来说，受众基本上都是能够翻墙自己折腾的同行
- 如果用户看不到评论(例如墙内没有架梯子)，那么通过简单的提示也可以让用户知道为何看不到

简单Google了一下， `Sphinx Comments <https://sphinx-comments.readthedocs.io/en/latest/index.html>`_ 开源Comments系统完美结合了 `utterances <https://utteranc.es/>`_ 和 :ref:`sphinx_doc` ，正是我所需要完善我的文档评论功能的利器。之前我想 :ref:`sphinx_disqus` 一直没有折腾，这下帮了我大忙了。


安装 Utterances
===================

- 在GitHub上需要安装 ``utterances GitHub App`` ，也就是 ``A lightweight comments widget built on GitHub issues`` ，访问 `utterances GitHub App <https://github.com/apps/utterances>`_ 页面，点击 ``Installation`` 按钮； 或者在 `GitHub Marketplace / Apps / utterances <https://github.com/marketplace/utterances>`_ 中也可以找到安装入口

  - 选择GitHub账号，然后 ``下一步``

  - 选择需要安装 ``utterances`` 的仓库，例如，这里是我的仓库 ``huataihuang/cloud-atlas`` :

.. figure:: ../../../_static/devops/docs/sphinx_doc/install_utterances.png

   安装 ``utterances`` 时选择指定仓库

安装和配置 ``sphinx-comments``
================================

- 使用 :ref:`pip` 完成 ``sphinx-comments`` 安装(安装前可以先 :ref:`upgrade_all_python_packages_with_pip` ):

.. literalinclude:: sphinx-comments/install
   :caption: :ref:`pip` 安装 ``sphinx-comments``

- 然后修改 ``conf.py`` :

.. literalinclude:: sphinx-comments/activate_sphinx-comments
   :caption: 在 :ref:`sphinx_doc` 配置中激活 ``sphinx-comments``

参考
======

- `utterances <https://utteranc.es/>`_
- `Sphinx Comments <https://sphinx-comments.readthedocs.io/en/latest/index.html>`_
