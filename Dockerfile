# 指定目标架构，不需要额外命令行参数
FROM --platform=linux/arm64 ubuntu:20.04

# 禁用交互式安装提示
ENV DEBIAN_FRONTEND=noninteractive

# 适配arm64架构，直接重写完整的阿里云apt源
RUN rm /etc/apt/sources.list && \
     apt update && \
     echo "deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal main contrib non-free" > /etc/apt/sources.list && \
     apt update

# 安装编译、依赖、打包工具
RUN apt install -y \
    build-essential \
    wget \
    libxml2-dev \
    libcurl4-openssl-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libzip-dev \
    libssl-dev \
    checkinstall \
    && rm -rf /var/lib/apt/lists/*

# 下载PHP5.6最终稳定版源码（官方归档站可稳定获取）
RUN wget https://museum.php.net/php5/php-5.6.40.tar.gz && \
    tar xvf php-5.6.40.tar.gz && \
    rm php-5.6.40.tar.gz && \
    cd php-5.6.40

# 进入源码目录
WORKDIR /php-5.6.40

# 基础常用编译配置，可自行修改增减扩展
RUN ./configure --prefix=/usr/local/php5.6 \
    --enable-fpm \
    --enable-mbstring \
    --enable-zip \
    --with-mysqli \
    --with-pdo-mysql \
    --with-curl \
    --with-gd \
    --with-jpeg-dir=/usr \
    --with-png-dir=/usr \
    --with-freetype-dir=/usr \
    --with-openssl

# 编译，用checkinstall生成deb包（不安装到容器内）
RUN make -j$(nproc) && \
    checkinstall -D \
    --install=no \
    --pakdir=/output \
    --pkgname=php5.6 \
    --maintainer=local@build \
    make install

# 留空保持容器不退出
CMD ["tail", "-f", "/dev/null"]
