# Multicraft Docker
Dockerized Multicraft-Server


![Multicraft version](https://img.shields.io/badge/Multicraft-2.4.1--64-brightgreen)
![GitHub](https://img.shields.io/github/license/MarioWi/multicraft-docker)

<p align="center">
  <a href="https://github.com/MarioWi/multicraft-docker/blob/main/README.md">English</a> |
  <span>Deutsch</span>
</p>

# **ACHTUNG!**
Aufgrund des letzten Updates an dem Kontainer, sind die beiden Konfig-Dateien *apache.conf* und *multicraft.conf* nicht zu 100% kompatibel.
Wenn die alten Konbfigurationsdateien weiterhin verwendet werden, kommt es daher zu Fehlern und Multicraft sowie die Oberfläche starten nicht.
Weitere Informationen unter: [Update](https://github.com/MarioWi/multicraft-docker/blob/main/UPDATE.md)
---
---
---
## Beschreibung
Inspieriert wurde dieser Docker-Kontainer von den unter Credits genannten Repos. Jedoch konnte keines meine Bedürfnisse vollumfänglich erfüllen. Da ich mehrere Minecraft-Server laufen lassen wollte, benötigte ich mindestens 10 frei gegebene Ports. Für dynMap und GeyserMC werden jeweils auch ein zusätzlicher Port je Server benötigt, also nochmal 20 Ports mehr. Der Container sollte auch unter unRaid laufen können. Daher habe ich mich entschieden den Container auf Basis der oben genannten Repos an meine Bedürfnisse anzupassen.

### Multicraft
![Multicraft](https://raw.githubusercontent.com/MarioWi/multicraft-docker/main/docs/Multicraft_logo.png) [Multicraft.org](www.multicraft.org) 

Multicraft ist eine Hosting Lösung mit integriertem Control Panel für Minecraft. 


Mehr Informationen zur Benutzung und den Konfigurations-Möglichkeiten im [Wiki](../../wiki)

---



### Aufbau des Containers
Als Basis Image für diesen Container wird Ubuntu 20.04 verwendet.
Dieser Multicraft Docker-Container ist mit (Java) Minecraft Minecraft >= V1.17 kompatibel, dazu wird Adoptium openJDK 17.0.1+12 mit HotSpot JVM installiert. Der Pfad zu der Java dieser Version wird automatisch in die Config-Dateien eingetragen.

Für diese Java-Version muss die entsprechende Server.jar.conf angepasst und der Pfad zur Java-Datei eingetragen werden.
Dazu muss in der entsprechenden jar.conf zum Beispiel *spigot-1.16.5.jar.conf* die Variable *{JAVA}* durch */opt/java/openjdk-11/bin/java* ersetzt werden.
ALternativ kann das Install-Script von [MarioWi/MultiCraft-JAR-Conf])https://raw.githubusercontent.com/MarioWi/MultiCraft-JAR-Conf zur installation der gewünschten *.jar.conf Dateien genutzt werden.

In dem Dockerfile ist aktuell noch vorgesehen die Adopt openJDK Version 16.0.2+7 zu installieren. Da die Version 11.0.13+8 eine LTS Version ist, wurde dieser Bereich jedoch auskommentiert.

Obwohl dieser Container auch per Commandline gestartet werden kann, empfiehlt es sich doch docker-compose zu verwenden, und die benötigten Environment-Variablen zu übergeben.
Hierzu wurde im Unterordner *examples* eine *docker-compose.yml* ebgelegt, diese soll den Start erleichtern.

Da ich auf meinen Servern fast immer eine Map mit [dynMap](https://www.spigotmc.org/resources/dynmap.274/) sowie die Möglichkeit mit Bedrock clients auf den Java Servern zu joinen ([GeyserMC](https://geysermc.org/) in Verbindung mit [Floodgate](https://github.com/GeyserMC/Floodgate/)) nutze, habe ich hier jeweils Portranges für 11 Server (Java und Bedrock) sowie für dynMap reserviert bzw. freigegeben. Die entsprechenden Ports müssen zur finalen Verwendung in den Server-Einstellungen sowie den Konfigurationen für dynMap und GeyserMC eingerichtet werden.

Wie GeyserMC, Floodgate oder dynMap eingerichtet werden wie auch die Verwendung von Multicraft, kann auf den Entsprechenden verlinkten Seiten nachgelesen werden. 


### unRaid
Der Container wurde so angelegt, dass er auch unter unRaid ohne Schwierigkeiten lauffähig ist. So wurde die *umask* auf *000* gesetzt und es wurde darauf geachtet, dass als Benutzer *nobody* in der Gruppe *users* verwendet wird.


Dieser Container wurde so entworfen, dass er nach dem ersten Start direkt einsatzbereit ist. Dazu wid auch das Panel anhand der übergebenen Variablen konfiguriert. Ebenso werden die Tabellen in der konfigurierten Datenbank initialisiert. Dafür wartet der Kontainer auf die Bereitschaft der  Datenbank. So entfällt auch die sonst übliche Panel Installation während des ersten starts.

***`Bitte ändern Sie die standardzugangsdaten nach dem ersten Login. Der Sicherheit wegen!`***

---

### Exposed Ports
- 80 Web-Oberfläche
- 21 FTP    
- 6000-6005 Passive FTP-Ports
- 25565 und 25565/udp Standard Port für Minecraft Server
- 19132-19133/udp Standard Ports für Bedrock Server
- 15580-15590/udp vorgesehen für GyserMC (Bedrock-Clients)
- 25580-25590 vorgesehen für Server (normal Java-Clients)
- 35580-35590 vorgesehen für dynMap

## Volume
`/multicraft` Volume mit Unterordnern für 
- `jar` Beinhaltet die Server-Jar Dateien und zugehörige Conf Dateien. Hier kann zum Beispiel in den (zu dem entsprechenden Server zugehörigen) Conf-Datei die Java Version angepasst werden.
- `data` Hier sind die Dateien des Deamon abgelegt
- `servers` In diesem Ordner werden die im Panel erstellten Server abgelegt. Es wird, automatisch von Multicraft, für jeden Server ein Unterpordner erstellt und dort alle zu dem Server gehörenden Dateien abgelegt.
- `templates` In diesem Ordner können Templates für Server erstellt und abgelegt werden
- `configs` Hier sind die Konfigurations-Dateien für Multicraft, das Panel sowie die Apache.conf für die Web-Oberfläche abgelegt. In diesem Ordner wird auch die `multicraft.key` Datei abgelegt. In dieser ist der *`Lizenz-Key`* gespeichert.
- `html` In diesem Ordner befinden sich die Dateien für das Panel / die Web-Oberfläche.
- `scripts` In diesem Ordner können Scripte abgelegt werden, welche in Zusammenhang mit Multicraft genutzt werden sollen.


## Einschränkungen und zukünftige Erweiterungen
### Einschränkungen
- Multicraft API
    - noch nicht implementiert, *vorerst nicht geplant*


## Credits
Inspirierende Repos
* [AsakuraFuuko/multicraft](https://github.com/AsakuraFuuko/multicraft)
* [LZStealth/Docker-Multicraft](https://github.com/LZStealth/Docker-Multicraft)
* [Clutch152/multicraft-docker](https://github.com/Clutch152/multicraft-docker)
* [ich777/docker-minecraft-basic-server](https://github.com/ich777/docker-minecraft-basic-server)