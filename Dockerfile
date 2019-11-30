FROM php:7.3.5-alpine3.9

LABEL maintainer="codinghuang"

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories

# install dev libraries
RUN apk add --no-cache \
        linux-headers \
        libc-dev \
        libstdc++ \
        postgresql-dev

# install dev tools
RUN apk add --no-cache \
        autoconf \
        gcc \
        g++ \
        make \
        git

# install debug tools
RUN apk add --no-cache --update gdb cgdb

# install ssh

RUN apk add --no-cache \
        openssh-server

# modify the password
ARG PASSWORD
RUN sed -i "s/#PermitRootLogin.*/PermitRootLogin yes/g" /etc/ssh/sshd_config \
        && ssh-keygen -t rsa -P "" -f /etc/ssh/ssh_host_rsa_key \
        && ssh-keygen -t ecdsa -P "" -f /etc/ssh/ssh_host_ecdsa_key \
        && ssh-keygen -t ed25519 -P "" -f /etc/ssh/ssh_host_ed25519_key \
        && echo "root:${PASSWORD}" | chpasswd

RUN docker-php-ext-install pdo_mysql

RUN pecl install redis \
        && docker-php-ext-enable redis \
        && pecl install msgpack \
        && docker-php-ext-enable msgpack

# install composer
RUN apk --no-cache add composer \
        && composer config -g repo.packagist composer https://mirrors.aliyun.com/composer/ \
        && composer global require hirak/prestissimo

# download swoole
ARG SWOOLE_VERSION
RUN cd /tmp \
        && curl -L https://github.com/swoole/swoole-src/archive/v${SWOOLE_VERSION}.tar.gz -o swoole-src.tar.gz

# build swoole
RUN cd /tmp \
        && tar -xzf swoole-src.tar.gz \
        && cd swoole-src* \
        && phpize \
        && ./configure \
        && make -j4 \
        && make install \
        && docker-php-ext-enable swoole

# add vscode environment
RUN apk add bash \
        nodejs

RUN apk --no-cache add ca-certificates wget
RUN wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub
RUN wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.30-r0/glibc-2.30-r0.apk
RUN apk add glibc-2.30-r0.apk

RUN apk add libstdc++6
# add id_rsa.pub in authorized_keys
ARG SSH_PUB_KEY
RUN mkdir -p ~/.ssh \
        && echo $SSH_PUB_KEY > ~/.ssh/authorized_keys

# set the path to the compiler's search library
ARG LD_LIBRARY_PATH
RUN echo "export LD_LIBRARY_PATH=$LD_LIBRARY_PATH" >> /etc/profile

WORKDIR /root/codeDir

CMD ["/usr/sbin/sshd", "-D"]