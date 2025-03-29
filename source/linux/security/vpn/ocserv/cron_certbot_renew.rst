.. _cron_certbot_renew:

=================================
使用cron定时更新letsencrypt证书
=================================

部署 :ref:`openconnect_vpn` 时，VPN的证书是由 `Let's Encrypt <https://letsencrypt.org/>`_ 签发的，这个免费签发的证书有效期3个月，所以需要设置一个定时更新证书脚本::

   IMPORTANT NOTES:
    - Congratulations! Your certificate and chain have been saved at:
      /etc/letsencrypt/live/vpn.huatai.me/fullchain.pem
      Your key file has been saved at:
      /etc/letsencrypt/live/vpn.huatai.me/privkey.pem
      Your cert will expire on 2022-05-04. To obtain a new or tweaked
      version of this certificate in the future, simply run certbot
      again. To non-interactively renew *all* of your certificates, run
      "certbot renew"

根据提示可知，需要每3个月重新执行一次 ``certbot renew`` 命令来更新证书，所以最简单方式是是使用 :ref:`cron` 定时执行脚本

- 编辑 ``root`` 用户的crontab文件::

   sudo crontab -e

- 添加以下配置，每天定时检查证书是否过期，如果过期则更新::

   @daily certbot renew --quiet && systemctl reload ocserv

参考
========

- `Set Up OpenConnect VPN Server (ocserv) on Ubuntu 20.04 with Let’s Encrypt <https://www.linuxbabe.com/ubuntu/openconnect-vpn-server-ocserv-ubuntu-20-04-lets-encrypt>`_
