Title:    Multicraft Docker
Date:     2021.07.09
Author:   Mario Wicke
Keywords: Multicraft, Minecraft, unRaid, Docker
# Multicraft Docker
Dockerized Multicraft-Server

README ***WIP***

*english description below*

Multicraft ist eine Hosting Lösung mit integriertem Control Panel für Minecraft. ![Multicraft](https://github.com/MarioWi/multicraft-docker/blob/main/docs/Multicraft_logo.png) [Multicraft.org](www.multicraft.org) 

Als Basis Image für diesen Container wird Ubuntu 20.04 verwendet.
Dieser Multicraft Docker-Container ist mit (Java) Minecraft Minecraft >= V1.17 kompatibel, dazu wird Adopt openJDK 16.0.1+9 mit HotSpot JVM installiert. Der Pfad zu der Java dieser Version wird automatisch in die Config-Dateien eingetragen.

Für Versionen < 1.17 wurde parallel die LTS Version Adopt openJDK jdk-11.0.11+9 ebenfalls mit HotSpot JVM installiert.
Für diese Java-Version muss die entsprechende Server.jar.conf angepasst und der Pfad zur Java-Datei eingetragen werden.

In dem Dockerfile ist aktuell noch vorgesehen die Adopt openJDK Version 15.0.2+7 zu installieren. Da die Version 11.0.11+9 eine LTS Version ist, wurde dieser Bereich noch auskommentiert.

Obwohl dieser Container auch per Commandline gestartet werden kann, empfiehlt es sich doch docker-compose zu verwenden, und die benötigten Environment-Variablen zu übergeben.
Hierzu wurde im Unterordner *examples* eine *docker-compose.yml* ebgelegt, diese soll den Start erleichtern.



## Exposed Ports
- 80 Web-Oberfläche
- 21    
- 6000-6005 Passive FTP-Ports
- 25565 und 25565/udp Standard Port für Minecraft Server
- 19132-19133/udp Standard Ports für Bedrock Server

Da ich auf meinen Servern fast immer eine Map mit [dynMap](https://www.spigotmc.org/resources/dynmap.274/) sowie die Möglichkeit mit Bedrock clients auf den Java Servern zu joinen ([GeyserMC](https://geysermc.org/) in Verbindung mit [Floodgate](https://github.com/GeyserMC/Floodgate/)) nutze, habe ich hier Portranges für 11 Server (Java und Bedrock) sowie für dynMap reserviert bzw. freigegeben. Die entsprechenden Ports müssen zur finalen Verwendung in den Server-Einstellungen sowie den Konfigurationen für dynMap und GeyserMC eingerichtet werden.
- 15580-15590 
- 25580-25590
- 35580-35590

## Volumes
`/multicraft` Volume mit Unterordnern für 
- `jar` Beinhaltet die Server-Jar Dateien und zugehörige Conf Dateien. Hier kann zum Beispiel in den (zu dem entsprechenden Server zugehörigen) Conf-Datei die Java Version angepasst werden.
- `data` Hier sind die Dateien des Deamon abgelegt
- `servers` In diesem Ordner werden die im Panel erstellten Server abgelegt. Es wird, automatisch von Multicraft, für jeden Server ein Unterpordner erstellt und dort alle zu dem Server gehörenden Dateien abgelegt.
- `templates` In diesem Ordner können Templates für Server erstellt und abgelegt werden
- `configs` Hier sind die Konfigurations-Dateien für Multicraft, das Panel sowie die Apache.conf für die Web-Oberfläche abgelegt. 
- `html` In diesem Ordner befinden sich die Dateien für das Panel / die Web-Oberfläche.

## Verwendbare Environment-Variablen sind:
Die folgenden Environment-Varialen werden verwendet, um die unterschiedlichen Konfigurations-Dateien an die persönlichen Bedürfnisse anzupassen.
- `MC_DAEMON_ID` (`1`) ID unter welcher der Deamon installiert wird. Es können mit einem Panel (einer Web-Oberfläche) mehrere Deamon verwaltet werden. Diese werden mithilfe dieser ID unterschieden. 
- `MC_DAEMON_PW` (`ChangeMe`) Passwort zur Authentifizierung am Daemon, wird ebenfalls für die Installation/Einrichtung der Web-Oberfläche benötigt
- `MC_DB_ENGINE` (`sqlite`)
- `MC_DB_NAME` (`multicraft_daemon`)
- `MC_KEY` (`no`)
- `MC_DB_HOST` (`db`)
- `MC_DB_USER` (`mc_user`)
- `MC_DB_PASSWORD` (`ChangeMe`)
- `MC_DB_CHARSET` (`utf8`)
- `MC_SERVER_ADMIN` (`webmaster@localhost`)
- `MC_SERVER_NAME` (``)
- `` (``)
- `MC_MULTIUSER` (`n`)
- `` (``)
- `` (``)
- `MC_FTP_SERVER` (`y`)
- `MC_FTP_IP` (``)
- `MC_FTP_PORT` (`21`)
- `` (``)
- `DEBUG` (`false`)

## Einschränkungen und zukünftige Erweiterungen
### Einschränkungen
In der aktuellen Verion sind noch folgende Probleme bzw. Einschränkungen vorhanden
- sqlite Datenbank
    - aktuell **ohne Funktion** hier kommt es bei der Installation des Panels häufig zu Zugriffsproblemen
- Multiuser
    - noch nicht vollständig implementiert, daher **ohne Funktion**
- Multicraft API
    - noch nicht implementiert, *vorerst nicht geplant*

### Pläne
- Wiki Einträge zur Einrichtung und Nutzung
- Wiki Einträge zur Nutzung mit unRaid
- Konfiguration (XML) für unRaid hinzufügen

# English description

