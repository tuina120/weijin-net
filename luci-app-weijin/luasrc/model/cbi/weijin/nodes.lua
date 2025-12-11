local fs   = require "nixio.fs"
local sys  = require "luci.sys"

m = SimpleForm("weijin_nodes", "节点接入",
[[本页会扫描当前 Tailnet 中的 100.x 节点，你可以查看哪些节点支持作为出口。]])

m.reset = false
m.submit = false

sys.call("/usr/bin/uninet_nodes.sh >/dev/null 2>&1")

local nodes_file = "/tmp/uninet/nodes.txt"
local html = {}
local s = m:section(SimpleSection)

local function name_quality(name)
    local lower = name:lower()
    local role, org, dev, id = lower:match("^([%w]+)%-([%w%-]+)%-(%w+)%-(%d%d)$")
    if role and org and dev and id then
        return "规范", "good"
    end
    if lower:match("bupt") or lower:match("sjtu") or lower:match("mit")
        or lower:match("imperial") or lower:match("nus")
        or lower:match("thu") or lower:match("tsinghua")
        or lower:match("pku") or lower:match("beida")
    then
        return "可用（建议优化）", "warn"
    end
    return "不规范（建议重命名）", "bad"
end

if not fs.access(nodes_file) then
    table.insert(html, "<p>尚未发现任何节点，请确认本机已登录 Tailscale。</p>")
else
    local rows = {}
    for line in (fs.readfile(nodes_file) or ""):gmatch("[^\r\n]+") do
        if not line:match("^#") and line:match("|") then
            local name, ip, exitflag, online = line:match("^(.-)|(.+)|(%d)|(%d)$")
            if name and ip and exitflag and online then
                table.insert(rows, {
                    name = name,
                    ip = ip,
                    exitflag = (exitflag == "1"),
                    online = (online == "1")
                })
            end
        end
    end
    table.insert(html, [[
<table style="width:100%;border-collapse:collapse;margin-top:6px;font-size:13px;">
<thead>
<tr style="background:#f5f7fa">
  <th style="padding:6px 8px;text-align:left;">节点名称</th>
  <th>IP(100.x)</th>
  <th>出口能力</th>
  <th>在线状态</th>
  <th>命名规范</th>
</tr>
</thead>
<tbody>
]])
    for _,n in ipairs(rows) do
        local exit_badge = n.exitflag and '<span style="background:#e1f3d8;color:#2f8132;padding:1px 6px;border-radius:10px;">支持出口</span>'
                                     or  '<span style="background:#f4f4f5;color:#909399;padding:1px 6px;border-radius:10px;">仅内部</span>'
        local online_badge = n.online and '<span style="background:#e1f3d8;color:#2f8132;padding:1px 6px;border-radius:10px;">在线</span>'
                                        or '<span style="background:#fde2e2;color:#c45656;padding:1px 6px;border-radius:10px;">离线</span>'
        local qtext, qclass = name_quality(n.name)
        local qcolor = (qclass == "good" and "#67c23a") or (qclass == "warn" and "#e6a23c") or "#f56c6c"
        local qbadge = string.format('<span style="background:%s20;color:%s;padding:1px 6px;border-radius:10px;">%s</span>',
            qcolor, qcolor, qtext)

        table.insert(html, string.format([[
<tr style="border-bottom:1px solid #eee">
  <td style="padding:6px 8px">%s</td>
  <td style="padding:6px 8px">%s</td>
  <td style="padding:6px 8px">%s</td>
  <td style="padding:6px 8px">%s</td>
  <td style="padding:6px 8px">%s</td>
</tr>
]], n.name, n.ip, exit_badge, online_badge, qbadge))
    end
    table.insert(html, "</tbody></table>")
end

s.template = "cbi/dvalue"
s.value = table.concat(html, "\n")
return m
