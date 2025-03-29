.. _choice_design_system:

=================
选择设计系统
=================


我在选择构建系统管理平台的framework时，对比了一些框架 （ `Web前端开发必不可少的9个开源框架 <https://www.51cto.com/article/616812.html>`_ 介绍了一些常见框架 ) ，我感觉:

- 大多数UX框架是通用型框架，主要是为了构建CMS，较少是类似PatternFly针对运维类工具平台的框架(短暂对比查找我甚至没有找到对标的合适框架)
- 比较易于使用的开发框架(但并不类似PatternFly针对运维平台):

  - `Clarity Design System <https://clarity.design>`_ 和PatternFly对标的UX开发框架，但是集成Angular组件来实现交互。这是另外一个前端框架体系(Augular框架由Google开发)，和PatternFly基于的React前端框架不同(React框架由Facebook开发)。这个UX开发框架是Vmware开源的，主要用于Vmware的Vsphere平台，也非常美观

    - Clarity 新一代设计拆分成 core / auglar / react / city 多个npm软件包
    - `Clarity Medium Blog <https://medium.com/claritydesignsystem>`_ 提供了学习资料

  - `material-ui <https://github.com/mui/material-ui>`_ : React UI库，适合开发产品界面，功能丰富美观，通用型框架，从GitHub的Star数量(8w+)可以看出远胜于其他框架( ``Clarity`` 6.5k star / ``PatternFly`` 500 star 属于小众UX )

    - 后续开发通用型交互界面可以考虑采用 ``material-ui`` 提供Google Material Disign风格的框架

- 通用框架:

  - `Semantic UI <https://semantic-ui.com>`_ 在GitHub上有5w+的Star数量

.. note::

   如果使用 :ref:`rust` 开发WEB，可以尝试 `Yew Rust开发WEB框架 <https://yew.rs>`_ (GitHub 2.3w star) 。 `A Rusty frontend: Patternfly & Yew <https://dentrassi.de/2021/01/08/rusty-frontend-patternfly-yew/>`_ 介绍了如何结合PatterFly和Yew，我觉得后续可以尝试这个开发模式。

.. note::

   如果使用轻量级的python web开发框架 ``flask`` (对比 :ref:`django` )，可以考虑参考 `Flask-Admin-Dashboard <https://github.com/jonalxh/Flask-Admin-Dashboard>`_

选择
=========

`Design Systems Gallery <https://designsystemsrepo.com/design-systems-recent/>`_ 汇总列出了大量的设计系统，包括我前面所说的PatternFly / Clarity / material-ui 。实际上，你可以看到这个网站上列出了上百个设计系统，让人眼花缭乱。这里提供了各个公司的设计UX指南以及框架，例如Ant Design(蚂蚁的UX)，以及SAP,GitLab等等

**后来我想了一下，其实选择UX框架并不重要** 因为实际底层还是 ``Augular`` 和 ``React`` ，再底层其实还是 :ref:`javascript` 。真正技术核心还是以 ``Augular`` 和 ``React`` 为主，所以只要能够掌握 ``Augular`` 或者 ``React`` ，那么切换UX框架也是比较容易的。这样我也就不再纠结Design System的选择了，选择符合自己工作需求为主。目前我选择 ``PatternFly`` 主要原因是:

- 目前开源软件巨头Red Hat主要采用自己开的 ``PatternFly`` ，例如 :ref:`openshift` 和 :ref:`ovirt` 等。所以熟悉这个UX框架，也方便比较深入学习Red Hat系列的软件
- 如 `Hacker News: PatternFly – a web UI framework by RedHat (patternfly.org) <https://news.ycombinator.com/item?id=17161536>`_ 中有一位使用了两年PatternFly的用户说道: 使用PatternFly框架主要是该框架针对企业应用的快速构建，虽然有很多限制但是对于利基市场(狭小)有一定竞争力，特别是对于后端开发人员不太关注前端的开发，使用较为便利。该用户现在也转向其他UX框架( `Semantic UI <https://semantic-ui.com>`_ )
- ``PattenFly`` 底层使用了 TypeScript ，并且基于 ``React`` ，这两个技术都是目前非常主流的 :ref:`javascript` 开发框架
- 后端可以采用 :ref:`golang` 或者 :ref:`rust` 来实现，方便开发基础软件

因为我主要在做后端运维和开发，所以前端无法投入太多精力，就选择PatternFly作为辅助开发框架。

参考
======

- `Hacker News: PatternFly – a web UI framework by RedHat (patternfly.org) <https://news.ycombinator.com/item?id=17161536>`_ 这是一个著名的(出圈)有关PatternFly的讨论，RedHat内部员工吐槽PatternFly引发不同观点碰撞，国内有中文IT资讯网站评述过这个事件
- `通过PatternFly超越Bootstrap <https://blog.csdn.net/cumj63710/article/details/107422547>`_
