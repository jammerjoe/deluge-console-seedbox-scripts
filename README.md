# seedbox-scripts
Scripts to help automate the maintenance and management of seedboxes

## Synopsis

This repository contains some basic scripts to be used with Deluge, the Deluge CLI (deluge-console), and ruTorrent autodl-irssi to help automate the seedbox users' tasks.

That is to say that this is **not** an instruction guide at setting up a seedbox with all these tools.  There are plenty of resources on how to do that.  If you are not to the point where you are comfortable with the Linux, deluge-console, autodl-irssi, irc, etc; then this will likely be beyond your capabilites and it's not my intention to build your understanding at that level.  If these things make sense to you then you may be able to benefit from the scripts contained herein.

At a high level there is a script to run after the a torrent is added via the Execute plugin.  The 'post-torrent-added.sh' script checks the tracker for a good announce and uses a pause / resume sequence to re-trigger the announce until a good result is received.  This will help ensure that you join the swarm as quickly as possible, or ditch if a good announce isn't received in short order.  There is also an 'Important Torrent' override that will add any torrent regardless of announce result to be sure you get the special torrents you want so badly regardless of ratio.

There is a 2nd and 3rd script that automatically removes old torrents based on the time since the torrent was added.  This script can also use a list of recently seeded torrents so it doesn't remove popular torrents that are still building you ratio.  Finally, these scripts also have the ability to not auto delete based on labels on the torrent using the Deluge Label plugin.

## Disclaimer

These scripts work for me, they are not designed to work for everyone, but I did try to make them portable.  I'm sharing these scripts due to the repeated posts I come across asking for these features, and the long delay of Deluge 2.0 which supposedly has some of them.  The expectaion is that you will need to modify them to meet your needs.

These scripts are written in bash and I am by no means an expert.  They are written to the best of my ability but are far from as effecient or accurate as they could be.  I make no claims of accuracy or quality regarding the scripts and you should use them at your own risk.  

That said, I have been using them myself on my seedbox for years with little to no trouble (save a few bug fixes).  With these scripts I am able to run autodl-irssi on ruTorrent to grab announces from IRC and load them into my Deluge 1.3.15 client.  I have tuned the removal timing to the size of my seedbox HDD so I never have to worry hit-and-runs or going over my alotted HDD space.  It's nearly a hands-off operation.  I only logon every week or two to download the content I want from the seedbox to my local network.

## Installation

These scripts run on your Linux seedbox and are run via the Deluge 'Execute' plugin, on the Torrent Added event, and via crontab scheduler.  Full instructions can be found on the wiki.

## Contributors

As is the case with so many projects, I learned the details necesary to build these scripts by reading material of others over the course of a couple of years.  As such, there is simply no way to recoginze all the sources I used to built these scripts.  Hopefully a hearty **Thanks to the community!** will suffice.

## License

MIT License:

Copyright 2018 Joe <mr jammer joe <at> g mail> (you get the gist - no spaces)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
