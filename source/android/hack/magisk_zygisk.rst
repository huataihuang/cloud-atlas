.. _magisk_zygisk:

=================
Magisk Zygisk
=================

Magisk v24.0 版本开始，之前Riru改成Zygisk，意思是注入 ``Zygote`` 后的Magisk。Zygisk作为Magisk模块，体痛了更深入、更强悍的修改能力: 提供一个排除列表，可以撤销Magisk做的所有修改，这样就能手动划定模块起作用的范围。

.. warning::

   **Zygisk 和 Riru Hide 不同，不能避免root被监测到，没有任何隐藏作用。**

   也就是说，即使把某个程序加入到排除列表，它依然可以发现Zygisk。 :strike:`如果用户的目的是隐藏root，只能借助其他方式，例如添加 shamiko` 也就是说，如果使用Zygisk，就可以让应用程序检测不到 Magisk 和 root，但是应用程序依然可以检测到 Zygisk。所以，如果有些应用程序对安全有强要求，并且不仅检测Magisk和root，还检测Zygisk，那么还需要安装 ``Zygisk模式下的shamiko`` 模块来进一步隐藏Root。参考 `MagiskHide没了，Zygisk又是啥？ <https://www.bilibili.com/read/cv14287396/>`_ 网友的commit，提到 "Zygisk模式下用Shamiko模块的白名单模式" :

   - 默认全局对所有应用隐藏Root
   - 除了超级用户授权过的应用可以获得Root权限，其他新装软件都完全请求不到和检测到Root
   - 开启后直接过Momo(地表最强Root检测软件)，任何新装软件都检测不到Root，需要用到ROOT关闭白名单模式后才能打开Root授权

我的实践:

- Google Play上的全家App(实际是台湾地区应用，后来我没有使用)会检测Root，我采用 Zygisk 直接可以排查Root检测，非常好用

参考
=======

- `Magisk模块Zygisk和Riru有啥区别？面具怎么打开Zygisk？ <https://www.xitmi.com/10831.html>`_
- `Magisk24.1版本Zygisk是什么？有哪些用途好处呢 <http://www.romleyuan.com/lec/read?id=712>`_
- `MagiskHide没了，Zygisk又是啥？ <https://www.bilibili.com/read/cv14287396/>`_
