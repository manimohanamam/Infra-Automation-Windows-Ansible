# Server Build Additional Disk Configuration

## Purpose of Playbook
> This is the ServerBuild Additional Disk Configuration Job which is an End-to-End Configuration of VM Disk and OS Disk.

Requirements
------------
>- WINRM should be Configured on the Windows Server for Ansible Connectivity

Tested on Operating System
--------------------------
>- WINDOWS - 2012 - R2 Standard
>- WINDOWS - 2016 - Standard

## Steps Performed via Application Installation & Configuration
>- Add the Additional Drives on VCenter Layer as per user Input
>- Configure the Disks on OS Layer as per user Input

## Variables needed for ServerBuild Jobs

Role Variables
--------------

| Variable Name | Default Value | Internal/Parameter | Comments |
|---------------|---------------|--------------------|----------------|
| DiskInfo |  | Parameter | This variable will have list of Disks (Application / Additional) to be added on the Server which will be passed as a variable by User |
| DiskInfo<br/><ul><li>DriveLabel</li></ul>|  | Parameter | This variable is part of DiskInfo dictionary which defines the Label of Drive on OS Layer|
| DiskInfo<br/><ul><li>DriveLetter</li>|  | Parameter | This variable is part of DiskInfo dictionary which defines the Drive Letter on OS Layer|
| DiskInfo<br/><ul><li>DriveSize</li>|  | Parameter | This variable is part of DiskInfo dictionary which defines the Drive Size on VM Layer|
| DiskInfo<br/><ul><li>DiskType</li>|  | Parameter | This variable is part of DiskInfo dictionary which defines whether the Disk is a Additional Disk or Application Disk|
| ServerInfo |  | Parameter | This variable will have details of Target Server to be connected to which will be passed as a variable by User |
| location |  | Parameter | This variable will have location details of Server which will be used to identify Vcenter, will be passed as a variable by User |

## Sample Variables:
```
DiskInfo:
  - DriveLabel: ''
    DriveLetter: D
    DriveSize: '20'
    DiskType: appl
ServerInfo:
  domain_name:
    - ServerName01.fqdn.net
location: XXXX
```

Dependencies
------------
* Powershell 4.0 / WMF 4.0 or above should be installed on target host.

* Note: The variables that are of "Variable Type=Parameter" they are needed to be passed in form of EXTRA-VARS in TOWER REST API calls or in the EXTRA-VARIABLES section ANSIBLE TOWER >> TEMPLATES >> EXTRA-VARIABLES


Launching Job Template using Tower REST API
------------------------------------------
* Use the following REST API call to launch the Ansible Tower Job Template from anywhere. This will connect the Ansible Tower from any where as far as the tower username/password has been provided in the following curl command.
```
curl -X POST --user <TOWER_USERNAME>:<TOWER_PASSWORED> -d '{"extra_vars": "{\"ServerInfo\": {\"domain_name\": [\"servername01.fqdn.net\"] } }"}' -H "Content-Type: application/json" https://<TOWER FQDN>>/api/v1/job_templates/<JOB_TEMPLATE_ID>/launch/ -k
```
* Sample values for the feild that are used in above curl command
    * TOWER_USERNAME: admin
    * TOWER_PASSWORD: P@ssw0rd
    * TOWER_FQDN: Can be IP Address or Fully Qualified Domain Name: tower.fqdn.com
    * JOB_TEMPLATE_ID: Pre-requisite to obtain this is : Job Template with some Job Template name should already exists with Project, Credentials, Inventory attached to it. Use the following curl to fetch the Job ID by giving the JOB_TEMPLATE_NAME=MW_COMPONENT_JOB. For example:
```
curl -X GET --user admin:ansiblerocks https://tower.example.com/api/v1/job_templates/?name="MW_COMPONENT_JOB" -k -s | json_pp
```
Output of above command:
```
{
   "previous" : null,
   "results" : [
      {
         "ask_variables_on_launch" : false,
         "next_job_run" : null,
         "id" : 10,
```
* All the extra variable that are to be passed should be under : "extra_vars" json payload.


Example Playbook
----------------
Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: all
      roles:
        - vcenter_add
        - win_disk_config

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
