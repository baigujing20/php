# 用Debian Stretch镜像适配PHP 5.6编译，替换为国内阿里云源解决过期问题
FROM debian:stretch
LABEL description="PHP 5.6 DEB package builder for GitHub Actions"

# 替换为阿里云国内镜像源，跳过证书验证解决旧系统源过期问题
RUN echo "deb https://mirrors.aliyun.com/debian stretch main non-free contrib" > /etc/apt/sources.list \
    && echo "deb https://mirrors.aliyun.com/debian-security stretch/updates main non-free contrib" >> /etc/apt/sources.list \
    && echo "deb https://mirrors.aliyun.com/debian stretch-updates main non-free contrib" >> /etc/apt/sources.list

# 安装所有编译打包依赖，允许未认证签名解决旧源问题
RUN apt update -y --allow-unauthenticated \
    && apt install -y --allow-unauthenticated --no-install-recommends \
    build-essential dh-make devscripts debhelper dpkg-dev wget \
    libxml2-dev libcurl4-openssl-dev libpng-dev libjpeg-dev \
    libfreetype6-dev libmcrypt-dev libssl-dev libreadline-dev \
    libtidy-dev libxslt1-dev zlib1g-dev libmysqlclient-dev \
    && rm -rf /var/lib/apt/lists/*

# 下载官方PHP 5.6.40源码，跳过SSL验证解决证书过期问题
WORKDIR /build
RUN wget --no-check-certificate https://www.php.net/distributions/php-5.6.40.tar.gz \
    && tar xzf php-5.6.40.tar.gz \
    && rm -rf php-5.6.40.tar.gz

# 把本地的debian打包配置复制进源码目录
COPY debian/ /build/php-5.6.40/debian/

# 给构建规则添加执行权限，避免权限报错
RUN chmod +x /build/php-5.6.40/debian/rules
