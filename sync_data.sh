#!/bin/bash

# si semble non monté alors on monte le webdav
# attention : ne pas faire précéder ce code par le flock (ci-dessous) car sinon semble ne pas supprimer le verrou
if [[ ! -d ~/owncloud/_geosync ]]; then
  mount ~/owncloud
fi    

# utilisation d'un verrou pour éviter que le script main.sh ne se lance plusieurs fois en même temps
(
  # Wait for lock on /var/lock/.myscript.exclusivelock (fd 200) for 10 seconds
  flock -x -w 10 200 || exit 1
  
  # appel de main.sh
  bash /home/georchestra-ouvert/bin/main.sh 1>>/var/log/geosync/main.log 2>>/var/log/geosync/main_error.log

) 200>/var/lock/.geosync.exclusivelock


#crontab -e
#toutes les minutes de 8h à 20h, du lundi au vendredi, importe les couches partagées via owncloud dans le geoserver
#*/1 08-20 * * 1-5  cd /home/georchestra-ouvert && ./bin/geosync/cron 2>>./owncloud/_geosync/data/cron_error.log