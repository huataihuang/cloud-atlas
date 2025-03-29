.. _convert_csv_to_json:

=======================
CSV转换JSON
=======================

:ref:`jq` 工具可以将JSON字符串转换成标准化格式，不过，我们日常经常处理的文件是 ``.csv`` 格式，转换成JSON格式后，可以方便 :ref:`javascript` 做进一步处理，例如 :ref:`patternfly_table` 。

``csvtojson`` 结合 ``jq``
===========================

- 安装 ``csvtojson`` - 部署好 :ref:`nodejs_dev_env` ，使用 ``npm`` 安装::

   npm install --location=global csvtojson

- 使用操作系统包管理器安装 ``jq`` ，例如 :ref:`redhat_linux` ::

   sudo yum install jq

- 使用方法::

   csvtojson example.csv | jq

python方式
===============

python可以使用一句命令完成转换::

   cat my.csv | python -c 'import csv, json, sys; print(json.dumps([dict(r) for r in csv.DictReader(sys.stdin)]))' | jq

参考
=======

- `Convert CSV to JSON on Linux using the Command-line <https://techexpert.tips/ubuntu/convert-csv-to-json-using-command-line/>`_
- `Converting CSV to JSON in bash <https://stackoverflow.com/questions/44780761/converting-csv-to-json-in-bash>`_
