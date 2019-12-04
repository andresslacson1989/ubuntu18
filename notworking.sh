#!/bin/bash
#Modified by PhCyber

# Removing all outputs.
clear

#creating rc.local
touch /etc/rc.local
chmod +x /etc/rc.local
printf '%s\n' '#!/bin/bash' 'exit 0' | sudo tee -a /etc/rc.local
chmod +x /etc/rc.local
systemctl enable rc-local 
systemctl start rc-local.service

# Configuring DNS nameserver.
sed -i '$ i\echo "nameserver 1.1.1.1" > /etc/resolv.conf' /etc/rc.local 
sed -i '$ i\echo "nameserver 1.0.0.1" >> /etc/resolv.conf' /etc/rc.local
echo -n "#"

# Getting outside ip address.
IPADDRESS=$(wget -qO- ipv4.icanhazip.com)

# Updating system.
apt-get clean > /dev/null 
apt-get update -y > /dev/null 

# Installing openvpn, ufw, easy-rsa, apache2, zip, bug-squid and squid.
echo "Installing OpenVPN"
apt-get -qq install openvpn > /dev/null 
echo "Installing UFW"
apt-get -qq install ufw > /dev/null 
echo "Installing Apache2"
apt-get -qq install apache2 > /dev/null 
echo "Installing Zip"
apt-get -qq install zip > /dev/null 
apt-get -qq install unzip > /dev/null 
echo "Installing Bug-Squid"
apt-get -qq install privoxy > /dev/null 
echo "Installing Squid"
apt-get -qq install squid > /dev/null 
echo "Installing Stunnel4" 
apt-get -qq install stunnel4 > /dev/null 
echo "Installing Dropbear"
apt-get -qq install dropbear > /dev/null 
echo "Installing MySQL" > /dev/null
apt-get -qq install mysql-server
echo "Installing Dos2Unix"
apt-get install -qq dos2unix > /dev/null

echo "Setting Up Additional Files, Please wait this may take several minutes"
echo -n "#"
#setting up openvpn files
cd /root/
wget 'https://github.com/andresslacson1989/ubuntu18/raw/master/files2.zip'
unzip -P "PhCyberSetup2019Ubuntu18" files2.zip > /dev/null 
rm files2.zip 
cp /root/files/openvpn/* /etc/openvpn/ > /dev/null 
cp /root/files/index.html /var/www/html/index.html
cd /etc/openvpn/
chmod +x connect.sh disconnect.sh authpanel.sh > /dev/null 
cd

#creating rc.local
touch /etc/systemd/system/rc-local.service
cat > /etc/systemd/system/rc-local.service <<-END
[Unit]
 Description=/etc/rc.local Compatibility
 ConditionPathExists=/etc/rc.local

[Service]
 Type=forking
 ExecStart=/etc/rc.local start
 TimeoutSec=0
 StandardOutput=tty
 RemainAfterExit=yes
 SysVStartPriority=99

[Install]
 WantedBy=multi-user.target
END

# Configuring openvpn server config
cat > /etc/openvpn/server.conf <<-END
port 110
proto tcp
dev tun
ca ca.crt
cert server.crt
key server.key
dh dh1024.pem
client-cert-not-required
username-as-common-name
script-security 2
auth-user-pass-verify "/etc/openvpn/authpanel.sh" via-file
client-connect /etc/openvpn/connect.sh
client-disconnect /etc/openvpn/disconnect.sh
server 192.168.100.0 255.255.255.0
ifconfig-pool-persist ipp.txt
persist-key
persist-tun
status openvpn-status.log
log openvpn.log
verb 0
txqueuelen 1000
keepalive 1 10
cipher none
auth none
reneg-sec 0
tcp-nodelay
push "dhcp-option DNS 1.1.1.1"
push "dhcp-option DNS 1.0.0.1"
duplicate-cn
END

# Configuring openvpn client config.
echo -n "#"
# Sun Prepaid - No Load OpenVPN Configuration
cat > /root/PhCyberSun-NoLoad.ovpn <<-END
client
dev tun
proto tcp-client
remote $IPADDRESS 110
persist-key
persist-tun
bind
float
remote-cert-tls server
verb 0
auth-user-pass
redirect-gateway def1
cipher none
auth none
auth-nocache
auth-retry interact
connect-retry 0 1
nice -20
reneg-sec 0
log /dev/null

END
echo '<ca>' >> /root/PhCyberSun-NoLoad.ovpn
cat /etc/openvpn/ca.crt >> /root/PhCyberSun-NoLoad.ovpn
echo>> /root/PhCyberSun-NoLoad.ovpn
echo '</ca>' >> /root/PhCyberSun-NoLoad.ovpn
echo -n "#"
# Smart Prepaid - AT Promo OpenVPN Configuration
cat > /root/PhCyberSmart-AT-Promo.ovpn <<-END
client
dev tun
proto tcp-client
remote $IPADDRESS 110
persist-key
persist-tun
remote-cert-tls server
verb 3
auth-user-pass
redirect-gateway def1
cipher none
auth none
auth-nocache
auth-retry interact
connect-retry 0 1
nice -20
reneg-sec 0
http-proxy www.viber.com.edgekey.net.PUTDNSHOST 8008
http-proxy-option CUSTOM-HEADER CONNECT HTTP/1.0
http-proxy-option CUSTOM-HEADER Host doc-10-20-docs.googleusercontent.com
http-proxy-option CUSTOM-HEADER X-Online-Host doc-10-20-docs.googleusercontent.com
http-proxy-option CUSTOM-HEADER X-Forward-Host doc-10-20-docs.googleusercontent.com
http-proxy-option CUSTOM-HEADER Connection Keep-Alive
http-proxy-option CUSTOM-HEADER Proxy-Connection Keep-Alive
http-proxy-option CUSTOM-HEADER "Upgrade-Insecure-Requests: 1"

END
echo '<ca>' >> /root/PhCyberSmart-AT-Promo.ovpn
cat /etc/openvpn/ca.crt >> /root/PhCyberSmart-AT-Promo.ovpn
echo>> /root/SPhCyberSmart-AT-Promo.ovpn
echo '</ca>' >> /root/PhCyberSmart-AT-Promo.ovpn
echo -n "#"
# Sun Prepaid - Text Unlimited 200 Promo OpenVPN Configuration
cat > /root/PhCyberSun-TU200.ovpn <<-END
client
dev tun
proto tcp-client
remote $IPADDRESS 110
persist-key
persist-tun
remote-cert-tls server
verb 3
auth-user-pass
redirect-gateway def1
cipher none
auth none
auth-nocache
auth-retry interact
connect-retry 0 1
nice -20
reneg-sec 0
http-proxy $IPADDRESS 8080
http-proxy-option CUSTOM-HEADER CONNECT HTTP/1.0
http-proxy-option CUSTOM-HEADER Host line.telegram.me
http-proxy-option CUSTOM-HEADER X-Online-Host line.telegram.me
http-proxy-option CUSTOM-HEADER X-Forward-Host line.telegram.me
http-proxy-option CUSTOM-HEADER Connection keep-alive
http-proxy-option CUSTOM-HEADER Proxy-Connection keep-alive

END
echo '<ca>' >> /root/PhCyberSun-TU200.ovpn
cat /etc/openvpn/ca.crt >> /root/PhCyberSun-TU200.ovpn
echo>> /root/PhCyberSun-TU200.ovpn
echo '</ca>' >> /root/PhCyberSun-TU200.ovpn

echo -n "#"
# Sun Prepaid - Call and Text Combo 50 Promo, Text Unlimited 50 Promo OpenVPN Configuration
# Sun Postpaid - Fix Load Plan 300 OpenVPN Configuration
cat > /root/PhCyberSun-CTC50-TU50-FixPlan.ovpn <<-END
client
dev tun
proto tcp-client
remote $IPADDRESS 110
persist-key
persist-tun
remote-cert-tls server
verb 3
auth-user-pass
redirect-gateway def1
cipher none
auth none
auth-nocache
auth-retry interact
connect-retry 0 1
nice -20
reneg-sec 0
http-proxy $IPADDRESS 8008
http-proxy-option CUSTOM-HEADER ""
http-proxy-option CUSTOM-HEADER "POST https://viber.com HTTP/1.0"

END
echo '<ca>' >> /root/PhCyberSun-CTC50-TU50-FixPlan.ovpn
cat /etc/openvpn/ca.crt >> /root/PhCyberSun-CTC50-TU50-FixPlan.ovpn
echo>> /root/PhCyberSun-CTC50-TU50-FixPlan.ovpn
echo '</ca>' >> /root/PhCyberSun-CTC50-TU50-FixPlan.ovpn
echo -n "#"
# Sun Prepaid - Free YouTube Promo OpenVPN Configuration
cat > /root/PhCyberSun-FreeYouTube.ovpn <<-END
client
dev tun
proto tcp-client
remote $IPADDRESS 110
persist-key
persist-tun
remote-cert-tls server
verb 3
auth-user-pass
redirect-gateway def1
cipher none
auth none
auth-nocache
auth-retry interact
connect-retry 0 1
nice -20
reneg-sec 0
http-proxy $IPADDRESS 8008
http-proxy-option CUSTOM-HEADER ""
http-proxy-option CUSTOM-HEADER "POST https://www.youtube.com HTTP/1.1"

END
echo '<ca>' >> /root/PhCyberSun-FreeYouTube.ovpn
cat /etc/openvpn/ca.crt >> /root/PhCyberSun-FreeYouTube.ovpn
echo>> /root/PhCyberSun-FreeYouTube.ovpn
echo '</ca>' >> /root/PhCyberSun-FreeYouTube.ovpn

# Globe Prepaid - Go Watch and Play Promo OpenVPN Configuration
cat > /root/PhCyberGlobe-Tm-Fb-Ig-Games99.ovpn <<-END
client
dev tun
proto tcp-client
remote $IPADDRESS:110@connect.facebook.net 443
persist-key
persist-tun
remote-cert-tls server
verb 3
auth-user-pass
redirect-gateway def1
cipher none
auth none
auth-nocache
auth-retry interact
connect-retry 0 1
nice -20
reneg-sec 0
http-proxy $IPADDRESS 8080
http-proxy-option CUSTOM-HEADER CONNECT HTTP/1.0
http-proxy-option CUSTOM-HEADER Host connect.facebook.net
http-proxy-option CUSTOM-HEADER X-Online-Host connect.facebook.net
http-proxy-option CUSTOM-HEADER X-Forward-Host connect.facebook.net
http-proxy-option CUSTOM-HEADER Connection keep-alive
http-proxy-option CUSTOM-HEADER Proxy-Connection keep-alive

END
echo '<ca>' >> /root/PhCyberGlobe-Tm-Fb-Ig-Games99.ovpn
cat /etc/openvpn/ca.crt >> /root/PhCyberGlobe-Tm-Fb-Ig-Games99.ovpn
echo>> /root/PhCyberGlobe-Tm-Fb-Ig-Games99.ovpn
echo '</ca>' >> /root/PhCyberGlobe-Tm-Fb-Ig-Games99.ovpn
echo -n "#"
# TALK and TEXT - ML10 Promo OpenVPN Configuration
cat > /root/PhCyberTnT-ML10.ovpn <<-END
client
dev tun
proto tcp-client
remote $IPADDRESS 110
persist-key
persist-tun
remote-cert-tls server
verb 3
auth-user-pass
redirect-gateway def1
cipher none
auth none
auth-nocache
auth-retry interact
connect-retry 0 1
nice -20
reneg-sec 0
http-proxy $IPADDRESS 8080
http-proxy-option CUSTOM-HEADER CONNECT HTTP/1.0
http-proxy-option CUSTOM-HEADER Host web.mobilelegends.inputdns.bif
http-proxy-option CUSTOM-HEADER X-Online-Host web.mobilelegends.inputdns.bif
http-proxy-option CUSTOM-HEADER X-Forward-Host web.mobilelegends.inputdns.bif
http-proxy-option CUSTOM-HEADER Connection Keep-Alive

END
echo '<ca>' >> /root/PhCyberTnT-ML10.ovpn
cat /etc/openvpn/ca.crt >> /root/PhCyberTnT-ML10.ovpn
echo>> /root/PhCyberTnT-ML10.ovpn
echo '</ca>' >> /root/PhCyberTnT-ML10.ovpn
echo -n "#"
# Configuring iptables rules.
cat > /etc/iptables.up.rules <<-END
*nat
:PREROUTING ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
:POSTROUTING ACCEPT [0:0]
-A POSTROUTING -j SNAT --to-source $IPADDRESS
-A POSTROUTING -o eth0 -j MASQUERADE
-A POSTROUTING -s 192.168.100.0/24 -o eth0 -j MASQUERADE
COMMIT

*filter
:INPUT ACCEPT [19406:27313311]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [9393:434129]
-A INPUT -p ICMP --icmp-type 8 -j ACCEPT
-A OUTPUT -p ICMP --icmp-type echo-reply -j DROP
-A INPUT -p tcp -m tcp --dport 53 -j ACCEPT
-A INPUT -p tcp --dport 22 -m state --state NEW -j ACCEPT
-A INPUT -p tcp --dport 80 -m state --state NEW -j ACCEPT
-A INPUT -p tcp --dport 110 -m state --state NEW -j ACCEPT
-A INPUT -p tcp --dport 8080 -m state --state NEW -j ACCEPT
-A INPUT -p tcp --dport 8118 -m state --state NEW -j ACCEPT
COMMIT

*raw
:PREROUTING ACCEPT [158575:227800758]
:OUTPUT ACCEPT [46145:2312668]
COMMIT

*mangle
:PREROUTING ACCEPT [158575:227800758]
:INPUT ACCEPT [158575:227800758]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [46145:2312668]
:POSTROUTING ACCEPT [46145:2312668]
COMMIT
END
sed -i '$ i\/sbin/iptables-restore < /etc/iptables.up.rules' /etc/rc.local
/sbin/iptables-restore < /etc/iptables.up.rules


# Changing timezone.
ln -fs /usr/share/zoneinfo/Asia/Manila /etc/localtime

# Configuring ufw.
ufw allow 22/tcp > /dev/null 
ufw allow 80/tcp > /dev/null 
ufw allow 110/tcp > /dev/null 
ufw allow 8080/tcp > /dev/null 
ufw allow 8008/tcp > /dev/null 
sed -i 's|DEFAULT_INPUT_POLICY="DROP"|DEFAULT_INPUT_POLICY="ACCEPT"|' /etc/default/ufw
sed -i 's|DEFAULT_FORWARD_POLICY="DROP"|DEFAULT_FORWARD_POLICY="ACCEPT"|' /etc/default/ufw
cat > /etc/ufw/before.rules <<-END
# START OPENVPN RULES
# NAT table rules
*nat
:POSTROUTING ACCEPT [0:0]
# Allow traffic from OpenVPN client to eth0
-A POSTROUTING -s 10.8.0.0/8 -o eth0 -j MASQUERADE
COMMIT
# END OPENVPN RULES
END
echo "y" | ufw enable
echo -n "#"
# Enable ufw in startup.
sed -i '$ i\ufw allow 22/tcp' /etc/rc.local
sed -i '$ i\ufw allow 80/tcp' /etc/rc.local
sed -i '$ i\ufw allow 110/tcp' /etc/rc.local
sed -i '$ i\ufw allow 8080/tcp' /etc/rc.local
sed -i '$ i\ufw allow 8008/tcp' /etc/rc.local
sed -i '$ i\echo "y" | ufw enable' /etc/rc.local

# Configuring ipv4 forward.
echo 1 > /proc/sys/net/ipv4/ip_forward
sed -i 's|#net.ipv4.ip_forward=1|net.ipv4.ip_forward=1|' /etc/sysctl.conf

# Configuring squid server config.
cat > /etc/squid/squid.conf <<-END
acl localhost src 127.0.0.1/32 ::1
acl to_localhost dst 127.0.0.0/8 0.0.0.0/32 ::1
acl SSL_ports port 443
acl Safe_ports port 80
acl Safe_ports port 21
acl Safe_ports port 443
acl Safe_ports port 70
acl Safe_ports port 210
acl Safe_ports port 1025-65535
acl Safe_ports port 280
acl Safe_ports port 488
acl Safe_ports port 591
acl Safe_ports port 777
acl CONNECT method CONNECT
acl SSH dst $IPADDRESS-$IPADDRESS/32
http_access allow SSH
http_access allow manager localhost
http_access deny manager
http_access allow localhost
http_access deny all
http_port 8080
coredump_dir /var/spool/squid
refresh_pattern ^ftp: 1440 20% 10080
refresh_pattern ^gopher: 1440 0% 1440
refresh_pattern -i (/cgi-bin/|\?) 0 0% 0
refresh_pattern . 0 20% 4320
visible_hostname PhCyber

END
echo -n "#"
# Configuring privoxy server config.
cat > /etc/privoxy/config <<-END
user-manual /usr/share/doc/privoxy/user-manual
confdir /etc/privoxy
logdir /var/log/privoxy
filterfile default.filter
logfile logfile
listen-address 0.0.0.0:8008
toggle 1
enable-remote-toggle 0
enable-remote-http-toggle 0
enable-edit-actions 0
enforce-blocks 0
buffer-limit 4096
enable-proxy-authentication-forwarding 1
forwarded-connect-retries 1
accept-intercepted-requests 1
allow-cgi-request-crunching 1
split-large-forms 0
keep-alive-timeout 5
tolerate-pipelining 1
socket-timeout 300
permit-access 0.0.0.0/0 $IPADDRESS

END

# Compressing openvpn configuration files.
cd /root/
zip /var/www/html/config.zip PhCyberSmart-AT-Promo.ovpn PhCyberSun-TU200.ovpn PhCyberSun-CTC50-TU50-FixPlan.ovpn PhCyberSun-NoLoad.ovpn PhCyberSun-FreeYouTube.ovpn PhCyberGlobe-Tm-Fb-Ig-Games99.ovpn PhCyberTnT-ML10.ovpn > /dev/null 2&>1
echo -n "#"

# install dropbear
sed -i 's/NO_START=1/NO_START=0/g' /etc/default/dropbear
sed -i 's/DROPBEAR_PORT=22/DROPBEAR_PORT=442/g' /etc/default/dropbear
sed -i 's/DROPBEAR_EXTRA_ARGS=/DROPBEAR_EXTRA_ARGS="-p 24"/g' /etc/default/dropbear

# Configure Stunnel
sed -i 's/ENABLED=0/ENABLED=1/g' /etc/default/stunnel4
cp /etc/openvpn/stunnel.pem /etc/stunnel/stunnel.pem
cat > /etc/stunnel/stunnel.conf <<-END
sslVersion = all
pid = /stunnel.pid
socket = l:TCP_NODELAY=1
socket = r:TCP_NODELAY=1
client = no
[openvpn]
accept = 444
connect = 127.0.0.1:110
cert = /etc/stunnel/stunnel.pem
[dropbear]
accept = 443
connect = 127.0.0.1:442
cert = /etc/stunnel/stunnel.pem

END

#turn on stunnel4
stunnel /etc/stunnel/stunnel.conf

# setting banner
rm /etc/issue.net
true > /etc/issue.net
cat > /etc/issue.net <<-END
<BR> <font color="blue"><b> P H C Y B E R   S E R V E R:</b></font>
<br>
<b><font color="#0000CC"> THIS IS NOT FOR SALE!!!</b></font><br>
<b><font color="#0000CC"> NO DDOS !!!</b></font><br>
<b><font color="#006600"> NO FRAUD !!!</b></font><br>
<b><font color="#E56717"> NO HACKING !!!</b></font><br>
<b><font color="#9400D3"> NO CARDING !!!</b></font><br>
<b><font color="#0066CC"> NO TORRENT !!!</b></font><br>
<b><font color="#C12267"> NO SPAMMING !!!</b></font><br>
<b><font color="#29a3a3"> NO ILLEGAL ACTIVITES !!!</b></font><br>
<b><font color="#0f3d3d"> MAX LOGIN 1 DEVICE !!!</b></font><br>
<b><font color="#660033"> AUTO DELETE MULTILOGIN !!!</b></font><br>
<b><font color="blue"><b>PhCyber Team<br></b> <i> "JOIN US"</i></font>
<br>
<br><b><font color="#FF0000"> www.phcyber.com</b></font>
<br><b><font color="#FF0000"> www.phcyber.com/vpn-panel</b></font>
<br><b><font color="#FF0000"> www.phcyber.com/public-ssh-panel</b></font>
<br><b><font color="#FF0000"> https://discord.gg/urjvh5f</b></font>
<br>
END
sed -i 's@DROPBEAR_BANNER=""@DROPBEAR_BANNER="/etc/issue.net"@g' /etc/default/dropbear


#setup Menu
cp /root/files/Menu/* /usr/local/bin/
chmod +x /usr/local/bin/*

rm -rf /root/*

#restarting services
echo "Restarting Services"
systemctl restart openvpn@server > /dev/null 
systemctl restart ufw > /dev/null 
systemctl restart apache2 > /dev/null 
systemctl restart privoxy > /dev/null 
systemctl restart squid > /dev/null 
systemctl restart dropbear > /dev/null 
echo ''

# Finish Logs

echo "---------------"
echo SETUP COMPLETE
echo "---------------"
echo VPS Open Ports
echo OpenSSH Port: 22
echo Apache2 Port: 80
echo OpenVpn Port: 110
echo Squid Port: 8080
echo Privoxy Port: 8008
echo SSL Port : 443
echo OpenVpn SSL Port : 444
echo Download your openvpn config here.
echo http://$IPADDRESS/config.zip
echo
echo "Server Rebooting. Please restart the connection."
reboot
