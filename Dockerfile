FROM ubuntu:16.04

RUN apt-get update && apt-get install -y \
    build-essential \
    dh-make \
    devscripts \
    dpkg-dev \
    libxml2-dev \
    libssl-dev \
    libcurl4-openssl-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libmcrypt-dev \
    libgd-dev \
    wget \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /root

RUN wget https://www.php.net/distributions/php-5.6.40.tar.gz \
 && tar xvf php-5.6.40.tar.gz \
 && rm php-5.6.40.tar.gz \
 && cd php-5.6.40
 
WORKDIR /root/php-5.6.40

RUN dh_make --createorig -s -n -y

VOLUME ["/output"]

RUN echo '#!/bin/bash' > /build.sh \
 && echo 'dpkg-buildpackage -us -uc' >> /build.sh \
 && echo 'cp /root/*.deb /output/' >> /build.sh \
 && chmod +x /build.sh

CMD ["/build.sh"]
