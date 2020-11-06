#!/usr/bin/env bash

# if error occured, then exit
set -e

# path
project_root_path=`pwd`
tmp_path="$project_root_path/.tmp"

if [ ! -d $tmp_path ]; then
    mkdir -p $tmp_path
fi

# git 同步 kenzok8/openwrt-packages 源码
if [ ! -d $tmp_path/kenzok8_packages ]; then
    mkdir -p $tmp_path/kenzok8_packages
    cd $tmp_path/kenzok8_packages
    git init
    git remote add origin https://github.com/kenzok8/openwrt-packages.git
    git config core.sparsecheckout true
fi
cd $tmp_path/kenzok8_packages
if [ ! -e .git/info/sparse-checkout ]; then
    touch .git/info/sparse-checkout
fi
if [ `grep -c "luci-app-ssr-plus" .git/info/sparse-checkout` -eq 0 ]; then
    echo "luci-app-ssr-plus" >> .git/info/sparse-checkout
fi
if [ `grep -c "naiveproxy" .git/info/sparse-checkout` -eq 0 ]; then
    echo "naiveproxy" >> .git/info/sparse-checkout
fi
git pull --depth 1 origin master

# git 同步 coolsnowwolf/lede 源码
if [ ! -d $tmp_path/lean ]; then
    mkdir -p $tmp_path/lean
    cd $tmp_path/lean
    git init
    git remote add origin https://github.com/coolsnowwolf/lede.git
    git config core.sparsecheckout true
fi
cd $tmp_path/lean
if [ ! -e .git/info/sparse-checkout ]; then
    touch .git/info/sparse-checkout
fi
# naiveproxy 不在 lean 库中, kenzok8 的搬运库中有收录
array_libs=(
shadowsocksr-libev
pdnsd-alt
microsocks
dns2socks
simple-obfs
tcpping
v2ray-plugin
v2ray
trojan
ipt2socks
redsocks2
kcptun
)
for var in ${array_libs[*]}
do
    if [ `grep -c "package/lean/$var" .git/info/sparse-checkout` -eq 0 ]; then
        echo "package/lean/$var" >> .git/info/sparse-checkout
    fi
done
git pull --depth 1 origin master

############################################################################################

# luci-app-ssr-plus 同步更新
if [ -d $project_root_path/luci-app-ssr-plus ]; then
    rm -rf $project_root_path/luci-app-ssr-plus
fi
if [ -d $project_root_path/naiveproxy ]; then
    rm -rf $project_root_path/naiveproxy
fi
cp -R $tmp_path/kenzok8_packages/luci-app-ssr-plus $project_root_path/
cp -R $tmp_path/kenzok8_packages/naiveproxy $project_root_path/

# libs 同步更新
for var in ${array_libs[*]}
do
    if [ -d $project_root_path/$var ]; then
        rm -rf $project_root_path/$var
    fi
done
cp -R $tmp_path/lean/package/lean/ $project_root_path/

# 提交
# cd $tmp_path/kenzok8_packages
# latest_commit_id=`git rev-parse HEAD`
# latest_commit_msg=`git log --pretty=format:"%s" $current_git_branch_latest_id -1`
# echo $latest_commit_id
# echo $latest_commit_msg

cd $project_root_path
cur_time=$(date "+%Y%m%d-%H%M%S")
git add -A && git commit -m "$cur_time" && git push origin master