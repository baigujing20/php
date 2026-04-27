FROM ubuntu:16.04

# 设置环境变量，避免交互式提示
ENV DEBIAN_FRONTEND=noninteractive

# 1. 更新源并安装构建依赖
RUN apt-get update && apt-get install -y \
    build-essential \
    autoconf \
    libtool \
    pkg-config \
    libssl-dev \
    libcurl4-openssl-dev \
    libxml2-dev \
    libbz2-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libreadline-dev \
    libxslt-dev \
    zlib1g-dev \
    libmysqlclient-dev \
    libsqlite3-dev \
    libzip-dev \
    libonig-dev \
    libldap2-dev \
    libmagic1 \
    libxpm-dev \
    libgd-dev \
    libmcrypt-dev \
    debhelper \
    dh-make \
    devscripts \
    fakeroot \
    po-debconf \
    wget \
    curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 2. 安装 fpm 工具 (用于快速打包，可选，但推荐)
# 注意：在旧系统上安装 ruby-fpm 可能需要额外依赖，这里为了简化，我们将手动使用 dpkg-deb
# 如果需要，可以安装 ruby 和 fpm
# RUN apt-get install -y ruby ruby-dev rubygems && gem install fpm

# 3. 创建工作目录
WORKDIR /tmp/php-build

# 4. 下载 PHP 5.6.40 源码 (最后一个 5.6 版本)
RUN wget -q https://www.php.net/distributions/php-5.6.40.tar.gz \
    && tar -xzf php-5.6.40.tar.gz \
    && rm php-5.6.40.tar.gz

WORKDIR /tmp/php-build/php-5.6.40

# 5. 配置 PHP
# 注意：Ubuntu 16.04 的 OpenSSL 1.0.2 是默认的，无需额外配置
# 这里开启常用模块
RUN ./configure \
    --prefix=/usr \
    --with-config-file-path=/etc/php/5.6 \
    --with-config-file-scan-dir=/etc/php/5.6/conf.d \
    --enable-fpm \
    --with-curl \
    --with-openssl \
    --with-mysql \
    --with-pdo-mysql \
    --with-zlib \
    --with-jpeg-dir \
    --with-png-dir \
    --with-freetype-dir \
    --with-gd \
    --with-xpm \
    --with-ldap \
    --with-mcrypt \
    --with-mbstring \
    --with-zip \
    --enable-mysqlnd \
    --enable-opcache \
    --enable-fpm \
    && make -j$(nproc) \
    && make install

# 6. 构建 Debian 包
# 使用 dh-make 创建基础结构
# 注意：由于 PHP 5.6 较老，我们需要手动编写 rules 和 control
# 这里使用一个简单的脚本方式，或者手动创建

# 创建 debian 目录
RUN mkdir -p debian

# 创建 debian/rules
RUN cat > debian/rules << 'EOF'
#!/usr/bin/make -f

%:
	dh $@ --with php

%:
	dh $@ --with php

%:
	dh $@ --with php

override_dh_auto_configure:
	dh_auto_configure -- \
		--prefix=/usr \
		--with-config-file-path=/etc/php/5.6 \
		--with-config-file-scan-dir=/etc/php/5.6/conf.d \
		--enable-fpm \
		--with-curl \
		--with-openssl \
		--with-mysql \
		--with-pdo-mysql \
		--with-zlib \
		--with-jpeg \
		--with-png \
		--with-freetype \
		--with-gd \
		--with-xpm \
		--with-ldap \
		--with-mcrypt \
		--with-mbstring \
		--with-zip \
		--enable-mysqlnd \
		--enable-opcache \
		--disable-static

%:
	dh $@
EOF

# 创建 debian/control
RUN cat > debian/control << 'EOF'
Source: php5.6
Section: php
Priority: optional
Maintainer: Docker User <user@example.com>
Build-Depends: debhelper (>= 9),
	build-essential,
	autoconf,
	libtool,
	pkg-config,
	libssl-dev,
	libcurl4-openssl-dev,
	libxml2-dev,
	libbz2-dev,
	libpng-dev,
	libjpeg-dev,
	libfreetype6-dev,
	libreadline-dev,
	libxslt-dev,
	zlib1g-dev,
	libmysqlclient-dev,
	libsqlite3-dev,
	libzip-dev,
	libonig-dev,
	libldap2-dev,
	libmagic1,
	libxpm-dev,
	libgd-dev,
	libmcrypt-dev,
	po-debconf
Standards-Version: 3.9.6

Package: php5.6
Architecture: any
Depends: ${misc:Depends}, ${shlibs:Depends}, ${php:Depends}, libmcrypt4, libzip1
Description: server-side, HTML-embedded scripting language
 PHP 5.6 is a general-purpose scripting language that is especially suited to web development.
EOF

# 创建 debian/changelog
RUN cat > debian/changelog << 'EOF'
php5.6 (5.6.40-1) xenial; urgency=medium

  * Initial release based on Ubuntu 16.04

 -- Docker User <user@example.com>  Wed, 27 Apr 2026 00:00:00 +0000
EOF

# 设置权限
RUN chmod +x debian/rules

# 7. 清理旧二进制，只保留编译产物
RUN make clean

# 8. 构建 .deb 包
RUN dpkg-buildpackage -us -uc -b

# 9. 将生成的 .deb 包移动到 /opt 以便导出
RUN mkdir -p /opt/debs && cp /tmp/php-build/php5.6*.deb /opt/debs/

# 10. 运行一个命令以完成构建 (保持容器运行以便我们退出后挂载)
CMD ["tail", "-f", "/dev/null"]
