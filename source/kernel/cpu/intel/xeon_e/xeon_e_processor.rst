.. _xeon_e_processor:

=========================
Intel Xeon E系列处理器
=========================

Intel于2018年推出Xeon E-2100处理器，面向入门级服务器平台。这个系列Xeon E是之前E3-1200 v系列改名。包括2019年推出的Xeon E-2200处理器，都是属于Coffee Lake微内核处理器，基于14nm工艺。



Xeon E系列处理器编号
======================

**Xeon E-2xxx (uniprocessor)**

- Xeon E-2xyz 表示:

  - x: 表示第几代
  - z: 表示core数量

- 后缀字母:

  - 没有后缀: 表示不集成GPU
  - ``G`` : 表示集成GPU
  - ``M`` : BGA移动处理器(Mobile processor)
  - ``L`` : 低电压(Low power)
  - ``E`` : 嵌入式(Embedded)

主板芯片
==========

Xeon E系列对应使用 C242 或 :ref:`intel_c246` ，这样才能实现支持ECC内存。我选购了 :ref:`nasse_c246` 来配套 :ref:`xeon_e-2274g`

.. warning::

   ECC内存支持需要处理器和主板同时支持才能正常工作:

   - 如果处理器支持ECC内存，但主板芯片不支持ECC内存，则可能能使用ECC内存但不能激活ECC校验
   - Intel官方网站提供了一篇 `How to Find ECC Memory Support for Intel® Processor <https://www.intel.com/content/www/us/en/support/articles/000096922/processors.html>`_ 文章最后提供了一个ECC支持查询列表

     - 第八代和第九代Intel Core只有 ``i3`` 是支持ECC的， ``i5`` 和 ``i7`` 可能因为定位和入门级Xeon重叠，所以并不支持ECC
     - 十二代以后处理器好像大多都支持ECC

参考
=====

- `ITX H310+大船XEON E不足千元？ASRock H310CM-HDV破解评测 <https://post.smzdm.com/p/anxvver2/>`_
- `Wikipedia: Coffee Lake <https://en.wikipedia.org/wiki/Coffee_Lake>`_
