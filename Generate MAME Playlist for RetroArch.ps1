
#
#              Script: Generate MAME Playlist for RetroArch
#              Author: singularity098
#                Date: 2016-09-26
#            Revision: v1.1
#   Last Revised Date: 2016-09-30
#

# Supply info as appropriate to your collection
$mameRomExtension         = '.zip'
$mameRomDirCurrentSystem  = 'Z:\ROMs\MAME [TorrentZipped-Split]\'
$mameRomDirTargetSystem   = '/home/singularity098/ROMs/MAME [1955 - 1998]/'
$mameRomDirTrimmedSet     = '.\MAME [1955 - 1998]\'
$databaseInputFile        = '.\MAME 0.178.dat'
$playlistOutputFile       = '.\MAME.lpl'

# Set minimum and maximum year for qualifying games
$minYear = "1955"
$maxYear = "1998"

# Adds backslash to end of dir if missing
if ($mameRomDirCurrentSystem.Substring($mameRomDirCurrentSystem.Length - 1) -ne "\") {
	$mameRomDirCurrentSystem = $mameRomDirCurrentSystem + "\"
}
if ($mameRomDirTrimmedSet.Substring($mameRomDirTrimmedSet.Length - 1) -ne "\") {
	$mameRomDirTrimmedSet = $mameRomDirTrimmedSet + "\"
}

clear-host

write-host ""
write-host "           =================================================="
write-host ""
write-host "            --=[ Generate MAME Playlist for RetroArch ]=-- "
write-host ""
write-host "           =================================================="
write-host ""

write-host "Currently configured variables (edit the script body if changes needed):"
write-host ""
write-host "   MAME ROM directory (current system):"$mameRomDirCurrentSystem
write-host "   MAME ROM directory  (target system):"$mameRomDirTargetSystem
write-host "   MAME ROM trimmed output directory  :"$mameRomDirTrimmedSet
write-host "                    MAME ROM extension:"$mameRomExtension
write-host "                         MAME DAT file:"$databaseInputFile
write-host "                    RetroArch playlist:"$playlistOutputFile
write-host "                      Minimum ROM year:"$minYear
write-host "                      Maximum ROM year:"$maxYear
write-host ""

function Ask-User ($question)
{
	$answer = read-host -prompt $question
	
	if (($answer -eq "y") -or ($answer -eq "Y")) {
		return $true
	}
	else {
		return $false
	}
}

if (!(test-path -literalpath $databaseInputFile)) {
	write-host ""
	write-host " -=ERROR=-  Terminating script because unable to locate input file: `"$databaseInputFile`""
	write-host ""
	sleep 1
	exit
}

if (ask-user("Exclude all clones?  y/n")) {
	$excludeClones = $true
}
else {
	$excludeClones = $false
}

if (ask-user("Check if ROM files actually exist before adding to playlist?  y/n")) {
	$checkIfRomsExist = $true
}
else {
	$checkIfRomsExist = $false
}

if (ask-user("Override directory with `"target system`" directory in the playlist?  y/n")) {
	$overrideWithTargetSystemDir = $true
}
else {
	$overrideWithTargetSystemDir = $false
}

if (ask-user("Copy all qualified ROM and BIOS files to trimmed directory ($mameRomDirTrimmedSet)?  y/n")) {
	$copyTrimmedRomset = $true
}
else {
	$copyTrimmedRomset = $false
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
	$fullRomPath = $mameRomDirCurrentSystem + $_.Name + $mameRomExtension
	
	if ($_.year -lt $minYear)                        {$processThisGame = $false}
	if ($_.year -gt $maxYear)                        {$processThisGame = $false}
	if (($_.cloneof) -and $excludeClones)            {$processThisGame = $false}
	if ($_.driver.status -eq "imperfect")            {$processThisGame = $false}
	if ($_.driver.status -eq "preliminary")          {$processThisGame = $false}
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
	
	# Check that ROM file actually exists if option was specified
	if ($checkIfRomsExist -and $processThisGame) {
		if (!(test-path -literalpath $fullRomPath)) {
			$processThisGame = $false
		}
	}
	
	# Check if the ROM file is a BIOS and add to biosList if so
	if (($_.isdevice -eq "yes" -or $_.runnable -eq "no") -and ((test-path -literalpath $fullRomPath) -or !($checkIfRomsExist))) {
		$biosList = $biosList + $_.Name + $mameRomExtension + "`n"
	}
	
	# Override the directory in the playlist if option was specified
	if ($overrideWithTargetSystemDir) {
		$fullRomPath = $mameRomDirTargetSystem + $_.Name + $mameRomExtension
	}
	
	# Add the game to playlist if it hasn't been disqualified
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

if ($copyTrimmedRomset) {
	
	if (!(test-path "$mameRomDirTrimmedSet")) {new-item "$mameRomDirTrimmedSet" -type directory | out-null}
	
	write-host ""
	write-host "Copying qualified roms to trimmed directory: $mameRomDirTrimmedSet"
	$gameList.split("`n") | foreach {if ($_ -ne "") {copy-item -literalpath $mameRomDirCurrentSystem$_ "$mameRomDirTrimmedSet" 2>&1 | out-null}}
	write-host "Copying any BIOS files to trimmed directory: $mameRomDirTrimmedSet"
	$biosList.split("`n") | foreach {if ($_ -ne "") {copy-item -literalpath $mameRomDirCurrentSystem$_ "$mameRomDirTrimmedSet" 2>&1 | out-null}}
	
}


remove-variable mameDat
remove-variable fullPlaylist
remove-variable biosList
remove-variable gameList

write-host ""
write-host "Finished."
write-host ""

