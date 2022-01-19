sudo iptables -A FORWARD -o eno4 -i br0 -s 192.168.6.0/24 -m conntrack --ctstate NEW -j ACCEPT
sudo iptables -A FORWARD -o eno4 -i br0:1 -s 192.168.7.0/24 -m conntrack --ctstate NEW -j ACCEPT
sudo iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
sudo iptables -t nat -A POSTROUTING -o eno4 -j MASQUERADE
sudo sh -c "echo 1 > /proc/sys/net/ipv4/ip_forward"
