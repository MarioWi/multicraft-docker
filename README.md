# Multicraft Docker
Dockerized Multicraft-Server

![Multicraft version](https://img.shields.io/badge/Multicraft-2.4.1--64-brightgreen)
![GitHub](https://img.shields.io/github/license/MarioWi/multicraft-docker)

<p align="center">
  <span>English | </span>
  <a href="https://github.com/MarioWi/multicraft-docker/blob/main/LIESMICH.md">Deutsch</a>
</p>

## Description
This Docker container was inspired by the repos mentioned under credits. However, none of them could fully meet my needs. Since I wanted to run multiple Minecraft servers, I needed at least 10 free ports. An additional port per server is required for dynMap and GeyserMC, i.e. another 20 ports more. The container should also be able to run under unRaid. Therefore I decided to adapt the container to my needs based on the repos mentioned above.

### Multicraft
![Multicraft](https://raw.githubusercontent.com/MarioWi/multicraft-docker/main/docs/Multicraft_logo.png) [Multicraft.org](www.multicraft.org) 

The Complete Minecraft Server Hosting Solution and Control Panel. 


More Information about usage and configuration possibilities in the [Wiki](../../wiki)

---

### Structure of the container
Ubuntu 20.04 is used as the base image for this container.
This Multicraft Docker container is testet with diferent (Java) Minecraft Versions up to v1.18.1 , for this Adoptium openJDK 17.0.1+12 with HotSpot JVM is installed. The path to the Java version of this version is automatically used in the config files.

`Should also run with higher versions, as long as no new Java version is required.`
If so, feel free to open an issue.

For compatibility with older Minecraft versions, the following Java versions were also installed:

- For Minevraft versions 1.16.1 til 1.16.5 the LTS Version Adopt openJDK 11.0.13+8 was installed with HotSpot JVM.
- For Minevraft versions below 1.16.1 the LTS Version Adopt openJDK 8u312-b07 was installed with HotSpot JVM and for Vanila Minecraft with OpenJ9.




For these Minrcraft versions, the corresponding Server.jar.conf must be adapted and the path to the Java file must be entered.
To do this, in the corresponding jar.conf, for example *spigot-1.16.5.jar.conf*, the variable *{JAVA}* must be replaced by */opt/java/openjdk-11/bin/java*.

Alternatively, the install script from [MarioWi/MultiCraft-JAR-Conf](https://raw.githubusercontent.com/MarioWi/MultiCraft-JAR-Conf) can be used to install the required *.jar files.


Although this container can also be started via the command line, it is advisable to use docker-compose and transfer the required environment variables.
For this purpose, a *docker-compose.yml* was placed in the subfolder *examples* for creation and use with a mySQL container, this should make the start easier.
To use an integrated sqlite database instead of an additional database container, the example file *docker-compose_sqlite.xml* was stored in the *examples* folder.

Since I almost always have a map with [dynMap](https://www.spigotmc.org/resources/dynmap.274/) as well as the possibility to join Bedrock clients on the Java servers ([GeyserMC](https: //geysermc.org/) in connection with [Floodgate](https://github.com/GeyserMC/Floodgate/)), I have reserved port ranges for 11 servers (Java and Bedrock) and for dynMap . The corresponding ports must be set up for final use in the server settings and the configurations for dynMap and GeyserMC.

How GeyserMC, Floodgate or dynMap are set up as well as the use of Multicraft can be found on the corresponding linked pages.


### unRaid
The container was designed in such a way that it can also be run without difficulties under unRaid. So the * umask * was set to * 000 * and it was ensured that the user * nobody * in the group * users * is used.

---

### Exposed Ports
- 80 web interface
- 21 FTP
- 6000-6005 Passive FTP ports
- 25565 and 25565/udp standard port for Minecraft servers
- 19132-19133/udp standard ports for Bedrock servers
- 15580-15590/udp intended for GyserMC (Bedrock clients)
- 25580-25590 intended for servers (normal Java clients)
- 35580-35590 intended for dynMap

## Volume
`/ multicraft` volume with subfolders for
- `jar` Contains the server jar files and associated conf files. Here, for example, the Java version can be adapted in the Conf file (belonging to the corresponding server).
- `data` The files of the Deamon are stored here
- `servers` The servers created in the panel are stored in this folder. A subfolder is automatically created by Multicraft for each server and all files belonging to the server are stored there.
- `templates` Templates for servers can be created and stored in this folder
- `configs` This is where the configuration files for Multicraft, the panel and Apache.conf for the web interface are stored. The `multicraft.key` file is also stored in this folder. The *`license key`* is stored in this file.
- `html` This folder contains the files for the panel / web interface.
- `scripts` In this folder scripts can be stored which are to be used in connection with Multicraft. For example the installscript with it's config from [MarioWi/MultiCraft-JAR-Conf](https://raw.githubusercontent.com/MarioWi/MultiCraft-JAR-Conf)

## Limitations and future extensions
### Limitations
- Multicraft API
    - not yet implemented, *not planned for the time being*

## Credits
Inspirierende Repos
* [AsakuraFuuko/multicraft](https://github.com/AsakuraFuuko/multicraft)
* [LZStealth/Docker-Multicraft](https://github.com/LZStealth/Docker-Multicraft)
* [Clutch152/multicraft-docker](https://github.com/Clutch152/multicraft-docker)
* [ich777/docker-minecraft-basic-server](https://github.com/ich777/docker-minecraft-basic-server)