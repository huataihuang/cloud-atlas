.. _microservice_vs_monolith:

==========================
微服务和单体架构对比
==========================

.. note::

   我隐约感觉，我们这个技术行业比较容易产生" `着魔 <https://movie.douban.com/subject/1297203/>`_ "状态，很多人会鼓吹某种架构、语言而忘记我们真正需要的是创造出影响世界的产品。要避免自己掌握某种技术就希望这个技术能够解决所有问题，也不要看什么热门就推崇某项技术，我们真正需要的是解决现实的问题，创造价值。


我在观看 `B站上的「Ruby on Rails 纪录片」 <https://www.bilibili.com/video/BV1Du4y187yq>`_ 产生了了解Rails架构、实现以及现实中的技术架构。我发现加拿大的电商 ``Shopify`` 采用Rails实现的超大规模平台，也是证明一个简单的语言和框架，在正确的 "算法和数据结构" 下也能够高性能地运行。

``shopify`` 使用了十几年的单体架构以及rails的开发和部署，是值得我们借鉴和学习(而不是无脑鼓吹微服务、serverless、servicemesh等热门技术)

案例
======

GitHub(开发协作) 和 Shopify(电商) 是非常成功和现实的Ruby on Rails实践案例，而且是非常成功的单体架构(a Ruby on Rails monolith):

- GitHub从创建开始就使用Ruby on Rails，到今天(2023年4月)每天有超过1000名工程师在接近200万行代码上进行协作开发，以及每天大约20次部署，每周这些部署中的中的一次部署都会进行一次Rails升级(待学习和分析)


参考
======

- `互联网架构介绍001 之 单体架构 <https://blog.csdn.net/Ciellee/article/details/101632748>`_
- `Building GitHub with Ruby and Rails <https://github.blog/2023-04-06-building-github-with-ruby-and-rails/>`_ 中文版是InfoQ翻译的 `使用 Ruby on Rails 构建 GitHub，每周做一次升级 <https://www.infoq.cn/article/ckazwqfw5axhobr4fcti>`_
- `没用微服务，Shopify的单体程序居然支撑了127万/秒的请求？ <https://colobu.com/2022/12/04/Shopify-monolith-served-1-27-Million-requests-per-second-during-Black-Friday/>`_ 

  - `Deconstructing the Monolith: Designing Software that Maximizes Developer Productivity <https://shopify.engineering/deconstructing-monolith-designing-software-maximizes-developer-productivity>`_
  - `A Pods Architecture To Allow Shopify To Scale <https://shopify.engineering/a-pods-architecture-to-allow-shopify-to-scale>`_
