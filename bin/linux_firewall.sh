#!/bin/sh

# Sets up secure ip tables rules using whitelisting. This must run as root in
# order to work. Specify TCP and UDP ports in their respective vars in a
# space separated list.

iptables=$(which iptables)
tcp=""
udp=""

if [ $(id -u) -ne 0 ]; then
  echo "Re-run as root to set firewall."
  exit 1
fi

# Flush current rule set to start over
$iptables -F

# Set default policy for all chains to DROP
$iptables INPUT DROP
$iptables FORWARD DROP
$iptables OUTPUT DROP

# Make sure localhost is really "localhost"
$iptables -A INPUT -i lo -j ACCEPT
$iptables -A INPUT -s 127.0.0.0/8 -j DROP

# Accept everything that's already established
$iptables -A INPUT -p tcp -m state --state ESTABLISHED -j ACCEPT
$iptables -A INPUT -p udp -m state --state ESTABLISHED -j ACCEPT

# Allow specified TCP and UDP ports
for port in $tcp; do
  $iptables -A INPUT -p tcp -m tcp --dport $port -m state --state NEW -j ACCEPT
done

for port in $udp; do
  $iptables -A INPUT -p udp -m udp --dport $port -m state --state NEW -j ACCEPT
done

# Allow all outbound packets
$iptables -A OUTPUT -o lo -j ACCEPT
$iptables -A OUTPUT -p tcp -m state --state NEW,ESTABLISHED -j ACCEPT
$iptables -A OUTPUT -p udp -m state --state NEW,ESTABLISHED -j ACCEPT
$iptables -A OUTPUT -p icmp -m state --state NEW,ESTABLISHED -j ACCEPT
