#!/bin/bash

# Set umask for unraid
umask ${MASK}

#######

## Read/Set some Variables

#######
USERNAME=$(cat /opt/multicraft/USERNAME)
GROUPNAME=$(cat /opt/multicraft/GROUPNAME)

MC_DIR="/multicraft"
MC_OPT_DIR="/opt/multicraft"

MC_KEY=${MC_KEY:-"no"}

MC_USER="${USERNAME}:${GROUPNAME}"
MC_WEB_USER="${USERNAME}:www-data"
MC_DAEMON_IP="`ifconfig 2>/dev/null | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}' | head -n1`"
MC_DAEMON_PORT=${MC_DAEMON_PORT:-"25465"}
MC_EXTERNAL_IP=${MC_EXTERNAL_IP:-""}
MC_DAEMON_PW=${MC_DAEMON_PW:-"ChangeMe"}
MC_ALLOWED_IPS=${MC_ALLOWED_IPS:-"127.0.0.1"}
MC_DAEMON_ID=${MC_DAEMON_ID:-"1"}
MC_DB_ENGINE=${MC_DB_ENGINE:-"sqlite"}
MC_DB_HOST=${MC_DB_HOST:-"db"}
MC_DB_USER=${MC_DB_USER:-"mc_user"}
MC_DB_PASSWORD=${MC_DB_PASSWORD:-"ChangeMe"}
MC_DB_CHARSET=${MC_DB_CHARSET:-"utf8"}
MC_DB_NAME_WEB=${MC_DB_NAME_WEB:-"multicraft_panel"}
MC_DB_NAME=${MC_DB_NAME:-"multicraft_daemon"}
MC_WEB_DATA="${MC_DIR}/data/${MC_DB_NAME_WEB}.db"
MC_DAEMON_DATA="${MC_DIR}/data/${MC_DB_NAME}.db"

MC_FTP_SERVER=${MC_FTP_SERVER:-"y"}
MC_FTP_IP=${MC_FTP_IP:-"0.0.0.0"}
MC_FTP_NATIP=${MC_FTP_NATIP:-""}
MC_FTP_PASS_PORT=${MC_FTP_PASS_PORT:-"6000-6005"}
MC_FTP_PORT=${MC_FTP_PORT:-"21"}
MC_PLUGINS=${MC_PLUGINS:-"y"}

MC_MEM=${MC_MEM:-"2048"}
MC_JAVA="${JAVA_HOME}/bin/java"
MC_JAR="minecraft_server.jar"

MC_USERADD="/usr/sbin/useradd"
MC_GROUPADD="/usr/sbin/groupadd"
MC_USERDEL="/usr/sbin/userdel"
MC_GROUPDEL="/usr/sbin/groupdel"

MC_ZIP="/usr/bin/zip"
MC_UNZIP="/usr/bin/unzip"


MC_LOCAL=${MC_LOCAL:-"y"}
MC_MULTIUSER=${MC_MULTIUSER:-"n"}
MC_SERVER_NAME=${MC_SERVER_NAME:-""}

CFG="${MC_DIR}/configs/multicraft.conf"
CFG_DIST="${CFG}.dist"
OPT_CFG="${MC_OPT_DIR}/multicraft.conf"
OPT_CFG_DIST="${OPT_CFG}.dist"
WEB_CFG="${MC_DIR}/configs/panel.php"

NEWINSTALL=0

# Create function to replace Settings
function repl {
    LINE="$SETTING = `echo $1 | sed "s/['\\&,]/\\\\&/g"`"
}

# Create the multicraft folders that will be persistent
mkdir -p ${MC_DIR}/jar
mkdir -p ${MC_DIR}/data
mkdir -p ${MC_DIR}/servers
mkdir -p ${MC_DIR}/templates
mkdir -p ${MC_DIR}/configs
mkdir -p ${MC_DIR}/html
mkdir -p ${MC_DIR}/scripts

# Change multicraft owner to ${MC_USER}
chown -R ${MC_USER} ${MC_DIR}

MC_DIR_ALL="${MC_DIR}/jar ${MC_DIR}/data ${MC_DIR}/templates ${MC_DIR}/configs ${MC_DIR}/html ${MC_DIR}/scripts "
#MC_DIR_OPT_ALL="${MC_OPT_DIR}/jar ${MC_OPT_DIR}/data ${MC_OPT_DIR}/templates ${MC_OPT_DIR}/scripts "
MC_DIR_SERVERS=${MC_DIR}/servers
#MC_DIR_OPT_SERVERS=${MC_OPT_DIR}/servers

#######

## Multicraft Daemon Config

#######
if [ ! -f ${CFG} ]; then
    NEWINSTALL=1


    echo "[$(date +%Y-%m-%d_%T)] - No multicraft daemon config file detected, creating new one from multicraft.conf.dist"
    cp -f ${OPT_CFG_DIST} ${CFG_DIST}
    # cp -f ${CFG_DIST} ${CFG}
    > "${CFG}"
    ### Generate config

    SECTION=""
    #cat "${OPT_CFG_DIST}" | while IFS="" read -r LINE
    cat "${CFG_DIST}" | while IFS="" read -r LINE
    do
        if [ "`echo $LINE | grep "^ *\[\w\+\] *$"`" ]; then
            SECTION="$LINE"
            SETTING=""
        else
            SETTING="`echo $LINE | sed -n 's/^ *\#\? *\([^ ]\+\) *=.*/\1/p'`"
        fi
        case "$SECTION" in
        "[multicraft]")
            case "$SETTING" in
            "user")             repl "${MC_USER}" ;;
            "ip")               if [ "$MC_LOCAL" != "y" ]; then repl "$MC_DAEMON_IP";           fi ;;
            "port")             if [ "$MC_LOCAL" != "y" ]; then repl "$MC_DAEMON_PORT";         fi ;;
            "externalIp")       if [ "$MC_LOCAL" != "y" ]; then repl "$MC_EXTERNAL_IP";         fi ;;
            "allowedIps")       repl "$MC_ALLOWED_IPS" ;;
            "password")         repl "$MC_DAEMON_PW" ;;
            "id")               repl "$MC_DAEMON_ID" ;;
            "database")         if [ "$MC_DB_ENGINE" = "mysql" ]; then
                                    repl "mysql:host=$MC_DB_HOST;dbname=$MC_DB_NAME"
                                else
                                    repl "sqlite:$MC_DAEMON_DATA"
                                fi ;;
            "dbUser")           if [ "$MC_DB_ENGINE" = "mysql" ]; then repl "$MC_DB_USER";      fi ;;
            "dbPassword")       if [ "$MC_DB_ENGINE" = "mysql" ]; then repl "$MC_DB_PASSWORD";  fi ;;
            "dbCharset")        if [ "$MC_DB_ENGINE" = "mysql" ]; then repl "$MC_DB_CHARSET";   fi ;;
            "webUser")          if [ "$MC_DB_ENGINE" = "mysql" ]; then 
                                    repl ""
                                else 
                                    repl "$MC_WEB_USER"
                                fi ;;
            "baseDir")          repl "${MC_OPT_DIR}" ;;
            "dataDir")          repl "${MC_DIR}/data" ;;
            "jarDir")           repl "${MC_DIR}/jar" ;;
            "serversDir")       repl "${MC_DIR}/servers" ;;
            "templatesDir")     repl "${MC_DIR}/templates" ;;
            "licenseFile")      repl "${MC_DIR}/configs/multicraft.key" ;;
            "allowSymlinks")    repl "true" ;;
            esac
        ;;
        "[ftp]")
            case "$SETTING" in
            "enabled")          if [ "$MC_FTP_SERVER" = "y" ]; then 
                                    repl "true"
                                else 
                                    repl "false"
                                fi ;;
            "ftpIp")            repl "$MC_FTP_IP" ;;
            "ftpPort")          repl "$MC_FTP_PORT" ;;
            "ftpPasvPorts")     repl "$MC_FTP_PASS_PORT" ;;
            "ftpNatIp")         if [ "$MC_FTP_NATIP" != "" ]; then repl "$MC_FTP_NATIP";        fi ;;
            "forbiddenFiles")   if [ "$MC_PLUGINS" = "n" ]; then repl "";                        fi ;;
            esac
        ;;
        "[minecraft]")
            case "$SETTING" in
            "memory")           repl "$MC_MEM" ;;
            "java")             repl "$MC_JAVA" ;;
            "jar")              repl "$MC_JAR" ;;
            esac
        ;;
        "[system]")
            case "$SETTING" in
            "unpackCmd")        repl "$MC_UNZIP"' -quo "{FILE}"' ;;
            "packCmd")          repl "$MC_ZIP"' -qr "{FILE}" .' ;;
            "infoCmd")          repl "uptime" ;;
            esac
            if [ "$MC_MULTIUSER" = "y" ]; then
                case "$SETTING" in
                "multiuser")    repl "true" ;;
                "addUser")      repl "$MC_USERADD"' -c "Multicraft Server {ID}" -d "{DIR}" -g "{GROUP}" -s /bin/false "{USER}"' ;;
                "addGroup")     repl "$MC_GROUPADD"' "{GROUP}"' ;;
                "delUser")      repl "$MC_USERDEL"' "{USER}"' ;;
                "delGroup")     repl "$MC_GROUPDEL"' "{GROUP}"' ;;
                esac
            else
                case "$SETTING" in
                "multiuser")    repl "false" ;;
                esac
            fi
        ;;
        "[backup]")
            case "$SETTING" in
            "command")  repl "$MC_ZIP"' -qr "{WORLD}-tmp.zip" . -i "{WORLD}"*/*' ;;
            "fullBackupCommand")  repl "$MC_ZIP"' -qr "{FILE}" .' ;;
            esac
        ;;
        esac
        echo "$LINE" >> "${CFG}"
    done
    rm ${CFG_DIST}

    # Copy config file to the Multicraft folder
    install -C -o nobody -g users ${CFG} ${OPT_CFG}

else
    echo "[$(date +%Y-%m-%d_%T)] - Multicraft daemon config file already exist! Installing config file."
    if [ -f ${OPT_CFG} ]; then
        rm ${OPT_CFG}
    fi
    install -C -o nobody -g users ${CFG} ${OPT_CFG}
fi

#######

## Multicraft Panel Config

#######
if [ "$MC_LOCAL" = "y" ]; then
    if [ "$NEWINSTALL" == 1 ]; then
        if [ ! -f ${WEB_CFG} ]; then
            echo "[$(date +%Y-%m-%d_%T)] - Copy Panel"
            cp -a $MC_OPT_DIR/panel/* ${MC_DIR}/html/
            cp -a $MC_OPT_DIR/panel/.ht* ${MC_DIR}/html/
            rm -rf "$MC_OPT_DIR/panel"

            chown -R ${MC_WEB_USER} ${MC_DIR}/html
            chmod -R o-rwx ${MC_DIR}/html

            echo "[$(date +%Y-%m-%d_%T)] - No Multicraft Panel config file found. Creating new one from config.php.dist";
            cp -f ${MC_DIR}/html/protected/config/config.php.dist ${WEB_CFG}

            if [ "$MC_DB_ENGINE" == "mysql" ]; then

                # Wait for DB
                #while [ !(mysql -u root -e 'use mydbname') ]
                while ! mysql -h "${MC_DB_HOST}" -u "${MC_DB_USER}" "-p${MC_DB_PASSWORD}" "${MC_DB_NAME}"  > /dev/null 2>&1
                do
                    echo "[$(date +%Y-%m-%d_%T)] - Waiting for mySQL DB check again in 10s"
                    sleep 10s
                done

                # Set Panel settings.
                sed -i -E "s|^\s*'panel_db'\s=>\s'(s\S*),|    'panel_db' => 'mysql:host=${MC_DB_HOST};dbname=${MC_DB_NAME_WEB}',\n    'panel_db_user' => '${MC_DB_USER}',\n    'panel_db_pass' => '${MC_DB_PASSWORD}',|" ${WEB_CFG}
                mysql -h "${MC_DB_HOST}" -u "${MC_DB_USER}" "-p${MC_DB_PASSWORD}" "${MC_DB_NAME_WEB}" < "${MC_DIR}/html/protected/data/panel/schema.mysql.sql" > /dev/null 2>&1

                # Set daemon settings
                sed -i -E "s|^\s*'daemon_db'\s=>\s'(s\S*),|    'daemon_db' => 'mysql:host=${MC_DB_HOST};dbname=${MC_DB_NAME}',\n    'daemon_db_user' => '${MC_DB_USER}',\n    'daemon_db_pass' => '${MC_DB_PASSWORD}',|" ${WEB_CFG}
                mysql -h "${MC_DB_HOST}" -u "${MC_DB_USER}" "-p${MC_DB_PASSWORD}" "${MC_DB_NAME}" < "${MC_DIR}/html/protected/data/daemon/schema.mysql.sql" > /dev/null 2>&1

            elif [ "$MC_DB_ENGINE" == "sqlite" ]; then
                # Set Panel settings.
                sed -i -E "s|^\s*'panel_db'\s=>\s'(\S*),|'panel_db' => 'sqlite:${MC_WEB_DATA}',|" ${WEB_CFG}
                sqlite3 ${MC_WEB_DATA} < ${MC_DIR}/html/protected/data/panel/schema.sqlite.sql

                # Set daemon settings
                sed -i -E "s|^\s*'daemon_db'\s=>\s'(\S*),|'daemon_db' => 'sqlite:${MC_DAEMON_DATA}',|" ${WEB_CFG}
                sqlite3 ${MC_DAEMON_DATA} < ${MC_DIR}/html/protected/data/daemon/schema.sqlite.sql
            else
                echo "[$(date +%Y-%m-%d_%T)] - No database engine specified. Please edit config files manually."
            fi

            sed -i -E "s|^\s*'daemon_password'\s=>\s'(\S*),|'daemon_password' => '${MC_DAEMON_PW}',|" ${WEB_CFG}

            #if [ "$MC_API" == "y" ]; then
            #    sed -i -E "s|^\s*'api_enabled'\s=>\s'(\S*),|'api_enabled' => true,|" ${WEB_CFG}
            #else
            #    sed -i -E "s|^\s*'api_enabled'\s=>\s'(\S*),|'api_enabled' => false,|" ${WEB_CFG}
            #fi

            #if [ -d /var/www/html/multicraft ]; then
            #    rm -r /var/www/html/multicraft
            #fi
            #ln -s ${MC_DIR}/html /var/www/html/multicraft
            #echo "[$(date +%Y-%m-%d_%T)] - Symlinked HTML/Panel"
            
            chown ${MC_USER} ${WEB_CFG}
            chmod 775 ${WEB_CFG}
            ln -s ${WEB_CFG} ${MC_DIR}/html/protected/config/config.php

        else
            echo "[$(date +%Y-%m-%d_%T)] - Copy and symlink Panel"
            cp -a $MC_OPT_DIR/panel/* ${MC_DIR}/html/
            cp -a $MC_OPT_DIR/panel/.ht* ${MC_DIR}/html/
            rm -rf "$MC_OPT_DIR/panel"

            chown -R ${MC_WEB_USER} ${MC_DIR}/html
            chmod -R o-rwx ${MC_DIR}/html

            if [ -d /var/www/html/multicraft ]; then
                rm -r /var/www/html/multicraft
            fi
            ln -s ${MC_DIR}/html /var/www/html/multicraft
            echo "[$(date +%Y-%m-%d_%T)] - Symlinked HTML"
            
            echo "[$(date +%Y-%m-%d_%T)] - Multicraft Panel config file found. Creating symbolic link"
            chown ${MC_USER} ${WEB_CFG}
            chmod 775 ${WEB_CFG}
            rm ${MC_DIR}/html/protected/config/config.php
            ln -s ${WEB_CFG} ${MC_DIR}/html/protected/config/config.php
        fi
    else
            chown -R ${MC_WEB_USER} ${MC_DIR}/html
            chmod -R o-rwx ${MC_DIR}/html
            if [ -d /var/www/html/multicraft ]; then
                rm -r /var/www/html/multicraft
            fi
            ln -s ${MC_DIR}/html /var/www/html/multicraft
            echo "[$(date +%Y-%m-%d_%T)] - Symlinked HTML"
            
            chown ${MC_USER} ${WEB_CFG}
            chmod 775 ${WEB_CFG}
            ln -s ${WEB_CFG} ${MC_DIR}/html/protected/config/config.php


    fi
else
    ### PHP frontend not on local machine
    echo
    echo "* NOTE: The web panel will not be installed on this machine. Please put the contents of the directory 'panel/' in a web accessible directory of the machine you want to run the web panel on and run the installer (install.php)."
    echo
fi

#######

## Apache Config

#######
if [ ! -f ${MC_DIR}/configs/apache.conf ]; then
    echo "[$(date +%Y-%m-%d_%T)] - No Apache config file found. Creating one from template."

    cp /etc/apache2/sites-enabled/000-default.conf ${MC_DIR}/configs/apache.conf
    rm /etc/apache2/sites-enabled/000-default.conf
    if [ "$MC_SERVER_NAME" != "" ]; then
        sed -i -E "s|^#ServerName\s=\s(\S*)|ServerName = ${MC_SERVER_NAME}|" ${MC_DIR}/configs/apache.conf
    fi
    ln -s ${MC_DIR}/configs/apache.conf /etc/apache2/sites-enabled/000-default.conf

else
    echo "[$(date +%Y-%m-%d_%T)] - Apache Config File found. Creating symbolic link"

    # If config file already exist in sites-enabled, delete it first.
    if [ -f /etc/apache2/sites-enabled/000-default.conf ]; then
        rm /etc/apache2/sites-enabled/000-default.conf
    fi

    ln -s ${MC_DIR}/configs/apache.conf /etc/apache2/sites-enabled/000-default.conf
fi


# Start apache2
service apache2 start

#######

## Symlink Folders and files

#######
# If new install
if [ "$NEWINSTALL" == 1 ]; then

    if [ "$MC_KEY" != "no" ]; then
        echo
        echo "[$(date +%Y-%m-%d_%T)] - Creating Licence File"
        echo "$MC_KEY" > "${MC_DIR}/configs/multicraft.key"
    fi

    cp -r ${MC_OPT_DIR}/jar/* ${MC_DIR}/jar
    chown -R ${MC_USER} ${MC_DIR}/jar

    cp -r ${MC_OPT_DIR}/scripts/* ${MC_DIR}/scripts
    chown -R ${MC_USER} ${MC_DIR}/scripts

    cp -r ${MC_OPT_DIR}/templates/* ${MC_DIR}/templates
    chown -R ${MC_USER} ${MC_DIR}/templates

    rm -r ${MC_OPT_DIR}/jar
    rm -r ${MC_OPT_DIR}/templates

    # Copy config file to the panel folder.
    chown ${MC_USER} ${WEB_CFG}
    chmod 777 ${WEB_CFG}
    ln -s ${WEB_CFG} /var/www/html/multicraft/protected/config/config.php

else
    # Remove install.php since it is not needed.
    rm /var/www/html/multicraft/install.php
fi

# Start and stop Multicraft to set permissions
${MC_OPT_DIR}/bin/multicraft set_permissions
sleep 1

# Remove data folder to replace with symlink
if [ -d ${MC_OPT_DIR}/data ]; then
    rm -r ${MC_OPT_DIR}/data
fi
ln -s ${MC_DIR}/data ${MC_OPT_DIR}/data
echo "[$(date +%Y-%m-%d_%T)] - Symlinked Data"

if [ -d ${MC_OPT_DIR}/jar ]; then
    rm -r ${MC_OPT_DIR}/jar
fi
ln -s ${MC_DIR}/jar ${MC_OPT_DIR}/jar
echo "[$(date +%Y-%m-%d_%T)] - Symlinked Jar"

if [ -d ${MC_OPT_DIR}/scripts ]; then
    rm -r ${MC_OPT_DIR}/scripts
fi
ln -s ${MC_DIR}/scripts ${MC_OPT_DIR}/scripts
echo "[$(date +%Y-%m-%d_%T)] - Symlinked Scripts"

if [ -d ${MC_OPT_DIR}/servers ]; then
    rm -r ${MC_OPT_DIR}/servers
fi
ln -s ${MC_DIR}/servers ${MC_OPT_DIR}/servers
echo "[$(date +%Y-%m-%d_%T)] - Symlinked Servers"

if [ -d ${MC_OPT_DIR}/templates ]; then
    rm -r ${MC_OPT_DIR}/templates
fi
ln -s ${MC_DIR}/templates ${MC_OPT_DIR}/templates
echo "[$(date +%Y-%m-%d_%T)] - Symlinked Templates"

echo "[$(date +%Y-%m-%d_%T)] - Set user and permissions to ${MC_OPT_DIR}"
chown -R ${MC_USER} "${MC_DIR_OPT_ALL} ${MC_DIR_OPT_SERVERS}"
chmod -R 775 ${MC_OPT_DIR}

if [ "$MC_MULTIUSER" = "y" ]; then
    echo -n "[$(date +%Y-%m-%d_%T)] - Set special Multiuser permissions... "
    chown 0:users ${MC_OPT_DIR}/bin/useragent
    chmod 4550 ${MC_OPT_DIR}/bin/useragent

    # Set data folder permissions
    echo "[$(date +%Y-%m-%d_%T)] - Set user and permissions for ${MC_DIR}"
    DIR=" `ls -lad ${MC_DIR_SERVERS}/*/ | tr -s ' ' | cut -d' ' -f9,3,4` "
    arr=($DIR)
    for ((i=0; i<${#arr[@]};i++)); do
        echo "[$(date +%Y-%m-%d_%T)] - Set user for ${arr[$i+2]}"
        chown -R ${arr[$i]}:${arr[$i+1]} ${arr[$i+2]}
        i=$i+2
    done
    chown -R ${MC_USER} ${MC_DIR_ALL}
    chmod -R 775 ${MC_DIR}
else
    # Set data folder permissions
    echo "[$(date +%Y-%m-%d_%T)] - Set user and permissions to ${MC_DIR}"
    chown -R ${MC_USER} "${MC_DIR_ALL} ${MC_DIR_SERVERS}"
    chmod -R 775 ${MC_DIR}

    #echo "[$(date +%Y-%m-%d_%T)] - Set user and permissions to ${MC_OPT_DIR}"
    #chown -R ${MC_USER} "${MC_DIR_OPT_ALL} ${MC_DIR_OPT_SERVERS}"
    #chmod -R 775 ${MC_OPT_DIR}
fi

# Start Multicraft
${MC_OPT_DIR}/bin/multicraft start
sleep 1

# Tail the multicraft logs
tail -f ${MC_OPT_DIR}/multicraft.log
