#!/bin/bash
#В процессе редактирования.
    if ! [ -d $HOME/.clamav_qarantine ]; then
      mkdir $HOME/.clamav_qarantine
    fi
date="$(date +"%H-%M-%S_%d-%m-%Y")"
echo "" > $HOME/.clamav_qarantine/clamavscan_log_file_$date.log
logfile="$HOME/.clamav_qarantine/clamavscan_log_file_$date.log"
#logfile_tmp="$HOME/.clamav_qarantine/clamavscan_log_tmp_file_$date.log"
total_files=0
version_clamav=$(echo -e "$(freshclam --version)")
# scanned=0 - На будущее =)
    for i in "$@"
#Считавется общее количество $@ на сканирование
    do
        if [[ -f "$i" ]]
#Если выбран(-ы) файл(-ы)
        then let "total_files += 1"  
        else
#Если выбрана(-ы) папка(-и)
            total_files="$[total_files+$(echo -e "$(find -H "$i" -type f)" | wc -l)]"
        fi
    done
`zenity --width 450 --info --title="Производится подготовка к сканированию( Примерно 10 секунд)." --text="Текущая версия Антивируса: \n$version_clamav" --timeout=10` &
clamscan  --detect-pua=yes --nocerts --recursive --scan-archive=yes --log=$logfile --exclude-dir="$HOME/.clamav_qarantine" "$@" | `zenity --progress --pulsate --width 640 --title="Сканирование началось" --text="Общее количество сканируемых файлов: $total_files" --auto-close --auto-kill`
    if grep FOUND < $logfile
        then
            paplay "$HOME/.local/share/nemo/actions/virus.wav"
            zenity --text-info --title="Обнаружены вирусы!" --width 640 --height 640 --filename=$logfile
        else
            zenity --text-info --title="Файлы проверены, вирусы не обнаружены" --width 640 --height 640 --filename=$logfile
    fi
rm $logfile
#rm $logfile_tmp
