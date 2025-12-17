#!/bin/bash

rsync -a --progress --delete --exclude '.*' /home/osho/ /tmp/backup &> /tmp/rsync.log

condition=$(cat /tmp/rsync.log | wc -l)

if [[ $condition -gt 1 ]]; then
        echo $(date) "changes in the directory /home/osho" >> /var/log/backup_journal.log
else
        echo $(date) "nothing change" >> /var/log/backup_journal.log
fi
rm /tmp/rsync.log
