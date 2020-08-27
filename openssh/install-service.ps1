Function Add-PathVariable {
    param (
        [string]$addPath
    )
    if (Test-Path $addPath){
        $regexAddPath = [regex]::Escape($addPath)
        $arrPath = $env:Path -split ';' | Where-Object {$_ -notMatch "^$regexAddPath\\?"}
        $env:Path = ($arrPath + $addPath) -join ';'
        [System.Environment]::SetEnvironmentVariable("OPENSSH", $addPath, [System.EnvironmentVariableTarget]::Machine)
    } else {
        Throw "'$addPath' is not a valid path."
    }
}
Invoke-Expression '.\OpenSSH-Win64\uninstall-sshd.ps1'
Copy-Item ".\OpenSSH-Win64\*" -Destination "C:\Program Files\OpenSSH-Win64" -Recurse -Force
Add-PathVariable "C:\Program Files\OpenSSH-Win64"

Invoke-Expression 'C:\Program` Files\OpenSSH-Win64\install-sshd.ps1'
Set-Service sshd -StartupType Automatic
Set-Service ssh-agent -StartupType Automatic
Start-Service sshd 
Start-Service ssh-agent

Invoke-Expression 'ssh-add $HOME\.ssh\id_rsa'
$r = Get-NetFirewallRule -DisplayName 'Ansible AWX' 2> $null;
if(!$r){ 
	New-NetFirewallRule -DisplayName "Ansible AWX" -Direction Inbound -Action Allow -EdgeTraversalPolicy Allow -Protocol TCP -LocalPort 22
	Write-Host "Ansible AWX firewall is created successful!"
}

Copy-Item ".\administrators_authorized_keys" -Destination "C:\ProgramData\ssh\" -Force
$acl = Get-Acl C:\ProgramData\ssh\administrators_authorized_keys
$acl.SetAccessRuleProtection($true, $false)
$administratorsRule = New-Object system.security.accesscontrol.filesystemaccessrule("Administrators","FullControl","Allow")
$systemRule = New-Object system.security.accesscontrol.filesystemaccessrule("SYSTEM","FullControl","Allow")
$acl.SetAccessRule($administratorsRule)
$acl.SetAccessRule($systemRule)
$acl | Set-Acl
Write-Host "create administrators_authorized_keys successful!"