.. _docker_images_on_nfs:

======================
NFS存储Docker镜像
======================

当构建Docker镜像时，默认Docker镜像是存储在主机本地存储目录 ``/var/lib/docker`` 。但是，本地存储通常容量有限，而我们企业网络中可能会有商业NAS存储服务器，例如NetApp存储。那么，是否可以将Docker存储在容量巨大的NetApp存储卷，或者自建的NFS存储上呢？


