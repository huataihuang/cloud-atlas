.. _sphinx_footer:

======================
Sphinx文档自定义页脚
======================

我在撰写「Cloud Atlas」时候，希望在每个页面下增加一段留言讨论和捐赠的链接，所以在很久以前就采用本文方法定制footer。最近又增加了 :ref:`sphinx_comments` 功能，也是在本文footer基础上修改，所以整理记录:

- 修订文档项目的 ``conf.py`` 指定模版目录:

.. literalinclude:: sphinx_footer/conf.py
   :language: python
   :caption: 修改 ``conf.py`` 指定模版目录

- 在源代码项目下创建  ``_templates`` 目录，然后在该目录下创建 ``foot.html`` ，增加以下内容:

.. literalinclude:: ../../../_templates/footer.html
   :language: html
   :emphasize-lines: 1,3,4,13

然后就可以在上述 ``footer.html`` 内容部分填写自己希望在每个页面展示的内容，内容会显示在页脚上。

上文 ``footer.html`` 部分内容是 :ref:`sphinx_comments` ，用于我的网站和网友交流评论

参考
=====

- `How can I add a custom footer to Sphinx documentation? <https://stackoverflow.com/questions/5585250/how-can-i-add-a-custom-footer-to-sphinx-documentation>`_
