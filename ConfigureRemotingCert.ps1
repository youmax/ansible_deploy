Function LoadCert
{
    $cert = New-Object -TypeName System.Security.Cryptography.X509Certificates.X509Certificate2
	[string]$path = [string](Get-Location)+"\cert.pem"
    Write-Host "Load cert from $path"
	$cert.Import( $path )
    return $cert   
}
Set-ExecutionPolicy RemoteSigned
.\ConfigureRemotingForAnsible.ps1 -SkipNetworkProfileCheck
Write-Host "disable basic authentication"
Set-Item -Path WSMan:\localhost\Service\Auth\Basic -Value $false
Write-Host "remove HTTP listener，HTTPS listener (optional)"    
Get-ChildItem -Path WSMan:\localhost\Listener | Where-Object { $_.Keys -contains "Transport=HTTP" } | Remove-Item -Recurse -Force 
Write-Host "start certificate authentication (optional)"
Set-Item -Path WSMan:\localhost\Service\Auth\Certificate -Value $true
$cert = LoadCert
## Import the public key into Trusted Root Certification Authorities
$store_name = [System.Security.Cryptography.X509Certificates.StoreName]::Root
$store_location = [System.Security.Cryptography.X509Certificates.StoreLocation]::LocalMachine
$store = New-Object -TypeName System.Security.Cryptography.X509Certificates.X509Store -ArgumentList $store_name, $store_location
$store.Open("MaxAllowed")
$store.Add($cert)
$store.Close()
## Import the public key into Trusted People
$store_name = [System.Security.Cryptography.X509Certificates.StoreName]::TrustedPeople
$store_location = [System.Security.Cryptography.X509Certificates.StoreLocation]::LocalMachine
$store = New-Object -TypeName System.Security.Cryptography.X509Certificates.X509Store -ArgumentList $store_name, $store_location
$store.Open("MaxAllowed")
$store.Add($cert)
$store.Close()

$username = $env:UserName
$password = ConvertTo-SecureString -String "Sun7DL&2" -AsPlainText -Force
$credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $username, $password
$thumbprint = (Get-ChildItem -Path cert:\LocalMachine\root | Where-Object { $_.Subject -eq "CN=$username" }).Thumbprint
New-Item -Path WSMan:\localhost\ClientCertificate `
       -Subject "$username@localhost" `
       -URI * `
       -Issuer $thumbprint `
       -Credential $credential `
       -Force
winrm get winrm/config/Service