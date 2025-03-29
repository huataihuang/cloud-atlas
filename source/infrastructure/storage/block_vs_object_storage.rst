.. _block_vs_object_storage:

=======================
块存储 vs. 对象存储
=======================

- ``块存储`` 提供了 ``固定大小`` ( ``fixed-sized`` ) 裸存储(raw storage)，必须attach到一个操作系统上才能使用

  - 每个块存储卷可以被视为一个独立的磁盘驱动器，并且由外部服务器操作系统控制
  - 块存储设备可以被 ``guest`` 操作系统挂载，并且被视为一个物理磁盘
  - 典型的块存储设备:

     - SAN
     - iSCSI ( :ref:`linux_iscsi` )
     - 本地磁盘
     - :ref:`longhorn`

  - 使用场景:

    - 数据库: 数据库需要稳定的 I/O 性能和低延迟连接
    - RAID卷: RAID使用块设备(磁盘)来构建条带化或镜像
    - 任何需要服务端进程的应用: 如Java, PHP 和 .Net需要块设备存储
    - 运行关键应用: 如Oracle, SAP, Microsoft Exchange / SharePoint

  - 块存储的云计算:

    - AWS Elastic Block Storage(EBS) 对于EC2实例就是一块硬盘，一旦挂载磁盘，就可以创建文件系统并直接使用磁盘
    - Rackspace Cloud Block Storage
    - Azure Premium Storage
    - Google Persistent Disks

- ``对象存储`` 包含了 ``对象数据`` (object data) 和 ``元数据`` (metadata)，可以 ``通过API直接访问`` 或者通过 ``http/https`` 访问

  - 对象存储可以任何类型数据，照片，视频，日志
  - 对象存储数据可以分布在不同数据中心，并提供简单的web服务接口来访问
  - 对象存储提供了 ``存储无限量媒体文件`` 的能力，数据存储可以达到数百TB到PB甚至更多

  - 典型对象存储:

    - :ref:`ceph`
    - :ref:`openstack` 的对象存储 Glance

  - 使用场景:

    - 存储 ``非结构化数据`` (unstructured data)，如音乐，图片和视频文件
    - 存储备份文件，数据库dump和日志文件
    - 大数据集: 如药物或金融数据，或者多媒体文件，都可以作为 :ref:`big_data` 对象存储
    - 替代本地磁带设备都归档文件

  - 对象存储都云计算:

    - Amazon S3
    - Rackspace Cloud Files
    - Azure Blob Storage
    - Google Cloud storage

参考
=======

- `Understanding Object Storage and Block Storage Use Cases <https://cloudacademy.com/blog/object-storage-block-storage/>`_
