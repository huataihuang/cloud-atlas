.. _sphinx_doc:

=================================
Sphinx文档
=================================

`Sphinx - Python  Documentation Generator <https://www.sphinx-doc.org/>`_ 是我主要的文档撰写工具，功能强大，我仅仅使用了部分功能来完成 :ref:`cloud_atlas` 撰写。

.. warning::

   我在使用readthdocs.io平台构建sphinx文档时，在2021年10月开始遇到build fail，参考 `Build Failed. TypeError: 'generator' object is not subscriptable #8616 <https://github.com/readthedocs/readthedocs.org/issues/8616>`_ :

   - 对于2020年10月之前创建的Sphinx项目，RTD会使用Sphinx<2的版本，此时如果你更新过pip环境，docutils-0.18 就会不兼容，导致 RTD 编译失败
   - 解决方法是明确指定RTD环境，参考 `RTD eproducible Builds <https://docs.readthedocs.io/en/stable/guides/reproducible-builds.html>`_ 特别是 `RTD pinning dependencies <https://docs.readthedocs.io/en/stable/guides/reproducible-builds.html#pinning-dependencies>`_

我依然觉得我需要学习和不断实践，才能相对较为合理地使用好这个工具。所以，我汇总我的一些实践，以便不断提高撰写技巧。

.. toctree::
   :maxdepth: 1

   sphinx_openstackdocstheme.rst
   sphinx_typeerror.rst
   sphinx_show_code.rst
   sphinx_table.rst
   sphinx_image.rst
   sphinx_strike.rst

.. only::  subproject and html

   Indices
   =======

   * :ref:`genindex`
