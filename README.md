# ImmortalWrt 编译仓库

## 使用方法

1. 进入 GitHub 仓库的 **Actions** 页面
2. 左侧选择 **Build ImmortalWrt**
3. 点击右侧 **Run workflow**
4. 下拉选择机型：`360v6` / `ax6600` / `all`
5. 等待编译完成，固件自动发布到 **Releases**

## 文件说明

| 文件 | 说明 |
|------|------|
| `.github/workflows/build.yml` | 编译流程主文件 |
| `configs/360v6.config` | 360v6 的 .config，替换为自己导出的 |
| `configs/ax6600.config` | AX6600 的 .config，替换为自己导出的 |
| `scripts/diy-360v6.sh` | 360v6 DIY 脚本（改 IP、主机名、插件等） |
| `scripts/diy-ax6600.sh` | AX6600 DIY 脚本 |

## 更换源码仓库

编辑 build.yml 顶部 env 区域：

  REPO_URL:    https://github.com/你的仓库地址
  REPO_BRANCH: main

## 导出 .config

在本地 openwrt 目录配置好后执行：

  make menuconfig
  ./scripts/diffconfig.sh > ~/configs/360v6.config

将输出文件替换掉 configs/ 下对应的文件即可。
