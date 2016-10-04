
#
#              Script: Generate MAME Playlist for RetroArch
#              Author: singularity098
#                Date: 2016-09-26
#            Revision: v1.1
#   Last Revised Date: 2016-09-30
#

# Supply info as appropriate to your collection
$mameRomExtension = '.zip'
$mameRomDir = 'Z:\ROMs\MAME [TorrentZipped-Split]\'
$databaseInputFile = '.\MAME 0.178.dat'
$playlistOutputFile = '.\MAME.lpl'

# Some optional criteria which results in more or less ROMs being added to the playlist
$minYear = "1955"
$maxYear = "1998"
$checkIfRomsExist = $true
$excludeClones = $true
$writePlaylist = $true
$writeBiosList = $false
$writeGameList = $false

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
$biosList = $null

$mameDat.ChildNodes.ChildNodes | foreach {
	
	$processThisGame = $true
	$fullRomPath = $mameRomDir + $_.Name + $mameRomExtension
	
	if ($_.year -lt $minYear)                        {$processThisGame = $false}
	if ($_.year -gt $maxYear)                        {$processThisGame = $false}
	if (($_.cloneof) -and $excludeClones)            {$processThisGame = $false}
	if ($_.driver.status -ne "Good")                 {$processThisGame = $false}
	if ($_.runnable -eq "no")                        {$processThisGame = $false}
	if ($_.isdevice -eq "yes")                       {$processThisGame = $false}
	
	if ($_.description -like "*Player's Edge Plus*") {$processThisGame = $false}
	if ($_.description -like "*PlayChoice*")         {$processThisGame = $false}
	if ($_.description -like "*Mahjong*")            {$processThisGame = $false}
	if ($_.description -like "*Apple*")              {$processThisGame = $false}
	if ($_.description -like "*Macintosh*")          {$processThisGame = $false}
	if ($_.description -like "*Quiz*")               {$processThisGame = $false}
	if ($_.description -like "*Trivia*")             {$processThisGame = $false}
	if ($_.description -like "*FS-*")                {$processThisGame = $false}
	if ($_.description -like "*HB-*")                {$processThisGame = $false}
	if ($_.description -like "*MSX*")                {$processThisGame = $false}
	
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
		
		$gameList = $gameList + $_.Name + $mameRomExtension + "`n"
		
	}
	
	if ($_.isdevice -eq "yes" -or $_.runnable -eq "no") {
		$biosList = $biosList + $_.Name + $mameRomExtension + "`n"
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

if ($writePlaylist) {
	
	write-host "Writing data to playlist file: `"$playlistOutputFile`""
	
	$fullPlaylist | out-file $playlistOutputFile -encoding utf8
	
}

if ($writeBiosList) {
	
	write-host "Writing list of BIOS files to: `".\_BIOSList.txt`""
	
	$biosList | out-file .\_BIOSList.txt -encoding utf8
	
}

if ($writeGameList) {
	
	write-host "Writing game ROM filenames to: `".\_GameList.txt`""
	
	$gameList | out-file .\_GameList.txt -encoding utf8
	
}

remove-variable fullPlaylist
remove-variable biosList
remove-variable gameList

write-host ""
write-host "Finished."
write-host ""
