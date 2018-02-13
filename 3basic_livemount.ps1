# Rubrik PowerShell 101
# 1/22/2018
# Written By - Michael Oglesby
# Version
       #Rubrik 4.0.0.117

#Import Rubrik
import-module Rubrik

#Variables
$rbk='IP OR FQDN OF RUBRIK NODE'
$db1='NAME OF TEST SQL DB'

#Connect to Rubrik
connect-rubrik -server $rbk

#DB Mount Variable
$db=Get-RubrikDatabase -name $db1

#Live Mount
New-RubrikDatabaseMount -id $db.id -targetInstanceId $db.instanceId -mountedDatabaseName 'RBK_LIVE_MOUNT' -recoveryDateTime (Get-date (Get-RubrikDatabase -id $db.id).latestRecoveryPoint) -Confirm:$false

#Remove all DB Mounts for Source Database
Get-RubrikDatabaseMount -source_database_name $db1 | Remove-RubrikDatabaseMount