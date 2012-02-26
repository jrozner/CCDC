#!/bin/sh

# Sets up secure ip tables rules using whitelisting. This must run as root in
# order to work. Specify TCP and UDP ports in their respective vars in a
# space separated list.

IPTABLES=$(which iptables)
TCP=""
UDP=""

if [ $(id -u) -ne 0 ]; then
  echo "Re-run as root to set firewall."
  exit 1
fi

# Set default policy for all chains to DROP
$IPTABLES INPUT DROP
$IPTABLES FORWARD DROP
$IPTABLES OUTPUT DROP

# Make sure localhost is really "localhost"
$IPTABLES -A INPUT -i lo -j ACCEPT
$IPTABLES -A INPUT -s 127.0.0.0/8 -j DROP

# Accept everything that's already established
$IPTABLES -A INPUT -p tcp -m state --state ESTABLISHED -j ACCEPT
$IPTABLES -A INPUT -p udp -m state --state ESTABLISHED -j ACCEPT

# Allow specified TCP and UDP ports
for $PORT in $TCP; do
  $IPTABLES -A INPUT -p tcp -m tcp --dport $PORT -m state --state NEW -j ACCEPT
done

for $PORT in $UDP; do
  $IPTABLES -A INPUT -p udp -m udp --dport $PORT -m state --state NEW -j ACCEPT
done

# Allow all outbound packets
$IPTABLES -A OUTPUT -o lo -j ACCEPT
$IPTABLES -A OUTPUT -p tcp -m state --state NEW,ESTABLISHED -j ACCEPT
$IPTABLES -A OUTPUT -p udp -m state --state NEW,ESTABLISHED -j ACCEPT
$IPTABLES -A OUTPUT -p icmp -m state --state NEW,ESTABLISHED -j ACCEPT
