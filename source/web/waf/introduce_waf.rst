.. _introduce_waf:

=========================
Web应用防火墙(WAF)简介
=========================

Web应用防火墙(WAF)是一种用于检查和分析HTTP流量的防火墙，提供了防范拒绝服务和数据盗窃的能力。WAF让系统管理员能够控制Web请求和系统返回的应答而无需修改后端代码。WAF和常规的保护特定web应用的防火墙不同，并且它不需要和web应用关联。

如果web应用程序没有漏洞和关键入口的防护，则非常容易被各种攻击摧毁。通常我们采用WAF来提供安全漏洞防火，或者直接对web应用程序修复，这两种方法都是可行的。WAF提供了一个扩展的外部安全增，增强了系统安全，在Web应用服务器之前提供保护。

WAF提供了HTTP协议增强，在受到攻击时，可以防护缓存移除或者DoS。

.. note::

   WAF仅是安全解决方案的一部分，我们需要结合网络防火墙和入侵检测系统来加固外部防护。

参考
======

- `Best Free Web Application Firewalls – Add an External Security Layer <https://www.linuxlinks.com/best-free-web-application-firewalls-add-an-external-security-layer/>`_
