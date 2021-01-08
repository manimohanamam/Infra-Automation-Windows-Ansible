<#
Author: ManiMohan Amam

Objective: To trigger the SCCM Agent actions in the back-end(Silent Mode).

Warning : Donot run the Script directly on Production servers, without testing on Dev Servers
          Reboot will be triggered automatically by SCCM client.
#>

#Function to pause the script and countdown time after the SCCM Client actions are triggered
function Countdown-Timer([int]$time){
    if ($time -eq 0)
    {
        #write-host "$time*"
        return
    }
    write-host "$time*" -NoNewline
    $time--
    Start-sleep -s 60
    Countdown-Timer -time $time
}

<#
Function to trigger the below SCCM Client Actions
1) Machine Policy Retrieval & Eval. Cycle
2) Software Updates Deployment Eval. Cycle
3) Software Updates Scan Cycle
This script is specifically for triggering the Download and install of patches which are already pushed to Windows Servers.
#>
function Run-SCCMClientActions{
    $ErrorActionPreference = "Stop"
    Write-Host "##### Running Configuration Manager Client Actions #####"
    try
    {
        Write-Host "## Running Machine Policy Retrieval & Eval. Cycle ##"
        Invoke-WMIMethod -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule “{00000000-0000-0000-0000-000000000021}” | Out-null
        Write-Host "Sleeping for 5 minutes..."
        RecurssiveTimer -time 5
        try
        {
            Write-Host "## Running Software Updates Deployment Eval. Cycle ##"
            Invoke-WMIMethod -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule “{00000000-0000-0000-0000-000000000108}” | Out-null
            Write-Host "## Running Software Updates Scan Cycle ##"
            Invoke-WMIMethod -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule “{00000000-0000-0000-0000-000000000113}” | Out-null
            Write-Host "Sleeping for 5 minutes..."
            RecurssiveTimer -time 5
        }
        catch
        {
            Write-Host -BackgroundColor Red "Error Running Software Update Cycles"
            throw
        }
    }
    catch
    {
        Write-Host -BackgroundColor Red "Error Running Machine Policy Retrieval & Eval. Cycle"
        throw
    }
}

Run-SCCMClientActions
Countdown-Timer -time 5