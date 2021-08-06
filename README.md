Title:    Multicraft Docker
Date:     2021.07.09
Author:   Mario Wicke
Keywords: Multicraft, Minecraft, unRaid, Docker
# Multicraft Docker
Dockerized Multicraft-Server

README ***WIP***

*english description below*

## Beschreibung
Inspieriert wurde dieser Docker-Container von den folgenden Repos. Jedoch konnte keines meine Bedürfnisse vollumfänglich erfüllen. Da ich mehrere Minecraft-Server laufen lassen wollte, benötigte ich mindestens 10 frei gegebene Ports. Für dynMap und GeyserMC werden jeweils auch ein zusätzlicher Port je Server benötigt, also nochmal 20 Ports mehr. Der Container sollte auch unter unRaid laufen können. Daher habe ich mich entschieden den Container auf Basis der oben genannten Repos an meine Bedürfnisse anzupassen.

### Multicraft
Multicraft ist eine Hosting Lösung mit integriertem Control Panel für Minecraft. ![Multicraft](https://raw.githubusercontent.com/MarioWi/multicraft-docker/main/docs/Multicraft_logo.png) [Multicraft.org](www.multicraft.org) 

### Aufbau des Containers
Als Basis Image für diesen Container wird Ubuntu 20.04 verwendet.
Dieser Multicraft Docker-Container ist mit (Java) Minecraft Minecraft >= V1.17 kompatibel, dazu wird Adopt openJDK 16.0.1+9 mit HotSpot JVM installiert. Der Pfad zu der Java dieser Version wird automatisch in die Config-Dateien eingetragen.

Für Versionen < 1.17 wurde parallel die LTS Version Adopt openJDK jdk-11.0.11+9 ebenfalls mit HotSpot JVM installiert.
Für diese Java-Version muss die entsprechende Server.jar.conf angepasst und der Pfad zur Java-Datei eingetragen werden.

In dem Dockerfile ist aktuell noch vorgesehen die Adopt openJDK Version 15.0.2+7 zu installieren. Da die Version 11.0.11+9 eine LTS Version ist, wurde dieser Bereich jedoch auskommentiert.

Obwohl dieser Container auch per Commandline gestartet werden kann, empfiehlt es sich doch docker-compose zu verwenden, und die benötigten Environment-Variablen zu übergeben.
Hierzu wurde im Unterordner *examples* eine *docker-compose.yml* ebgelegt, diese soll den Start erleichtern.

Da ich auf meinen Servern fast immer eine Map mit [dynMap](https://www.spigotmc.org/resources/dynmap.274/) sowie die Möglichkeit mit Bedrock clients auf den Java Servern zu joinen ([GeyserMC](https://geysermc.org/) in Verbindung mit [Floodgate](https://github.com/GeyserMC/Floodgate/)) nutze, habe ich hier jeweils Portranges für 11 Server (Java und Bedrock) sowie für dynMap reserviert bzw. freigegeben. Die entsprechenden Ports müssen zur finalen Verwendung in den Server-Einstellungen sowie den Konfigurationen für dynMap und GeyserMC eingerichtet werden.

Wie GeyserMC, Floodgate oder dynMap eingerichtet werden wie auch die Verwendung von Multicraft, kann auf den Entsprechenden verlinkten Seiten nachgelesen werden. 


### unRaid
Der Container wurde so angelegt, dass er auch unter unRaid ohne Schwierigkeiten lauffähig ist. So wurde die *umask* auf *000* gesetzt und als Benutzer darauf geachtet, das *nobody* in der Gruppe *users* verwendet wird.

## Verwendung
### per Comandline
    docker run -p 21:21 -p 80:80 -p 6000-6005:6000-6005 -p 15580-15590:15580-15590/udp -p 25580-25590:25580-25590 -p 35580-35590:35580-35590 -v /home/docker/multicraft:/multicraft -e MC_DAEMON_PW=changeMe -itd --name multicraft mariowi/multicraft
Dieses Beispiel startet einen Dockercontainer mit dem Namen multicraft


### per Docker-Compose
Für die nutzer mit Docker-Compose wurde eine Beispiel docker-compose.yml un dem Ordner examples bereitgestellt.

Diese kann nach clonen dieses Repositorys direkt gestartet werden über:

    docker-compose -f examples/docker-compose.yml -d

Es sollten vorher noch die Variablen und Passwörter überprüft nud ggf. angepasst werden.

Mögliche ENV-Variablen sind weiter unten beschrieben.

### als Container in unRaid
#### Schritt 1: Template Reposirory hinzufügen
In unRaid unter Docker das folgende Template Repository hinzufügen
    https://github/mariowi/multicraft-docker
***ScreenShot hinzufügen***


#### Schritt 2: Container hinzufügen
1. Auf **Add Container** klicken
2. Die default Werte überprüfen und ggf. anpassen, anschließend auf **Apply** klicken.
***ScreenShot hinzufügen***


#### Schritt 4: Warten, bis Image heruntergeladen
Das Image wird nun heruntergeladen un der Container erstellt.
Wenn das erfolgt ist, auf **Done** klicken.
***ScreenShot hinzufügen***


#### Fertig: Multicraft Panel einrichten
Der Container ist nun fertig heruntergeladen nud bereit für die Konfiguration von Multicraft über das Web-Panel.

Das Web-Panel ist zu erreichen über `http:IP_ADRESS:80`, oder uber die Auswahl von **WebUI** bei dem Container in unRaid.
***ScreenShot hinzufügen***



### Exposed Ports
- 80 Web-Oberfläche
- 21 FTP    
- 6000-6005 Passive FTP-Ports
- 25565 und 25565/udp Standard Port für Minecraft Server
- 19132-19133/udp Standard Ports für Bedrock Server
- 15580-15590/udp reserved for GyserMC (Bedrock-Clients)
- 25580-25590 reserved for Server (normal Java-Clients)
- 35580-35590 reserved for dynMap

## Volume
`/multicraft` Volume mit Unterordnern für 
- `jar` Beinhaltet die Server-Jar Dateien und zugehörige Conf Dateien. Hier kann zum Beispiel in den (zu dem entsprechenden Server zugehörigen) Conf-Datei die Java Version angepasst werden.
- `data` Hier sind die Dateien des Deamon abgelegt
- `servers` In diesem Ordner werden die im Panel erstellten Server abgelegt. Es wird, automatisch von Multicraft, für jeden Server ein Unterpordner erstellt und dort alle zu dem Server gehörenden Dateien abgelegt.
- `templates` In diesem Ordner können Templates für Server erstellt und abgelegt werden
- `configs` Hier sind die Konfigurations-Dateien für Multicraft, das Panel sowie die Apache.conf für die Web-Oberfläche abgelegt. In diesem Ordner wird auch die `multicraft.key` Datei abgelegt. In dieser ist der *`Lizenz-Key`* gespeichert.
- `html` In diesem Ordner befinden sich die Dateien für das Panel / die Web-Oberfläche.

## Verwendbare Environment-Variablen sind:
Die folgenden Environment-Varialen werden verwendet, um die unterschiedlichen Konfigurations-Dateien an die persönlichen Bedürfnisse anzupassen.
- `MC_DAEMON_ID` (`1`) ID unter welcher der Deamon installiert wird. Es können mit einem Panel (einer Web-Oberfläche) mehrere Deamon verwaltet werden. Diese werden mithilfe dieser ID unterschieden. 
- `MC_DAEMON_PW` (`ChangeMe`) Passwort zur Authentifizierung am Daemon, wird ebenfalls für die Installation/Einrichtung der Web-Oberfläche benötigt
- `MC_KEY` (`no`) Lizenz-Key, wenn vorhanden.
- `MC_DB_ENGINE` (`sqlite`) Datenbank-Engine, hier kann zwischen `sqlite` und `mysql` gewählt werden. Die sqlite Datenbank, als default, ist eine interne Datenbank in dem Container selbst. Als externe Datenbank `mysql` kann eine MySQL oder Maria-DB verwendet werden, hierbei müssen noch der DB-Host, DB-User und dessen Passwort angegeben werden
- `MC_DB_HOST` (`db`) Datenbank Hostname oder IP-Adresse
- `MC_DB_USER` (`mc_user`) Datenbanknutzer für Multicraft mit Zugriff auf die beiden Datenbanken.
- `MC_DB_PASSWORD` (`ChangeMe`) Passwort zur Verbindung zum Deamon. Wird bei der Einrichtung des Panel benötigt und dort eingetragen.
- `MC_DB_CHARSET` (`utf8`) Charset der Datenbank.
- `MC_DB_NAME` (`multicraft_daemon`) Datenbank-Name für die Deamon Datenbank. Diese kann hier angepasst werden, ansonsten wird als Standar multicraft_daemon verwendet.
- `MC_DB_NAME_WEB` (`multicraft_panel`) Datenbankname für die Web-Oberfläche, das Panel, kann wie die Daemon-Datenbank hier angepasste werden.
- `MC_SERVER_ADMIN` (`webmaster@localhost`) Email Adresse des Server-Admins.
- `MC_SERVER_NAME` (kein default) hier kann der Servername angegeben werden, unter welchem der Multicraft Server errecihbar ist, wie zum Beispiel `multicraft.example.com`. Dieser wird in der Apache-Config eingetragen.
- `MC_FTP_SERVER` (`y`) Aktivierung des internen FTP-Servers
- `MC_FTP_IP` (`0.0.0.0`) 
- `MC_FTP_PORT` (`21`)
- `MC_MULTIUSER` (`n`) Aktivierung des Multiuser-Betriebs von Multicraft (`n`,`y`) Ist zur Zeit nicht implementiert, Variable wird daher noch nicht beachtet.


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
***TBD***
