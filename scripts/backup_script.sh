#!/bin/bash

DATE=$(date +"%Y-%m-%d_%H%M%S")
CURRENT_DIR=/tmp/backup_dir
USER="osho"
ADDR="192.168.0.55"

ssh $USER@$ADDR "[ -d $CURRENT_DIR ] || mkdir -p $CURRENT_DIR"
#ssh $USER@$ADDR "if [ -d \"$CURRENT_DIR\" ]; then echo 'dir \"$CURRENT_DIR\" exist'; else mkdir -p \"$CURRENT_DIR\" && echo 'dir \"$CURRENT_DIR\" created'; fi"

# проверка количества директорий с копиями
i=$(ssh $USER@$ADDR "ls -1 "$CURRENT_DIR" | wc -l")

if [[ $i -eq 0 ]]; then

    # добавление резервной копии
    rsync -ac --exclude '.*' . $USER@$ADDR:$CURRENT_DIR/$DATE
    echo "создана директория $CURRENT_DIR/$DATE"
    exit 0
elif [[ $i -lt 5 ]]; then
    # проверка изменений
    DIR_LAST=$(ssh $USER@$ADDR "ls -1 \"$CURRENT_DIR\" | tail -n 1")
    CHANGES=$(rsync -ainc --delete --exclude '.*' --link-dest=$CURRENT_DIR/$DIR_LAST . $USER@$ADDR:$CURRENT_DIR/$DATE | grep -E '^<f|^cd|deleting')

    if [[ -z $CHANGES ]]; then
        echo "изменений нет"
    else
        # добавление инкрементной резервной копии
        echo "есть изменения"
        rsync -ac --exclude '.*' --link-dest=$CURRENT_DIR/$DIR_LAST . $USER@$ADDR:$CURRENT_DIR/$DATE
        echo "создана директория $CURRENT_DIR/$DATE"
    fi
else    
    DIR_LAST=$(ssh $USER@$ADDR "ls -1 \"$CURRENT_DIR\" | tail -n 1")
    CHANGES=$(rsync -ainc --delete --exclude '.*' --link-dest=$CURRENT_DIR/$DIR_LAST . $USER@$ADDR:$CURRENT_DIR/$DATE | grep -E '^<f|^cd|deleting')

    if [[ -z $CHANGES ]]; then
        echo "изменений нет"
    else
        # добавление инкрементной резервной копии
        echo "есть изменения"
        rsync -ac --exclude '.*' --link-dest=$CURRENT_DIR/$DIR_LAST . $USER@$ADDR:$CURRENT_DIR/$DATE
        echo "создана директория $CURRENT_DIR/$DATE"

        i=$(ssh $USER@$ADDR "ls -1 "$CURRENT_DIR" | wc -l")

        # цикл удаления лишних копий
        while [[ $i -gt 5 ]]; do
            DIR_DEL=$(ssh $USER@$ADDR "ls -1 \"$CURRENT_DIR\" | head -n 1")

            ssh $USER@$ADDR "rm -r \"$CURRENT_DIR/$DIR_DEL\""
            echo "удалена директория $DIR_DEL"
            i=$(($i - 1))
        done
    fi
fi
