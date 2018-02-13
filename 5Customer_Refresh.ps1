import-module rubrik
[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO') | out-null

# -- Settings ---------------
$RBKHost = "192.168.11.183"
$PWDFile = "E:\PoSHScripts\DM_RBK_PWD.xml"
$SourceServer = "sql01.test.local"
$SourceInstance = "MSSQLSERVER"
$TargetServer = "sql01.test.local"
$TargetInstance = "MSSQLSERVER"
$SourceDatabase = "DM_RBKTest_01"
$TargetDatabase = "DM_RBKTest_01"

$TargetFiles = @()
$TargetFiles += @{logicalName=$TargetDatabase;exportPath='J:\MSSQL\Data\'}
$TargetFiles += @{logicalName="$($TargetDatabase)_LOG";exportPath='M:\MSSQL\Data\'}

$VerbosePreference = "Continue"
#$VerbosePreference = "SilentlyContinue"

# ----------------------------

Try{

    # Load credentials from file
    $cred = Import-Clixml -Path $PWDFile

    # Connect to rubrik
    Connect-Rubrik -Server $RBKHost -Credential $Cred | out-null


    # Get Source Database Object
    $db = Get-RubrikDatabase -Name $SourceDatabase -Hostname $SourceServer -Instance $SourceInstance | Get-RubrikDatabase

    # Get Target SQL Instance
    $TargetInstanceID = (Get-RubrikDatabase -Name 'model' -Hostname $TargetServer -Instance $TargetInstance).instanceId

    # Close all connections and drop traget database if it exists
    $srv = new-Object Microsoft.SqlServer.Management.Smo.Server($TargetServer)
    $sqldbs = $srv.Databases | select name
    foreach($sqldb in $sqldbs){
        if($sqldb.Name -eq $TargetDatabase){
            Write-Verbose "dropping connections and deleting database - $($sqldb.Name)"  
            $srv.KillDatabase($TargetDatabase)
        }
    }


    # Refresh databases on target server
    $dbt = $null
    do
    {
        New-RubrikHost -Name $TargetServer -Confirm:$false | Out-Null
        Start-Sleep -Seconds 10
        $dbt = Get-RubrikDatabase -Name $TargetDatabase -Hostname $TargetServer -Instance $TargetInstance
        

    }
    until ($dbt -eq $null)


    # Get target database object
    $dbt = Get-RubrikDatabase -Name $TargetDatabase -Hostname $TargetServer -Instance $TargetInstance

    # Check if database has inherited protection - unprotect and remove unmanaged object
    if($dbt){
        if($dbt.configuredSlaDomainId -eq 'INHERIT'){
            Protect-RubrikDatabase -id $dbt.id -DoNotProtect -confirm:$false
            Get-RubrikUnmanagedObject -Name $TargetDatabase -Status Unprotected | Remove-RubrikUnmanagedObject -Confirm:$false
        }
        else{
            Get-RubrikUnmanagedObject -Name $TargetDatabase -Status Unprotected | Remove-RubrikUnmanagedObject -Confirm:$false
        }
    }

    # Restore Target database
    Export-RubrikDatabase -Id $db.id -TargetInstanceId $TargetInstanceID -RecoveryDateTime $db.latestRecoveryPoint -TargetDatabaseName $TargetDatabase -TargetFilePaths $targetfiles -FinishRecovery -Confirm:$false | out-null


}
Catch
{
    [System.Environment]::Exit(1)
}