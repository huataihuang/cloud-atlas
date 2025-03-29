.. _arm_neve:

==================================================================
ARM嵌套虚拟化扩展(NEVE: Nested Virtualization Extensions for ARM)
==================================================================

随着虚拟化云计算架构的发展，在现有云计算虚拟机中运行虚拟机的软件堆栈成为一种越来越重要的能力。嵌套虚拟化，也就是虚拟机中运行虚拟机，成为服务器领域的云计算关键技术。对于Intel有这样的 :ref:`intel_vmcs` 技术用来加速 Nested Virtualizaion，而ARM也在2017年和哥伦比亚大学(Columbia University)共同研发推出了对标的NEVE(Nested Virtualization Extensions for ARM)技术。

.. note::

   参考 `Haker News: Ubuntu successfully virtualized on M1 <https://news.ycombinator.com/item?id=25221244>`_ 苹果的 Apple M1处理器是 ARM v8.4 架构实现，也包含了 Nested virtualization技术，不过苹果自身的虚拟化解决方案没有支持。看来，还是需要在 Linux on M1 上实践该解决方案。

参考
======

- `NEVE: Nested Virtualization Extensions for ARM <http://www.cs.columbia.edu/~cdall/pubs/sosp2017-neve.pdf>`_
- `NEVE: Nested Virtualization Extensions for ARM 介绍PPT <https://www.sigops.org/s/conferences/sosp/2017/slides/neve-sosp17-slides.pdf>`_
