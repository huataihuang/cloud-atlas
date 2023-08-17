.. _node_exporter_textfile-collector:

======================================
Node Exporter的Textfile Collector扩展
======================================

``textfile`` collector是Proetheus的一个扩展功能，可以通过定时任务输出状态，类似于 ``Pushgateway`` 。 ``Pushgateway`` 被用于服务类metrics，而 ``textfile`` 模块则用于处理主机的metrics。

在 :ref:`node_exporter` 运行参数上加上 ``--collector.textfile.directory`` 参数，则 collector 就会处理该目录下所有使用 `Prometheus Exposition formats <https://prometheus.io/docs/instrumenting/exposition_formats/>`_ 格式的以 ``*.prom`` 后缀的文件。(不支持时间戳)

( **汗，这段我没有理解，等以后再折腾** ) 对于一个cron任务要实现自动推送完成时间，可以采用如下方法(假设脚本名字是 ``count_hosts`` 用于计算服务器数量， ``/var/lib/node_exporter/textfile_collector/`` 是用来对应 ``--collector.textfile.directory`` 的存储 ``*.prom`` 文件目录):

.. literalinclude:: node_exporter_textfile-collector/count_hosts_textfile-collector
   :caption: 为脚本增加时间戳输出到 ``*.prom`` 文件

社区脚本
==========

Prometheus社区提供了 `node-exporter-textfile-collector-scripts <https://github.com/prometheus-community/node-exporter-textfile-collector-scripts>`_ ，将这些脚本下载到服务器上:

.. literalinclude:: node_exporter_textfile-collector/git_node-exporter-textfile-collector-scripts
   :caption: 下载 ``node-exporter-textfile-collector-scripts`` 到本地( ``/etc/prometheus`` )

实践案例
==========

- :ref:`node_exporter_ipmitool_text_plugin`
- :ref:`node_exporter_smartctl_text_plugin`

参考
========

- `Node Exporter (GitHub)#Textfile Collector <https://github.com/prometheus/node_exporter#textfile-collector>`_
- `Prometheus Textfile Collectors <https://www.nine.ch/en/blog/prometheus-textfile-collectors>`_ 关于如何将Nagios监控输出改成Prometheus的兼容metrics
- `Using the textfile collector from a shell script <https://www.robustperception.io/using-the-textfile-collector-from-a-shell-script/>`_ 这个文档非常简单清晰，提供了一个脚本案例将自己的输出结果转换成Prometheus textfile collector的案例，可以借鉴
