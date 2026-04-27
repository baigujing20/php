# 基础镜像选Arm64原生Ubuntu 16.04
FROM arm64v8/ubuntu:16.04

LABEL maintainer="PHP5.6 DEB Builder (arm64) <builder@example.com>"

ENV DEBIAN_FRONTEND=noninteractive

# 替换国内源，解决官方旧源Arm64拉取失败的问题
RUN sed -i 's/archive.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list && \
    sed -i 's/security.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list && \
    apt-get clean && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    devscripts \
    dh-make \
    dpkg-dev \
    libtool \
    libxml2-dev \
    libcurl4-openssl-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libmcrypt-dev \
    libmysqlclient-dev \
    wget \
    && rm -rf /var/lib/apt/lists/*

# 下载解压源码，保持目录规范
WORKDIR /usr/src
RUN wget https://museum.php.net/php5/php-5.6.40.tar.gz && \
    tar xzf php-5.6.40.tar.gz && \
    rm -f php-5.6.40.tar.gz

WORKDIR /usr/src/php-5.6.40

# 初始化dh_make，生成配置模板
RUN rm -rf debian && \
    dh_make --createorig -s -n -y && \
    > debian/control && \
    cat >> debian/control << EOF
Source: php5.6
Section: web
Priority: optional
Maintainer: Custom Build <build@example.com>
Build-Depends: debhelper (>= 9), libtool, libxml2-dev, libcurl4-openssl-dev, libpng-dev, libjpeg-dev, libfreetype6-dev, libmcrypt-dev, libmysqlclient-dev
Standards-Version: 3.9.8
Homepage: https://www.php.net/

Package: php5.6
Version: 5.6.40-1
Architecture: arm64
Depends: \${shlibs:Depends}, \${misc:Depends}
Description: Custom compiled PHP 5.6 for Ubuntu ARM64
 Custom-built PHP 5.6 with common extensions, packaged as DEB.
EOF

# 适配Arm64的编译规则，去掉不兼容参数
RUN > debian/rules && \
    cat >> debian/rules << EOF
#!/usr/bin/make -f

%:
	dh \$@

override_dh_auto_configure:
	dh_auto_configure -- --prefix=/usr/local/php5.6 \
	--with-config-file-path=/usr/local/php5.6/etc \
	--enable-fpm \
	--enable-mbstring \
	--enable-mbregex \
	--enable-opcache \
	--enable-sockets \
	-with-mysql \
	--with-mysqli \
	--with-pdo-mysql \
	--with-gd \
	--with-jpeg-dir \
	--with-png-dir \
	--with-freetype-dir \
	--with-curl \
	--with-mcrypt \
	--with-zlib \
	--disable-fileinfo
EOF

RUN chmod +x debian/rules

# 编译打包，Arm64编译略慢，耐心等即可
RUN dpkg-buildpackage -us -uc -b -j$(nproc)

# 导出deb包到挂载目录
CMD ["sh", "-c", "cp /usr/src/php5.6_5.6.40-1_arm64.deb /output/ && echo 'Build completed! DEB saved to output directory'"]
