# 运行容器并执行构建
docker run --rm -it ubuntu:16.04 bash << 'EOF'
apt-get update && apt-get install -y \
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
    wget

cd /tmp
wget -q https://www.php.net/distributions/php-5.6.40.tar.gz
tar -xzf php-5.6.40.tar.gz
cd php-5.6.40

./configure \
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
    --enable-fpm

make -j$(nproc)
make install

# 创建 debian 包
mkdir -p debian
cat > debian/rules << 'RULES'
#!/usr/bin/make -f
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
RULES

chmod +x debian/rules

cat > debian/control << 'CONTROL'
Source: php5.6
Section: php
Priority: optional
Maintainer: Docker User
Build-Depends: debhelper (>= 9), build-essential, autoconf, libtool, pkg-config, libssl-dev, libcurl4-openssl-dev, libxml2-dev, libbz2-dev, libpng-dev, libjpeg-dev, libfreetype6-dev, libreadline-dev, libxslt-dev, zlib1g-dev, libmysqlclient-dev, libsqlite3-dev, libzip-dev, libonig-dev, libldap2-dev, libmagic1, libxpm-dev, libgd-dev, libmcrypt-dev, po-debconf
Standards-Version: 3.9.6
Package: php5.6
Architecture: any
Depends: ${misc:Depends}, ${shlibs:Depends}, libmcrypt4, libzip1
Description: PHP 5.6
CONTROL

cat > debian/changelog << 'CHANGELOG'
php5.6 (5.6.40-1) xenial; urgency=medium
  * Initial release
 -- Docker User <user@example.com>
CHANGELOG

dpkg-buildpackage -us -uc -b
cp *.deb /tmp/debs/
EOF
# 挂载宿主机目录以导出 deb
# 实际上，由于我们使用 bash heredoc，输出会直接显示在终端
# 我们需要修改脚本以将文件复制到挂载点

最实用的单命令方案：

docker run --rm -it -v "$(pwd)":/host ubuntu:16.04 bash << 'SCRIPT'
apt-get update && apt-get install -y \
    build-essential autoconf libtool pkg-config \
    libssl-dev libcurl4-openssl-dev libxml2-dev \
    libbz2-dev libpng-dev libjpeg-dev libfreetype6-dev \
    libreadline-dev libxslt-dev zlib1g-dev \
    libmysqlclient-dev libsqlite3-dev libzip-dev \
    libonig-dev libldap2-dev libmagic1 libxpm-dev \
    libgd-dev libmcrypt-dev \
    debhelper dh-make devscripts fakeroot po-debconf wget

cd /tmp
wget -q https://www.php.net/distributions/php-5.6.40.tar.gz
tar -xzf php-5.6.40.tar.gz
cd php-5.6.40

./configure \
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
    --enable-fpm

make -j$(nproc)
make install

mkdir -p debian
cat > debian/rules << 'EOF'
#!/usr/bin/make -f
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
chmod +x debian/rules
cat > debian/control << 'EOF'
Source: php5.6
Section: php
Priority: optional
Maintainer: Docker User
Build-Depends: debhelper (>= 9), build-essential, autoconf, libtool, pkg-config, libssl-dev, libcurl4-openssl-dev, libxml2-dev, libbz2-dev, libpng-dev, libjpeg-dev, libfreetype6-dev, libreadline-dev, libxslt-dev, zlib1g-dev, libmysqlclient-dev, libsqlite3-dev, libzip-dev, libonig-dev, libldap2-dev, libmagic1, libxpm-dev, libgd-dev, libmcrypt-dev, po-debconf
Standards-Version: 3.9.6
Package: php5.6
Architecture: any
Depends: ${misc:Depends}, ${shlibs:Depends}, libmcrypt4, libzip1
Description: PHP 5.6
EOF

cat > debian/changelog << 'EOF'
php5.6 (5.6.40-1) xenial; urgency=medium
  * Initial release
 -- Docker User <user@example.com>
EOF

dpkg-buildpackage -us -uc -b
cp *.deb /host/
SCRIPT
