#!/bin/bash
now=$(date +"%Y_%m_%d")

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

logfilename="$logsdir/post_torrent_added.log"

gzip -f "$logfilename"  ## compress the log file
mv "$logfilename.gz" "$logfilename-$now.gz"  ## move/rename the compressed log file to a daily file
find "$logsdir" -mtime +61 -type f -delete  ## remove log files that are over 60 days old
