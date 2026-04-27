FROM debian:stretch
LABEL maintainer="php5.6-deb-builder"

# 换国内源加快下载，嫌慢可以注释掉用官方源
RUN sed -i 's/deb.debian.org/mirrors.aliyun.com/g' /etc/apt/sources.list

# 安装所有依赖
RUN apt update && apt install -y --no-install-recommends \
    build-essential \
    dh-make \
    devscripts \
    debhelper \
    dpkg-dev \
    wget \
    libxml2-dev \
    libcurl4-openssl-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libmcrypt-dev \
    libssl-dev \
    libreadline-dev \
    libtidy-dev \
    libxslt1-dev \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

# 初始化构建目录
WORKDIR /build
RUN wget https://www.php.net/distributions/php-5.6.40.tar.gz \
    && tar xzf php-5.6.40.tar.gz \
    && mv php-5.6.40 php5.6-5.6.40

# 复制自定义打包配置到容器
COPY debian/ /build/php5.6-5.6.40/debian/
