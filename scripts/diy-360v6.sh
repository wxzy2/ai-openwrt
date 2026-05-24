#!/bin/bash
# =====================================================
# 360v6 专属 DIY 脚本
# 用法: bash diy-360v6.sh [pre|post]
# pre  = feeds 更新前执行（修改 feeds 源）
# post = feeds 安装后执行（克隆插件、改配置）
# =====================================================

STAGE=${1:-post}

pre() {
  # ddns-go（sirpdboy 原作者）
  echo "src-git ddns-go https://github.com/sirpdboy/luci-app-ddns-go" \
    >> feeds.conf.default

  # OpenClash（vernesong 原作者）
  echo "src-git openclash https://github.com/vernesong/OpenClash" \
    >> feeds.conf.default
}

post() {
  # ── 默认 IP ───────────────────────────────────────
  sed -i 's/192.168.1.1/10.1.1.1/g' \
    package/base-files/files/bin/config_generate

  # ── 主机名 ────────────────────────────────────────
  #sed -i 's/ImmortalWrt/360v6/g' \
   # package/base-files/files/bin/config_generate

  # ── 时区 ──────────────────────────────────────────
  sed -i "s/'UTC'/'CST-8'/g" \
    package/base-files/files/bin/config_generate

  # ── Aurora 主题（eamonxg 原作者）─────────────────
  git clone --depth=1 -b master \
    https://github.com/eamonxg/luci-theme-aurora \
    package/luci-theme-aurora

  # ── openlist2（sbwml 原作者）─────────────────────
  git clone --depth=1 \
    https://github.com/sbwml/luci-app-openlist2 \
    package/luci-app-openlist2

  # ── homeproxy（immortalwrt 官方）─────────────────
  git clone --depth=1 \
    https://github.com/immortalwrt/homeproxy \
    package/luci-app-homeproxy

  # ── aria2（openwrt 官方 luci，sparse clone 只取需要的目录）
  git clone --depth=1 --filter=blob:none --sparse \
    https://github.com/openwrt/luci /tmp/luci-sparse
  cd /tmp/luci-sparse
  git sparse-checkout set applications/luci-app-aria2
  cp -r applications/luci-app-aria2 \
    $GITHUB_WORKSPACE/openwrt/package/luci-app-aria2
  cd $GITHUB_WORKSPACE/openwrt

  # ── 强制移除不需要的插件 ──────────────────────────
  # 格式: find package feeds -type d -name "包名" -exec rm -rf {} + 2>/dev/null || true
  # 如需移除其他插件，复制下面一行并替换包名即可
  find package feeds -type d -name "luci-app-attendedsysupgrade" \
    -exec rm -rf {} + 2>/dev/null || true
}

case "$STAGE" in
  pre)  pre  ;;
  post) post ;;
esac
