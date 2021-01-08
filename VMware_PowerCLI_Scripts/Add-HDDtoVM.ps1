# Script to add the Disk to a VM on Paravirtual SCSI Controller with given Disk Size
# Pre-requisite: SCSI Controller has to be available on VM

param
(
    # Use ConvertTo-Securestring to convert your password as encrypted text and then use it in the script
    [Parameter(Mandatory=$true)][String]$vcpassword,
    [Parameter(Mandatory=$true)][String]$hostnameFqdn,
    [Parameter(Mandatory=$true)][String]$vCenterServer,
    [Parameter(Mandatory=$true)][single]$size_target
)
Import-Module VMware.VimAutomation.Core
#Get-Module -Name VMware* -ListAvailable | Import-Module

$vcusername = 'vcenter_username'
$hostname = $hostnameFqdn.split(".")[0]
$controllerName = @()

$Connection = Connect-VIServer -Server $vCenterServer -User $vcusername -Password $vcpassword

If($Connection)
{
    # lookup VM name in vCenter
    $vm = Get-VM $hostname

    # Getting the ParaVirtual SCSI controller name
    $vmScsiController = Get-VM $vm | Get-ScsiController | ?{ $_.Type -eq "ParaVirtual" }
    $controller = ($vmScsiController.Name).Split(",")

    $controllerName = $controller[0]

    # adding new vmdk disk
    $vm | New-HardDisk -CapacityGB $size_target -Persistence persistent -StorageFormat Thin -Controller $controllerName -ErrorAction SilentlyContinue

    # Check for the Last command RUN Status and set the Status Message
    If ($?)
    {
        Write-Host "Status: VM_Disk_Add_Success"
    }
    else
    {
        Write-Error "Status: VM_Disk_Add_Fail"
    }
}
else
{
    Write-Error "Vcenter Connection unsuccesfull"
}

Disconnect-VIServer -Server $vCenterServer -Confirm:$false
