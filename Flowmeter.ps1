# UltraSonic Flowmeter Parser by bonafide@martica.org   https://tonyscc.ca

Function Get-FileName($initalDirectory) {
[System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
 $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
 $OpenFileDialog.Title = "Please select the putty log file."
 $OpenFileDialog.InitialDirectory = $initalDirectory
 $OpenFileDialog.Filter = "Log Files (*.log)| *.log"
 $OpenFileDialog.ShowDialog() | Out-Null
 $OpenFileDialog.FileName`
}

Function Save-FileName($initialDirectory) {
[System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
$savename = New-Object -TypeName System.Windows.Forms.SaveFileDialog
$savename.Title = "Save .csv file as:"
$savename.InitialDirectory = $initialDirectory
$savename.Filter = "CSV Files (*.csv)| *.csv"
$savename.FileName = "output.csv"
$savename.ShowDialog() | Out-Null
$savename.FileName
} 

Function Parse-Date($line) {
 $info = $line -split " "
 $dateinfo = $info[0] -split "-"
 $timeinfo = $info[1] -split ":"
 $year = 2000 + $dateinfo[0]
 Get-Date -Year $year -Month $dateinfo[1] -Day $dateinfo[2] -Hour $timeinfo[0] -Minute $timeinfo[1] -Second $timeinfo[2]   
}

$logfile = Get-FileName -initalDirectory Get-Location
$count = 0
$row = 2
$items = New-Object System.Collections.Generic.List[System.Object]

Write-Host "Flowmeter parser Version 0.2"
Write-Host -NoNewLine "Working"
foreach($line in Get-Content $logfile) {
    if ($line.length -gt 1) {
        if ($line.Substring(0,2) -ne "AT") {
            if ($count -gt 0) {
                switch ( $count % 4 ) {
                 0 { $items.Add("$timestamp`t$flow")
                     $row += 1
                     Write-Host -NoNewLine "."
                   }
                 1 {$timestamp = Parse-Date $line}
                 3 { $flow = $line
                     $flow = $flow -replace 'Flow', '' -replace 'l/s', ''
                     $flow = $flow.Trim()
                   }
                }
            }
            if ($count -eq 1) {
              $starttime = Parse-Date $line
            }
            if ($count -eq 5) {
              $endtime = Parse-Date $line
              $duration = New-TimeSpan -Start $starttime -End $endtime
            }
            $count += 1
        }
    }
}
Write-Host "Done!"

$savename = Save-FileName -initialDirectory Get-Location
"Timestamp`tFlow (l/s)`t`tTotal Flow (l):`t=SUM(B2:B$row)*" + [int]$duration.TotalSeconds | out-file -FilePath $savename
foreach ($item in $items) {
 Add-Content -Path $savename -Value ($item)
}
