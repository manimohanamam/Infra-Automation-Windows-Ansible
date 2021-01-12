# Server Connectivity Check

## Purpose of Playbook
> This is the Server Connectivity Check Job which checks for successful Ansible Connectivity via WINRM.
> Can Perform checks for multiple servers, multiple domains with one single job

Requirements
------------
>- WINRM should be Configured on the Target Windows Server for Ansible Connectivity

Tested on Operating System
--------------------------
>- WINDOWS - 2012 - R2 Standard
>- WINDOWS - 2016 - Standard
>- WINDOWS - 2019 - Standard

## Steps Performed via Ansible Connectivity Check
>- Check for Successful Ansible Connectivity

## Variables needed for ServerBuild Jobs

Playbook Variables
------------------

| Variable Name | Default Value | Internal/Parameter | Comments |
|---------------|---------------|--------------------|----------------|
| ServerInfo |  | Parameter | This variable will have details of Target Server to be connected to which will be passed as a variable by User |

## Sample Variables:
Based on the Server Domain the 2nd level Json object changes Domain_name1/Domain_name2/Domain_name3
```
ServerInfo:
  domain_name:
    - webserver01.fqdn.net
```
    
Dependencies
------------
* Powershell 4.0 / WMF 4.0 or above should be installed on target host.

* Note: The variables that are of "Variable Type=Parameter" they are needed to be passed in form of EXTRA-VARS in TOWER REST API calls or in the EXTRA-VARIABLES section ANSIBLE TOWER >> TEMPLATES >> EXTRA-VARIABLES

Launching Job Template using Tower REST API
------------------------------------------
* Use the following REST API call to launch the Ansible Tower Job Template from anywhere. This will connect the Ansible Tower from any where as far as the tower username/password has been provided in the following curl command.
```
curl -X POST --user <TOWER_USERNAME>:<TOWER_PASSWORED> -d '{"extra_vars": "{\"ServerInfo\": {\"domain_name\": [\"targetserver.fqdn.net\"] } }"}' -H "Content-Type: application/json" https://<TOWER FQDN>>/api/v1/job_templates/<JOB_TEMPLATE_ID>/launch/ -k
```
* Sample values for the feild that are used in above curl command
    * TOWER_USERNAME: admin
    * TOWER_PASSWORD: P@ssw0rd
    * TOWER_FQDN: Can be IP Address or Fully Qualified Domain Name of your Tower
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

    - name: Add Server to Dynamic Inventory
      hosts: localhost
      gather_facts: false
      tasks:
      - import_tasks: Dynamic_Inventory.yml
    
    - name: Run Ping Test
      hosts: all
      gather_facts: false
      tasks:
      - win_ping:
    
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
