# 惟谨智网（Weijin Net）

一个基于 Tailscale + OpenWrt / iStoreOS 的「高校+多出口智能路由」LuCI 插件。

> 仓库：`https://github.com/tuina120/weijin-net`（你在本地推送后即可生效）

---

## ✨ 主要功能

- **高校网络优先**：校内 IPv4/IPv6 流量优先走「放在学校机房 / 宿舍」的小主机。
- **国内走家宽**：国内公网（非校园）优先走你家的宽带，不占用学校上行。
- **国外走 VPS / 机场**：国外流量优先走 Tailscale 接入的 VPS（日本 / 洛杉矶 / 加州等）。
- **多高校支持**：可以在北邮、上交、国外高校放多台 Ubuntu 小主机，通过 Tailscale 打通。
- **Tailscale 自动识别**：扫描 100.x Tailnet 节点，识别出口节点，并给出命名规范建议。
- **全球测速与智能出口**：对所有出口节点进行延迟 + 丢包评分，自动选择最优出口。
- **守护进程**：后台周期性测速，根据 RTT / 丢包率自动调整出口策略。
- **远程桌面友好**：家里 Windows / macOS 可以通过 100.x 访问校园或 VPS 环境。
- **完全中文界面**：LuCI 菜单、表单、提示全部中文，适合日常使用与分享给同学。

---

## 📂 目录结构

```text
weijin-net/
 ├── luci-app-weijin/           # LuCI 插件源码
 │    ├── Makefile
 │    ├── root/
 │    │    ├── etc/config/uninet
 │    │    └── usr/bin/
 │    │         ├── uninet_nodes.sh
 │    │         ├── uninet_speedtest.sh
 │    │         ├── uninet_daemon.sh
 │    │         └── uninet_tailscale.sh
 │    ├── luasrc/
 │    │    ├── controller/weijin.lua
 │    │    ├── model/cbi/weijin/basic.lua
 │    │    ├── model/cbi/weijin/nodes.lua
 │    │    └── model/cbi/weijin/speed.lua
 │    └── luasrc/view/weijin/
 │         ├── basic.htm
 │         ├── nodes.htm
 │         └── speed.htm
 └── .github/workflows/build.yml # GitHub Actions 自动编译
```

---

## 🧪 在 GitHub 上自动编译 IPK

本仓库已经包含 `GitHub Actions` 工作流（`.github/workflows/build.yml`），支持四种架构：

- `x86_64`
- `aarch64`（armvirt/64）
- `armv7`（armvirt/32）
- `mipsel_mt7621`（常见 MT7621 软路由）

### 使用步骤

1. 在本地创建仓库并推送：

   ```bash
   cd weijin-net                # 本 ZIP 解压后的目录
   git init
   git add .
   git commit -m "Weijin Net V14.3 初版"
   git branch -M main
   git remote add origin https://github.com/tuina120/weijin-net.git
   git push -u origin main
   ```

2. 打开 GitHub → 进入 `Actions` 页面  
   第一次会询问是否启用工作流，点 **Enable / 允许**。

3. 每次 `push` / 合并 PR / 手动触发，GitHub 都会：
   - 下载对应架构的 OpenWrt SDK
   - 编译 `luci-app-weijin`
   - 在右侧 **Artifacts** 里生成：
     - `luci-app-weijin-x86_64`
     - `luci-app-weijin-aarch64`
     - `luci-app-weijin-armv7`
     - `luci-app-weijin-mipsel_mt7621`

4. 点击对应 Artifact，即可下载压缩包，里面就是可安装的 `.ipk`。

---

## 📥 在路由器上安装

1. 打开 Web 管理界面（iStoreOS / OpenWrt）。
2. 进入：**系统 → 软件包 → 上传软件包**。
3. 选择你下载的 `luci-app-weijin_*.ipk` 文件。
4. 点击「上传并安装」。

安装成功后，在左侧菜单看到：

> `网络 → 惟谨智网 → 基础设置 / 节点接入 / 全球测速`

---

## 🧷 Tailscale 节点命名规范建议

为了方便跨高校、大量节点管理，建议统一命名格式：

```text
<role>-<org>-<device>-<id>

示例：
exit-bupt-ubuntu-01
exit-sjtu-ubuntu-01
exit-mit-ubuntu-01
exit-home-nas-01
vps-jp-tokyo-01
vps-us-la-01
```

插件中的「节点接入」页面会：
- 自动检查命名规范
- 给出「规范 / 可用（建议优化）/ 不规范」标签

---

## 📌 本地手动编译（可选）

如果你仍然想在自己的 Ubuntu 上编译：

```bash
# 以 x86_64 为例
wget https://downloads.openwrt.org/releases/23.05.2/targets/x86/64/openwrt-sdk-23.05.2-x86-64_gcc-12.3.0_musl.Linux-x86_64.tar.xz
tar -xJf openwrt-sdk-23.05.2-x86-64*.tar.xz
cd openwrt-sdk-23.05.2-x86-64_gcc-12.3.0_musl.Linux-x86_64

# 把插件拷进去
cp -r /path/to/weijin-net/luci-app-weijin package/

# 安装依赖（如果需要）
# sudo apt-get install build-essential gawk libncurses5-dev zlib1g-dev ...

# 编译
make package/luci-app-weijin/compile V=s

# IPK 输出位置：
find bin -name "luci-app-weijin_*.ipk"
```

---

## 📝 License

本项目使用 MIT 协议开源，详见 `LICENSE` 文件。

你可以自由：
- 在校内外使用
- 在多高校部署
- 搭配 VPS / NAS / 机场
- 修改后给同学用，或者提交 PR 一起维护

---

## 🙌 致未来的你

- 你可能已经从北邮毕业，去到上交 / Imperial / 其它高校 / 国外读博；
- 你可能在更多的服务器上部署了 Tailscale；
- 你可能为惟谨智网加上了：自动 IPv6 校园识别、更智能的策略、图形化拓扑展示……

无论如何，这个仓库可以一直陪着你成长，  
只要有一台小主机 + 一个软路由，你就能把「自己的网络」带到世界各个角落。
