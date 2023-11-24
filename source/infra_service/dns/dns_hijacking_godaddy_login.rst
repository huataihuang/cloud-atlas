.. _dns_hijacking_godaddy_login:

=====================
DNS劫持和Godaddy登陆
=====================

我在准备修订DNS记录时，发现我原先在Godaddy注册的域名，现在已经无法直接访问 `Godaddy网站 <https://www.godaddy.com>`_ 了。我也遇到了 `V2EX: godaddy 被污染登陆页面打不开，挂代理能打开，但登陆检查不让挂代理，死循环如何破解 <https://www.v2ex.com/t/984163>`_ 相同问题:

- Godaddy 网站登陆会拒绝使用VPN的连接，这对墙内用户极不友好，因为不开启VPN是访问不了被墙网站的(Godaddy在2023年被GFW墙了)
- 目前网上的资料显示Godaddy并不是完全被GFW封锁，GFW对Godaddy的屏蔽是通过DNS劫持实现的，也就是在国内访问GoDaddy的DNS解析是错误的

静态解析 ``hosts`` 配置
=========================

我验证了一下，在家中(中国移动宽带)，使用 :ref:`dig` 查询 ``www.godaddy.com`` 返回的IP地址是 ``103.252.115.49`` 。这个地址是哪里呢？ 从 `ip138.com 查询 103.252.115.49 <https://www.ip138.com/iplookup.php?ip=103.252.115.49>`_ 可以看到这个IP地址 ``ASN归属地`` 是 ``日本东京都`` ，运营商是 ``Twitter`` 。也就是说，在国内DNS解析 ``Godaddy`` 会被解析成我们无法访问的Twitter的IP，也就是会被GFW挡住。

有网友建议使用本地 ``hosts`` 文件解析，关键是如何找到Godaddy的众多网站域名对应的IP地址:

- 先登陆到墙外的VPS上，然后在墙外VPS上使用 :ref:`dig` 或者 ``host`` 命令查询Godaddy的域名
- 由于WEB网站会包含很多服务器域名，所以即使访问一个简单 ``www.godaddy.com`` 也会连接不同的服务器: 通过 ``chrome`` 的 ``Developer Tools`` 工具，可以查看一个WEB页面访问的所有site地址(确实有点多)，然后一一在外网VPS上查询对应IP

简单总结一下 ``/etc/hosts`` :

.. literalinclude:: dns_hijacking_godaddy_login/hosts
   :caption: 外网查询到的Godaddy的域名静态解析配置

.. note::

   很不幸，即使通过 ``/etc/hosts`` 配置文件静态解析来访问Godaddy也不是很可靠，因为Godaddy的IP通讯被GFW丢弃的包太多，不太稳定，需要反复刷新，断断续续访问。目测在公司办公网络访问比在家中宽带要好一些。

远程Windows主机桌面
=====================

另一个建议是使用墙外虚拟机的Windows远程桌面，不过我对比了一下Vultr提供的Windows虚拟机价格，一方面有License授权费，另一方面Windows运行的硬件配置要高一档，导致Windows虚拟机大约是Linux虚拟机的4~5倍价格。不过，万不得已，我还是尝试了一下

.. note::

   从技术角度，要节约费用可以使用Linux的 :ref:`x_window` 远程桌面，甚至可以考虑部署 :ref:`xpra` 或者构建一个 WEB 访问的远程桌面... 我突然想到这是一个绝佳的技术挑战，等过一段时间空闲了来折腾一下。这样即节约了费用，又能够锻炼技术

DNS over HTTPS
=================

DNS over HTTPS一定程度上能够防范DNS劫持，因为DNS查询都通过HTTPS传输，所以可以防止中间人恶意修改DNS查询结果。不过，目前常用的DNS over HTTPS服务访问似乎被GFW封锁了，所以不使用VPN或SSH tunnel，似乎很难实现干净的DNS查询。

FireFox内置了DNS over HTTPS支持，可以尝试参考 `Configure DNS over HTTPS protection levels in Firefox <https://support.mozilla.org/en-US/kb/dns-over-https>`_ ，不过我依然没有尝试成功。应该是访问不了Cloudflare的DoH服务导致的。

参考
======

- `Wikipedia: DNS hijacking <https://en.wikipedia.org/wiki/DNS_hijacking>`_
- `Wikipedia: 域名服务器缓存污染 <https://zh.wikipedia.org/wiki/%E5%9F%9F%E5%90%8D%E6%9C%8D%E5%8A%A1%E5%99%A8%E7%BC%93%E5%AD%98%E6%B1%A1%E6%9F%93>`_
- `Wikipedia: DNS over HTTPS <https://en.wikipedia.org/wiki/DNS_over_HTTPS>`_
