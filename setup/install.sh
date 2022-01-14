#!/bin/bash

umask ${MASK}

# check and set user and group
if [ $(getent passwd "$USERID") ]; then
    USERNAME_2=$(getent passwd "$USERID" | cut -d: -f1)
    echo "[$(date +%Y-%m-%d_%T)] - User ID ($USERID) bereits vorhanden! User: $USERNAME_2"
    USERNAME=$USERNAME_2
else
    if [ $(getent passwd "$USERNAME") ]; then
        USERID_2=$(getent passwd "$USERNAME" | cut -d: -f1)
        echo "[$(date +%Y-%m-%d_%T)] - User Name ($USERNAME) bereits vorhanden! User: $USERID_2"
        echo "[$(date +%Y-%m-%d_%T)] - Setze User ID $USERID für User $USERNAME!"
        usermod -u ${USERID} ${USERNAME}
    fi
fi

if [ $(getent group "$GROUPID") ]; then
    GROUPNAME=$(getent group "$GROUPID" | cut -d: -f1)
    #usermod -a -G ${GROUPNAME} ${USERNAME}
    usermod -g ${GROUPNAME} ${USERNAME}
    echo "[$(date +%Y-%m-%d_%T)] - Group ID ($GROUPID) bereits vorhanden! Gruppe: $GROUPNAME"
else
    GROUPNAME="$USERNAME"
    usermod -g ${GROUPID} ${USERNAME}
fi
usermod -a -G www-data $USERNAME

if [ !${USERNAME}="nobody" ]; then
    useradd ${USERNAME} -s /bin/bash && 
    usermod -d /home ${USERNAME} && 
    usermod -a -G users www-data && 
    chown -R ${USERNAME}:users /home
fi

# Safe username and groupname for aditional scripts
mkdir -p /opt/multicraft/
echo "$USERNAME" > "/opt/multicraft/USERNAME"
echo "$GROUPNAME" > "/opt/multicraft/GROUPNAME"

# Download and unzip aktual multicraft
wget http://www.multicraft.org/download/linux64 -O /tmp/multicraft.tar.gz && \
    tar xvzf /tmp/multicraft.tar.gz -C /tmp && \
    rm /tmp/multicraft.tar.gz

# Enable Apache Rewrite
a2enmod rewrite

# Update website owner to www-data:www-data
chown -R ${USERNAME}:www-data /var/www/html/

# Remove default index.html file in the html folder.
rm /var/www/html/index.html

# Copy multicraft binaries to /opt
cp -rf /tmp/multicraft /opt/

# Remove the temporary multicraft folder
rm -rf /tmp/multicraft

# Change the multicraft binary to ${UID}:${GID}
#chown -R nobody:users /opt/multicraft
chown -R ${USERNAME}:${GROUPNAME} /opt/multicraft