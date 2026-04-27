# 用arm64v8架构的Ubuntu16.04作为基础镜像
FROM --platform=linux/arm64 ubuntu:16.04

ENV DEBIAN_FRONTEND=noninteractive

# 安装编译与打包依赖
RUN apt-get update && apt-get install -y \
    build-essential \
    checkinstall \
    wget \
    libxml2-dev \
    libcurl4-openssl-dev \
    libpng-dev \
    libjpeg-dev \
    libmcrypt-dev \
    && rm -rf /var/lib/apt/lists/*

# 下载PHP5.6最终版本源码
WORKDIR /usr/local/src

RUN wget https://museum.php.net/php5/php-5.6.40.tar.gz \
    && tar -zxf php-5.6.40.tar.gz \
    && rm php-5.6.40.tar.gz \
    && cd php-5.6.40
    
WORKDIR /usr/local/src/php-5.6.40

# 编译配置（保留常用扩展，可自行修改）
RUN ./configure --prefix=/usr/local/php5.6 \
    --enable-fpm \
    --enable-mbstring \
    --with-mysqli \
    --with-mcrypt \
    --with-curl \
    --with-gd \
    --with-jpeg-dir \
    --with-png-dir

# 编译
RUN make -j$(nproc)

# 打包生成arm64 deb包，不安装到容器内
RUN checkinstall -D --install=no --pkgname=php5.6 --pkgversion=5.6.40 -y
