.. _yaml_not_find_expected_key:

===============================================
YAML转换JSON报错 ``did not find expected key``
===============================================

在提交YAML到CI/CD系统校验错误，平台提示 ::

   error converting YAML to JSON: yaml: line 47: did not find expected key

我使用 ``yamllint`` 工具进行校验::

   yamllint alert.yaml

提示信息:

.. literalinclude:: yaml_not_find_expected_key/yamllint_output
   :caption: 使用 ``yamllint`` 校验提示
   :emphasize-lines: 13

这里可以看到一些可以忽略的错误(例如行太长超过80字符)，但是最后提示错误 ``syntax error: expected <block end>, but found '<scalar>' (syntax)`` 不能忽略，确实是语法错误。但是什么是 ``<block end>`` 什么又是 ``<scalar>`` ?

我这里的YAML案例是一个告警:

.. literalinclude:: yaml_not_find_expected_key/alert.yaml
   :language: yaml
   :caption: ``alert.yaml`` 配置语法错误
   :emphasize-lines: 12

语法错误在上述高亮行，为何提示期望的内容是 ``block end`` (块结束)，而不是 ``scalar`` (纯量)

复习一下 :ref:`yaml` 语法: 纯量表示最基本的，不可再分的值。但是我没有看懂为何会提示是纯量

问了一下 :ref:`gpt` ，GPT说::

   这个错误提示意思是在yaml文件中缺少了块结束符，但却找到了标量（scalar）。
   解决方法是检查文件中是否有缺少大括号、中括号、冒号等符号的错误，如果有则添加正确的符号。

我仔细看了一下，原来我在上述 ``expr:`` 行中嵌套使用 单引号 和 双引号，我没有注意到:

  - 语法上是可以在单引号内部使用多个双引号的
  - 但是 **不能在单引号内部再使用单引号**

这导致语法断句错误::

   'sum by (cluster)(cluster:unhealthy_pod_namespace_count:sum1m{phase=~"Pending|unScheduledPending|scheduledFailedPending",namespace=' ...  '}) > 2'
 
也就是2段字符串

解决方法是修订: 

.. literalinclude:: yaml_not_find_expected_key/alert_fix.yaml
   :language: yaml
   :caption: 修订 ``alert.yaml`` ，在单引号内部只能使用双引号
   :emphasize-lines: 12

参考
======

- `error converting YAML to JSON: yaml: line 10: did not find expected key <https://unix.stackexchange.com/questions/556090/error-converting-yaml-to-json-yaml-line-10-did-not-find-expected-key>`_
