Stop-Service -Name CyberArkDPAConnector
cmd /c sc delete CyberArkDPAConnector
Remove-Item -Recurse -Force "$env:ProgramFiles\CyberArk\DPAConnector" -ErrorAction SilentlyContinue