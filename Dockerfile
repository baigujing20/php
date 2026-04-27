# 基础镜像用debian:stretch对应debian9，适配php5.6编译环境
FROM debian:stretch

# 替换阿里源加速下载
RUN sed -i 's/deb.debian.org/mirrors.aliyun.com/g' /etc/apt/sources.list

# 安装编译依赖
RUN apt-get update && apt-get install -y \
    build-essential \
    dh-make \
    devscripts \
    debhelper \
    libxml2-dev \
    libcurl4-openssl-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    wget \
    && rm -rf /var/lib/apt/lists/*

# 创建工作目录
WORKDIR /build

# 下载php5.6源码，生成debian打包模板
RUN wget https://museum.php.net/php5/php-5.6.40.tar.gz \
    && tar xzf php-5.6.40.tar.gz \
    && mv php-5.6.40 php5.6-5.6.40 \
    && cd php5.6-5.6.40 \
    && dh_make -e your@email.com --createorig -y \
    && rm -f debian/*.ex debian/*.EX

# 正确写入debian/rules配置，全部小写保持语法正确
RUN cat > /build/php5.6-5.6.40/debian/rules << 'EOF'
%:
	dh $@

override_dh_auto_configure:
	./configure --prefix=/usr \
            --with-config-file-path=/etc/php \
            --enable-fpm \
            --with-mysqli \
            --with-pdo-mysql \
            --with-gd \
            --enable-mbstring \
            --with-curl \
            --with-jpeg-dir=/usr \
            --with-freetype-dir=/usr
EOF
