#!/bin/bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

year=$(date +"%Y")
month=$(date +"%-m")
day=$(date +"%-d")

name=$(hostname)

ymd=$year$month$day

db_name=mysql

start_dump_mysql() {

	echo $"Back up Starting: "
	echo -n $"Databases dumping....: "
		mysqldump -uroot -ppassword "$db_name" > "$CURRENT_DIR"/backup_mysql/"$ymd"/"$db_name"-"$name"-"$ymd".sql
	echo $"Done !!!!!!!!!!!!!!!"

}

remove_backup_database() {

	 for i in `seq 2 5`; do
                year_old=$(date -d "$i days ago" +"%Y")
                month_old=$(date -d "$i days ago" +"%-m")
                day_old=$(date -d "$i days ago" +"%-d")
                ymd_old=$year_old$month_old$day_old
                rm -rf "$CURRENT_DIR"/backup_mysql/"$ymd_old"
        done			

}

packet_file_sqldump() {

	cd "$CURRENT_DIR"/backup_mysql/"$ymd"
	tar -czvf "$db_name"-"$name"-"$ymd".tar.gz "$db_name"-"$name"-"$ymd".sql		

}


copy_mysql_backup_to_192_168_1_100() {
	
	echo "Copying From 192.168.1.100 To 192.168.1.200 Wating............................!!!!!!!!!!!!!!"
		scp "$CURRENT_DIR"/backup_mysql/"$ymd"/"$db_name"-"$name"-"$ymd".tar.gz 192_168_1_100:/home/backup_mysql_192.168.1.200/	
	echo "Done !!!"

}

check_folder_start_script() {
	
	DIRECTORY="$CURRENT_DIR"/backup_mysql/"$ymd"

	if [ -d "$DIRECTORY" ];
                then
                        echo "Folder $DIRECTORY exists"
			start_dump_mysql
			sleep 2
			packet_file_sqldump
			
        elif [ ! -d "$DIRECTORY" ];
                then
                        echo "Folder $DIRECTORY doesnt exists"
                              mkdir -p "$CURRENT_DIR"/backup_mysql/"$ymd"
                        echo "Creating Foleder $DIRECTORY Done !!!"
				start_dump_mysql
                                sleep 2
				packet_file_sqldump
        fi
	copy_mysql_backup_to_192_168_1_100
	remove_backup_database
}

check_folder_start_script


