#!/bin/sh
# Helper for checking tailscale status and route
TSBIN="$(command -v tailscale 2>/dev/null || echo /usr/sbin/tailscale)"

case "$1" in
	status)
		$TSBIN status 2>/dev/null
	;;
	route)
		ip="$2"
		[ -z "$ip" ] && { echo "Usage: $0 route <host>"; exit 1; }
		traceroute -n "$ip" 2>/dev/null || ip route get "$ip" 2>/dev/null
	;;
	*)
		echo "Usage: $0 {status|route <host>}"
	;;
esac

exit 0
