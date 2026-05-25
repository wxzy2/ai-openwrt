#!/bin/bash
# =====================================================
# 通用 DIY 脚本（360v6 / ax6600 共用）
# 用法: bash diy.sh [pre|post] [device]
# =====================================================

STAGE=${1:-post}
DEVICE=${2:-unknown}

pre() {
  echo "===== DIY Pre Stage (feeds 前) ====="

  # === 关键修复：重新生成 feeds.conf.default，保留 VIKINGYFY 的 NSS feeds ===
  cat > feeds.conf.default << 'EOF'
src-git packages https://github.com/immortalwrt/packages.git
src-git luci https://github.com/immortalwrt/luci.git
src-git routing https://github.com/openwrt/routing.git
src-git telephony https://github.com/openwrt/telephony.git
EOF

  # 追加自定义 feeds（干净写入，避免缩进问题）
  echo "" >> feeds.conf.default
  echo "# ================== 自定义 feeds ==================" >> feeds.conf.default
  echo "src-git ddns-go https://github.com/sirpdboy/luci-app-ddns-go" >> feeds.conf.default
  echo "src-git openclash https://github.com/vernesong/OpenClash" >> feeds.conf.default
  echo "# ==================================================" >> feeds.conf.default

  echo "feeds.conf.default 已修复完成"
}

post() {
  echo "===== DIY Post Stage (feeds 后) ====="
  cd $GITHUB_WORKSPACE/openwrt || exit 1

  # ── 默认 IP ───────────────────────────────────────
  sed -i 's/192.168.1.1/10.1.1.1/g' \
    package/base-files/files/bin/config_generate

  # ── 主机名（按机型区分）──────────────────────────────────
  #if [ "$DEVICE" = "ax6600" ]; then
  #  sed -i 's/ImmortalWrt/AX6600/g' \
  #    package/base-files/files/bin/config_generate
  #else
  #  sed -i 's/ImmortalWrt/360v6/g' \
  #    package/base-files/files/bin/config_generate
  #fi

  # ── 时区 ──────────────────────────────────────────────────
  sed -i "s/'UTC'/'CST-8'/g" \
    package/base-files/files/bin/config_generate

  # ── Aurora 主题（eamonxg 原作者）─────────────────────────
  git clone --depth=1 -b master \
    https://github.com/eamonxg/luci-theme-aurora \
    package/luci-theme-aurora

  # ── ddns-go（sirpdboy 原作者）────────────────────────────
  git clone --depth=1 \
    https://github.com/sirpdboy/luci-app-ddns-go \
    package/luci-app-ddns-go

  # ── OpenClash（vernesong 原作者）─────────────────────────
  git clone --depth=1 -b master \
    https://github.com/vernesong/OpenClash \
    package/luci-app-openclash

  # ── openlist2（sbwml 原作者）─────────────────────────────
  git clone --depth=1 \
    https://github.com/sbwml/luci-app-openlist2 \
    package/luci-app-openlist2

  # ── homeproxy（immortalwrt 官方）─────────────────────────
  git clone --depth=1 \
    https://github.com/immortalwrt/homeproxy \
    package/luci-app-homeproxy

  # ── aria2（openwrt 官方 luci，sparse clone 只取所需目录）─
  git clone --depth=1 --filter=blob:none --sparse \
    https://github.com/openwrt/luci /tmp/luci-sparse
  cd /tmp/luci-sparse
  git sparse-checkout set applications/luci-app-aria2
  cp -r applications/luci-app-aria2 \
    $GITHUB_WORKSPACE/openwrt/package/luci-app-aria2
  cd $GITHUB_WORKSPACE/openwrt

  # ── AX6600 专属：LED 点阵屏控制（NONGFAH 原作者）────────
  if [ "$DEVICE" = "ax6600" ]; then
    git clone --depth=1 \
      https://github.com/NONGFAH/luci-app-athena-led \
      package/luci-app-athena-led
  fi

  # ── 强制移除不需要的插件 ──────────────────────────────────
  find package feeds -type d -name "luci-app-attendedsysupgrade" \
    -exec rm -rf {} + 2>/dev/null || true

  echo "DIY Post 阶段完成"
}

case "$STAGE" in
  pre)  pre  ;;
  post) post ;;
esac
