#!/bin/bash

# usage : "bash /chemin/complet/script.sh"  et non "bash script.sh"
# sinon ${BASH_SOURCE[0]} utilisé par certaines librairies renverra "." au lieu du répertoire attendu 

BASEDIR=$(dirname "$0")

# lecture des variables d'environnement de l'utilisateur (.geosync.conf)
PARAMFILE="$HOME/.geosync.conf"
# on a besoin ici de : ocl_host login passwd
source "$PARAMFILE"

# vérifie que le chemin de l'arborescence à publier a bien été défini dans la conf
if [[ "${publishing_directory}" ]]; then 
    INPUT_COPY_PATH="${publishing_directory}"
else
    echo "WARNING aucun chemin d'arborescence à publier ('publishing_directory') défini dans .geosync.conf" >> $LOG_PATH/publish_error.log

    INPUT_COPY_PATH="$HOME/owncloudsync" # le chemin par défaut est conservé temporairement pour rétro-compatibilité # TODO ne pas prendre de valeur pas défaut et faire une vraie erreur
    echo "WARNING chemin d'arborescence par défaut : ${INPUT_COPY_PATH}"  >> $LOG_PATH/publish_error.log
fi

verbose=1 # commenter pour diminuer les logs

#echo if verbose=1
echo_ifverbose() {
  if [[ $verbose ]]; then echo "$@"; fi
}

# synchronise les fichiers du montage webdav pour être plus performant
# attention : si des photos sont présentes dans un répertoire Photos, elles pourraient être prises pour des rasters
# pour dépublier des couches, les déplacer dans le répertoire _unpublished
#cmd="rsync --quiet -avr --delete --exclude 'lost+found' --exclude __*/ --exclude _unpublished '$INPUT_OUTPUT_PATH/' '$INPUT_COPY_PATH/'"
cmd="owncloudcmd --silent --unsyncedfolders $HOME/folder-to-exclude.lst --user $login --password $passwd $INPUT_COPY_PATH $ocl_host"
echo_ifverbose $cmd
eval $cmd

