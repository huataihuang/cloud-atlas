# squid transparent proxy
sudo iptables -t nat -A PREROUTING -i br0 -p tcp --dport 80 -j DNAT --to 192.168.6.200:3128
sudo iptables -t nat -A PREROUTING -i br0:1 -p tcp --dport 80 -j DNAT --to 192.168.6.200:3128
sudo iptables -t nat -A PREROUTING -i eno4 -p tcp --dport 80 -j REDIRECT --to-port 3128

# masquerade 192.168.6.0/24 & 192.168.7.0/24
sudo iptables -A FORWARD -o eno4 -i br0 -s 192.168.6.0/24 -m conntrack --ctstate NEW -j ACCEPT
sudo iptables -A FORWARD -o eno4 -i br0:1 -s 192.168.7.0/24 -m conntrack --ctstate NEW -j ACCEPT
sudo iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
sudo iptables -t nat -A POSTROUTING -o eno4 -j MASQUERADE
sudo sh -c "echo 1 > /proc/sys/net/ipv4/ip_forward"
