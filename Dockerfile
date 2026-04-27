# Base image: debian 9 (stretch) for php5.6 building
FROM debian:stretch

# Replace with aliyun mirror
RUN sed -i 's/deb.debian.org/mirrors.aliyun.com/g' /etc/apt/sources.list

# Install build dependencies
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

# Work directory
WORKDIR /build

# Download php5.6 source and create debian template
RUN wget https://museum.php.net/php5/php-5.6.40.tar.gz \
    && tar xzf php-5.6.40.tar.gz \
    && mv php-5.6.40 php5.6-5.6.40 \
    && cd php5.6-5.6.40 \
    && dh_make -e your@email.com --createorig -y \
    && rm -f debian/*.ex debian/*.EX

# Generate debian rules file
RUN cd /build/php5.6-5.6.40 \
    && echo '%:' > debian/rules \
    && echo '	dh $@' >> debian/rules \
    && echo '' >> debian/rules \
    && echo 'override_dh_auto_configure:' >> debian/rules \
    && echo './configure --prefix=/usr \' >> debian/rules \
    && echo '            --with-config-file-path=/etc/php \' >> debian/rules \
    && echo '            --enable-fpm \' >> debian/rules \
    && echo '            --with-mysqli \' >> debian/rules \
    && echo '            --with-pdo-mysql \' >> debian/rules \
    && echo '            --with-gd \' >> debian/rules \
    && echo '            --enable-mbstring \' >> debian/rules \
    && echo '            --with-curl \' >> debian/rules \
    && echo '            --with-jpeg-dir=/usr \' >> debian/rules \
    && echo '            --with-freetype-dir=/usr' >> debian/rules
