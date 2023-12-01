.. _extract_proprietary_blobs_from_lineageos_zip:

=======================================
从LineageOS安装zip文件中提取专有blobs
=======================================

- 下载 `LineageOS installation package <https://download.lineageos.org/devices/flame>`_ 中的安装zip包:

.. literalinclude:: extract_proprietary_blobs_from_lineageos_zip/download_lineageos_zip
   :caption: 下载 LineageOS 最新安装zip文件

我不太确定下载的安装包zip是 `Extracting proprietary blobs from LineageOS zip files <https://wiki.lineageos.org/extracting_blobs_from_zips>`_ 哪种类型的zip，不过我看到这个zip文件解压缩后有 ``payload_properties.txt`` 和 ``payload.bin`` ，所以我推测为需要 `Extracting proprietary blobs from payload-based OTAs <https://wiki.lineageos.org/extracting_blobs_from_zips#extracting-proprietary-blobs-from-payload-based-otas>`_

- 安装 ``payload.bin`` (这个文件有 1.1G 大小)解压缩工具: 

.. literalinclude:: extract_proprietary_blobs_from_lineageos_zip/install_payload.bin_extrator
   :caption: 安装 ``payload.bin`` 解压缩工具

.. note::

   ``python3-protobuf`` 这个模块是用来处理 :ref:`protobuf` (Google的数据交换格式)，这个数据格式通过二进制方式可以极大提升数据交换性能

- 创建使用 ``payload.bin`` 解压缩工具所需的repo仓库:

.. literalinclude:: extract_proprietary_blobs_from_lineageos_zip/repo_payload.bin_extrator
   :caption: clone ``payload.bin`` 解压缩工具使用的repos

- 从 ``lineage-*.zip`` 文件的 ``payload.bin`` 中提取 ``.img`` 文件:

.. literalinclude:: extract_proprietary_blobs_from_lineageos_zip/extract_img
   :caption: 从 ``lineage-*.zip`` 文件的 ``payload.bin`` 中提取 ``.img`` 文件

- 提取后在当前目录下会有如下 ``.img`` 文件需要挂载到 ``system`` 目录下:

.. literalinclude:: extract_proprietary_blobs_from_lineageos_zip/mount_system
   :caption: 将提取的 ``.img`` 文件挂载到 ``system`` 目录下

- 然后执行 ``extract-files.sh`` 提取 blobs:

.. literalinclude:: extract_proprietary_blobs_from_lineageos_zip/extract_blobs
   :caption: 通过 ``payload.bin`` 解压缩的镜像挂载后提取blobs

上述命令会指示 ``extract-files.sh`` 脚本从指定目录下挂载的 system dump 提取 blobs ，而不是连接的设备

- 完成后就可以移除挂载并删除不需要的文件:

.. literalinclude:: extract_proprietary_blobs_from_lineageos_zip/rm_system_dump
   :caption: 移除挂载并删除不需要的文件

参考
======

- `Extracting proprietary blobs from LineageOS zip files <https://wiki.lineageos.org/extracting_blobs_from_zips>`_
