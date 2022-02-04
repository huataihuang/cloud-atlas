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
