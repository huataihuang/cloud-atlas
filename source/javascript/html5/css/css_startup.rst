.. _css_startup:

===============
CSS快速起步
===============

CSS是一组规则，其中每条规则制定了网页中的元素及其样式:

.. literalinclude:: css_startup/css_demo.html
   :language: html
   :caption: css_demo.html 使用外部css
   :emphasize-lines: 4

.. literalinclude:: css_startup/styles.css
   :language: css
   :caption: 指定网页元素及其样式 styles.css

可以看到:

- ``css_demo.html`` 引用外部 ``styles.css`` : ``<link rel="stylesheet" href="styles.css">``
- ``styles.css`` 配置的 ``h1.drink`` 是对象 ``<h1 class="drink"></h1>`` 配置为棕色； ``p`` 对象设置字体 ``sans-serif``

显示效果如下:

.. figure:: ../../../_static/javascript/html5/css/css_demo.png
   :scale: 80

   采用 styles.css 后页面显示效果

说明
------

每个样式规则为一个或多个HTML元素指定一个或多个格式化信息，语法结构如下:

.. literalinclude:: css_startup/css_structure.json
   :language: json
   :caption: 样式表语法

- ``selector`` (选择符) : 浏览器会在整个页面中查找选择符匹配的元素
- ``property`` (属性) : 也就是样式，如颜色、字体、对齐方式等等
- ``value`` (值) : 样式值，对于颜色，这个值可以是浅蓝色或淡绿色等等
- 在CSS中，注释和HTML不同，使用的是 :ref:`clang` 注释风格 ``/* 注释内容 */``

.. note::

   除了上述通过独立引用 ``styles.css`` 文件来使用样式，还可以直接把样式信息嵌入到元素中(使用 ``style`` 属性:

   .. literalinclude:: css_startup/style_property.html
      :language: html
      :caption: 使用 ``style`` 属性

   或者将全部样式嵌入到 ``<style>`` 元素中，这个 ``<style>`` 元素放在页面的 ``<head>`` 部分

参考
=======

- `w3schools.com: HTML Styles - CSS <https://www.w3schools.com/html/html_css.asp>`_
- ``Head First JavaScript``
- `HTML5秘籍(第二版) <https://book.douban.com/subject/26342322/>`_
