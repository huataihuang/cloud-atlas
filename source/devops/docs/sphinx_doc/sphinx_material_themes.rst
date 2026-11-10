.. _sphinx_material_themes:

===========================================
Sphinx使用Material for MkDocs 风格的主题
===========================================

我非常习惯 :ref:`mkdocs` 所使用的 Material 风格，不过，我的Cloud Atlas已经使用了Sphinx好多年了，再花时间和精力去转换平台实在意义不大。那么有没有办法在Sphinx上实现类似 Material for MkDocs 风格呢？

社区有2个完美的平替: ``furo`` 或 ``sphinx-book-theme``

.. warning::

   我最终放弃了本文所述的两个 Material 风格的themes ``furo`` 和 ``sphinx-book-theme``

   **原因是这种现代化主题在Sphinx上使用非常消耗编译资源，需要数十分钟(45分钟到1小时)才能完成make html，无法直接在ReadTheDocs平台上使用!!!**

   最终还是回退到经典且简洁的 ``sphinx_rtd_theme`` ，本网站还是以文章内容为主，页面风格不刻意美观。

   作为对比 ``sphinx_rtd_theme`` 编译仅仅只需要 2~3 分钟就完成 ( ``make html  406.93s user 52.13s system 278% cpu 2:44.58 total`` )

``furo`` 主题
================

furo 是目前 Sphinx 社区中公认最现代、颜值最高的响应式主题之一。它的设计理念、配色方案、侧边栏布局和字体内边距，几乎完美复刻了 :ref:`mkdocs` 的 Material 风格:

- 极佳的明暗模式(Dark/Light Mode)切换体验
- 移动端适配极其流畅
- 完美的代码块复制、标题锚点交互

.. note::

   现在社区中有很多著名项目使用了 ``furo`` 主题的Sphinx来撰写技术文档:

   - `Python Developer's Guide <https://devguide.python.org>`_
   - `Blender Manual <https://docs.blender.org/manual/en/latest/index.html>`_

安装和使用 ``furo`` 主题
---------------------------

- 安装

.. literalinclude:: sphinx_material_themes/install_furo
   :caption: 安装 ``furo`` 主题

- 使用非常简单，在Sphinx的 ``conf.py`` 中配置:

.. literalinclude:: sphinx_material_themes/conf_furo.py
   :caption: 在 ``conf.py`` 中设置 ``furo`` 风格

使用 ``furo`` 主题的困扰和解决思路
-----------------------------------

虽然 ``furo`` 主题非常符合现代网站的审美，但是我实际执行 ``time make html`` 惊讶地发现，这个主题编译非常消耗资源，在我的4核8线程的i7处理器( :ref:`mbp15_late_2013` )并发8个进程满负荷编译整整花费了 **44分钟**

.. literalinclude:: sphinx_material_themes/furo_make_html
   :caption: 在4核8线程的i7处理器( :ref:`mbp15_late_2013` )编译花费44分钟

这意味着如果在 ``readthedocs`` 平台托管的域名 `cloud-atlas.readthedocs.io <https://cloud-atlas.readthedocs.io>`_ 是无法完成编译的: ReadTheDocs 对每次构建的时间有明确的硬性限制，对于免费账户或标准公开项目，单次构建的超时时间通常限制在 **15分钟** 左右。

.. note::

   Sphinx 最初是为了 Python 官方 API 文档（reStructuredText）设计的。为了处理成千上万的 Python 类、函数、模块交叉引用（Cross-references）、多级索引、以及 autodoc 动态代码提取，Sphinx 在构建时必须在内存中建立一个庞大的全局文档对象图（Document Graph / .doctree）。这种全局计算的开销极其巨大。

   Furo 为了追求高级感，在 Sphinx 的 Jinja2 模板层做了大量的嵌套、响应式断点计算和结构重组。当 Sphinx 的全局对象图解析 Furo 复杂的模板时，就会导致 Python 解释器在模板渲染阶段进行疯狂的进程间通信和 CPU 争抢。

解决的思路可能有( :strike:`待尝试` **放弃了** ):

- **使用 GitHub Actions + GitHub Pages / Cloudflare Pages** :

  - GitHub Actions 提供的标准 Linux 虚拟机每个 Job 的运行时间上限高达 6 小时
  - 可以在 GitHub Actions 中配置缓存策略（Cache Sphinx ``.doctree`` 和 ``.quarto`` 缓存），让后续的增量构建速度大幅缩短
  
    - 当代码推送到 GitHub 时，触发 GitHub Actions 运行 ``build.sh``
    - 脚本在云端把文档全部编译成纯静态的 HTML
    - 直接将编译好的 ``_site/`` 产物一键部署到 GitHub Pages 或 Cloudflare Pages

- 考虑到我已经长期使用了 `cloud-atlas.readthedocs.io <https://cloud-atlas.readthedocs.io>`_

  - 利用"301重定向"保留 SEO 信誉: 在 RTD 的后台或通过配置文件，将所有旧页面的访问 301 重定向 到新托管地址 `infra.cloud-atlas.dev/discovery <https://infra.cloud-atlas.dev/discovery>`_

  - **目前看这个方案最稳妥** RTD 官方提供了一个高级特性：允许上传预构建的静态文件( ``Pre-rendered HTML`` )

    - 在本地(或在性能充沛的 ``GitHub Actions`` 里)完成编译 ``make html`` ，把 HTML 静态网页全部编译好，然后通过 ReadTheDocs 的 ``API`` 或特定集成，直接把编译好的 ``_site`` 压缩包推上去让 RTD 托管。

.. note::

   本段可能有待后续实践...

``sphinx-book-theme`` 主题
============================

``sphinx-book-theme`` 主题是基于 ``PyData`` 主题构建，广泛用于 :ref:`jupyter` 生态和各大科学计算、AI项目的官方文档。它同样吸收了现代 Web 设计的精华，带有顶部通栏、左侧树状导航和右侧文章目录（TOC Tree）。

安装和使用 ``sphinx-book-theme`` 主题
---------------------------------------

- 安装

.. literalinclude:: sphinx_material_themes/install_sphinx-book-theme
   :caption: 安装 ``sphinx-book-theme`` 主题

- 在Sphinx的 ``conf.py`` 中配置:

.. literalinclude:: sphinx_material_themes/conf_sphinx-book-theme.py
   :caption: 在 ``conf.py`` 中设置 ``sphinx-book-theme`` 风格

.. note::

   ``sphinx-book-theme`` 的编译时间比 ``furo`` 更长，花费了1个小时才完成编译 ( ``make html  23453.17s user 301.96s system 623% cpu 1:03:31.90 total`` )。

   彻底放弃了...

参考
======

- gemini
- `GitHub: pradyunsg/furo <https://github.com/pradyunsg/furo>`_
- `GitHub: executablebooks/sphinx-book-theme <https://github.com/executablebooks/sphinx-book-theme>`_
