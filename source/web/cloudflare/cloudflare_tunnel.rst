.. _cloudflare_tunnel:

=====================
Cloudflare Tunnel
=====================

我在部署自己的 「云图 -- 云计算图志」 `docs.cloud-atlas.io <https://docs.cloud-atlas.io>`_ 采用了:

:ref:`nginx_reverse_proxy_https` (部署在阿里云) 结合 :ref:`ctunnel` 穿透连接家里的树莓派集群来构建

整个链路都由自己构建提高了技术控制能力，但是我也发现阿里云的个人ECS主机外部访问HTTPS接口总是在某些环境时间歇性卡顿(页面显示网络断开连接)，所以考虑是否采用更为稳定的Cloudflare服务:

- 由Cloudflare Tunnel来承担 :ref:`nginx_reverse_proxy_https` + :ref:`ctunnel` 工作，自带SSL认证
- 后续再将DNS迁移到Cloudfare DNS来使用 :ref:`cloudflare_cdn`

参考
======

- `无需公网IP！CloudFlare Tunnel内网穿透实现内网访问 <https://post.smzdm.com/p/admp85dn/>`_
- `基于 Cloudflare Tunnel 进行内网穿透 <https://gythialy.github.io/expose-homelab-service-via-cloudflare-tunnel/>`_
- `使用Cloudflare Tunnel实现内网穿透，把服务器架在家里 <https://bra.live/setup-home-server-with-cloudflare-tunnel/>`_
- `CloudFlare Tunnel 免费内网穿透的简明教程 <https://sspai.com/post/79278>`_
