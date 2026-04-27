#!/bin/bash
# 构建镜像
docker build -t php56-deb-builder .
# 启动容器开始编译打包
docker run -id --name php56-builder php56-deb-builder bash
# 容器内执行打包
docker exec php56-builder bash -c "cd /build/php5.6-5.6.40 && dpkg-buildpackage -us -uc -b"
# 把生成的deb包拷到当前目录
docker cp php56-builder:/build/php5.6_5.6.40_amd64.deb ./
# 清理容器
docker rm -f php56-builder
