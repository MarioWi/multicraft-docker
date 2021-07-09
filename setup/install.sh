#!/bin/bash
umask 000

# Download and unzip aktual multicraft
wget http://www.multicraft.org/download/linux64 -O /tmp/multicraft.tar.gz && \
    tar xvzf /tmp/multicraft.tar.gz -C /tmp && \
    rm /tmp/multicraft.tar.gz

# Enable Apache Rewrite
a2enmod rewrite

# Create the Panel WebFolder
mkdir -p /var/www/html/multicraft

# Copy the web files over to the html folder
cp -rf /tmp/multicraft/panel/* /var/www/html/multicraft

# Update website owner to www-data:www-data
chown -R www-data:www-data /var/www/html/

# Remove default index.html file in the html folder.
rm /var/www/html/index.html

# Remove the panel folder from the multicraft folder
rm -rf /tmp/multicraft/panel

# Copy multicraft binaries to /opt
cp -rf /tmp/multicraft /opt/

# Change the multicraft binary to nobody:users
chown -R nobody:users /opt/multicraft