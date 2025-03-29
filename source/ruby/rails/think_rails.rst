.. _think_rails:

=====================
Rails 思考
=====================

楔子
======

在学习Rails之前，我建议你先看一下 `B站上的「Ruby on Rails 纪录片」 <https://www.bilibili.com/video/BV1Du4y187yq>`_ 

英文原版纪录片 `Ruby on Rails: The Documentary <https://www.youtube.com/watch?v=HDKUEXBF3B4>`_ :

.. youtube:: HDKUEXBF3B4

   `Ruby on Rails: The Documentary <https://www.youtube.com/watch?v=HDKUEXBF3B4>`_

我感觉这是个人开发者一个非常好的启示录

思考
=======

ruby或许会让你成为一个优秀的程序员
-----------------------------------

rails的创造者大卫说 **他曾经多次学习开发，但都失败了** 。他似乎学习过多种语言，例如java，但是很沮丧。但是他发现ruby是一个非常类似英语的自然语言， **他非常喜欢ruby，学习并开发了rails框架** 。他说他不是好的程序员，但是能用ruby开发出程序，这就很好。ruby / rails  可以让他从一个非常初级的程序员一直成长到公司的顶级程序员(他用手在空中画了一条上升的曲线)。

我觉得可能这些西方人从小受到的教育和环境就非常鼓励他们不断尝试，失败也没有什么，所以他甚至不必是全能或者优秀的天才，就能自己作出作品。我非常钦佩他的态度，也感觉到创造出这些影响力巨大的语言、框架的人，他们的生活和工作的方式是值得我们学习借鉴的。

社区融合
---------

纪录片中提到的一个竞争框架 `GitHub: merb <https://github.com/wycats/merb>`_ 最终社区合并到Rails，Merb的核心开发者Yehuda Katz(Ember.js创建者，Rust,Rails和jQuery的核心开发者，著名程序员)在个人网站撰写了 `Together: The Merb Story <https://yehudakatz.com/2020/02/19/together-the-merb-story/>`_ 讲述了两个WEB框架合并的故事，可以作为纪录片的补充。

shopify的故事
----------------

shopify的创始人最初使用Rails开发的时候，rails还只是1.0。但是简洁灵活有效的框架使得shopify的电商平台快速建立并取得商业成功。然后shopify不断投入rails的开发，最终使得shopfiy的系统成为延续最持久同时也是非常成功的rails开发的平台项目。在 `Shopify Engineering <https://shopify.engineering/>`_ 能够找到shopify工程师的技术和经验分享:

- shopify没有盲目追求微服务这样的技术热点，而是在自己的rails单体架构上演化迭代，实现模块分离，自己创建了一种类似 :ref:`kubernetes` 的pod部署，实现了水平扩展:  `没用微服务，Shopify的单体程序居然支撑了127万/秒的请求？ <https://colobu.com/2022/12/04/Shopify-monolith-served-1-27-Million-requests-per-second-during-Black-Friday/>`_ ， "鸟窝" 的这篇综合性技术架构文章可以看出Shopify的Rails架构稳健演进，更细节技术可以参考 `Shopify Engineering <https://shopify.engineering/>`_ 原文
- InfoQ上有一篇2018年早期的技术翻译文章 `电商平台 Shopify 的技术架构演进思路 <https://www.infoq.cn/article/e-commerce-at-scale-inside-shopifys-tech-stack>`_ 可以参考

我觉得我们做技术的人往往有一种迷思，总是追求大而全的技术，追求规模极致化来彰显自己的技术。然而，很多技术可能是屠龙之技，甚至没有成型的产出。反过来说，ruby这种看起来简单的脚本语言，在合适的使用下，按照shopify创始人的说法，只要是正确的数据结构和算法，现代计算机就能够高效运行，所以不要忽略这种简单的语言，你应该追求的是产出产品，经历实际的应用，才能不断迭代改进。

即使像Rails这样的框架，很多鼓吹技术的人说rails不适合大型平台，不适合大型项目。但是，这个世界上，大多数公司规模都很小，甚至无法生长到超出rails简单单体架构的支持范围，而这些企业、idea需要的是快速落地，在商业上尝试不同的方向，最终看能否存活或者重新来过。这时候，类似PHP和Rails这样简单快速的技术可能才是最合适的。更何况，即使规模增长到像GitHub和Shopify这样大规模，依然可以有不同的架构演进(存储、计算、网络)来平稳扩展Rails，实现秒级百万的服务峰值支持l

37signals
==============

最后，在Rails的背后，有一个非常著名的 `37signals <https://37signals.com/>`_ ，它甚至不是一个公司，而是一个ideas的汇总，它是自由思考的自然产物。37signals还出版了颇具影响的 「ReWork」来推广他们的理念。

「37signals」公司现在已经改名为 「Basecamp」，这是他们研发的一款项目管理软件 ``Basecamp`` 得名: 因为有很多客户使用了他们开发的这款自用软件，「37signals」对这款软件进行打磨和定价正式对外开放，很快受到用户欢迎，并且成为公司最具营收的产品。这样「37signals」就从网页设计公司转型为专做项目软件，也做了公司改名。

虽然Basecamp全球有200万客户，获得4100万美元营收(数据可能是2022年)，但公司依然保持极小规模，不足100人:

- Basecamp 就代表了小型专注于创造价值的 SaaS 公司: 为客户创造了价值，为员工创造了事业和收入
- 拒绝融资，也不追求快速扩张和上市:

  - SaaS是一个长期业务，需要坚持长期主义
  - 拒绝融资可以保持最初的灵活，专注于提高效率创造盈利而不是烧钱来获取营收
  - 看重价值，而非估值

参考
======

- `B站上的「Ruby on Rails 纪录片」 <https://www.bilibili.com/video/BV1Du4y187yq>`_
- `37signals——这家上个世纪成立的 SaaS 公司给了我们哪些启示？ <https://www.woshipm.com/chuangye/5498306.html>`_
