.. _sphinx_readthedocs_yaml:

================================================
Sphinx结合readthdocs.yaml实现定制Read The Docs
================================================

.. _sphinx_typeerror:

Build Filed: TypeError: 'generator'...
================================================

我在使用readthdocs.io平台构建sphinx文档时，在2021年10月开始遇到build fail。报错同 `Build Failed. TypeError: 'generator' object is not subscriptable #8616 <https://github.com/readthedocs/readthedocs.org/issues/8616>`_ ::

   ...
   TypeError: 'generator' object is not subscriptable

   Exception occurred:
     File "/home/docs/checkouts/readthedocs.org/user_builds/diadocsdk-1c/envs/dev/lib/python3.7/site-packages/sphinx/domains/std.py", line 638, in note_labels
       n = node.traverse(addnodes.toctree)[0]
   TypeError: 'generator' object is not subscriptable

原因是对于2020年10月之前创建的Sphinx项目，ReadTheDocs(RTD)会使用Sphinx<2的版本，此时如果你更新过pip环境， ``docutils-0.18`` 就会不兼容。所以上传到 RTD 平台编译就会失败。不过，在我本地编译的时候，安装的是 ``docutils==0.17.1`` ，所以没有任何问题。

解决方法是明确指定RTD环境，参考 `RTD eproducible Builds <https://docs.readthedocs.io/en/stable/guides/reproducible-builds.html>`_ 特别是 `RTD pinning dependencies <https://docs.readthedocs.io/en/stable/guides/reproducible-builds.html#pinning-dependencies>`_

- 在项目目录下添加一个配置文件 ``.readthedocs.yaml`` :

.. literalinclude:: sphinx_readthedocs_yaml/readthedocs.yaml
   :language: yaml

这个配置文件会指定项目需要的安装依赖包

- 在源代码 ``sources`` 目录下添加 ``requirements.txt`` :

.. literalinclude:: sphinx_readthedocs_yaml/requirements.txt

- 在源代码 ``sources`` 目录下添加 ``environment.yaml`` 这个文件非常重要，会强制 ReadTheDocs(RTD) 安装和使用指定pip包，这样就能能够避免 ``docutils`` 版本冲突:

.. literalinclude:: sphinx_readthedocs_yaml/environment.yaml
   :language: yaml
   :emphasize-lines: 9

- 然后 ``make html`` 没有问题后， ``git push`` 到github，再观察 ReadTheDocs(RTD) 就会发现build成功了。

python版本指定升级以适配Sphinx
===============================

最近一次重新安装了 :ref:`virtualenv` ，然后重新生成了 ``requirements.txt`` 配置(为了解决版本漏洞)。但是发现Read The Docs平台build失败，从build日志可以看到安装 ``Sphinx`` 失败:

.. literalinclude:: sphinx_readthedocs_yaml/sphinx_error
   :caption: 安装Sphinx失败

但是为何线下我自己的sphinx ``make html`` 是正常的呢？

注意到 ``Sphinx==8.2.3`` 显示的是大写字母的 ``Sphinx`` ，我本地的 :ref:`python` ``3.12.4`` ，而之前构建RTD时候指定了版本 ``3.7`` 。看来现在高版本的Sphinx，安装名从小写的 ``sphinx`` 改成了大写的 ``Sphinx`` 导致。

那么，修订 ``.readthedocs.yaml`` 配置，升级对应 Python 版本:

.. literalinclude:: sphinx_readthedocs_yaml/readthedocs_python.yaml
   :language: yaml
   :caption: 升级RTD环境的Python版本
   :emphasize-lines: 12

这样重建RTD就能够成功

指定graphviz依赖
================

:ref:`` 运行需要系统中安装 ``graphviz`` 工具，所以也需要对 ``readthdocs.yaml`` 设置，否则Read The Docs平台编译会WARNING:

.. literalinclude:: sphinx_readthedocs_yaml/graphviz_err
   :caption: 环境中缺乏 ``graphviz`` 工具时RTD报错

类似上述指定python版本，我尝试指定graphviz的安装版本 ``2.42`` :

.. literalinclude:: sphinx_readthedocs_yaml/readthedocs_try.yaml
   :language: yaml
   :caption: 尝试指定环境安装 ``graphviz``
   :emphasize-lines: 13

但是发现build失败，提示变量错误: 原来Read The Docs 只支持有限的变量: ``python, nodejs, ruby, rust, golang`` 

.. literalinclude:: sphinx_readthedocs_yaml/readthedocs_try_fail
   :caption: 不支持 ``python, nodejs, ruby, rust, golang`` 以外的变量

原来在编译环境中只能指定语言的版本，如果需要安装软件包则使用另外一个分类 ``apt_packages`` 可以安装不同的软件包:

.. literalinclude:: sphinx_readthedocs_yaml/readthedocs_apt.yaml
   :language: yaml
   :caption: 通过 ``apt_packages`` 安装 ``graphviz``
   :emphasize-lines: 13,14


参考
=======

- `Build Failed. TypeError: 'generator' object is not subscriptable #8616 <https://github.com/readthedocs/readthedocs.org/issues/8616>`_
- `How to make ReadTheDocs build graphs using graphviz <https://stackoverflow.com/questions/77366687/how-to-make-readthedocs-build-graphs-using-graphviz>`_
