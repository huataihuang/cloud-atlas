.. _intro_matrix:

======================
开源IM平台Matrix简介
======================

Internet relay chat (IRC)是一个非常古老的聊天协议，虽然现代上网用户很少关注它，但是实际上IRC是很多开源组织中非常流行的平台。IRC就像一个开放社区的最佳去中心沟通方式，任何人都能和他/她所连接的社区互动。

现代企业非常流行使用IM软件来代替传统的电子邮件进行内部交流，类似 Slack ，国内有钉钉和企业微信。实际上，古老的IRC完全能够实现这些企业级IM的功能，只不过需要进一步的适应现代互联网以及WEB。

Matrix 和 Element
===================

Matrix是一个去中心化的安全消息协议，使用HTTP和JSON API，能够完全端到端加密发送和接收消息，支持WebRTC VoIP/video护驾，以及提供更多重要的集成能力。

Matrix内建集成了IRC服务器和其他通讯协议，并且有各种客户端实现。例如，最主要的客户端是 ``Element`` ，提供了跨平台(Windows/macOS/Linux/Android/iOS)客户端软件。此外，Matrix还提供了桥接 Freenode 和 Mozilla IRC等服务，也就是可以用Element作为统一客户端来连接上述服务。

Matrix 和 Element 都是开源实现，你可以自己架设企业内部服务器以及分发企业客户端。当然， `element.io <https://app.element.io/>`_ 也提供注册服务，可以直接使用连接到互联网庞大的IRC讨论中。

.. note::

   Element.io 是一家建立在Matrix开源项目之上的公司，该公司创始人开发了Matrix协议，并一直监护Matrix开源项目。

应用
=======

Matrix和Element是商业化Slack的一个很好的开源替代，如果你注重安全隐私，可以自己构建IM系统。或者向Element.io公司购买IM服务 - 提供Matrix的SaaS服务。

- :ref:`synapse` Matrix homeserver written in Python 3/Twisted
- 打开 `Matrix客户端列表 <https://matrix.org/clients/>`_ 你会看到形形色色的使用不同语言实现的不同平台的客户端，洋洋大观可以作为学习参考

.. note::

   我是在折腾 :ref:`suckless` 时候，偶然从 ``an9wer`` 的blog `搭建自己的 IM <https://an9wer.github.io/2019/06/04_%E6%90%AD%E5%BB%BA%E8%87%AA%E5%B7%B1%E7%9A%84%20IM.html>`_ 了解到这个从未接触过的IM开源解决方案。我想在后续做一些部署和开发实践...IM开源解决方案。我想在后续做一些部署和开发实践...

参考
======

- `IRC for the 21st Century: Introducing Element.io <https://opensource.com/article/17/5/introducing-riot-IRC>`_
