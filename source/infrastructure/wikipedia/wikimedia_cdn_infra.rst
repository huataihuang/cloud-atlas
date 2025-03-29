.. _wikimedia_cdn_infra:

======================
Wikimedia CDN架构
======================

`Wikimedia <https://www.wikimedia.org/>`_ 是世界上最大的在线百科全书 `Wikipedia <https://www.wikipedia.org/>`_ 背后的协作组织，运行了世界最大的网站之一(top 10 website)，而且基础架构是该组织自行构建的，可谓令人叹为观止。

作为top 10 website， :ref:`wikipedia_early_infra` 采用 :ref:`squid` 作为缓存代理，但是随着规模不断扩大和技术发展，缓存技术从 :ref:`squid` 替换为 :ref:`varnish` ，并最终转换到 :ref:`trafficserver` 。

参考
=========

- `Wikimedia’s CDN: the road to ATS <https://techblog.wikimedia.org/2020/11/25/wikimedias-cdn-the-road-to-ats/>`_
