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

$logfile = Get-FileName -initalDirectory Get-Location
$count = 0
$row = 2
$items = New-Object System.Collections.Generic.List[System.Object]

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
                 1 {$timestamp = $line}
                 3 { $flow = $line
                     $flow = $flow -replace 'Flow', '' -replace 'l/s', ''
                     $flow = $flow.Trim()
                   }
                }
            }
            if ($count -eq 1) {
              $info = $line -split " "
              $dateinfo = $info[0] -split "-"
              $timeinfo = $info[1] -split ":"
              $starttime = Get-Date -Year $dateinfo[2] -Month $dateinfo[1] -Day $dateinfo[0] -Hour $timeinfo[0] -Minute $timeinfo[1] -Second $timeinfo[2]   
            }
            if ($count -eq 5) {
              $info = $line -split " "
              $dateinfo = $info[0] -split "-"
              $timeinfo = $info[1] -split ":"
              $endtime = Get-Date -Year $dateinfo[2] -Month $dateinfo[1] -Day $dateinfo[0] -Hour $timeinfo[0] -Minute $timeinfo[1] -Second $timeinfo[2]   
              $duration = New-TimeSpan -Start $starttime -End $endtime
            }
            $count += 1
        }
    }
}
Write-Host "Done!"

$savename = Save-FileName -initialDirectory Get-Location
"Timestamp`tFlow (l/s)`t`tTotal Flow (l):`t=SUM(B2-B$row)*" + [int]$duration.TotalSeconds | out-file -FilePath $savename
foreach ($item in $items) {
 Add-Content -Path $savename -Value ($item)
}