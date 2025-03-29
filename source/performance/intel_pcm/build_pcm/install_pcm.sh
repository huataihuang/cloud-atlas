curl https://onesre.cloud-atlas.io/download/pcm.tar.gz -o /pcm.tar.gz
cd /
tar xfz pcm.tar.gz
systemctl daemon-reload
systemctl enable --now pcm-exporter
rm /pcm.tar.gz
