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
$SLA1 = 'NAME OF SLA'

#Connect to Rubrik
connect-rubrik -server $rbk

#Assign SLA to SQL DB
get-rubrikdatabase -name $db | protect-rubrikdatabase -SLA $SLA1 -Confirm:$false

#On Demand SQL DB Backup
Get-RubrikDatabase -name $db | New-RubrikSnapshot -inherit -Confirm:$false