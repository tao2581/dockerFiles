#!/bin/bash
# Referring from https://raymii.org/s/tutorials/IPSEC_L2TP_vpn_with_Ubuntu_14.04.html

if [[ $EUID -ne 0 ]]; then
    echo 'Error:This script must be run as root!'
    exit 1
fi

apt-get install -y openswan xl2tpd ppp lsof vim rng-tools curl
SERVERIP=`curl -s -4 icanhazip.com`
iptables -t nat -A POSTROUTING -j SNAT --to-source $SERVERIP -o eth0

echo 'net.ipv4.ip_forward = 1' |  tee -a /etc/sysctl.conf
echo 'net.ipv4.conf.all.accept_redirects = 0' |  tee -a /etc/sysctl.conf
echo 'net.ipv4.conf.all.send_redirects = 0' |  tee -a /etc/sysctl.conf
echo 'net.ipv4.conf.default.rp_filter = 0' |  tee -a /etc/sysctl.conf
echo 'net.ipv4.conf.default.accept_source_route = 0' |  tee -a /etc/sysctl.conf
echo 'net.ipv4.conf.default.send_redirects = 0' |  tee -a /etc/sysctl.conf
echo 'net.ipv4.icmp_ignore_bogus_error_responses = 1' |  tee -a /etc/sysctl.conf

for vpn in /proc/sys/net/ipv4/conf/*; do echo 0 > $vpn/accept_redirects; echo 0 > $vpn/send_redirects; done
sysctl -p

# start VPN onstart
cp /etc/rc.local{,.bak}
sed -i '/exit 0/d' /etc/rc.local
cat >> /etc/rc.local<<EOF
for vpn in /proc/sys/net/ipv4/conf/*; do echo 0 > $vpn/accept_redirects; echo 0 > $vpn/send_redirects; done
iptables -t nat -A POSTROUTING -j SNAT --to-source $SERVERIP -o eth0

exit 0
EOF

# config ipsec
cp /etc/ipsec.conf{,.bak}
cat >/etc/ipsec.conf <<EOF
version 2 # conforms to second version of ipsec.conf specification

config setup
    dumpdir=/var/run/pluto/
    #in what directory should things started by setup (notably the Pluto daemon) be allowed to dump core?

    nat_traversal=yes
    #whether to accept/offer to support NAT (NAPT, also known as 'IP Masqurade') workaround for IPsec

    virtual_private=%v4:10.0.0.0/8,%v4:192.168.0.0/16,%v4:172.16.0.0/12,%v6:fd00::/8,%v6:fe80::/10
    #contains the networks that are allowed as subnet= for the remote client. In other words, the address ranges that may live behind a NAT router through which a client connects.

    protostack=netkey
    #decide which protocol stack is going to be used.

    force_keepalive=yes
    keep_alive=60
    # Send a keep-alive packet every 60 seconds.

conn L2TP-PSK-noNAT
    authby=secret
    #shared secret. Use rsasig for certificates.

    pfs=no
    #Disable pfs

    auto=add
    #the ipsec tunnel should be started and routes created when the ipsec daemon itself starts.

    keyingtries=3
    #Only negotiate a conn. 3 times.

    ikelifetime=8h
    keylife=1h

    ike=aes256-sha1,aes128-sha1,3des-sha1
    phase2alg=aes256-sha1,aes128-sha1,3des-sha1
    # https://lists.openswan.org/pipermail/users/2014-April/022947.html
    # specifies the phase 1 encryption scheme, the hashing algorithm, and the diffie-hellman group. The modp1024 is for Diffie-Hellman 2. Why 'modp' instead of dh? DH2 is a 1028 bit encryption algorithm that modulo's a prime number, e.g. modp1028. See RFC 5114 for details or the wiki page on diffie hellmann, if interested.

    type=transport
    #because we use l2tp as tunnel protocol

    left=$SERVERIP
    #fill in server IP above

    leftprotoport=17/1701
    right=%any
    rightprotoport=17/%any

    dpddelay=10
    # Dead Peer Dectection (RFC 3706) keepalives delay
    dpdtimeout=20
    #  length of time (in seconds) we will idle without hearing either an R_U_THERE poll from our peer, or an R_U_THERE_ACK reply.
    dpdaction=clear
    # When a DPD enabled peer is declared dead, what action should be taken. clear means the eroute and SA with both be cleared.
EOF

#config ipsec.secrets
cp /etc/ipsec.secrets{,.bak}
cat >/etc/ipsec.secrets <<EOF
$SERVERIP  %any:   PSK 'psk' #<<<<<<<<<<PSK>>>>>>>>>>#
EOF

ipsec verify

cp /etc/xl2tpd/xl2tpd.conf{,.bak}
cat > /etc/xl2tpd/xl2tpd.conf <<EOF
[global]
ipsec saref = yes
saref refinfo = 30

;debug avp = yes
;debug network = yes
;debug state = yes
;debug tunnel = yes

[lns default]
ip range = 172.16.1.30-172.16.1.100
local ip = 172.16.1.1
require authentication = yes
unix authentication = yes
;ppp debug = yes
pppoptfile = /etc/ppp/options.xl2tpd
length bit = yes
EOF

# config options.xl2tpd
cp /etc/ppp/options.xl2tpd{,.bak}
cat >/etc/ppp/options.xl2tpd <<EOF
ms-dns 8.8.8.8
ms-dns 8.8.4.4
auth
mtu 1200
mru 1000
crtscts
hide-password
modem
name l2tpd
proxyarp
lcp-echo-interval 30
lcp-echo-failure 4
login
EOF

#config pam.d
cp  /etc/pam.d/ppp{,.bak}
sed -i '/^auth/c\
auth    required        pam_nologin.so\
auth    required        pam_unix.so\
account required        pam_unix.so\
session required        pam_unix.so
' /etc/pam.d/ppp

#config pap-secrets
cp /etc/ppp/pap-secrets{,.bak}
cat >>/etc/ppp/pap-secrets <<EOF
*       l2tpd           ''              *
EOF

useradd vpn_user
echo -n 'set password for [vpn_user]:'
passwd vpn_user
/etc/init.d/ipsec restart
/etc/init.d/xl2tpd restart

echo 'IP:' $SERVERIP
echo 'UserName(set by useradd vpn_user): vpn_user'
echo 'PSK(set by /etc/ipsec.secrets): psk'

exit 0
