#!/bin/bash

##
## This is the script that should be called using the Deluge Execute Plugin on the event Torrent Added.
##
## This script will check the tracker to make sure a good announce is received.  If not, then this script
## will pause and resume the torrent to re-trigger the announce.  This overrides the default logic in Deluge
## which is to wait 30 minutes for the next announce.
##
## The pause and resume cycle is repeated 8 or 9 times (unless you go below and change it) every 1/2 second.
## That means that within about 5 seconds if a good announce is not received from the tracker the torrent is
## removed from the Deluge client because theres a high likelyhood that you will miss the swarm, resulting in
## very poor ratio.
##
## See the example log file ~/scripts/logs/post_torrent_added.log to see the normal behavior of a busy tracker
## wtih a heavy swarm.
##
## I routinely get over 4.00 ratio using this method but your mileage may vary.  If you find you are not getting
## into the swarm fast enough, then dial back the retries from 8 to 3 or 4.  Yes, youll miss more torrents but
## the ones you get in on will be better ratio.
##


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

important_torrents="$scriptsdir/important-torrents.txt"  ## regex strings read from this file are used to override the ratio building logic and will not be auto removed if the tracker does not have a good announce fast enough
logfilename="$logsdir/post_torrent_added.log"  ## detailed output goes to this file.  This script can fire multiple times before the previous run is completed so sometimes the log trackerstatuss will be out of order. Thats expected.

## The Execute plugin calls the script with 3 parameters passed in
torrentid=$1  ## 1st is the ID (or hash) of the Torrent
torrentname=$2  ## 2nd is the filename of the torrent
torrentpath=$3  ## 3rd is the path where the torrent file will be stored on disk
torrenttitle=`echo $2 | tr . " " | sed -e 's/$/.torrent/'`  ## we derive the title of the torrent by removing the . (dots) from the torrent filename

## I like pretty output
echo "====================================================================================================" >> $logfilename
echo "$(date) -- Working on ..." >> $logfilename
echo "        -- Title: $torrenttitle" >> $logfilename
echo "        -- ID: $torrentid" >> $logfilename
echo "        -- File Name: $torrentname" >> $logfilename
echo "        -- Location: $torrentpath" >> $logfilename
echo "  -----------------------------------------------------------------------------------------------" >> $logfilename

# Here we are getting the details of the torrent using the torrent id and
#    then we are inspecting the result of the tracker announce.  If not
#    successful, meaning we get back and unregistered, sent, or C/connect status,
#    then pause and resume a few times until we can hopfully get a success.
#    This will get us into the swarm early.
# If, after looping thru the pause and resume cycle a few times (8), we still
#    dont get a success then just delete the torrent so we dont get stuck late
#    to the swarm and end up with a bad ratio
trackerstatus=$(/usr/local/bin/deluge-console "connect 127.0.0.1:$delugeport $delugeid $delugepasswd; info" $torrentid | grep "Tracker status")

echo "  $trackerstatus" >> $logfilename  ## put the actual tracker status result in the log file in case there are issues we need to debug

case "$trackerstatus" in
  *unregistered*|*Sent*|*onnect*)  ## if the tracker announce was not successful

    for (( c=1; c<=8; c++ ))  ## loop 8 times (pausing for .5 seconds) to perform a pause and resume cycle
    do
        echo "  Good announce eludes me.  Trying to pause and resume to retrigger.  Attempt: $c" >> $logfilename
        echo "  ... Pausing $torrenttitle for .5 seconds" >> $logfilename
        eval /usr/local/bin/deluge-console "connect 127.0.0.1:$delugeport $delugeid $delugepasswd\; pause '$torrentid'\; "
        sleep .5 
        eval /usr/local/bin/deluge-console "connect 127.0.0.1:$delugeport $delugeid $delugepasswd\; resume '$torrentid'\; "
        echo "  ... Resumed $torrenttitle" >> $logfilename
        
        #Check the tracker announce status again
        trackerstatus=$(/usr/local/bin/deluge-console "connect 127.0.0.1:$delugeport $delugeid $delugepasswd; info" $torrentid | grep "Tracker status")
        case "$trackerstatus" in
        *unregistered*|*Sent*|*onnect*)
          echo "" #the tracker announce reply is still not success so we will do nothing and fall through the loop to do another pasue and resume cycle
        ;;
        *)
          echo "  Bingo! I got $torrenttitle on retry $c" >> $logfilename
          c=100 # no need to continue checking for a good announce so break out of the for loop by setting c greater that 8 (from the for loop above)
        ;;
        esac
    done

    if [ "$c" -le 100 ]; then  ## if the counter c is less than 100 then that means a good announce was not found in the loop so remove the torrent from the client
        echo "** Error ** Could not get a good Announce quickly enough.  Ditching this torrent. $trackerstatus" >> $logfilename

        #Check for important torrent to download regardless of swarm entry point
        while read p; do  ## loop over the list of strings from the important.torrents file
          if [[ "$torrentname" =~ ^$p* ]]; then  ## If there is a partial (regex) match then leave torrent alone (dont remove)
            echo " ** BUT ** This is an important torrent and matches entry $p so I'm leaving it in client regardless of announce" >> $logfilename
            echo "====================================================================================================" >> $logfilename
            exit 1
          fi
        done <$important_torrents

        ## Okay, we are in the logic where the announce was not successful so we are going to remove the torrent and not take the ratio hit.
        eval /usr/local/bin/deluge-console "connect 127.0.0.1:$delugeport $delugeid $delugepasswd\; rm '$torrentid'\; "
        echo "====================================================================================================" >> $logfilename
        exit 1
    fi
  ;;

  *)
    echo "  Woo-hoo... Found $torrenttitle on the first try" >> $logfilename
  ;;
esac

echo "====================================================================================================" >> $logfilename

