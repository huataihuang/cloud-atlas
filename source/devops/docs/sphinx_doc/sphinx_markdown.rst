.. _sphinx_markdown:

===============================
在Sphinx中使用MarkDown格式文档
===============================

因为在 :ref:`deploy_deepseek-r1_locally_cpu_arch` 测试结果返回都是 ``MarkDown`` 格式，直接作为源码嵌入文档看起来很简陋不直观，所以考虑如何在Sphinx文档中嵌入部分 ``MarkDown`` 文档。

简单来说，使用 `myst-parser <https://myst-parser.readthedocs.io/>`_ 扩展，就可以非常轻松地引用 ``MarkDown`` 格式文档，会自动渲染HTML，就好像这些文档是标准的RST格式一样。

- 安装 ``myst_parser`` :

.. literalinclude:: sphinx_markdown/install_myst
   :caption: 安装 ``myst_parser`` 扩展

- 配置 ``conf.py`` :

.. literalinclude:: sphinx_markdown/conf.py
   :caption: 配置 ``conf.py``
   :emphasize-lines: 6

- 在 ``.rst`` 文档中就可以引用 ``.md`` 文档:

.. literalinclude:: sphinx_markdown/include
   :caption: 引入 ``.md`` 文档

很神奇

需要注意， ``.md`` 文档需要严格遵循 ``MarkDown`` 格式，否则 ``build`` 时候会有报错

参考
=====

- `Include my markdown README into Sphinx <https://stackoverflow.com/questions/46278683/include-my-markdown-readme-into-sphinx/68005314>`_
