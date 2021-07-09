# create databases
CREATE DATABASE IF NOT EXISTS `multicraft_panel`;
CREATE DATABASE IF NOT EXISTS `multicraft_daemon`;

# create user and grant rights
CREATE USER 'mc_user'@'%' IDENTIFIED BY 'multicraft1234!';
GRANT ALL PRIVILEGES ON multicraft_panel.* TO 'mc_user'@'%';
GRANT ALL PRIVILEGES ON multicraft_daemon.* TO 'mc_user'@'%';
FLUSH PRIVILEGES;
