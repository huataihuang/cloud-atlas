sudo iptables -t nat -A POSTROUTING -s 192.168.1.0/24 -o wlan0 -j MASQUERADE
echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward
