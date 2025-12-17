#!/bin/bash

CURRENT_DIR=/tmp/backup_dir
USER="osho"
ADDR="192.168.0.55"

echo "какую резервную копию нужно восстановить?"

select chose in $(ssh $USER@$ADDR "ls -1 $CURRENT_DIR"); do
  echo "You chose $chose"
  rsync -az --delete $USER@$ADDR:$CURRENT_DIR/$chose .
  echo "копия $chose восстановлена $PWD/$chose"
break
done
