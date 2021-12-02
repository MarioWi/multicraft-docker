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

# install jdk-11.0.13+8
RUN curl -LfsSo /tmp/openjdk.tar.gz 'https://github.com/adoptium/temurin11-binaries/releases/download/jdk-11.0.13%2B8/OpenJDK11U-jdk_x64_linux_hotspot_11.0.13_8.tar.gz'; \
    echo "3b1c0c34be4c894e64135a454f2d5aaa4bd10aea04ec2fa0c0efe6bb26528e30 */tmp/openjdk.tar.gz" | sha256sum -c -; \
    mkdir -p /opt/java/openjdk-11; \
    cd /opt/java/openjdk-11; \
    tar -xf /tmp/openjdk.tar.gz --strip-components=1; \
    rm -rf /tmp/openjdk.tar.gz;

## install jdk-16.0.2+7
#RUN curl -LfsSo /tmp/openjdk.tar.gz 'https://github.com/adoptium/temurin16-binaries/releases/download/jdk-16.0.2%2B7/OpenJDK16U-jdk_x64_linux_hotspot_16.0.2_7.tar.gz'; \
#    echo "323d6d7474a359a28eff7ddd0df8e65bd61554a8ed12ef42fd9365349e573c2c */tmp/openjdk.tar.gz" | sha256sum -c -; \
#    mkdir -p /opt/java/openjdk-16; \
#    cd /opt/java/openjdk-16; \
#    tar -xf /tmp/openjdk.tar.gz --strip-components=1; \
#    rm -rf /tmp/openjdk.tar.gz;

# install jdk-17.0.1+12
RUN curl -LfsSo /tmp/openjdk.tar.gz 'https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.1%2B12/OpenJDK17U-jdk_x64_linux_hotspot_17.0.1_12.tar.gz'; \
    echo "323d6d7474a359a28eff7ddd0df8e65bd61554a8ed12ef42fd9365349e573c2c */tmp/openjdk.tar.gz" | sha256sum -c -; \
    mkdir -p /opt/java/openjdk-17; \
    cd /opt/java/openjdk-17; \
    tar -xf /tmp/openjdk.tar.gz --strip-components=1; \
    rm -rf /tmp/openjdk.tar.gz;

ENV JAVA_HOME=/opt/java/openjdk-17 \
    PATH="/opt/java/openjdk-17/bin:$PATH"

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
