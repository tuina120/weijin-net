module("luci.controller.weijin", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/uninet") then
		return
	end

	local page = entry({"admin", "network", "weijin"}, firstchild(), _("惟谨智网"), 60)
	page.dependent = true

	entry({"admin", "network", "weijin", "basic"}, cbi("weijin/basic"), _("基础设置"), 10).leaf = true
	entry({"admin", "network", "weijin", "nodes"}, cbi("weijin/nodes"), _("节点接入"), 20).leaf = true
	entry({"admin", "network", "weijin", "speed"}, cbi("weijin/speed"), _("全球测速"), 30).leaf = true

	entry({"admin", "network", "weijin", "speed_now"}, call("action_speed_now")).leaf = true
	entry({"admin", "network", "weijin", "daemon"}, call("action_daemon")).leaf = true
end

function action_speed_now()
	luci.http.prepare_content("text/plain")
	luci.sys.call("/usr/bin/uninet_nodes.sh >/dev/null 2>&1")
	luci.sys.call("/usr/bin/uninet_speedtest.sh >/dev/null 2>&1")
	luci.http.write("OK\n")
end

function action_daemon()
	local enable = luci.http.formvalue("enable") or "0"
	if enable == "1" then
		luci.sys.call("/usr/bin/uninet_daemon.sh start >/dev/null 2>&1 &")
	else
		luci.sys.call("/usr/bin/uninet_daemon.sh stop >/dev/null 2>&1 &")
	end
	luci.http.prepare_content("text/plain")
	luci.http.write("OK\n")
end
