#!/bin/sh
# Simple watchdog daemon: choose best exit node periodically
CONF="/etc/config/uninet"
OUTDIR="/tmp/uninet"
SPEED="$OUTDIR/speed.txt"
PIDFILE="/var/run/uninet_daemon.pid"

[ "$1" = "stop" ] && {
	[ -f "$PIDFILE" ] && kill "$(cat "$PIDFILE")" 2>/dev/null
	rm -f "$PIDFILE"
	exit 0
}

if [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
	echo "uninet daemon already running"
	exit 0
fi

(
	while true; do
		. /lib/functions.sh
		config_load uninet
		INTERVAL=300
		config_get INTERVAL global speedtest_interval 300

		/usr/bin/uninet_nodes.sh
		/usr/bin/uninet_speedtest.sh

		# choose best score exit node (placeholder: just log)
		[ -r "$SPEED" ] && sort -t'|' -k7,7nr "$SPEED" | head -n1 > "$OUTDIR/best.txt"

		sleep "$INTERVAL"
	done
) &

echo $! > "$PIDFILE"
exit 0
