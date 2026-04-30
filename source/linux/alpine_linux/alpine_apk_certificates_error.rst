.. _alpine_apk_certificates_error:

==================================
Alpine Linux执行apk证书错误修正
==================================

在 Alpine Linux（以及大多数 Linux 发行版）中，如果系统时间与现实时间偏差过大，或者根证书（CA-Certificates）过期，APK 包管理器在尝试通过 HTTPS 连接镜像站时，会因为无法验证 SSL 证书的有效期而直接中断连接。由于连接中断，底层文件无法写入，从而抛出了权限错误（其实是文件流写入失败）

我是在我的 :ref:`mba13_early_2014` :ref:`alpine_install` ，但是几个月没有使用(更新)，现在执行 ``apk install flashrom`` 以及 ``apk update`` 都出现报错:

.. literalinclude:: alpine_apk_certificates_error/apk_fail
   :caption: 由于证书错误导致apk更新失败

这种情况下，首先要检查主机的时间是否出现偏差，利用 ``date`` 检查并使用 :ref:`alpine_chrony` 矫正时间。如果时间正确，但依然报错，则基本可以确认是长时间没有更新系统，导致系统使用的证书已经陈旧过期，已经无法连接更新服务器，因为更新服务器使用https连接也无法完成。

解决方法是暂时将软件仓库更新和连接改为 ``http`` 连接，先更新一把证书，在证书满足最新且正确情况下，就能够恢复之前的 ``https`` 连接:

.. literalinclude:: alpine_apk_certificates_error/http
   :caption: 修订仓库连接改为http
