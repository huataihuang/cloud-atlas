.. _cloud-init:

==============
cloud-init
==============

cloud-init是多种发行版支持的跨平台云计算实例初始化工业标准。cloud-init支持所有主要的公有云服务商，也支持私有云基础架构和裸金属服务器安装。

云计算实例是从一个磁盘镜像和实例数据进行初始化的：

* Cloud metadata
* User data(可选)
* Vendor data(可选)

cloud-init可以在启动时运行来标识云计算厂商，从云上读取任何提供的元数据并且相应初始化系统。这个初始化过程包括设置网络和存储设备来配置SSH访问密钥以及很多系统设置，并且可以处理任何可选用户或这供应商数据。

参考
========

- `cloud-init Documentation <https://cloudinit.readthedocs.io/en/latest/index.html>`_
