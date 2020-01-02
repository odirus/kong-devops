#!/usr/bin/env sh

# 复制页面模板到对应的位置
mkdir -p /usr/local/share/lua/5.1/views/maintenance
cp -r /kong_components/kong/plugins/maintenance/view/* /usr/local/share/lua/5.1/views/maintenance/
# 启动应用
/docker-entrypoint.sh kong docker-start