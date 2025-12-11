local fs   = require "nixio.fs"
local disp = require "luci.dispatcher"

m = SimpleForm("weijin_speed", "全球测速与智能出口",
[[本页用于对各出口节点进行延迟与丢包测试，并可一键启动守护进程进行自动选择。]])

m.reset = false
m.submit = false

local s = m:section(SimpleSection)
local html = {}

local speed_now = disp.build_url("admin/network/weijin/speed_now")
local daemon_on = disp.build_url("admin/network/weijin/daemon") .. "?enable=1"
local daemon_off = disp.build_url("admin/network/weijin/daemon") .. "?enable=0"

table.insert(html, "<p>")
table.insert(html, string.format('<a class="cbi-button cbi-button-apply" href="%s">立即测速</a>', speed_now))
table.insert(html, " ")
table.insert(html, string.format('<a class="cbi-button cbi-button-apply" href="%s">启动守护进程</a>', daemon_on))
table.insert(html, " ")
table.insert(html, string.format('<a class="cbi-button cbi-button-reset" href="%s">停止守护进程</a>', daemon_off))
table.insert(html, "</p>")

local speed_file = "/tmp/uninet/speed.txt"
if not fs.access(speed_file) then
    table.insert(html, "<p>尚未生成测速数据，请先点击“立即测速”。</p>")
else
    local rows = {}
    for line in (fs.readfile(speed_file) or ""):gmatch("[^\r\n]+") do
        if not line:match("^#") and line:match("|") then
            local name, ip, exitflag, online, rtt, loss, score = line:match("^(.-)|(.+)|(%d)|(%d)|(%d+)|(%d+)|(%d+)$")
            if name and ip and rtt and score then
                table.insert(rows, {
                    name = name,
                    ip = ip,
                    exitflag = (exitflag == "1"),
                    online = (online == "1"),
                    rtt = tonumber(rtt),
                    loss = tonumber(loss),
                    score = tonumber(score)
                })
            end
        end
    end
    table.sort(rows, function(a,b) return a.score > b.score end)
    table.insert(html, [[
<table style="width:100%;border-collapse:collapse;margin-top:6px;font-size:13px;">
<thead>
<tr style="background:#f5f7fa">
  <th style="padding:6px 8px;text-align:left;">节点名称</th>
  <th>IP(100.x)</th>
  <th>出口能力</th>
  <th>在线状态</th>
  <th>延迟(ms)</th>
  <th>丢包率(%)</th>
  <th>评分</th>
</tr>
</thead>
<tbody>
]])
    for _,r in ipairs(rows) do
        local exit_badge = r.exitflag and '<span style="background:#e1f3d8;color:#2f8132;padding:1px 6px;border-radius:10px;">支持出口</span>'
                                         or '<span style="background:#f4f4f5;color:#909399;padding:1px 6px;border-radius:10px;">仅内部</span>'
        local online_badge = r.online and '<span style="background:#e1f3d8;color:#2f8132;padding:1px 6px;border-radius:10px;">在线</span>'
                                          or '<span style="background:#fde2e2;color:#c45656;padding:1px 6px;border-radius:10px;">离线</span>'
        table.insert(html, string.format([[
<tr style="border-bottom:1px solid #eee">
  <td style="padding:6px 8px">%s</td>
  <td style="padding:6px 8px">%s</td>
  <td style="padding:6px 8px">%s</td>
  <td style="padding:6px 8px">%s</td>
  <td style="padding:6px 8px">%d</td>
  <td style="padding:6px 8px">%d</td>
  <td style="padding:6px 8px">%d</td>
</tr>
]], r.name, r.ip, exit_badge, online_badge, r.rtt, r.loss, r.score))
    end
    table.insert(html, "</tbody></table>")
end

s.template = "cbi/dvalue"
s.value = table.concat(html, "\n")
return m
