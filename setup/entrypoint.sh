#!/bin/bash

# Set umask for unraid
umask 000

NEWINSTALL=0
# Create the multicraft folders that will be persistent
mkdir -p /multicraft/jar
mkdir -p /multicraft/data
mkdir -p /multicraft/servers
mkdir -p /multicraft/templates
mkdir -p /multicraft/configs
mkdir -p /multicraft/html

# Change multicraft owner to nobody:users
chown -R nobody:users /multicraft

#######

## Read/Set some Variables

#######

MC_DAEMON_ID=${MC_DAEMON_ID:-"1"}
MC_DAEMON_IP="`ifconfig 2>/dev/null | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}' | head -n1`"
MC_EXTERNAL_IP=${MC_EXTERNAL_IP:-""}
MC_DAEMON_PORT="25465"
MC_DAEMON_DATA="/multicraft/data/daemon.db"
MC_WEB_DATA="/multicraft/data/panel.db"
MC_DAEMON_PW=${MC_DAEMON_PW:-"ChangeMe"}
MC_FTP_SERVER=${MC_FTP_SERVER:-"y"}
MC_FTP_IP=${MC_FTP_IP:-""}
MC_FTP_NATIP=${MC_FTP_NATIP:-""}
MC_FTP_PORT=${MC_FTP_PORT:-"21"}
MC_DB_ENGINE=${MC_DB_ENGINE:-"sqlite"}
MC_DB_HOST=${MC_DB_HOST:-"db"}
MC_DB_NAME=${MC_DB_NAME:-"multicraft_daemon"}
MC_DB_USER=${MC_DB_USER:-"mc_user"}
MC_DB_PASSWORD=${MC_DB_PASSWORD:-"ChangeMe"}
MC_DB_CHARSET=${MC_DB_CHARSET:-"utf8"}
MC_DB_NAME_WEB=${MC_DB_NAME_WEB:-"multicraft_panel"}
MC_KEY=${MC_KEY:-"no"}
MC_LOCAL="y"
MC_MULTIUSER=${MC_MULTIUSER:-"n"}
MC_PLUGINS=""
MC_WEB_USER="nobody:users"
#MC_WEB_USER="www-data"
MC_CREATE_USER="y"
###MC_WEB_DIR="$DIR_ROOT/panel"

CFG="/multicraft/configs/multicraft.conf"
WEB_CFG="/multicraft/configs/panel.php"


MC_JAVA="/opt/java/openjdk-16/bin/java"
MC_ZIP="/usr/bin/zip"
MC_UNZIP="/usr/bin/unzip"

# Multiuser????
MC_USER="multicraft"
MC_USERADD="/usr/sbin/useradd"
MC_GROUPADD="/usr/sbin/groupadd"
MC_USERDEL="/usr/sbin/userdel"
MC_GROUPDEL="/usr/sbin/groupdel"



#######

## Multicraft Daemon Config

#######
if [ ! -f /multicraft/configs/multicraft.conf ]; then
    NEWINSTALL=1


    echo "[$(date +%Y-%m-%d_%T)] - No multicraft daemon config file detected, creating new one from multicraft.conf.dist"
    cp -f /opt/multicraft/multicraft.conf.dist /multicraft/configs/multicraft.conf

    # Update multicraft config file with docker variables
    sed -i -E "s|^user\s=\s(\S*)|user = nobody:users|" /multicraft/configs/multicraft.conf
    sed -i -E "s|^#password\s=\s(\S*)|password = ${MC_DAEMON_PW}|" /multicraft/configs/multicraft.conf
    sed -i -E "s|^#id\s=\s(\S*)|id = ${MC_DAEMON_ID}|" /multicraft/configs/multicraft.conf

    if [ "$MC_LOCAL" != "y" ]; then
        sed -i -E "s|^ip\s=\s(\S*)|ip = ${MC_DAEMON_IP}|" /multicraft/configs/multicraft.conf
        sed -i -E "s|^port\s=\s(\S*)|port = ${MC_DAEMON_PORT}|" /multicraft/configs/multicraft.conf
        sed -i -E "s|^#externalIp\s=\s(\S*)|externalIp = ${MC_EXTERNAL_IP}|" /multicraft/configs/multicraft.conf
    fi
        sed -i -E "s|^#allowSymlinks\s=\s(\S*)|allowSymlinks = true|" /multicraft/configs/multicraft.conf

    if [ "$MC_DB_ENGINE" == "mysql" ]; then
        sed -i -E "s|^#database\s=\s(m\S*)|database = mysql:host=${MC_DB_HOST};dbname=${MC_DB_NAME}|" /multicraft/configs/multicraft.conf
        sed -i -E "s|^#dbUser\s=\s(\S*)|dbUser = ${MC_DB_USER}|" /multicraft/configs/multicraft.conf
        sed -i -E "s|^#dbPassword\s=\s(\S*)|dbPassword = ${MC_DB_PASSWORD}|" /multicraft/configs/multicraft.conf
        sed -i -E "s|^webUser\s=\s(\S*)|webUser = ""|" /multicraft/configs/multicraft.conf
        #sed -i -E "s|^#dbCharset\s=\s(\S*)|dbCharset = ${MC_DB_CHARSET}|" /multicraft/configs/multicraft.conf
    elif [ "$MC_DB_ENGINE" == "sqlite" ]; then
        sed -i -E "s|^#database\s=\s(s\S*)|database = sqlite:${MC_DAEMON_DATA}|" /multicraft/configs/multicraft.conf
        sed -i -E "s|^webUser\s=\s(\S*)|webUser = "${MC_WEB_USER}"|" /multicraft/configs/multicraft.conf
    else
        echo "[$(date +%Y-%m-%d_%T)] - No database engine specified. Please edit config files manually."
    fi
    sed -i -E "s|^baseDir\s=\s(\S*)|baseDir = /opt/multicraft|" /multicraft/configs/multicraft.conf

    if [ "$MC_FTP_SERVER" = "y" ]; then
        #sed -i -E "s|^#ftpIp\s=\s(\S*)|ftpIp = ${MC_FTP_IP}|" /multicraft/configs/multicraft.conf
        sed -i -E "s|^#ftpIp\s=\s(\S*)|ftpIp = 0.0.0.0|" /multicraft/configs/multicraft.conf
        sed -i -E "s|^enabled\s=\s(\S*)|enabled = true|" /multicraft/configs/multicraft.conf
        sed -i -E "s|^#ftpNatIp\s=\s(\S*)|ftpNatIp = ${MC_FTP_NATIP}|" /multicraft/configs/multicraft.conf
        sed -i -E "s|^#ftpPasvPorts\s=\s(\S*)|ftpPasvPorts = 6000-6005|" /multicraft/configs/multicraft.conf
        if [ "$MC_FTP_PORT" != "" ]; then
            sed -i -E "s|^ftpPort\s=\s(\S*)|ftpPort = ${MC_FTP_PORT}|" /multicraft/configs/multicraft.conf
        fi
    else
        sed -i -E "s|^enabled\s=\s(\S*)|enabled = false|" /multicraft/configs/multicraft.conf
    fi
    if [ "$MC_PLUGINS" = "" ]; then
        sed -i -E "s|^forbiddenFiles\s=\s(\S*)|#forbiddenFiles = |" /multicraft/configs/multicraft.conf
    else
        sed -i -E "s|^forbiddenFiles\s=\s(\S*)|forbiddenFiles = ${MC_PLUGINS}|" /multicraft/configs/multicraft.conf
    fi
    sed -i -E "s|^java\s=\s(\S*)|java = ${MC_JAVA}|" /multicraft/configs/multicraft.conf
    sed -i -E "s|^unpackCmd\s=\s(\S*)|unpackCmd = ${MC_UNZIP}' -quo "{FILE}"'|" /multicraft/configs/multicraft.conf
    sed -i -E "s|^packCmd\s=\s(\S*)|packCmd = ${MC_ZIP}' -qr "{FILE}" .'|" /multicraft/configs/multicraft.conf

    if [ "$MC_MULTIUSER" = "y" ]; then
        
        sed -i -E "s|^#multiuser\s=\s(\S*)|multiuser = true|" /multicraft/configs/multicraft.conf
        sed -i -E "s|^addUser\s=\s(\S*)|addUser = ${MC_USERADD}' -c \"Multicraft Server {ID}\" -d \"{DIR}\" -g \"{GROUP}\" -s /bin/false \"{USER}\"'|" /multicraft/configs/multicraft.conf
        sed -i -E "s|^addGroup\s=\s(\S*)|addGroup = ${MC_GROUPADD}' "{GROUP}"'|" /multicraft/configs/multicraft.conf
        sed -i -E "s|^delUser\s=\s(\S*)|delUser = ${MC_USERDEL}' "{USER}"'|" /multicraft/configs/multicraft.conf
        sed -i -E "s|^delGroup\s=\s(\S*)|delGroup = ${MC_GROUPDEL}' "{GROUP}"'|" /multicraft/configs/multicraft.conf
    else
        sed -i -E "s|^multiuser\s=\s(\S*)|multiuser = false|" /multicraft/configs/multicraft.conf
    fi
    sed -i -E "s|command ^\s=\s(\S*)|command = ${MC_ZIP}' -qr "{WORLD}-tmp.zip" . -i "{WORLD}"*/*'|" /multicraft/configs/multicraft.conf

    # Copy config file to the Multicraft folder
    install -C -o nobody -g users /multicraft/configs/multicraft.conf /opt/multicraft/multicraft.conf
else
    echo "[$(date +%Y-%m-%d_%T)] - Multicraft daemon config file already exist! Installing config file."
    install -C -o nobody -g users /multicraft/configs/multicraft.conf /opt/multicraft/multicraft.conf
fi

#######

## Multicraft Panel Config

#######
if [ ! -f /multicraft/configs/panel.php ]; then
    echo "[$(date +%Y-%m-%d_%T)] - No Multicraft Panel config file found. Creating new one from config.php.dist";
    cp -f /var/www/html/multicraft/protected/config/config.php.dist /multicraft/configs/panel.php

    if [ "$MC_DB_ENGINE" == "mysql" ]; then
        # Set Panel settings.
        sed -i -E "/^\s*'panel_db'\s=>\s'(s\S*),/a 'panel_db_pass' => '${MC_DB_PASSWORD}'," /multicraft/configs/panel.php
        sed -i -E "/^\s*'panel_db'\s=>\s'(s\S*),/a 'panel_db_user' => '${MC_DB_USER}'," /multicraft/configs/panel.php
        sed -i -E "/^\s*'panel_db'\s=>\s'(s\S*),/a 'panel_db' => 'mysql:host=${MC_DB_HOST};dbname=${MC_DB_NAME_WEB}'," /multicraft/configs/panel.php

        # Remove Panel SQLite settings
        sed -i -E "s|^\s*'panel_db'\s=>\s'(s\S*),||" /multicraft/configs/panel.php

        # Set daemon settings
        sed -i -E "/^\s*'daemon_db'\s=>\s'(s\S*),/a 'daemon_db_pass' => '${MC_DB_PASSWORD}'," /multicraft/configs/panel.php
        sed -i -E "/^\s*'daemon_db'\s=>\s'(s\S*),/a 'daemon_db_user' => '${MC_DB_USER}'," /multicraft/configs/panel.php
        sed -i -E "/^\s*'daemon_db'\s=>\s'(s\S*),/a 'daemon_db' => 'mysql:host=${MC_DB_HOST};dbname=${MC_DB_NAME}'," /multicraft/configs/panel.php

        # Remove Daemon SQLite settings
        sed -i -E "s|^\s*'daemon_db'\s=>\s'(s\S*),||" /multicraft/configs/panel.php

    elif [ "$MC_DB_ENGINE" == "sqlite" ]; then
        sed -i -E "s|^\s*'panel_db'\s=>\s'(\S*),|'panel_db' => 'sqlite:${MC_WEB_DATA}',|" /multicraft/configs/panel.php
        sed -i -E "s|^\s*'daemon_db'\s=>\s'(\S*),|'daemon_db' => 'sqlite:${MC_DAEMON_DATA}',|" /multicraft/configs/panel.php
    else
        echo "[$(date +%Y-%m-%d_%T)] - No database engine specified. Please edit config files manually."
    fi

    sed -i -E "s|^\s*'daemon_password'\s=>\s'(\S*),|'daemon_password' => '${MC_DAEMON_PW}',|" /multicraft/configs/panel.php

    #if [ "$MC_API" == "y" ]; then
    #    sed -i -E "s|^\s*'api_enabled'\s=>\s'(\S*),|'api_enabled' => true,|" /multicraft/configs/panel.php
    #else
    #    sed -i -E "s|^\s*'api_enabled'\s=>\s'(\S*),|'api_enabled' => false,|" /multicraft/configs/panel.php
    #fi

    cp -r /var/www/html/* /multicraft/html
    chown -R www-data:www-data /multicraft/html
    chown -R www-data:users /multicraft/html
    chmod -R o-rwx /multicraft/html

    /opt/multicraft/bin/multicraft set_permissions

else
    echo "[$(date +%Y-%m-%d_%T)] - Multicraft Panel config file found. Creating symbolic link"
    chown nobody:users /multicraft/configs/panel.php
    chmod 777 /multicraft/configs/panel.php
    #rm /var/www/html/multicraft/protected/config/config.php
    ln -s /multicraft/configs/panel.php /var/www/html/multicraft/protected/config/config.php
fi

#######

## Apache Config

#######
if [ ! -f /multicraft/configs/apache.conf ]; then
    echo "[$(date +%Y-%m-%d_%T)] - No Apache config file found. Creating one from template."

    cp /etc/apache2/sites-enabled/000-default.conf /multicraft/configs/apache.conf
    rm /etc/apache2/sites-enabled/000-default.conf

    ln -s /multicraft/configs/apache.conf /etc/apache2/sites-enabled/000-default.conf

else
    echo "[$(date +%Y-%m-%d_%T)] - Apache Config File found. Creating symbolic link"

    # If config file already exist in sites-enabled, delete it first.
    if [ -f /etc/apache2/sites-enabled/000-default.conf ]; then
        rm /etc/apache2/sites-enabled/000-default.conf
    fi

    ln -s /multicraft/configs/apache.conf /etc/apache2/sites-enabled/000-default.conf
fi


# Start apache2
service apache2 start

# If new install
if [ "$NEWINSTALL" == 1 ]; then

    if [ "$MC_KEY" != "no" ]; then
        echo
        echo "[$(date +%Y-%m-%d_%T)] - Creating Licence File"
        echo "$MC_KEY" > "/opt/multicraft/multicraft.key"
    fi

    cp -r /opt/multicraft/jar/* /multicraft/jar
    chown -R nobody:users /multicraft/jar

    cp -r /opt/multicraft/templates/* /multicraft/templates
    chown -R nobody:users /multicraft/templates

    cp -r /opt/multicraft/templates/* /multicraft/html
    chown -R nobody:users /multicraft/templates

    rm -r /opt/multicraft/jar
    rm -r /opt/multicraft/templates

    # Copy config file to the panel folder.
    chown nobody:users /multicraft/configs/panel.php
    chmod 777 /multicraft/configs/panel.php
    #rm /var/www/html/multicraft/protected/config/config.php
    ln -s /multicraft/configs/panel.php /var/www/html/multicraft/protected/config/config.php

else
    # Remove install.php since it is not needed.
    rm /var/www/html/multicraft/install.php
fi

# Remove data folder to replace with symlink
if [ -d /opt/multicraft/data ]; then
rm -r /opt/multicraft/data
fi
ln -s /multicraft/data /opt/multicraft/data
echo "[$(date +%Y-%m-%d_%T)] - Symlinked Data"

if [ -d /opt/multicraft/jar ]; then
rm -r /opt/multicraft/jar
fi
ln -s /multicraft/jar /opt/multicraft/jar
echo "[$(date +%Y-%m-%d_%T)] - Symlinked Jar"

if [ -d /opt/multicraft/servers ]; then
rm -r /opt/multicraft/servers
fi
ln -s /multicraft/servers /opt/multicraft/servers
echo "[$(date +%Y-%m-%d_%T)] - Symlinked Servers"

if [ -d /opt/multicraft/templates ]; then
rm -r /opt/multicraft/templates
fi
ln -s /multicraft/templates /opt/multicraft/templates
echo "[$(date +%Y-%m-%d_%T)] - Symlinked Templates"

if [ -d /var/www/html ]; then
chown -R nobody:users /var/www/html/
rm -r /var/www/html
fi
ln -s /multicraft/html /var/www/html
chown -R www-data:www-data /var/www/html/
echo "[$(date +%Y-%m-%d_%T)] - Symlinked HTML"


# Start and stop Multicraft to set permissions
/opt/multicraft/bin/multicraft start
sleep 1

# Set data folder permissions
chown -R nobody:users /multicraft
chmod -R 777 /multicraft

chown -R nobody:users /opt/multicraft
chmod -R 770 /opt/multicraft

# Tail the multicraft logs
tail -f /opt/multicraft/multicraft.log
