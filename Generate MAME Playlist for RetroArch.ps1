
#
#              Script: Generate MAME Playlist for RetroArch
#              Author: singularity098
#                Date: 2016-09-26
#            Revision: v1.0
#   Last Revised Date: 2016-09-26
#

# Supply info as appropriate to your collection
$mameRomExtension = '.zip'
$mameRomDir = 'Z:\ROMs\MAME ROMs [TorrentZipped-Split]\'
$databaseInputFile = '.\MAME 177 Full.dat'
$playlistOutputFile = '.\MAME.lpl'

# Some optional criteria which results in more or less ROMs being added to the playlist
$minYear = "1977"
$maxYear = "1998"
$checkIfRomsExist = $true
$excludeClones = $true

if (!(test-path -literalpath $databaseInputFile)) {
	write-host ""
	write-host " -=ERROR=-  Terminating script because unable to locate input file: `"$databaseInputFile`""
	write-host ""
	sleep 1
	exit
}

write-host ""
write-host "Loading XML data from file: `"$databaseInputFile`""
write-host ""
$mameDat = [xml] (get-content $databaseInputFile -readcount 0)

write-host "Processing ROMs..."
write-host ""

$x = 0
$fullPlaylist = $null

$mameDat.ChildNodes.ChildNodes | foreach {
	
	$processThisGame = $true
	$fullRomPath = $mameRomDir + $_.Name + $mameRomExtension
	
	if (($_.cloneof) -and $excludeClones)            {$processThisGame = $false}
	if ($_.driver.status -ne "Good")                 {$processThisGame = $false}
	if ($_.description -like "*Player's Edge Plus*") {$processThisGame = $false}
	if ($_.year -lt $minYear)                        {$processThisGame = $false}
	if ($_.year -gt $maxYear)                        {$processThisGame = $false}
	
	if ($checkIfRomsExist -and $processThisGame) {
		if (!(test-path -literalpath $fullRomPath)) {
			$processThisGame = $false
		}
	}
	
	if ($processThisGame) {
	
		$x = $x + 1
		write-host $x.ToString("0000") `| $_.Name.PadLeft(8) `| $_.Description
		
		$fullPlaylist = $fullPlaylist + $fullRomPath + "`n"
		$fullPlaylist = $fullPlaylist + $_.Description + "`n"
		$fullPlaylist = $fullPlaylist + "DETECT" + "`n"
		$fullPlaylist = $fullPlaylist + "DETECT" + "`n"
		$fullPlaylist = $fullPlaylist + $x.ToString("00000000") + "`|crc`n"
		$fullPlaylist = $fullPlaylist + "MAME.lpl" + "`n"
		
	}
}

remove-variable mameDat

if ($x -eq 0) {
	write-host " -=ERROR=-  No ROMs found"
	write-host ""
	sleep 1
	exit
}

write-host ""
write-host "Writing data to playlist file: `"$playlistOutputFile`""
write-host ""

$fullPlaylist | out-file $playlistOutputFile -encoding utf8

remove-variable fullPlaylist

write-host "Finished."
write-host ""
