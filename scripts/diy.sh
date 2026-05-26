pre() {
  # ── 覆盖 feeds.conf.default ────────────
  echo "src-git nss_packages https://github.com/VIKINGYFY/nss-packages.git" > feeds.conf.default
  echo "src-git packages https://github.com/immortalwrt/packages.git"      >> feeds.conf.default
  echo "src-git luci https://github.com/immortalwrt/luci.git"              >> feeds.conf.default
  echo "src-git routing https://github.com/openwrt/routing.git"            >> feeds.conf.default
  echo "src-git telephony https://github.com/openwrt/telephony.git"        >> feeds.conf.default
}

post() {
  # ── 【新增】在 feeds update 之后，强制替换兼容的 golang ──
  echo "正在替换兼容的 Golang 版本..."
  rm -rf feeds/packages/lang/golang 2>/dev/null || true
  git clone --depth=1 -b 26.x \
    https://github.com/sbwml/packages_lang_golang \
    feeds/packages/lang/golang

  # ── 默认 IP ───────────────────────────────────────────────
  sed -i 's/192.168.1.1/10.1.1.1/g' \
    package/base-files/files/bin/config_generate

  # ── 时区 ──────────────────────────────────────────────────
  sed -i 's/timezone_hint.*/timezone_hint="Asia\/Shanghai"/' package/base-files/files/bin/config_generate
  sed -i 's/timezone=.*/timezone="CST-8"/' package/base-files/files/bin/config_generate

  # ── Aurora 主题 ─────────────────────────
  git clone --depth=1 -b master \
    https://github.com/eamonxg/luci-theme-aurora \
    package/luci-theme-aurora

  # ── ddns-go ────────────────────────────
  git clone --depth=1 \
    https://github.com/sirpdboy/luci-app-ddns-go \
    package/luci-app-ddns-go

  # ── OpenClash ─────────────────────────
  git clone --depth=1 -b master \
    https://github.com/vernesong/OpenClash \
    package/luci-app-openclash

  # ── openlist2 ─────────────────────────────
  # 仓库结构：根目录下有 openlist2/ 和 luci-app-openlist2/ 两个子目录
  # 必须分别放到对应的 package/ 目录下，否则 OpenWrt 找不到 Makefile
  git clone --depth=1 \
    https://github.com/sbwml/luci-app-openlist2 \
    /tmp/luci-app-openlist2-src
  cp -r /tmp/luci-app-openlist2-src/openlist2        package/openlist2
  cp -r /tmp/luci-app-openlist2-src/luci-app-openlist2 package/luci-app-openlist2

  # ── homeproxy ─────────────────────────
  git clone --depth=1 \
    https://github.com/immortalwrt/homeproxy \
    package/luci-app-homeproxy

  # ── aria2 ─────────────────────────
  git clone --depth=1 --filter=blob:none --sparse \
    https://github.com/openwrt/luci /tmp/luci-sparse
  cd /tmp/luci-sparse
  git sparse-checkout set applications/luci-app-aria2
  cp -r applications/luci-app-aria2 \
    $GITHUB_WORKSPACE/openwrt/package/luci-app-aria2
  cd $GITHUB_WORKSPACE/openwrt

  # ── AX6600 专属：LED 点阵屏 ────────
  if [ "$DEVICE" = "ax6600" ]; then
    git clone --depth=1 \
      https://github.com/NONGFAH/luci-app-athena-led \
      package/luci-app-athena-led
  fi

  # ── 强制移除不需要的插件 ──────────────────────────────────
  find package feeds -type d -name "luci-app-attendedsysupgrade" -exec rm -rf {} + 2>/dev/null || true
  find package feeds -type d -name "*xray*" -exec rm -rf {} + 2>/dev/null || true
  find package feeds -type f -name "Makefile" -exec grep -l "xray" {} \; | xargs -I {} dirname {} | xargs rm -rf 2>/dev/null || true

}

# ▼▼▼ 这两行是关键，之前完全缺失 ▼▼▼
DEVICE="${2:-}"
"$1"
