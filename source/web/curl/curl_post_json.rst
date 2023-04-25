.. _curl_post_json:

========================
cURL提交json文件
========================

在使用 curl 来POST JSON数据，需要设置请求的 ``Content-Type`` 并且在命令行使用 ``-d`` 参数来传递JSON数据。这里的 JSON 内容类型是使用 ``-H "Content-Type: application/json"`` 命令参数，而 JSON 数据是作为字符串传递。需要注意，在Windows计算机上，JSON数据的双引号前面需要一个反斜杠 \ ，以下为POST JSON案例:

.. literalinclude:: curl_post_json/curl_post_json_example
   :language: bash
   :caption: 使用curl提交JSON数据

在 :ref:`alertmanager_startup` 中也采用了 POST JSON 方式向 :ref:`alertmanager` 提交测试告警:

.. literalinclude:: ../../kubernetes/monitor/alertmanager/alertmanager_startup/test_alert
   :language: bash
   :caption: 测试alertmanager

参考
=======

- `Testing AlertManager webhooks with curl <https://www.puppeteers.net/blog/testing-alertmanager-webhooks-with-curl/>`_ 这个文档很清晰
- `Posting JSON with Curl <https://reqbin.com/req/c-dwjszac0/curl-post-json-example>`_
- `Prometheus: sending a test alert through AlertManager <https://fabianlee.org/2022/07/03/prometheus-sending-a-test-alert-through-alertmanager/>`_
- `Testing Alertmanager <https://blog.mafr.de/testing-alertmanager.html>`_
- `send a dummy alert to prometheus-alertmanager <https://gist.github.com/cherti/61ec48deaaab7d288c9fcf17e700853a>`_
