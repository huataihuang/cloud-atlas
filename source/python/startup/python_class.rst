.. _python_class:

======================
Python类(class)
======================

面向对象编程(object-oriented programming, OOP)是最有效的软件编写方法之一。

在面向对象编程中，你编写表现现实世界中的食物和情景的类(class)，并基于止遏写类来创建对象(object)。在编写类时，你要定义一批对象都具备的通用行为。在基于类创建对象时，每个对象都自动具备这种通用欣慰。然后，可以根据需要赋予每个对象独特的个性。

根据类来创建对象称为实例化。

举例: 创建 ``Dog`` 类
=======================

.. note::

   类名的首字母大写

.. literalinclude:: python_class/dog.py
   :language: python
   :caption: 创建dog类

说明:

- ``__init__()`` 方法:

类中的函数称为 **方法** 

``__init__()`` 是一个特殊的方法，当根据类创建新实例时，Python 会自动运行 ``__init__()`` 方法，这个特殊的 ``init`` 方法名字前后各有两个下划线，这是一种约定，旨在避免Python默认方法与普通方法发生名称冲图。务必确保 ``__init__()`` 的两边都有两个下划线，否则当使用类来创建实例时，将不会自动调用这个方法，进而引发难以发现的错误。

举例: 创建Car类
=================

.. literalinclude:: python_class/car.py
   :language: python
   :caption: 创建Car类

类的继承
===========

如果编写的类是一个既有的类的特殊版本，可以使用继承(inheritance)。当一个类继承另一个类时，将自动获得后者的所有属性和方法。原有的类称为父类(parent class)，而新类被称为子类(child class)。子类不仅继承了父类的所有属性和方法，还可以定义自己的属性和方法。

重写父类中的方法
-------------------

在使用子类时，如果父类中的一些方法不能满足子类的需求，可以在子类中定义一个与要重写的父类方法同名的方法。这样，Python会忽略父类中方法，只使用子类中定义的相应方法。

- 当类继承了父类的属性进行初始化父类: ``__init__()`` 中 ``super().__init__(make, model, year)`` ，就可以开始初始化自己特有的属性

.. literalinclude:: python_class/electric_car.py
   :language: python
   :caption: 创建ElectricCar继承Car

将实例用作属性
-----------------

将大型类拆分成多个协同工作的小类，这种方法称为组合(composition)

例如在不断给 ``ElectricCar`` 类添加细节时，可能会发现有很多专门针对汽车电池的属性和方法。这种情况下，可以将这些属性和方法提取出来，放到一个名为 ``Battery`` 的类中，并将一个 ``Battery`` 实例作为 ``ElectricCar`` 类的属性:

**感觉有点类似树状结构，一个 ElectricCar 的树上挂了一个 Battery 实例的属性，就自动为这个 ElectricCar 扩展了一部分从 Battery 继承的能力**

.. literalinclude:: python_class/battery.py
   :language: python
   :caption: 单独创建一个Battery类

创建一个 ``ElectricCar`` 类，继承 ``Car`` 类，并且创建一个实例属性 ``battery`` ，指向一个 ``Battery`` 类的实例对象: ``self.battery = Battery()`` :

  - ``self.battery`` -> 访问的是当前 ``ElectricCar`` 实例上的 ``battery`` 属性(一个 ``Battery`` 对象)
  - ``self.battery.describe_battery()`` -> 在这个 ``Battery`` 对象上调用 ``describe_battery()`` 方法，即 ``ElectricCar`` 中的  ``describe_battery`` 方式只是转发了这个调用，委托给 ``self.battery`` 去执行

这种模式叫做 **组合(composition)** : ``ElectricCar`` 拥有一个 ``Battery`` 对象，而不是"继承"自 ``Battery`` 。 

.. literalinclude:: python_class/electric_car_composition.py
   :language: python
   :caption: 使用组合(composition)获得对象的方法
   :emphasize-lines: 11,15
