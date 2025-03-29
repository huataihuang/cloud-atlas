cd /tmp
version=1.6.1
curl https://onesre.cloud-atlas.io/download/node_exporter-${version}.linux-amd64.tar.gz -o node_exporter-${version}.linux-amd64.tar.gz
tar xvfz node_exporter-${version}.linux-amd64.tar.gz
cd node_exporter-${version}.linux-amd64/
sudo mv node_exporter /usr/local/bin/

sudo groupadd --system prometheus
sudo useradd -s /sbin/nologin --system -g prometheus prometheus

curl https://onesre.cloud-atlas.io/download/node_exporter.service -o /etc/systemd/system/node_exporter.service
sudo systemctl daemon-reload
sudo systemctl enable --now node_exporter
sudo systemctl status node_exporter
