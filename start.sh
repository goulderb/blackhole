#!/bin/sh
# start.sh
# Written by: predatorfreak
if [ `whoami` = "root" ]; then
 continue
else
 echo "predatorwall: User must be root in order to apply rules"
 exit 1
fi

if [ -f /etc/predatorwall/predwall.conf ]; then
 if [ -f /usr/share/predatorwall/includes/options ]; then
  . /etc/predatorwall/predwall.conf
  . /usr/share/predatorwall/includes/options
 else
  echo "Unable to load the required includes."
  exit 1
 fi
else
 echo "Unable to load the configuration file."
 exit 1
fi

if [ $PASSIVEFTP = "ON" ]; then
 modprobe -q ip_conntrack_ftp
 if [ $? = "1" ]; then
  echo "Failed to load ip_conntrack_ftp, setting PASSIVEFTP to OFF"
  export PASSIVEFTP=OFF
 fi
fi
# Lay the groundwork for everything else
if [ $BASIC = "ON" ]; then
 iptables -P INPUT DROP
 iptables -P FORWARD DROP
 iptables -P OUTPUT DROP
 iptables -A INPUT -i lo -s 0.0.0.0/0 -d 0.0.0.0/0 -j ACCEPT
 iptables -A OUTPUT -o lo -s 0.0.0.0/0 -d 0.0.0.0/0 -j ACCEPT
 iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
 iptables -A OUTPUT -m state --state NEW,RELATED,ESTABLISHED -j ACCEPT
fi
# Don't add useless chains
if [ $CHAINS = "ON" ]; then 
 if [ $TCPFLAGS = "ON" ]; then
  iptables -N TCPFLAG
 fi
 if [ $FLOODPROT = "ON" ]; then
  iptables -N FLOOD
 fi
 if [ $TCPALLOW = "ON" ]; then
  iptables -N TCPALLOW
 fi
 if [ $UDPALLOW = "ON" ]; then
  iptables -N UDPALLOW
 fi
 if [ $LOG = "ON" ]; then
  iptables -N LOG_DROP
 fi
fi
# Flood protection, does syn, furtive and ping of death flood protection.
if [ $FLOODPROT = "ON" ]; then
 iptables -I INPUT 2 -p tcp -m state --state NEW,RELATED -j FLOOD
 iptables -A FLOOD -p tcp --syn -m limit --limit 20/s --limit-burst 5 -j $DROP
 iptables -A FLOOD -p tcp --tcp-flags SYN,ACK,FIN,RST RST -m limit --limit 20/s --limit-burst 5 -j $DROP
 iptables -A FLOOD -p icmp --icmp-type echo-request -m limit --limit 20/s --limit-burst 5 -j $DROP
fi
# $PASSIVEFTP has to function via state, so it shouldn't use the new port opening system.
if [ $PASSIVEFTP = "ON" ]; then
 iptables -A INPUT -p tcp --sport 21 --dport 21 -m state --state ESTABLISHED -j ACCEPT
 iptables -A OUTPUT -p tcp --sport 21 --dport 21 -m state --state ESTABLISHED,RELATED -j ACCEPT
 iptables -A INPUT -p tcp --sport 1024 --dport 1024 -m state --state ESTABLISHED -j ACCEPT
 iptables -A OUTPUT -p tcp --sport 1024 --dport 1024 -m state --state ESTABLISHED,RELATED -j ACCEPT
fi
# Make sure we don't get any invalid TCP flags.
if [ $TCPFLAGS = "ON" ]; then
 iptables -I INPUT 3 -p tcp -m state --state NEW,RELATED -j TCPFLAG
 iptables -A TCPFLAG -p tcp --tcp-flags ALL NONE -m limit --limit 3/m --limit-burst 5 -j $DROP
 iptables -A TCPFLAG -p tcp --tcp-flags ACK,FIN FIN -m limit --limit 3/m --limit-burst 5 -j $DROP
 iptables -A TCPFLAG -p tcp --tcp-flags ACK,PSH PSH -m limit --limit 3/m --limit-burst 5 -j $DROP
 iptables -A TCPFLAG -p tcp --tcp-flags FIN,RST FIN,RST -m limit --limit 3/m --limit-burst 5 -j $DROP
 iptables -A TCPFLAG -p tcp --tcp-flags ALL FIN,URG,PSH -m limit --limit 3/m --limit-burst 5 -j $DROP
 iptables -A TCPFLAG -p tcp --tcp-flags ALL SYN,RST,ACK,FIN,URG -m limit --limit 3/m --limit-burst 5 -j $DROP
 iptables -A TCPFLAG -p tcp --tcp-flags ALL ALL -m limit --limit 3/m --limit-burst 5 -j $DROP
 iptables -A TCPFLAG -p tcp --tcp-flags ALL FIN -m limit --limit 3/m --limit-burst 5 -j $DROP
 iptables -A TCPFLAG -p tcp --tcp-flags SYN,RST SYN,RST -m limit --limit 3/m --limit-burst 5 -j $DROP
 iptables -A TCPFLAG -p tcp --tcp-flags SYN,FIN SYN,FIN -m limit --limit 3/m --limit-burst 5 -j $DROP
 iptables -A TCPFLAG -p tcp --tcp-option 128 -j $DROP
 iptables -A TCPFLAG -p tcp --tcp-option 64 -j $DROP
 iptables -A TCPFLAG -f -j $DROP
fi
if [ $SMB = "ON" ]; then
 iptables -A TCPALLOW -p tcp --dport 135:139 -j ACCEPT
 iptables -A UDPALLOW -p udp --dport 135:139 -j ACCEPT
 iptables -A OUTPUT -p tcp --dport 135:139 -j ACCEPT
 iptables -A OUTPUT -p udp --dport 135:139 -j ACCEPT
 iptables -A OUTPUT -p tcp --dport 445 -j ACCEPT
 iptables -A OUTPUT -p udp --dport 1024 -j ACCEPT
 rm /etc/predatorwall/tcpallow/null
 rm /etc/predatorwall/udpallow/null
 touch /etc/predatorwall/tcpallow/445
 touch /etc/predatorwall/udpallow/1024
fi
# Check if TCPALLOW/UDPALLOW are defined as on, 
# if so go too there respective directories and run a for loop to open the 
# ports. The ports opened are determined by the files in the directory, such 
# as 22 opens port 22.
if [ $TCPALLOW = "ON" ]; then
 cd /etc/predatorwall/tcpallow/
 if [ ! -f /etc/predatorwall/tcpallow/null ]; then
 iptables -I INPUT 4 -p tcp -m state --state NEW,RELATED -j TCPALLOW
  for i in *; do
   iptables -A TCPALLOW -p tcp --dport $i -j ACCEPT
  done
 fi
fi
if [ $UDPALLOW = "ON" ]; then
 cd /etc/predatorwall/udpallow/
 if [ ! -f /etc/predatorwall/udpallow/null ]; then
  iptables -I INPUT 4 -p udp -m state --state NEW,RELATED -j UDPALLOW
   for i in *; do
    iptables -A UDPALLOW -p udp --dport $i -j ACCEPT
   done
 fi
fi
if [ $LOG = "ON" ]; then
 iptables -A LOG_DROP -j LOG --log-tcp-options --log-ip-options --log-prefix $LOGPREFIX
 iptables -A LOG_DROP -j DROP
fi 
exit 0
