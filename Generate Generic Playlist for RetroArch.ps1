
#
#              Script: Generate Generic Playlist for RetroArch
#              Author: singularity098
#                Date: 2016-11-28
#            Revision: v1.0
#   Last Revised Date: 2016-11-28
#

# Supply info as appropriate to your collection
$romExtension         = ".zip"
$romSystemDir         = "Nintendo NES"
$playlistOutputFile   = "Nintendo - Nintendo Entertainment System.lpl"
$romDirCurrentSystem  = "Z:\ROMs\$romSystemDir\"
$romDirTargetSystem   = "/storage/roms/$romSystemDir/"

# Adds backslash to end of dir if missing (local dirs only)
if ($romDirCurrentSystem.Substring($romDirCurrentSystem.Length - 1) -ne "\") {
	$romDirCurrentSystem = $romDirCurrentSystem + "\"
}

clear-host

write-host ""
write-host "        ======================================================="
write-host ""
write-host "           --=[ Generate Generic Playlist for RetroArch ]=-- "
write-host ""
write-host "        ======================================================="
write-host ""

write-host "Currently configured variables (edit the script body if changes needed):"
write-host ""
write-host "   ROM directory (current system):"$romDirCurrentSystem
write-host "   ROM directory  (target system):"$romDirTargetSystem
write-host "                    ROM extension:"$romExtension
write-host "               RetroArch playlist:"$playlistOutputFile
write-host ""

function Ask-User ($question)
{
	$answer = read-host -prompt $question
	
	if (($answer.ToUpper() -eq "Y") -or ($answer.ToUpper() -eq "YES")) {
		return $true
	}
	else {
		return $false
	}
}

if (ask-user("Override directory with `"target system`" directory in the playlist?  y/n")) {
	$overrideWithTargetSystemDir = $true
}
else {
	$overrideWithTargetSystemDir = $false
}

write-host "Processing ROMs..."
write-host ""

$x = 0
$fullPlaylist = $null

get-childitem $romDirCurrentSystem*$romExtension | select -expand Name | foreach {
	
	$fullRomPath = $romDirCurrentSystem + $_
	
	# Override the directory in the playlist if option was specified
	if ($overrideWithTargetSystemDir) {
		$fullRomPath = $romDirTargetSystem + $_
	}
	
	$x = $x + 1
	write-host $x.ToString("0000") `| $_.PadLeft(12)
	
	$fullPlaylist = $fullPlaylist + $fullRomPath + "`n"
	$fullPlaylist = $fullPlaylist + $_.TrimEnd("$romExtension") + "`n"
	$fullPlaylist = $fullPlaylist + "DETECT" + "`n"
	$fullPlaylist = $fullPlaylist + "DETECT" + "`n"
	$fullPlaylist = $fullPlaylist + $x.ToString("00000000") + "`|crc`n"
	$fullPlaylist = $fullPlaylist + "$playlistOutputFile" + "`n"
}

if ($x -eq 0) {
	write-host " -=ERROR=-  No ROMs found"
	write-host ""
	sleep 1
	exit
}

write-host ""
write-host "Writing data to playlist file: `"$playlistOutputFile`""

$fullPlaylist | out-file $playlistOutputFile -encoding utf8

remove-variable fullPlaylist

write-host ""
write-host "Finished."
write-host ""

sleep 1
