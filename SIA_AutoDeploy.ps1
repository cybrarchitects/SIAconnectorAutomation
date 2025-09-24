#####created by Javid Ibrahimov#####
$currDir = Get-Location
$currDir = $currDir.Path
Import-Module -Name ($currDir + '\IdentityAuth.psm1')
cls

[string]$subdomain = Read-Host 'Please provide your tenant subdomain'
[string]$platformURL = "https://platform-discovery.cyberark.cloud/api/identity-endpoint/" + $subdomain
$identity = Invoke-RestMethod -Uri $platformURL -Method Get
[string]$identityURL = $identity.endpoint
[string]$identityUser = Read-Host 'Please provide your username'
$logonToken = Get-IdentityHeader -IdentityTenantURL $identityURL -IdentityUserName $identityUser

do
    {
        [int]$action_i = Read-Host 'Do you want to add or remove Connector, 1 - for add, 2 - for remove'
        if ($action_i -ge 1 -and $action_i -le 2) {$inpuValid = $true}
        else 
            { Write-Host "Please select valid value"
            $inpuValid = $false
            }
    }
    while (-not $inpuValid)
do
    {
    [int]$os_i = Read-Host 'Please select OS, 1 - windows, 2 - linux' -ErrorAction Ignore
    if ($os_i -ge 1 -and $os_i -le 2) {$inpuValid = $true}
    else 
    { Write-Host "Please select valid value"
    $inpuValid = $false
    }
    }
while (-not $inpuValid)
if ($os_i -eq 1) 
    {
    $os = 'windows'
    $os_user = Get-Credential
    }
elseif ($os_i -eq 2) 
    {
    $os = 'linux'
    $os_user = Read-Host 'Please provide username for Linux Connector'
    $os_key = Read-Host 'Please provide full path to Private key for accessing Linux machine'
    }
[string]$os_hostname = read-host 'please provide Servers Hostname:'
[string]$URL = "https://" + $subdomain + ".dpa.cyberark.cloud/"

if ($action_i -eq 1)
{
    [string]$poolURL = "https://" + $subdomain + ".connectormanagement.cyberark.cloud/api/connector-pools"
    $pools = Invoke-RestMethod -Uri $poolURL -Method Get -Headers $logonToken
    Write-Host "List of Connector Pools with ID, name and descriptions:"
    $n = 1
    foreach ($pool in $pools.connectorPools)
        {
            $text = "Pool number " + $n + " : " + $pool
            $text = $text.replace('@{','')
            $text = $text.Replace('}','')
            $text
            #Write-Host "Pool number " $n " : " $pool
            $n++
        }
    [int]$i = Read-Host 'Please select which pool you want to use, just provide the number of it:'
    $i--
    $connPoolID = $pools.connectorPools[$i].poolId

    $ScriptRequestURL = $URL + "api/connectors/setup-script"

    $ConnectorSet = @{
        connector_os = $os
        connector_pool_id = $connPoolID
        expiration_minutes = 15
        proxy_host = ""
        proxy_port = 443
        windows_installation_path = ""
    }

    $json = $ConnectorSet | ConvertTo-Json -Depth 10 

    $scriptURL = Invoke-RestMethod -Uri $ScriptRequestURL -Method Post -Headers $logonToken -body $json -ContentType "application/json"

    $scriptFile = Get-Date -Format "yyyy-MM-dd"
    if ($os_i -eq 1) 
        { 
        $scriptFile = 'win' + $scriptFile + '.ps1'
        Invoke-WebRequest $ScriptURL.script_url -OutFile $scriptFile
        Invoke-Command -ComputerName $os_hostname -Credential $os_user -FilePath .\$scriptFile
        }
    elseif ($os_i -eq 2) 
        { 
        $scriptFile = 'nix' + $scriptFile + '.sh'
        $scriptURL.bash_cmd | Out-File $scriptFile
        $target = $os_user + '@' + $os_hostname
        Get-Content .\$scriptFile | ssh $target -i $os_key
        }
}
elseif ($action_i -eq 2)
{
    [string]$connectorURL = "https://" + $subdomain + ".dpa.cyberark.cloud/api/connectors"
    $connectors = Invoke-RestMethod -Uri $connectorURL -Method Get -Headers $logonToken
    Write-Host "List of Connectors with hostname,type, OS and Connector ID:"
    $n = 1
    foreach ($connector in $connectors.items)
        {
            $text = "Connector number " + $n + " HOSTNAME: " + $connector.hostname + "; HOST_TYPE:" +$connector.hostType + "; REGION:"+ $connector.region + "; HOST_OS:" +  $connector.os + "; CONNECTOR_ID:" + $connector.id
            $text
            $n++
        }
    [int]$i = Read-Host 'Please select which connector you want to uninstall, script will remove connector from backend and uninstall Service, just provide the number of it:'
    $i--
    $ConnectorID = $connectors.items[$i].id
    [string]$connectorURLdel = $connectorURL + '/' + $ConnectorID
    if ($os_i -eq 1) 
        { 
        Invoke-Command -ComputerName $os_hostname -Credential $os_user -FilePath ($currDir + '\removeWindows.ps1')
        }
    elseif ($os_i -eq 2) 
        { 
        $target = $os_user + '@' + $os_hostname
        $scriptRemoveNIX = Get-Content ($currDir + '\removeLinux.sh') -Raw
        $scriptRemoveNIX | ssh $target -i $os_key -T bash -
        }
    Invoke-RestMethod -Uri $connectorURLdel -Method Delete -Headers $logonToken
}