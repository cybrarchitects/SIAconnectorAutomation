# SIAconnectorAutomation
This script can deploy or remove SIA connector on Windows or Linux based machine
FILE Description:
**SIA_AutoDeploy.ps1** main file that shall be executed, no parameters are needed. System and user that runs this script should be able to import PowerShell Module while runs the script
**IdentityAuth.psm1** PCloud authentication module, that will be imported at the very begin of process
**removeLinux.sh** file contains script to remove SIA connector from Linux based connector. Tested on RockyLinux 8.9 at the moment.
**removeWindows.ps1** file contains PowerShell script to remove SIA connector from Windows Server based connector.
Script prompts information in CLI Wizard mode. Such as, PCloud subdomain, username, password and MFA for authentication. Later it prompts for action- ADD or REMOVE connector, and collect information about SIA Connector- Hostname, credentials for Windows based server, and username + Public Key file for Linux Server. In order, to run script without any issue, executor must be able to SSH to Server or Remote PowerShell if it is Windows based Server.
Whenever we run ADD SH or PowerShell files will be automatically appear in local drive, name format will be **nixDATE.sh** for NIX system and **winDATE.ps1**
**IMPORTANT:** Unfortunately, we are not sure if API's are not changed on backend, script created just a few weeks ago, and I had to change some part of it to accustome it to newest updated responses to some of API request.
