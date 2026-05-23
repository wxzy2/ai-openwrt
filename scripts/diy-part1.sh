#!/bin/bash
# =================================================
# 通用 DIY 脚本 — 支持 pre (feeds前) / post (feeds后)
# 用法: bash diy-default.sh [pre|post]
# =================================================

STAGE=${1:-post}

source_common() {
  # 加载公共函数库
  DIR=$(dirname "$(readlink -f "$0")")
  source "$DIR/common.sh" 2>/dev/null || true
}

pre_stage() {
  echo "=== [pre] 修改 feeds 源 ==="

  # 添加自定义 feeds
  sed -i 's|src-git helloworld.*||g' feeds.conf.default
  cat >> feeds.conf.default <# 修改默认 IP
  sed -i 's/192.168.1.1/192.168.10.1/g' \
    package/base-files/files/bin/config_generate
}

post_stage() {
  echo "=== [post] 自定义包 & 配置 ==="

  # 修改主机名
  sed -i "s/OpenWrt/ImmortalWrt/g" \
    package/base-files/files/bin/config_generate

  # 修改时区
  sed -i "s/'UTC'/'CST-8'/g" \
    package/base-files/files/bin/config_generate

  # 克隆第三方插件
  if [[ ! -d "package/luci-app-adguardhome" ]]; then
    git clone --depth=1 \
      https://github.com/kongfl888/luci-app-adguardhome \
      package/luci-app-adguardhome
  fi

  # 替换默认主题
  pushd feeds/luci
  git checkout -- . 2>/dev/null || true
  popd
}

# 入口
case "$STAGE" in
  pre)  pre_stage  ;;
  post) post_stage ;;
  *)    pre_stage; post_stage ;;
esac

echo "✅ DIY [$STAGE] 完成"
