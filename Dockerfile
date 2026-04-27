# 用debian9基础镜像，兼容php5.6编译
FROM debian:stretch

# 替换国内源加速
RUN sed -i 's/deb.debian.org/mirrors.aliyun.com/g' /etc/apt/sources.list

# 安装编译依赖和打包工具+编辑器（如果后续要手动修改可以保留vim/nano）
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
    nano \
    && rm -rf /var/lib/apt/lists/*

# 创建工作目录
WORKDIR /build

# 下载php5.6源码并生成debian打包模板
RUN wget https://museum.php.net/php5/php-5.6.40.tar.gz \
    && tar xzf php-5.6.40.tar.gz \
    && mv php-5.6.40 php5.6-5.6.40 \
    && cd php5.6-5.6.40 \
    && dh_make -e your@email.com --createorig -s -y

# 直接用RUN cat覆盖rules文件，写入自定义编译配置
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
