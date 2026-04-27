# 基础镜像选择适配PHP5.6的Ubuntu版本
FROM ubuntu:16.04
LABEL maintainer="yourname@example.com"

# 更换国内源加速下载
RUN sed -i 's/archive.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list

# 安装编译工具和PHP依赖
RUN apt-get update && apt-get install -y \
    build-essential \
    dh-make \
    devscripts \
    dpkg-dev \
    libxml2-dev \
    libssl-dev \
    libcurl4-openssl-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libmcrypt-dev \
    libgd-dev \
    wget \
 && rm -rf /var/lib/apt/lists/*

# 下载PHP5.6源码
WORKDIR /root
RUN wget https://www.php.net/distributions/php-5.6.40.tar.gz \
 && tar zxf php-5.6.40.tar.gz \
 && cd php-5.6.40 \
 && mv ../php-5.6.40.tar.gz ../php5.6_5.6.40.orig.tar.gz

# 生成Debian打包模板
WORKDIR /root/php-5.6.40
RUN dh_make --createorig -s -n -y

# 提前输出deb包到容器外目录
VOLUME ["/output"]

# 编译打包脚本
RUN echo '#!/bin/bash' > /build.sh \
 && echo 'dpkg-buildpackage -us -uc' >> /build.sh \
 && echo 'cp /root/*.deb /output/' >> /build.sh \
 && chmod +x /build.sh

CMD ["/build.sh"]
