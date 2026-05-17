#!/bin/sh

case "$1" in
  bound|renew)
    ip addr flush dev "$interface"
    ip addr add "$ip/$mask" dev "$interface"
    ip route replace default via "$router" dev "$interface"
    ;;
  deconfig)
    ip addr flush dev "$interface"
    ip route flush dev "$interface"
    ;;
esac
