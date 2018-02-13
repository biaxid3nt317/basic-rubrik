param($ServerName = 'se-moglesby-win'
      ,$RubrikServer = '172.17.28.18'
      ,$RubrikCredential = (Get-Credential -Message 'Please enter your Rubrik credentials')
      )

#Parse ServerInstance 
if($ServerName -contains '\'){
    $HostName = ($ServerName -split '\')[0]
    $ServerName = ($ServerName -split '\')[1]
} else {
    $HostName = $ServerName
    $ServerName = 'MSSQLSERVER'
}

#Connect to the Rubrik Cluster
Connect-Rubrik -Server $RubrikServer -Credential $RubrikCredential

$dbs = Get-RubrikDatabase -Hostname $HostName -Instance $ServerName | Get-RubrikDatabase | Where-Object {$_.isrelic -ne 'TRUE' -and $_.isLiveMount -ne 'TRUE'}

$dbs = $dbs | Select-Object name,recoveryModel,effectiveSLADomainName,latestRecoveryPoint,id | 
    Sort-Object name | 
    Out-GridView -PassThru 
    
$requests = $dbs | ForEach-Object{New-RubrikSnapshot -id $_.id -Inherit -Confirm:$False}

return $requests