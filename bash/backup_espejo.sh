#!/bin/bash
# -*- ENCODING: UTF-8 -*-
while [ 1 ]
do
    sshpass -p 'xxxxxxxxx' rsync -av --delete --partial --update --ignore-errors /home/admin-sonor admin-sonor@192.168.10.110:/home/admin-sonor/backup_admin-sonor
    if [ "$?" = "0" ] ; then
        echo "rsync completed normally"
        exit
    else
        echo "Rsync failure. Backing off and retrying..."
        sleep 180
    fi
done




