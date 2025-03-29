.. _get_drf_last_element:

======================================
获取Django REST framework最后一个记录
======================================

通过 :ref:`drf_quickstart` 我们可以搭建一个REST系统，并且通过::

   curl -H 'Accept: application/json; indent=4' http://127.0.0.1/api/mytest/

来获得 ``mytest`` 这个API的数据，并使用::

   curl -H 'Accept: application/json; indent=4' http://127.0.0.1/api/mytest/N/

来获得第 ``N`` 条数据

但是，并不知道当前记录了多少条数据，有些业务场景只需要获得最新的数据(也就是最后一条数据)就可以，此时我们需要定制。



参考
======

- `How to access the last element added in Django Rest API? <https://stackoverflow.com/questions/58320635/how-to-access-the-last-element-added-in-django-rest-api>`_
