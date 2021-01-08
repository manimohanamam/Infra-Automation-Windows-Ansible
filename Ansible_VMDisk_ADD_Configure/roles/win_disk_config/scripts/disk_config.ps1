# Script to perform Disk Configuration on Windows OS, once the disk is added on the VM
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

"rescan" | diskpart