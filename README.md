# Generate-MAME-Playlist-for-RetroArch

Grab the dat file appropriate to your own collection here:  http://www.progettosnaps.net/dats/

Change the variables in the beginning of the PowerShell script as appropriate (most importantly pointing to the dat file that you just downloaded, and supplying correct ROM path/file extension).  Be sure to review all of the variables here as some options will limit the number of ROMs that get added to the playlist.  The default values may not be to your liking.

Run the script and answer the questions that you are presented with, then drop the generated playlist (.lpl file) into your playlist directory in RetroArch and you should be able to browse your games using the full ROM titles.

Note the option to copy the ROM files out to a "trimmed" directory.  This is useful if you are loading the ROMs onto a device with limited storage, such as a Raspberry Pi, as your new ROM collection could be trimmed down by up to 90% if excluding clones and using the default date ranges.

Note also the option to override the directory with a different value in the generated playlist.  This is again useful if the playlist and ROMs will end up on another device, as the other device would almost certainly have a different directory structure.
