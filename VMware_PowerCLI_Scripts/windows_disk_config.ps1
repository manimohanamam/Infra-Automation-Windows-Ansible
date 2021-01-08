# Script to config Windows Disk on a VM, after the Disk is added on a VM on Vcenter
param(
[Parameter(Mandatory=$true)][String]$DriveLetter,
[Parameter(Mandatory=$true)][String]$DriveLabel,
[Parameter(Mandatory=$true)][single]$ReqDriveSize
)

$Disks = Get-Disk | Where partitionstyle -eq 'raw' | select UniqueId,serialnumber,@{ Name = 'TotalSize';  Expression = {($_.size)/1GB}}

foreach ($Disk in $Disks)
{
    $DiskSize = $Disk.TotalSize
    If ($ReqDriveSize -eq $DiskSize)
    {
        #$SN = $Disk.serialnumber
        If ($SN -like "") { $SN = $Disk.UniqueId } else {$SN = $Disk.serialnumber}
        break;
    }
}

Get-Disk -UniqueId $SN | Initialize-Disk -PartitionStyle GPT -PassThru | New-Partition -DriveLetter $DriveLetter -UseMaximumSize | Format-Volume -FileSystem NTFS -NewFileSystemLabel $DriveLabel -Force -Confirm:$False

# Check for the Last command RUN Status and set the Status Message
If ($?)
{ Write-Host "Status: Win_Disk_Config_Success" }
else
{ Write-Host "Status: Win_Disk_Config_Fail" }