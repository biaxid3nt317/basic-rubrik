# Rubrik PowerShell 101
# 02/02/2018
# Written By - Michael Oglesby
# Versions
       #Rubrik 4.0.0.117


#Import Rubrik and PowerCLI
import-module Rubrik

#Variables
$rbk='FQDN or IP of Rubrik'
$sqlhosts='FQDN1','FQDN2','FQDN3'

#Connect to Rubrik
connect-rubrik -server $rbk

#Add hosts definted in $sqlhosts to Rubrik
foreach ($sqlhost in $sqlhosts)
    {
         New-RubrikHost -Name $sqlhost -Confirm:$false
         write "Added host $sqlhost to Rubrik cluster $rbk"
         start-sleep -s 10
    } 
#Done