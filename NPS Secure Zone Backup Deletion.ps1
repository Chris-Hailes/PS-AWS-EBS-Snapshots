<# 

.NOTES 
+---------------------------------------------------------------------------------------------+ 
| ORIGIN STORY                                                                                | 
+---------------------------------------------------------------------------------------------+ 
|   DATE        : 19/09/2021                                                                  |
|   AUTHOR      : Chris Hailes (cubesys)                                                      | 
|   VERSION     : 0.5                                                                         | 
+---------------------------------------------------------------------------------------------+ 

.SYNOPSIS 
 This PowerShell script is used to delete EBS Snapshots from AWS account

#> 

#Required Modules
Import-Module AWS.Tools.Common
Import-Module AWS.Tools.EC2

#Params
$Output = 'output.txt'
$AWSProfile = 'profile1'

#AWS Account Credential
Set-AWSCredential -ProfileName $AWSProfile

#Targeted Tag Values for Tag Key "Name"
$TagValues = @("")


Foreach ($Tag in $TagValues){
$snapshots = Get-EC2Snapshot | ? { $_.Tags.Key -eq "Name" -and $_.Tags.Value -eq $Tag } | ? { $_.StartTime -le ((get-date).AddMonths(-1)) } | Select SnapshotID,StartTime
If ($snapshots -eq $null){
    Write-Output "No Backups for $Tag" >> $Output
    } Else {
        Write-Output "Deleting $Tag backups" >> $Output
        Write-Output $snapshots >> $Output
        Get-EC2Snapshot | ? { $_.Tags.Key -eq "Name" -and $_.Tags.Value - $Tag } | ? { $_.StartTime -le ((get-date).AddMonths(-1)) } | Remove-EC2Snapshot -Confirm:$false
    }
}