FROM ubuntu:20.04

LABEL maintainer="email@mario-wicke.de" \
	description="Dockerised Multicraft Server"

ARG MASK=000 \
    USERID=99 \
    GROUPID=100 \
    USERNAME="nobody"
ENV MASK=${MASK} \
    USERID=${USERID} \
    GROUPID=${GROUPID} \
    USERNAME=${USERNAME}
    
ENV LANG='de_DE.UTF-8' \
    LANGUAGE='de_DE:de' \
    LC_ALL='de_DE.UTF-8' \
    TZ='Europe/Berlin'

ENV DEBIAN_FRONTEND=noninteractive \
    LC_ALL=C.UTF-8 \
    PHP_VERSION=7.4 \
    CONFIG_DIR=/config

ENV EXTRA_PACKAGES="mlocate mysql-client" \
    PHP_PACKAGES="php${PHP_VERSION} php${PHP_VERSION}-cli libapache2-mod-php${PHP_VERSION} sqlite3 php${PHP_VERSION}-sqlite3 php${PHP_VERSION}-mysql php${PHP_VERSION}-gd php${PHP_VERSION}-pdo" \
    BUILD_PACKAGES="wget"

RUN useradd ${USERNAME} -s /bin/bash && \
    usermod -d /home ${USERNAME} && \
    usermod -a -G users www-data && \
    chown -R ${USERNAME}:users /home

RUN apt-get update \
    && apt-get install -y --no-install-recommends tzdata curl ca-certificates fontconfig locales \
    && echo "de_DE.UTF-8 UTF-8" >> /etc/locale.gen \
    && locale-gen de_DE.UTF-8 \
    && rm -rf /var/lib/apt/lists/* \
    echo ${TZ} | tee /etc/timezone

RUN apt-get update && \
    apt-get install -y --no-install-recommends $EXTRA_PACKAGES $PHP_PACKAGES \
        lib32gcc1 lib32stdc++6 wget binutils apache2 \
        vim sudo zip unzip imagemagick lsof quota && \
    apt-get clean && \
    a2enmod php${PHP_VERSION} && \
    rm -rf /var/lib/apt/lists/* && \
    update-alternatives --set php /usr/bin/php${PHP_VERSION}

# to be compatible with https://github.com/ValentinTh/MultiCraft-JAR-Conf we need the following versions and Folder Structure
# Java 8 J9 : /usr/lib/jvm/adoptopenjdk-8-openj9-jre-amd64
# Java 8    : /usr/lib/jvm/adoptopenjdk-8-hotspot-jre-amd64
# Java 11   : /usr/lib/jvm/adoptopenjdk-11-hotspot-jre-amd64
# Java 17   : /usr/lib/jvm/zulu17-ca-amd64 
#
# for compatible with https://github.com/MarioWi/MultiCraft-JAR-Conf we do not need a specific Folder Structure the paths could be defined in installscript 
# so we will install Java in the following folders 
# Java 8 J9 : /opt/java/openjdk-8J9
# Java 8    : /opt/java/openjdk-8
# Java 11   : /opt/java/openjdk-11
# Java 17   : /opt/java/openjdk-17

# install OpenJDK 8u312-b07 - OpenJ9 0.29.0 from IBM developer (latest Version of OpenJDK8 with OpenJ9)
RUN curl -LfsSo /tmp/openjdk.tar.gz 'https://github.com/ibmruntimes/semeru8-binaries/releases/download/jdk8u312-b07_openj9-0.29.0/ibm-semeru-open-jdk_x64_linux_8u312b07_openj9-0.29.0.tar.gz'; \
    echo "c7306112201b45cc8b96e6d6fb3f6de727ddbbb51022cbd9cff98b661e37a510 */tmp/openjdk.tar.gz" | sha256sum -c -; \
    mkdir -p /opt/java/openjdk-8J9; \
    cd /opt/java/openjdk-8J9; \
    tar -xf /tmp/openjdk.tar.gz --strip-components=1; \
    rm -rf /tmp/openjdk.tar.gz;

# install jdk8u312-b07
RUN curl -LfsSo /tmp/openjdk.tar.gz 'https://github.com/adoptium/temurin8-binaries/releases/download/jdk8u312-b07/OpenJDK8U-jdk_x64_linux_hotspot_8u312b07.tar.gz'; \
    echo "699981083983b60a7eeb511ad640fae3ae4b879de5a3980fe837e8ade9c34a08 */tmp/openjdk.tar.gz" | sha256sum -c -; \
    mkdir -p /opt/java/openjdk-8; \
    cd /opt/java/openjdk-8; \
    tar -xf /tmp/openjdk.tar.gz --strip-components=1; \
    rm -rf /tmp/openjdk.tar.gz;

# install jdk-11.0.13+8
RUN curl -LfsSo /tmp/openjdk.tar.gz 'https://github.com/adoptium/temurin11-binaries/releases/download/jdk-11.0.13%2B8/OpenJDK11U-jdk_x64_linux_hotspot_11.0.13_8.tar.gz'; \
    echo "3b1c0c34be4c894e64135a454f2d5aaa4bd10aea04ec2fa0c0efe6bb26528e30 */tmp/openjdk.tar.gz" | sha256sum -c -; \
    mkdir -p /opt/java/openjdk-11; \
    cd /opt/java/openjdk-11; \
    tar -xf /tmp/openjdk.tar.gz --strip-components=1; \
    rm -rf /tmp/openjdk.tar.gz;

# install jdk-17.0.1+12
RUN curl -LfsSo /tmp/openjdk.tar.gz 'https://cdn.azul.com/zulu/bin/zulu17.30.15-ca-jdk17.0.1-linux_x64.tar.gz'; \
    echo "9b8e4d1e47b02b9c2392462ee82988c189357471de3224c37173fa58e2b25112 */tmp/openjdk.tar.gz" | sha256sum -c -; \
    mkdir -p /opt/java/openjdk-17; \
    cd /opt/java/openjdk-17; \
    tar -xf /tmp/openjdk.tar.gz --strip-components=1; \
    rm -rf /tmp/openjdk.tar.gz;

ENV JAVA_HOME=/opt/java/openjdk-17 \
    PATH="/opt/java/openjdk-17/bin:$PATH" \
    JAVA_VERSION=jdk-17.0.1+12

COPY ./setup/000-default.conf /etc/apache2/sites-enabled/000-default.conf 

RUN mkdir -p /scripts/
COPY ./setup/install.sh /scripts/install.sh 
RUN chmod +x /scripts/install.sh && \
    /scripts/install.sh
COPY ./setup/entrypoint.sh /scripts/entrypoint.sh
RUN chmod +x /scripts/entrypoint.sh

# Panel
EXPOSE 80
# FTP
EXPOSE 21
# FTP passive ports
EXPOSE 6000-6005

# Daemon
EXPOSE 25465

# Java CLient standard
EXPOSE 25565
EXPOSE 25565/udp
# Bedrock Client standard
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
