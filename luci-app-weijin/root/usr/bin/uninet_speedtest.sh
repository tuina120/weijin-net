#!/bin/sh
# Very lightweight RTT "speedtest" to each Tailscale node
TSBIN="$(command -v tailscale 2>/dev/null || echo /usr/sbin/tailscale)"
OUTDIR="/tmp/uninet"
NODES="$OUTDIR/nodes.txt"
OUTFILE="$OUTDIR/speed.txt"

mkdir -p "$OUTDIR"
: > "$OUTFILE"

if [ ! -r "$NODES" ]; then
	echo "# no nodes file, run uninet_nodes.sh first" > "$OUTFILE"
	exit 0
fi

while IFS='|' read -r name ip exitflag online; do
	[ -z "$ip" ] && continue
	[ "${ip#100.}" = "$ip" ] && continue

	rtt=$(ping -c 3 -W 1 "$ip" 2>/dev/null | awk -F'/' '/^rtt/ {print int($5)}')
	[ -z "$rtt" ] && rtt=9999
	loss=$(ping -c 3 -W 1 "$ip" 2>/dev/null | awk -F',' '/packet loss/ {gsub(/%/,"",$3);gsub(/ /,"",$3);print int($3)}')
	[ -z "$loss" ] && loss=100

	score=$((10000 - rtt*5 - loss*20))
	[ "$score" -lt 0 ] && score=0

	printf "%s|%s|%s|%s|%d|%d|%d\n" "$name" "$ip" "$exitflag" "$online" "$rtt" "$loss" "$score" >> "$OUTFILE"
done < "$NODES"

exit 0
