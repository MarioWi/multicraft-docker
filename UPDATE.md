![](https://github.com/MarioWi/multicraft-docker/blob/main/docs/DE.png?raw=true) 
Der einfachste Weg ist, vor dem Starten des neuen Kontainers die ebiden Konfiguartionsdateien zu sichern und zu löschen.
Bei jedem Kontainerstart wird überprüft, ob die Dateien vorhanden sind und bei Bedarf neu erstellt. Dafür werden übergebene Variablen oder Standardwerte verwendet.
Von daher sollte dieses Vorgehen in den allermeisten Fällen am schnellsetn zur Lösung führen.

![](https://github.com/MarioWi/multicraft-docker/blob/main/docs/GB.png?raw=true) 
*The easiest way is to save the configuration files and delete them before starting the new container.
Each time the container is started, it is checked whether the files are available and, if necessary, created. Transferred variables or standard values ​​are used for this.
Therefore, this procedure should lead to a solution as quickly as possible in the vast majority of cases.*

![](https://github.com/MarioWi/multicraft-docker/blob/main/docs/DE.png?raw=true) 
Wurden jedoch manuelle Änderungen an den Konfigurationsdateien vorgenommen, so müssen dei Dateien per Hand angepasst werden.
Da der Kontainer beim Start vorhandene Dateien verwendet und diese nicht ändert, ist dieser Schritt notwendig.

Sollten nur einzelne oder wenige Änderungen vorgenommen worden sein, so ist es am einfachsten, die Dateien wie oben beschrieben zu sichern und neu erstellen zu lassen. Anschließend können die durchgeführten Änderungen auch in den neuen Konfigurationsdateien eingegeben werden.

![](https://github.com/MarioWi/multicraft-docker/blob/main/docs/GB.png?raw=true) 
*However, if manual changes have been made to the configuration files, the files must be adapted by hand.
Since the container uses existing files when it starts and does not change them, this step is necessary.*

*If only a few or a few changes have been made, the easiest way is to save the files as described above and have them recreated. The changes made can then also be entered in the new configuration files.*

---
![](https://github.com/MarioWi/multicraft-docker/blob/main/docs/DE.png?raw=true) 
Sollte es notwendig sein, die alten Konfiguarionsdateien zu behalten und die neuen, notwendigen Änderungen per hand durchzuführen (zum Beispiel, wenn mehrere, größere Änderungen an den Konfigarionsdeien durchgeführt wurden), kommt im Anschluss eine Liset der entsprechenden Änderungen!

![](https://github.com/MarioWi/multicraft-docker/blob/main/docs/GB.png?raw=true) 
*If it is necessary to keep the old configuration files and to make the necessary changes by hand (for example, if several, larger changes have been made to the configuration files), a list of the corresponding changes will appear afterwards!*

Die Dateien befinden sich unter: | *The files are locatet under:*

data(docker-compose or manual start): /multicraft/configs/ | unRaid: appdata/multicraft/configs/


- apache.conf
    - DocumentRoot from */var/www/html/multicraft* to */multicraft/html* 
    - Directory from */var/www/html/multicraft* to */multicraft/html*
   

  von | *from*:
  ```
  ...
  DocumentRoot /var/www/html/multicraft

  # DO NOT REMOVE THIS NEXT LINE.
  #RedirectMatch ^/$ /multicraft/

  <Directory "/var/www/html/multicraft">
  ...
  ```
  nach | *to*:
  ```
  ...
  DocumentRoot /multicraft/html

  # DO NOT REMOVE THIS NEXT LINE.
  #RedirectMatch ^/$ /multicraft/

  <Directory "/multicraft/html">
  ...
  ```

- multicraft.conf

  von | *from*:
  ```
  ...
  dataDir = data
  ...
  jarDir = jar
  ...
  serversDir = servers
  ...
  templatesDir = templates
  ...
  licenseFile = multicraft.key
  ...
  unpackCmd = /usr/bin/unzip' -quo {FILE}' -quo "{FILE}"
  ...
  packCmd = /usr/bin/zip' -qr {FILE} .' -qr "{FILE}" .
  ...
  [docker]
  ## Enable Docker support
  ## default: false
  enabled = true
  ...
  ```

  nach | *to*:
  ```
  ...
  dataDir = /multicraft/data
  ...
  jarDir = /multicraft/jar
  ...
  serversDir = /multicraft/servers
  ...
  templatesDir = /multicraft/templates
  ...
  licenseFile = /multicraft/configs/multicraft.key
  ...
  unpackCmd = /usr/bin/unzip -quo "{FILE}"
  ...
  packCmd = /usr/bin/zip -qr "{FILE}" .
  ...
  [docker]
  ## Enable Docker support
  ## default: false
  enabled = false
  ...

  ```
  

  ---
  
  Wenn Multiuserfunktionen gewünsch sind, ist noch ein zusätzliche Einstellung notwendig.

  *If multi-user functions are required there must be changed one aditional Setting*

  von | *from*:
  ```
  ...
  #multiuser = true
  ...
  ```
  nach | *to*:
  ```
  ...
  multiuser = true
  ...
  ```

  ---

  Aus Sicherheitsgründen, sollte das Hochladen von gefährdenten Dateien blockiert werden, dazu gibt es folgende Einstellung.
  
  *For security reasons, the uploading of some executable files should be blocked. For this, the following setting is available.*
  
  von | *from*:
  ```
  ...
  #forbiddenFiles = 
  ...
  ```
  nach | *to*:
  ```
  ...
  forbiddenFiles = \.(jar|exe|bat|pif|sh)$
  ...
  ```


