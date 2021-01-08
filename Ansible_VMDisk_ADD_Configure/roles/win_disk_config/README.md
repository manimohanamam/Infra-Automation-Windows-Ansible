# Server Build Additional Disk Configuration

## Purpose of Role
> This Role is to Configure the Disk on a Windows Server on OS Layer, after the disk is added on VCenter Layer

Requirements
------------
>- WINRM should be Configured on the New Build Server for Ansible Connectivity

Tested on Operating System
--------------------------
>- WINDOWS - 2012 - R2 Standard
>- WINDOWS - 2016 - Standard

## Steps Performed via Application Installation & Configuration
>- Configure the Disks on OS Layer as per user Input

## Variables needed for ServerBuild Jobs

Role Variables
--------------

| Variable Name | Default Value | Internal/Parameter | Comments |
|---------------|---------------|--------------------|----------------|
| DiskInfo |  | Parameter | This variable will have list of Disks (Application / Additional) to be added on the Server which will be passed as a variable by User |
| ServerInfo |  | Parameter | This variable will have details of Target Server to be connected to which will be passed as a variable by User |
| location |  | Parameter | This variable will have location details of Server which will be used to identify Vcenter, will be passed as a variable by User |

## Sample Variables: MSSQL Server Build
```
DiskInfo:
  - DriveLabel: ''
    DriveLetter: D
    DriveSize: '20'
    DiskType: addl
ServerInfo:
  domain_name:
    - ServerName01.fqdn.net
location: XXXX
```

Author Information
------------------

>ManiMohan Amam
> 
>manimohan.amam@gmail.com

Support
-------

>ManiMohan Amam
> 
>manimohan.amam@gmail.com
