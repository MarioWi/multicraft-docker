FROM ubuntu:20.04

LABEL maintainer="email@mario-wicke.de" \
	description="Dockerised Multicraft Server"

ENV LANG='de_DE.UTF-8' \
    LANGUAGE='de_DE:de' \
    LC_ALL='de_DE.UTF-8' \
    TZ='Europe/Berlin'

ENV DEBIAN_FRONTEND=noninteractive \
    LC_ALL=C.UTF-8 \
    PHP_VERSION=7.4 \
    CONFIG_DIR=/config

ENV EXTRA_PACKAGES="mlocate" \
    PHP_PACKAGES="php${PHP_VERSION} php${PHP_VERSION}-cli libapache2-mod-php${PHP_VERSION} sqlite3 php${PHP_VERSION}-sqlite3 php${PHP_VERSION}-mysql php${PHP_VERSION}-gd php${PHP_VERSION}-pdo" \
    BUILD_PACKAGES="wget"

# ENV JAVA_VERSION jdk-11.0.11+9
ENV JAVA_VERSION jdk-16.0.1+9

RUN usermod -u 99 nobody && \
    usermod -g 100 nobody && \
    usermod -d /home nobody && \
    usermod -a -G users www-data && \
    chown -R nobody:users /home

RUN apt-get update \
    && apt-get install -y --no-install-recommends tzdata curl ca-certificates fontconfig locales \
    && echo "de_DE.UTF-8 UTF-8" >> /etc/locale.gen \
    && locale-gen de_DE.UTF-8 \
    && rm -rf /var/lib/apt/lists/* \
    echo ${TZ} | tee /etc/timezone

RUN apt-get update && \
    apt-get install -y --no-install-recommends $EXTRA_PACKAGES $PHP_PACKAGES \
        lib32gcc1 lib32stdc++6 wget binutils apache2 \
        vim sudo zip unzip imagemagick lsof && \
    apt-get clean && \
    a2enmod php${PHP_VERSION} && \
    rm -rf /var/lib/apt/lists/* && \
    update-alternatives --set php /usr/bin/php${PHP_VERSION}

# install jdk-11.0.11%2B9
RUN curl -LfsSo /tmp/openjdk.tar.gz 'https://github.com/AdoptOpenJDK/openjdk11-binaries/releases/download/jdk-11.0.11%2B9/OpenJDK11U-jdk_x64_linux_hotspot_11.0.11_9.tar.gz'; \
    echo "e99b98f851541202ab64401594901e583b764e368814320eba442095251e78cb */tmp/openjdk.tar.gz" | sha256sum -c -; \
    mkdir -p /opt/java/openjdk-11; \
    cd /opt/java/openjdk-11; \
    tar -xf /tmp/openjdk.tar.gz --strip-components=1; \
    rm -rf /tmp/openjdk.tar.gz;

## install jdk-15.0.2%2B7
#RUN curl -LfsSo /tmp/openjdk.tar.gz 'https://github.com/AdoptOpenJDK/openjdk15-binaries/releases/download/jdk-15.0.2%2B7/OpenJDK15U-jdk_x64_linux_hotspot_15.0.2_7.tar.gz'; \
#    echo "94f20ca8ea97773571492e622563883b8869438a015d02df6028180dd9acc24d */tmp/openjdk.tar.gz" | sha256sum -c -; \
#    mkdir -p /opt/java/openjdk-15; \
#    cd /opt/java/openjdk-15; \
#    tar -xf /tmp/openjdk.tar.gz --strip-components=1; \
#    rm -rf /tmp/openjdk.tar.gz;

# install jdk-16.0.1%2B9
RUN curl -LfsSo /tmp/openjdk.tar.gz 'https://github.com/AdoptOpenJDK/openjdk16-binaries/releases/download/jdk-16.0.1%2B9/OpenJDK16U-jdk_x64_linux_hotspot_16.0.1_9.tar.gz'; \
    echo "7fdda042207efcedd30cd76d6295ed56b9c2e248cb3682c50898a560d4aa1c6f */tmp/openjdk.tar.gz" | sha256sum -c -; \
    mkdir -p /opt/java/openjdk-16; \
    cd /opt/java/openjdk-16; \
    tar -xf /tmp/openjdk.tar.gz --strip-components=1; \
    rm -rf /tmp/openjdk.tar.gz;

ENV JAVA_HOME=/opt/java/openjdk-16 \
    PATH="/opt/java/openjdk-11/bin:/opt/java/openjdk-16/bin:$PATH"

COPY setup/000-default.conf /etc/apache2/sites-enabled/000-default.conf 

RUN mkdir -p /scripts/
COPY setup/install.sh /scripts/install.sh 
RUN chmod +x /scripts/install.sh && \
    /scripts/install.sh
COPY setup/entrypoint.sh /scripts/entrypoint.sh
RUN chmod +x /scripts/entrypoint.sh

EXPOSE 80
EXPOSE 21
EXPOSE 6000-6005

EXPOSE 25565
EXPOSE 25565/udp
# Bedrock
EXPOSE 19132-19133/udp

# Reserved for
# GeyserMC
EXPOSE 15580-15590/udp
# Server
EXPOSE 25580-25590
# dynMap
EXPOSE 35580-35590

VOLUME /multicraft

ENV MC_DAEMON_ID="1" \
    MC_DAEMON_PW="ChangeMe" \
    MC_FTP_IP="" \
    MC_FTP_PORT="21" \
    MC_FTP_SERVER="y" \
    MC_DB_ENGINE="sqlite" \
    MC_DB_NAME="multicraft_daemon" \
    MC_DB_HOST="db" \
    MC_DB_USER="mc_user" \
    MC_DB_PASSWORD="ChangeMe" \
    MC_DB_CHARSET="utf8" \
    MC_KEY="" \
    MC_SERVER_ADMIN="webmaster@localhost" \
    MC_SERVER_NAME="" \
    MC_MULTIUSER="n" \
    DEBUG=false

CMD ["/scripts/entrypoint.sh"]
