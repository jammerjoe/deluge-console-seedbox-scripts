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
export TZ="America/Chicago"


temp_filename="$tempdir/fulltorrentinfoseedingchecker.txt"
/usr/local/bin/deluge-console "connect 127.0.0.1:$delugeport $delugeid $delugepasswd; info" > $temp_filename ## Get a list of all torrents

temp_activeseeding="$tempdir/activeseedinglist.txt"

## List of actively seeding torrents right now
grep -A 1 ID $temp_filename | tr -d '\n' | sed 's/--/ \n/g' | sed 's/State:/ State:/g'  | grep -v '0.0' | grep Up | awk '{print $2}' > $temp_activeseeding

now=$(date +"%Y_%m_%d")

seededdailylog="$seedingdir/seeded-$now.out" ## this uses the current date in the filename to keep the list of seeding torrents by date
seededlog="$tempdir/seeded-temp" ## need a tempfile to shuffle the list around to append and sort and remove duplicates
cat $temp_activeseeding >> $seededdailylog  ## Append latest seeding torrents to the running daily log
cat $seededdailylog | sort | uniq >> $seededlog  ## remove dups from the running daily log to a temp file
mv $seededlog $seededdailylog ## make that de-duped temp file the new running daily log
