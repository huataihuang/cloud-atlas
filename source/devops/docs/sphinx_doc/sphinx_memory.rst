.. _sphinx_memory:

===================================
Sphinx 内存
===================================

我租用的VPS虚拟机为了节约经费，购买的是每月5刀最低规格，仅仅有1GB内存。在实际使用中，我尝试在 :ref:`podman` 容器环境中构建Sphinx文档，其中 ``make html`` 每次运行都会因为内存不足而OOM:

.. literalinclude:: sphinx_memory/oom
   :caption: 因内存不足而OOM

Gemini提供了一些建议，我的实践验证，还是通过设置 :ref:`linux_swap` :

.. literalinclude:: ../../../linux/admin/linux_swap/swapfile_alpine_2g
   :caption: 为alpine linux配置2G交换文件

实践确实满足了我的Sphinx文档 ``make html`` :

.. literalinclude:: sphinx_memory/make_html
   :caption: 耗时19分钟完成 ``make html``

至少完成，满意
