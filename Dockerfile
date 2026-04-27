# 用debian9基础镜像，兼容php5.6编译
FROM debian:stretch
# 替换国内源加速，可选
RUN sed -i 's/deb.debian.org/mirrors.aliyun.com/g' /etc/apt/sources.list
# 安装编译依赖和打包工具
RUN apt-get update && apt-get install -y \
    build-essential \
    dh-make \
    devscripts \
    debhelper \
    libxml2-dev \
    libcurl4-openssl-dev \
    libpng-dev \
    libjpeg-dev \
    freetype-dev \
    wget \
    && rm -rf /var/lib/apt/lists/*
# 创建工作目录
WORKDIR /build
# 下载php5.6源码
RUN wget https://museum.php.net/php5/php-5.6.40.tar.gz \
    && tar xzf php-5.6.40.tar.gz \
    && mv php-5.6.40 php5.6-5.6.40 \
    && cd php5.6-5.6.40 \
    # 生成debian打包模板，选single binary
    && dh_make -e your@email.com --createorig -s -y \
    # 这里可以修改debian/rules，配置编译参数
