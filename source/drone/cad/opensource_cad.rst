.. _opensource_cad:

====================
开源CAD
====================

.. note::

   调研一些开源CAD解决方案，为以后3D打印自制零件做一些准备

整理资料
===========

CAD
-------

- ``FreeCAD`` 最成熟的开源CAD软件，但是对装配(Assembly)实现不佳(需要使用其他实现方案，但不完善)
- ``OpenSCAD`` 非交互的设计软件，而是程序式建模语言，通过代码描述创建的模型

  - 需要代码和产生结果的抽象思维，上手比较难，但是适合重复设计修改
  - 纯代码适合跟踪和管理(类似 :ref:`git` 管理代码)
  - 非常适合零件复用，以及零件装配

.. note::

   `OpenSCAD User Manual <https://en.wikibooks.org/wiki/OpenSCAD_User_Manual>`_ 官方文档，提供了详细的使用说明

   在同一个wikibooks上还有开源的Blender 3D的书籍

- ``DeclaraCAD`` 

  - `CodeLV: DeclaraCAD <https://www.codelv.com/projects/declaracad/>`_ 目前还不是开源软件(七年前 `GitHub: tazjel/declaracad <https://github.com/tazjel/declaracad>`_ 曾经开源过，不过现在已经闭源开发)，不过其使用Python语言开发并且通过Python语言(enaml, Python的超集)定义CAD比较有特色
  - CodeLV开源了 `Inkcut <https://www.codelv.com/projects/inkcut/>`_ ，提供2D绘图、切割以及CNC加工功能
  - 从 `DeclaraCAD官网 <https://declaracad.com>`_ 可以下载到软件以及查阅文档

3D打印
---------

- ``OpenSCAD`` 支持输出STL模型文件，可以加载到3D打印机制作零部件:

  - `Practical problem solving: Programming objects for 3D printing in OpenSCAD <https://blog.prusa3d.com/practical-problem-programming-objects-3d-printing-openscad_8415/>`_
  - `Saving your STL file and preparation for 3D printing <https://www.sculpteo.com/en/tutorial/openscad-prepare-your-model-3d-printing/openscad-prepare-your-3d-object-3d-printing/>`_

参考
=======

- `纯开源CAD/CAM方案调研 <https://www.bilibili.com/read/cv9552810/>`_
