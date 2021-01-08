<#
Author: ManiMohan Amam

Objective: Function to verify the patching status on windows server, after the Installation is triggered
           via SCCM Agent.
#>
function Check-PatchingStatus {

    #$compliance_check = Get-WmiObject -Namespace "root\ccm\clientSDK" -Class CCM_SoftwareUpdate | Where {($_.EvaluationState -ne 8) -and ($_.EvaluationState -ne 13)}
    $compliance_check = Get-WmiObject -Namespace "root\ccm\clientSDK" -Class CCM_SoftwareUpdate | Where {$_.EvaluationState -ne 8 } | %{$_.Name}

    If (($compliance_check).count -ne "0")
    {
        Write-Host "Installation is in Progress for Below Updates"
        $compliance_check
        Write-Host "*********************************************************************"
    }
    else
    {
        Write-Host "No Updates found for Installation"
    }

    $FailedUpdates = Get-WmiObject -Namespace "root\ccm\clientSDK" -Class CCM_SoftwareUpdate | Where {$_.EvaluationState -eq 13 } | % {$_.Name} -ErrorAction SilentlyContinue

    If (($FailedUpdates).count -ne "0")
    {
        $Updates = Get-WmiObject -Namespace "root\ccm\clientSDK" -Class CCM_SoftwareUpdate | Where {$_.EvaluationState -eq 13 } -ErrorAction SilentlyContinue
        Invoke-WmiMethod -Class CCM_SoftwareUpdatesManager -Name InstallUpdates -ArgumentList (,$Updates) -Namespace root\ccm\clientsdk -ErrorAction SilentlyContinue | Out-Null
        Write-Host "Below Updates Failed and Rerun Triggered"
        $Updates | %{$_.Name}
    }
    else
    {
        Write-Host "No Failed Updates found for Re-Run"
    }

    if ($compliance_check -eq $null) {

        Write-Host "Completed"
        return

    }

}

Check-PatchingStatus
