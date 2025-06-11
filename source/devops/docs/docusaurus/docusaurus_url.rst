.. _docusaurus_url:

===================
Docusaurus URL
===================

我在开始撰写 `docs.cloud-atlas.dev <https://docs.cloud-atlas.dev>`_ 文档时，我注意到我所使用的 ``Docusaurus`` 平台的官方文档中，对于多个英文单词组合成的字符串作为URL部分时，使用了 ``-`` (连字符)来串起字符串。而我之前在 :ref:`sphinx_doc` 撰写时，采用了类似 :ref:`ruby` 风格的 ``_`` (下划线)来串起字符串。那么，到底哪个更合适，还是没有区别？

结论是: 推荐使用 ``-`` (连字符)来串起字符串:

``-`` 叫做分词符，顾名思义用作分开不同词的。

这个最佳实践来自于针对Google为首的SEO（搜索引擎优化）需要，Google搜索引擎会把url中出现的 ``-`` (连字符)当做空格对待，这样url  ``/it-is-crazy`` 会被搜索引擎识别为与 ``it`` , ``is`` , ``crazy`` 关键词或者他们的组合关键字相关。

当用户搜索 ``it`` , ``crazy`` ,  ``it is crazy`` 时，很容易检索到这个url，排名靠前。

``_`` (下划线)这个符号如果出现在url中，会自动被Google忽略， ``/it_is_crazy`` 被识别为与关键词 “itIsCrazy”相关。

.. note::

   使用 ``-`` (连字符)可以认为是业内习惯，项目内保持一种写法就可以了，没有强求。

.. note::

   由于我的 :ref:`sphinx_doc` 项目 `「云图 -- 云计算图志: 探索」 <https://docs.cloud-atlas.dev/discovery>`_ 已经撰写多年，使用了 ``_`` (下划线)作为字符串连接，所以该项目不再调整。

   不过，我的新项目 `docs.cloud-atlas.dev <https://docs.cloud-atlas.dev>`_ 将按照业内习惯，统一采用 ``-`` (连字符)来串起字符串!

参考
======

- `RESTFul API设计时，URL路径中不可以使用下划线吗？ <https://segmentfault.com/q/1010000009149189>`_
