#
# This file is part of LSPosed.
#
# LSPosed is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# LSPosed is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with LSPosed.  If not, see <https://www.gnu.org/licenses/>.
#
# Copyright (C) 2021 LSPosed Contributors
#

MODDIR=${0%/*}
cd "$MODDIR"
# post-fs-data.sh may be blocked by other modules. retry to start this
set_value() {
  if [[ -f $2 ]]; then
    chmod 644 $2 2>/dev/null
    echo $1 > $2
  fi
}

swapoff /dev/block/zram0 >/dev/null
echo 1 > /sys/block/zram0/reset
set_value lzo-rle /sys/block/zram0/comp_algorithm
set_value 4G /sys/block/zram0/disksize
mkswap /dev/block/zram0
swapon /dev/block/zram0 >/dev/null
set_value 1 /proc/sys/vm/page-cluster

unshare --propagation slave -m sh -c "$MODDIR/daemon --from-service $@&"

#开机30秒清理电池优化名单
sleep 30
#sh /storage/emulated/0/Android/data/moe.shizuku.privileged.api/start.sh
#优化白名单，（添加应用包名后，将保留应用不被移出电池优化）
#示例：+com.tencent.mm +后面是微信包名
noDozes="
+com.tencent.mm
+com.xiaomi.xmsf
+com.mi.health
"
#执行移出电池优化名单
noDozes=`pm list packages -e | sed "s/package:/-/g"`$noDozes
dumpsys deviceidle whitelist $noDozes

#MIUI安全组件
pm disable com.miui.guardprovider/com.miui.guardprovider.manager.SecurityService
pm disable com.miui.guardprovider/com.miui.guardprovider.manager.CacheBuildJobService