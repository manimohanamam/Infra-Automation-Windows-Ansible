#Script to Add VM Disk, Paravirtual SCSI Controller also will be added if not available on the VM

param(
    #passwords are encrypted on ansible vault
[Parameter(Mandatory=$true)][String]$vcpassword,
[Parameter(Mandatory=$true)][String]$hostnameFqdn,
[Parameter(Mandatory=$true)][String]$vCenterServer,
[Parameter(Mandatory=$true)][single]$size_target
)

Import-Module VMware.VimAutomation.Core
#Get-Module -Name VMware* -ListAvailable | Import-Module

$vcusername = 'Vcenter_username'
$hostname = $hostnameFqdn.split(".")[0]
#$controllerName = @()

Connect-VIServer -Server $vCenterServer -User $vcusername -Password $vcpassword | Out-Null

# lookup VM name in vCenter
$vm = Get-VM $hostname

#Get the detals of all SCSI Controllers on the VM
$SCSIControllers = $vm | Get-HardDisk | Select @{N = 'VM'; E = {$_.Parent.Name}}, Name,
@{N = 'SCSIName'; E = {(Get-ScsiController -HardDisk $_).Name}},
@{N = 'SCSIType'; E = {(Get-ScsiController -HardDisk $_).Type}} | select VM, Name, SCSIName, SCSIType

$SCSI_All = $SCSIControllers | Group-Object -Property SCSIName | Select @{N="Disks";E={$_.Count}},Name,Group

# Get the details of Para Virtual SCSI Controllers on VM
$SCSI_PV = $SCSIControllers | ?{ $_.SCSIType -eq "ParaVirtual" } | Group-Object -Property SCSIName | Select @{N="Disks";E={$_.Count}},Name,Group
$SCSI_PV_Available = $SCSI_PV | ? {$_.Disks -lt 14} | Sort-Object Disks | Select Name

# Checks whether a New SCSI Controller can be added if required
If ($SCSI_PV_Available.count -eq '0')
{
    If ($SCSI_All.count -lt '4')
    {
        # Adding the SCSI Controller
        Write-Host "New ParaVirtual SCSI Controller will be added"
        $vm | Shutdown-VMGuest -Confirm:$false

        # Shutting down the VM
        do { $vmstatus = (get-vm $vm).PowerState; Write-Host "$hostname Power-Off In-Progress"; Start-Sleep -Seconds 5 }until($vmstatus -eq "PoweredOff")

        # Adding the New Harddisk, New SCSI Controller and mapping HDD to New Controller
        $New_Harddisk = $vm | New-HardDisk -CapacityGB "$size_target" -Persistence persistent -StorageFormat Thin
        New-ScsiController -HardDisk $New_Harddisk -BusSharingMode NoSharing -Type ParaVirtual

        # Powering ON the VM
        Start-VM -vm $vm
        do{ $vmstatus1 = (get-vm $vm).PowerState ; Start-Sleep -Seconds 15 }until($vmstatus1 -eq "PoweredOn")
        Start-Sleep -Seconds 20
        #Disconnect-VIServer -Server $vCenterServer -Confirm:$false
    }
    else
    {
        Disconnect-VIServer -Server $vCenterServer -Confirm:$false
        throw "$hostname has reached maximum capacity of SCSI Controllers, Cannot add a new Controller"
    }
}
else
{
    # Adding New Harddisk to the available SCSI Controller
    $SCSI_Controller = $SCSI_PV_Available[0].Name
    Write-Host "ParaVirtual SCSI Controller available for Disk Addition: $SCSI_Controller "
    $vm | New-HardDisk -CapacityGB $size_target -Persistence persistent -StorageFormat Thin -Controller $SCSI_Controller
    Disconnect-VIServer -Server $vCenterServer -Confirm:$false
}