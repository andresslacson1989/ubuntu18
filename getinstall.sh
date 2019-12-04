#!/bin/bash
#Modified by PhCyber

#creating rc.local
rm /etc/rc.local
touch /etc/rc.local
chmod 777 /etc/rc.local
cat > /etc/rc.local <<-END
#!/bin/bash
nameserver 1.1.1.1 > /etc/resolv.conf
nameserver 1.0.0.1 >> /etc/resolv.conf
wget https://raw.githubusercontent.com/andresslacson1989/ubuntu18/master/install -O /root/install
chmod +x /root/install
/root/install
exit 0
END

systemctl enable rc-local 
systemctl start rc-local.service
