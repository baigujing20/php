# 使用arm64版本的Ubuntu作为基础镜像
FROM arm64v8/ubuntu:20.04

# 避免交互式配置提示
ENV DEBIAN_FRONTEND=noninteractive

# 安装编译与打包工具
RUN apt-get update && apt-get install -y \
    build-essential \
    wget \
    libxml2-dev \
    libcurl4-openssl-dev \
    libpng-dev \
    libjpeg-dev \
    checkinstall \
    && rm -rf /var/lib/apt/lists/*

# 下载PHP5.6源码
RUN wget https://museum.php.net/php5/php-5.6.40.tar.gz && \
    tar -zxf php-5.6.40.tar.gz && \
    rm php-5.6.40.tar.gz

# 进入源码目录
WORKDIR /php-5.6.40

# 配置编译选项（可根据需求修改）
RUN ./configure --prefix=/usr/local/php5.6 \
    --enable-fpm \
    --with-mysqli \
    --with-curl \
    --with-gd \
    --with-jpeg-dir \
    --with-png-dir

# 编译源码
RUN make -j$(nproc)

# 使用checkinstall打包为deb包
RUN checkinstall -D --install=no --pakdir=/output make install
