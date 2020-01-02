# kong-devops
Kong 网关开发环境，方便插件开发和调试


## 如何使用
确保本机已经安装了 Docker 环境，然后在项目路径下直接执行启动命令 
```
docker-compose up -d
```
启动成功后，则可以访问到一下资源
1. 80 端口，对应 kong 的 8000 端口
2. 1337 端口，konga 管理界面，已经配置好默认节点信息（账号：admin，密码：kongaadmin）

当某个插件修改代码之后，需要重启 kong 才行，执行以下命令即可
```
docker-compose restart kong
```

## 插件示例
## 页面维护插件（maintenance）
当某个项目需要显示维护界面时，在对应的 service 下启用该插件即可，如果需要全部项目都进入维护状态，通过全局方式启用该插件即可
