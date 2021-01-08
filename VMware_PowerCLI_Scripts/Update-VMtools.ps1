# Script to update VMtools on the Windows VM to Latest

param(
    # # Use ConvertTo-Securestring to convert your password as encrypted text and then use it in the script
    [Parameter(Mandatory=$true)][String]$vcpassword,
    [Parameter(Mandatory=$true)][String]$hostnameFqdn,
    [Parameter(Mandatory=$true)][String]$vCenterServer
)

Import-Module VMware.VimAutomation.Core

$vcusername = 'vcenter_username'
$hostname = $hostnameFqdn.split(".")[0]

$Connection = Connect-VIServer -Server $vCenterServer -User $vcusername -Password $vcpassword | Out-Null

If($Connection)
{
    # lookup VM name in vCenter
    $vm = Get-VM $hostname -ErrorAction SilentlyContinue

    If ($vm)
    {
        $vmtools_version = $vm.Guest.ToolsVersion
        $vmtools_status = (get-view $vm).Guest.ToolsVersionStatus

        If ($vmtools_status -eq "guestToolsNeedUpgrade")
        {
            # Trigger VM tools update
            $vm | Update-Tools -NoReboot -ErrorAction SilentlyContinue

            # Check for the Last command RUN Status and set the Status Message
            If ($?)
            {
                Write-Host "Status: VM Tools Upgrade is Successful"
                # Check tools version after the upgrade
                $vmtools_version = (Get-VM $hostname).Guest.ToolsVersion
                Write-Host "Latest Tools Version: $vmtools_version"
            }
            else
            {
                Write-Host "Current Tools Version: $vmtools_version"
                Write-Error "Status: VM Tools Upgrade is Failed"
            }
        }
        else
        {
            Write-Host "VMTools Version is Up-to-Date : $vmtools_version"
        }
    }
    else
    {
        Write-Error "$hostname not found on Vcenter"
    }
}
else
{
    Write-Error "Vcenter Connection unsuccesfull"
}
Disconnect-VIServer -Server $vCenterServer -Confirm:$false