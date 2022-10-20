.. _patternfly_customize:

====================
PatternFly定制
====================

全局CSS变量
===========

- ``src/app/app.css`` 中可以定义全局变量，全局变量用 ``:root`` 扩起::

   :root {
     /* Default & hovered link colors */
     --pf-global--link--Color: #06c;
     --pf-global--link--Color--hover: #004080;
   }

- `PatternFly: full list of global CSS variables <https://www.patternfly.org/v4/developer-resources/global-css-variables#global-css-variables>`_

这里定义的颜色可以用于不同组件，例如 页头 的背景色 ``page__header`` ，我在 ``app.css`` 中添加如下内容(参考教程案例)::

   .pf-c-page {
     --pf-global--link--Color: var(--my-app-card-theme--Color);
     --pf-c-page__header--BackgroundColor: var(--pf-global--palette--blue-400);
   }


参考
========

- `PatternFly Global CSS variables <https://www.patternfly.org/v4/developer-resources/global-css-variables>`_
