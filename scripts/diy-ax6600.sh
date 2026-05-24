#!/bin/bash
# =====================================================
# 雅典娜 AX6600 专属 DIY 脚本
# 用法: bash diy-ax6600.sh [pre|post]
# pre  = feeds 更新前执行（修改 feeds 源）
# post = feeds 安装后执行（克隆插件、改配置）
# =====================================================

STAGE=${1:-post}

pre() {
  # ── 添加自定义 feeds ──────────────────────────────
  # ddns-go（sirpdboy 原作者）
  echo "src-git ddns-go https://github.com/sirpdboy/luci-app-ddns-go" \
    >> feeds.conf.default

  # OpenClash（vernesong 原作者）
  echo "src-git openclash https://github.com/vernesong/OpenClash;master" \
    >> feeds.conf.default

  # homeproxy（immortalwrt 官方）
  echo "src-git homeproxy https://github.com/immortalwrt/homeproxy" \
    >> feeds.conf.default
}

post() {
  # ── 默认 IP ───────────────────────────────────────
  sed -i 's/192.168.1.1/192.168.10.1/g' \
    package/base-files/files/bin/config_generate

  # ── 主机名 ────────────────────────────────────────
  sed -i 's/ImmortalWrt/AX6600/g' \
    package/base-files/files/bin/config_generate

  # ── 时区 ──────────────────────────────────────────
  sed -i "s/'UTC'/'CST-8'/g" \
    package/base-files/files/bin/config_generate

  # ── Aurora 主题（eamonxg 原作者）────────────────
  git clone --depth=1 -b master \
    https://github.com/eamonxg/luci-theme-aurora \
    package/luci-theme-aurora

  # ── openlist2（sbwml 原作者）────────────────────
  git clone --depth=1 \
    https://github.com/sbwml/luci-app-openlist2 \
    package/luci-app-openlist2

  # ── aria2（openwrt 官方 luci）────────────────────
  git clone --depth=1 --filter=blob:none --sparse \
    https://github.com/openwrt/luci /tmp/luci-sparse
  cd /tmp/luci-sparse
  git sparse-checkout set applications/luci-app-aria2
  cp -r applications/luci-app-aria2 \
    $GITHUB_WORKSPACE/openwrt/package/luci-app-aria2
  cd $GITHUB_WORKSPACE/openwrt

  # ── AX6600 LED 点阵屏控制（NONGFAH 原作者）──────
  # VIKINGYFY 仓库未内置，需单独引入
  git clone --depth=1 \
    https://github.com/NONGFAH/luci-app-athena-led \
    package/luci-app-athena-led

  # ── 强制移除不需要的插件 ──────────────────────────
  # 在此处添加需要删除的包名，每行一个
  # 格式: find package feeds -type d -name "包名" -exec rm -rf {} + 2>/dev/null || true
  find package feeds -type d -name "luci-app-attendedsysupgrade" \
    -exec rm -rf {} + 2>/dev/null || true
  # 如需移除其他插件，复制上面一行并替换包名即可：
  # find package feeds -type d -name "luci-app-XXX" \
  #   -exec rm -rf {} + 2>/dev/null || true
}

case "$STAGE" in
  pre)  pre  ;;
  post) post ;;
esac
