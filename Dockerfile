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
            --with-freetype-dir=/usr # 在这里加你的扩展参数
EOF
