.. _host_time_init:

=======================
主机时间初始化
=======================

Linux主机安装之后，如论是 :ref:`redhat_linux` 还是 :ref:`ubuntu_linux` ，作为日常客户端，配置准确的系统时钟是必不可少的步骤。这里汇总一些常见的必要操作

- 默认发行版，例如 :ref:`raspberry_pi` 官方 ``Raspberry Pi OS`` 是以厂商所在国家(英国)来设置默认时区(以及国际化语言配置)，所以作为中国用户，很可能需要调整为本地时区:

.. literalinclude:: host_time_init/local_timezone.sh
   :language: bash
   :caption: 配置上海本地时区
