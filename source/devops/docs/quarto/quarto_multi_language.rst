.. _quarto_multi_language:

=======================
Quarto多语言
=======================

多语言目录结构
=================

为了能够实现多语言版本的Quarto网站，参考gemini建议初步搭建目录结构:

.. literalinclude:: quarto_multi_language/tree
   :caption: 多语言目录结构(gemini)

gemini提供了以下脚本(经过一番折腾)，一键生成包含 ``courses/`` （多课程分类）和 ``packages/`` （算法库）的双语骨架

.. literalinclude:: quarto_multi_language/init.sh
   :caption: 一键生成双语骨架

上述目录和初始化的框架完成后，则执行以下命令预览"子项目"(在哪个目录下执行就渲染哪个子项目):

- 预览英文版（进入 ``en/`` 目录）:

.. literalinclude:: quarto_multi_language/preview
   :caption: 进入子目录进行预览

如果不进入 ``en/`` 目录，则可以在根目录下指定目录进行预览:

.. literalinclude:: quarto_multi_language/preview_en
   :caption: 指定目录进行预览

不过，出于安全考虑(防止误删父目录中的文件)， **Quarto 默认不允许子目录中的配置文件** ，所以我最初将渲染输出到父级目录(如 ``../_site/zh`` )就会出现如下告警:

.. literalinclude:: quarto_multi_language/render_warning
   :caption: 渲染目录时告警
   :emphasize-lines: 7,8

解决的方法是遵循Quarto的规范，将 ``output-dir`` 从 ``output-dir: ../_site/zh`` 修订为 ``output-dir: _site`` ，也就是仅输出到本项目的目录范围，而不会写到父级目录。

现在，可以在项目根目录下去渲染 ``quarto render`` ，此时会分别调用 ``en/`` 和 ``zh/`` 目录进行渲染，但是需要注意输出的都是在各自子项目目录下

多语言版本导航
---------------

那么怎么合并到一个目录下并使用首页面串联起来呢？实际上就是在不同的项目目录中分别执行 ``quarto render`` ，然后在根目录下把这些渲染后的目录合并起来。

我最初按照gemini的建议构建了一个根目录的 ``_quarto.yml`` 和 ``index.qmd`` :

.. literalinclude:: quarto_multi_language/_quarto.yml
   :caption: 根目录 ``_quarto.yml``
   :language: yaml

以及让用户导航选择语言版本 ``index.qmd`` :

.. literalinclude:: quarto_multi_language/index.qmd
   :caption: 根目录 ``index.qmd``
   :language: markdown

但是我发现这带来一个问题，就是在项目根目录下执行 ``quarto render`` 确实能够渲染根目录下的 ``index.qmd`` ，而且非常巧妙的对子目录 ``en/`` 和 ``zh/`` 也进行了渲染并一起输出到根目录的 ``_site`` 下的 ``en/`` 和 ``zh/`` ，初看非常完美。但是实际浏览却发现，根目录下的 ``_quarto.yml`` 会覆盖子目录的 ``_quarto.yml`` 这就导致了在 ``en/`` 和 ``zh/`` 下 ``_quarto.yml`` 配置的导航栏完全失效了。

这个问题困扰了我，最终也没有解决。

不过，参考gemini的建议，最后简化为根目录下就不渲染 ``index.qmd`` ，而是直接生成一个标准的重定向，直接重定向到默认语言(en)页面。当然，手工写一个语言选择页面也行。

目前就这样吧，先以内容为主，页面就不纠结了。

合并build
------------

为了能够完成页面生成，采用如下 ``build.sh`` :

.. literalinclude:: quarto_multi_language/build.sh
   :caption: 一次性编译多语言site脚本
