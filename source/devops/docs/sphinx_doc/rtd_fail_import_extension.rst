.. _rtd_fail_import_extension:

=============================================================================
Read the Docs build失败: ``Could not import extension sphinxcontrib.video``
=============================================================================

最近在引入 :ref:`sphinx_embed_video` 和 :ref:`sphinx_embed_youtube`  到我的 Sphinx 项目，我在 ``source`` 目录下的 ``requirements.txt`` 加入了:

.. literalinclude:: sphinx_typeerror/requirements.txt
   :caption: requirements.txt 加入模块
   :emphasize-lines: 6,7

但是我发现在 Read the Docs 平台，最近的build失败，提示错误如下:

.. literalinclude:: sphinx_embed_video/readthedocs_build_fail_output
   :caption: Read the Docs 平台Build失败输出信息
   :emphasize-lines: 23,26

这里导入 ``sphinxcontrib.video`` 触发了 ``sphinx.util.docutils`` 无法导入 ``SphinxTranslator`` 模块。

Read the Docs 类似问题在之前遇到过 :ref:`sphinx_typeerror` ，主要是 `RTD reproducible Builds <https://docs.readthedocs.io/en/stable/guides/reproducible-builds.html>`_ 需要明确的依赖包版本

需要重新修订配置文件了，之前 :ref:`sphinx_typeerror` 修订过配置，随着时间推移又出现新的问题了。需要配置成和当前本地环境一致，这样可以引导 Read the Docs 按照我本地build方式build

``.readthedocs.yaml`` 配置文件
================================

- 修订项目目录下添加一个配置文件 ``.readthedocs.yaml`` ，这次参考 `Configuration file v2 <https://docs.readthedocs.io/en/stable/config-file/v2.html>`_ 修改:

.. literalinclude:: rtd_fail_import_extension/readthedocs.yaml
   :language: yaml
   
配置Python依赖的 ``requirements`` 文件
=======================================

之前在 ``source`` 目录下 ``requirements.txt`` 文件只指定需要哪些模块，但是不指定版本。为了能够更好完成build，改进成指定版本(和本地版本一致)

- 更新 ``requirements.txt`` :

.. literalinclude:: ../../../python/startup/rebuild_virtualenv/generate_requirements
   :language: bash
   :caption: 生成 :ref:`virtualenv` 所使用Python软件包依赖列表 ``requirements.txt``

现在似乎不再使用 ``environment.yaml`` ，我移除了这个配置文件

build的新问题
================

完成上述配置修订后，推送到Read the docs的build输出果然不同，但是却出现了新的问题(显示安装依赖包出错):

.. literalinclude:: sphinx_embed_video/readthedocs_build_install_fail_output
   :caption: Read the Docs 平台Build失败显示安装包出错

仔细看了日志输出，发现 RTD 使用的 Python 版本低于 ``3.8`` ，导致不满足 ``Sphinx==6.1.3`` 的要求

奇怪，我配置了项目目录下 ``.readthedocs.yaml`` 指定了 ``python: "3.10.6"`` (我根据我本地 :ref:`ubuntu_linux` 22.04.2 LTS当前发行版Python版本)为何没有生效？

看了Sphinx官方 ``.readthedocs.yaml`` 配置 `RTD reproducible Builds <https://docs.readthedocs.io/en/stable/guides/reproducible-builds.html>`_ 采用 ``python: "3.11"`` ，但是我依样画葫芦也不行，从build日志来看，RTD依然使用了 Python 3.7::

   ...
   python3.7 -mvirtualenv $READTHEDOCS_VIRTUALENV_PATH
   ...

.. figure:: ../../../_static/kubernetes/deployment/bootstrap_kubernetes_ha/ha_k8s_dnsrr/marmot.gif

我发现我犯了一个 **愚蠢的低级错误** : 现在我为了避免每次 ``make html`` 之后不断生成的变化的html被同步到github仓库，我每次只 ``git add`` 子目录 ``source`` ，根本没有提交上一级项目根目录下的 ``.readthedocs.yaml`` ，难怪RTD根本没有按照预想的那样使用高版本Python...

重新推送了 ``.readthedocs.yaml`` ，OK

参考
========

- `RTD eproducible Builds <https://docs.readthedocs.io/en/stable/guides/reproducible-builds.html>`_
