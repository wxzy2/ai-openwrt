{
  "include": [
    {
      "name":        "360v6",
      "repo_url":    "https://github.com/VIKINGYFY/immortalwrt",
      "repo_branch": "main",
      "config_file": "configs/360v6.config",
      "diy_script":  "scripts/diy-default.sh"
    },
    {
      "name":        "x86-64",
      "repo_url":    "https://github.com/immortalwrt/immortalwrt",
      "repo_branch": "openwrt-23.05",
      "config_file": "configs/x86-64.config",
      "diy_script":  "scripts/diy-x86.sh"
    },
    {
      "name":        "r4s",
      "repo_url":    "https://github.com/coolsnowwolf/lede",
      "repo_branch": "master",
      "config_file": "configs/r4s.config",
      "diy_script":  "scripts/diy-default.sh"
    }
    // 新增机型：复制上面一块，改 name/repo/config 即可
  ]
}
