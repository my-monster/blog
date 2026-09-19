#!/usr/bin/env sh

# 确保脚本抛出遇到的错误
set -e

# 百度链接推送
# 请在百度搜索资源平台获取你的 site 与 token
BAIDU_TOKEN="${BAIDU_PUSH_TOKEN:-T5PEAzhGaPNbjQ2X}"
curl -H 'Content-Type:text/plain' --data-binary @urls.txt "http://data.zz.baidu.com/urls?site=https://my-monster.github.io&token=${BAIDU_TOKEN}"

rm -rf urls.txt # 删除文件
