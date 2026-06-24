.. _obsidian-custom-sort:

=======================================
_obsidian-custom-sort自定义排序插件
=======================================

在使用Obsidian时，会发现一个和 :ref:`mkdocs` 完全不同的体验: 无法控制folder中note排序。准确的说，Obsidian采用的是note标题的ASCII/Unicode的顺序排序。这对于英文用户来说可能问题不大，毕竟很明显数字和字母排序是有意义的，但是对于中文用户来说，汉字unicode排序是完全摸不着头脑的。

当然强行为每个标题加上数字或者字母开头也是一种变通方法，但是假如我更进一步想让某些文档浮动在最上面，有自己特定的排序要求，就无法解决了。而且添加字母可以按照拼音来完成，但是非常别扭。

`GitHub: SabastianMC/obsidian-custom-sort <https://github.com/sebastianmc/obsidian-custom-sort>`_ 提供了一个完全控制文档和目录的方法:

- ``config-driven`` 可以通过不同的弦线来控制排序
- ``drag and drop`` 可以通过书签集成来实现排序

``sortspec`` 设置排序
========================

在目录下增加一个 ``sortspec`` 名字的文件，在其中添加一个YAML内容:

.. literalinclude:: obsidian-custom-sort/sortspec
   :caption: 指定排序的sortspec
   :language: yaml

虽然有点麻烦，但是确实能够对文档排序，只需要在目录名上右击鼠标选择  ``Custom sort: >> Apply custom sorting`` 这样就能生效
