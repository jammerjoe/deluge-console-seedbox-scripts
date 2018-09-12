#!/bin/bash

#change these to meet your needs
delugeid="deluge userid" #found in your ~/.config/deluge/auth file
delugepasswd="deluge password" #found in your ~/.config/deluge/auth file
delugeport="52960"
basedir="/media/sdaj1/your_home_dir_where_scripts_is_located"
scriptsdir="$basedir/scripts"
logsdir="$scriptsdir/logs"
tempdir="$scriptsdir/temp"
seedingdir="$scriptsdir/seeding"
delugedir="$basedir/private/deluge"
delugedirdelete="$delugedir/delete"  ## This folder must exists so that auto deleted files can be moved into here before being deleted.  This is an important safety measure.
delugeautoadddownloadloc="$delugedir/tl"  ## this is the directory in the Set Download Location field from the deluge AutoAdd plugin.  See screen shots for details.
export TZ="America/Chicago"

tracker_name=$1  ## pass in the name of the tracker that you want to autoclean, this must be a partial match tracker name from the tracker status line (ie. torrentleech) not an abbreviation
days_old_in_tens=$2  ## for bash its easier to grep on char placement so this works for me.  its in 10 day increments (ie. 1 = 10 days or more, 2 = 20 days or more, 3 = 30 days or more, etc).  If you want to play with it look for the Seed time regex string on line 21 
temp_filename="$tempdir/fulltorrentinfo.txt"

cd "$seedingdir"

/usr/local/bin/deluge-console "connect 127.0.0.1:$delugeport $delugeid $delugepasswd; info" > $temp_filename ## Get a list of all torrents
list_to_delete=`grep -B 6 "Tracker status: $tracker_name" $temp_filename | grep -A 4 -B 1 ID | grep -B 5 "^Seed time: [$days_old_in_tens-9][0-9]" | grep -B 1 ID | sed 's/^ID: //g' | sed 's/^Name: //g' | grep -v '^--$' | sed 'N;s/\n/ /'`
list_of_recent_seeding_files=`find . -type f -mtime -10 -printf "%f\n" | grep seeded` ## active seeding log files from the last 10 days
list_of_recently_active=`cat $list_of_recent_seeding_files`  ## cat the contents of the recently seeded files into this var

if [[ ! -z "$list_to_delete" ]]  ## if there are files to delete
then

  while read -r linex; do  ## for each line in the in the list of torrents to delete
    id=`echo $linex | awk '{ print $NF }'` ## split the line and get the torrent id
    namex=`echo $linex  | sed s/'\w*$'// | awk '{$1=$1};1' | sed 's/[^a-zA-Z0-9._\-]/\\?/g'`  ## split the line and get the filename of the torrent
    tags=`grep "$id" $basedir/.config/deluge/label.conf | awk '{print $2}' | sed 's/[^a-zA-Z0-9]//g'`  ## look up the labels for the torrent id so we can override the auto delete based on the label

    case "$tags" in
      *autodl*|*delete*)  ## if the torrent had a label that was either *autodl* or *delete* then 
        if [[ $id =~ $list_of_recently_active ]]; then  ## if the torrent was in the list of recently active torrents then
          echo "  --> Popular torrent flagged for delete will not be deleted yet: $namex"  ## do not remove recently active torrent even though they are ready to delete
        else  ## if the match *autodl* or *delete* and they are not in the recently active torrent list then delete the torrent
          echo "  --> Deleting $id and removing files from $delugeautoadddownloadloc/$namex"
          mv "$delugeautoadddownloadloc/$namex" "$delugedirdelete"  ## move the files/directories to a location to be deleted later so we dont have to use the dredded rm -Rf in a script that may be blank (ie. deleting your whole directory from whereever this is running)  Setup a crontab job to delete the files from the delete directory
          eval /usr/local/bin/deluge-console "connect 127.0.0.1:$delugeport $delugeid $delugepasswd\; rm '$id'\; "  ## actually remove it from deluge
        fi
      ;;
      *) #do not delete torrent that has had the label changed to something besides *autodl* or *delete*
        echo "  --> NOT deleting because not labeled as autodl or delete: $namex"
      ;;
    esac
  done <<< "$list_to_delete"

fi
