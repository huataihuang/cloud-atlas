.. _intro_patternfly:

======================
PatternFly简介
======================

PatternFly是一个开源设计系统，以统一和有效访问一系列应用程序和用户案例。PatternFly提供了清晰的标准，指导和工具帮助设计师和开发者一起更高效工作并创建更好的用户体验。

Red Hat Developer 网站提供了 `Developing with PatternFly React教程 <https://developers.redhat.com/courses/patternfly-react>`_ ，并且在持续更新。由于PatternFly非常小众，实际参考资料极少，所以这个网站是比较值得参考的资料。

.. note::

   我在选择构建系统管理平台的framework时，对比了一些框架 （ `Web前端开发必不可少的9个开源框架 <https://www.51cto.com/article/616812.html>`_ 介绍了一些常见框架 ) ，我感觉:

   - 大多数UX框架是通用型框架，主要是为了构建CMS，较少是类似PatternFly针对运维类工具平台的框架(短暂对比查找我甚至没有找到对标的合适框架)
   - 比较易于使用的开发框架(但并不类似PatternFly针对运维平台):

     - `Clarity Design System <https://clarity.design>`_ 和PatternFly对标的UX开发框架，但是集成Angular组件来实现交互。这是另外一个前端框架体系(Augular框架由Google开发)，和PatternFly基于的React前端框架不同(React框架由Facebook开发)。这个UX开发框架是Vmware开源的，主要用于Vmware的Vsphere平台，也非常美观

       - Clarity 新一代设计拆分成 core / auglar / react / city 多个npm软件包
       - `Clarity Medium Blog <https://medium.com/claritydesignsystem>`_ 提供了学习资料

     - `material-ui <https://github.com/mui/material-ui>`_ : React UI库，适合开发产品界面，功能丰富美观，通用型框架，从GitHub的Star数量(8w+)可以看出远胜于其他框架( ``Clarity`` 6.5k star / ``PatternFly`` 500 star 属于小众UX )

       - 后续开发通用型交互界面可以考虑采用 ``material-ui`` 提供Google Material Disign风格的框架

.. note::

   如果使用 :ref:`rust` 开发WEB，可以尝试 `Yew Rust开发WEB框架 <https://yew.rs>`_ (GitHub 2.3w star) 。 `A Rusty frontend: Patternfly & Yew <https://dentrassi.de/2021/01/08/rusty-frontend-patternfly-yew/>`_ 介绍了如何结合PatterFly和Yew，我觉得后续可以尝试这个开发模式。

.. note::

   如果使用轻量级的python web开发框架 ``flask`` (对比 :ref:`django` )，可以考虑参考 `Flask-Admin-Dashboard <https://github.com/jonalxh/Flask-Admin-Dashboard>`_

基本结构
===========

- Components(组件)

Components类似于构建块(building blocks)。设计是可伸缩和模块化的，可以混合和匹配组件来创建任何UI

- Layouts(层)

层提供了组件的组织有序，可以针对任何屏幕进行规范对齐

- Demos

Demons展示了多个组件如何用于一致的设计，并且提供有用的启动代码，这样就可以在此基础上进行进一步开发

设计指南
==========

- Styles

风格指南定义了功能性的设计系统，例如色彩，版面设计以及留白(spacing)

- 使用和特性(Usage and behavior)

Usage and behavior guidelines提供了通用设计模式的社区标准和最佳实践，例如导航、面板(dashboards)或者论坛(forms)

- UX编写(UX writing)

内容指南提供了有关用户写作体验的概念和最佳实践

附加工具
===========

- CSS变量: 通过使用CSS变量系统，可以定制PatternFly以适合自己的项目。CSS变量系统是一个2层主题系统提供了:

  - 全局变量(Global variables)
  - Component variables(组件变量)

- 工具(Utilities)

工具是一组类，可以激活需要定制和修改元素，无需写任何自定义CSS
  

参考
=====

- `About PatternFly <https://www.patternfly.org/v4/get-started/about>`_
- `Developing with PatternFly React <https://developers.redhat.com/courses/patternfly-react>`_
