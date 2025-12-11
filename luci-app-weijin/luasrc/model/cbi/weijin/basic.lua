local uci = require "luci.model.uci".cursor()

m = Map("uninet", "惟谨智网 - 基础设置",
[[这里配置惟谨智网的全局行为，例如是否自动测速、是否开启智能守护进程。]])

local s = m:section(TypedSection, "uninet", "全局配置")
s.anonymous = true

local o
o = s:option(Flag, "enabled", "启用惟谨智网")
o.rmempty = false

o = s:option(Flag, "auto_daemon", "自动守护进程")
o.rmempty = false

o = s:option(Flag, "auto_speedtest", "自动测速")
o.rmempty = false

o = s:option(Value, "speedtest_interval", "测速间隔（秒）")
o.datatype = "uinteger"
o.default  = 300

o = s:option(Value, "failover_rtt", "切换阈值：延迟(ms)")
o.datatype = "uinteger"
o.default  = 800

o = s:option(Value, "failover_loss", "切换阈值：丢包率(%)")
o.datatype = "uinteger"
o.default  = 60

return m
