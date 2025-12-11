#!/bin/sh
# Scan Tailscale nodes and dump to /tmp/uninet/nodes.txt
TSBIN="$(command -v tailscale 2>/dev/null || echo /usr/sbin/tailscale)"
OUTDIR="/tmp/uninet"
OUTFILE="$OUTDIR/nodes.txt"

mkdir -p "$OUTDIR"
: > "$OUTFILE"

if [ ! -x "$TSBIN" ]; then
	echo "# tailscale not found" > "$OUTFILE"
	exit 0
fi

$TSBIN status --peers --json 2>/dev/null | \
	jsonfilter -e '@.PeerAddresses' >/dev/null 2>&1

$TSBIN status --peers --json 2>/dev/null | jsonfilter -e '@.Peer' 2>/dev/null | \
sed -n 's/^{//;s/}$//;p' 2>/dev/null >/dev/null

# Fallback: simple text mode
$TSBIN status --peers 2>/dev/null | awk '
/^100\./ {
	ip=$1; name=$2; exitflag=0; online=1
	if (index($0,"exit node")>0) exitflag=1
	printf "%s|%s|%d|%d\n", name, ip, exitflag, online
}' >> "$OUTFILE"

exit 0
