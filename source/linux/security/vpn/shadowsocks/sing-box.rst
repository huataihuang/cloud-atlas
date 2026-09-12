.. _sing-box:

===================
sing-box
===================

安装
======

- alpine linux上可以直接安装 ``sing-box`` :

.. literalinclude:: sing-box/install
   :caption: apk可以直接安装sing-box

配置
=======

- 配置文件 ``/etc/sing-box/config.json`` :

.. literalinclude:: sing-box/config.json
   :language: json
   :caption: sing-box配置

- 在正式运行前，先进行配置验证以及前台测试:

.. literalinclude:: sing-box/test
   :caption: 测试

.. note::

   客户端和服务器端的加密协议必须一致，否则会静默抛弃数据包，会看不到任何返回数据

- 测试完成后，再继续修订 ``config.json`` ，增加 "智能分流配置" :

.. literalinclude:: sing-box/config_rules.json
   :language: json
   :caption: sing-box配置增加route rules

规则解析
---------

.. csv-table:: sing-box route rules规则解析
   :file: sing-box/rules.csv
   :widths: 25,25,25,25
   :header-rows: 1

服务配置
-----------

- 测试完成后，最后将 ``sing-box`` 服务添加到启动

.. literalinclude:: sing-box/openrc
   :caption: 配置OpenRC服务

参考
=======

- gemini
