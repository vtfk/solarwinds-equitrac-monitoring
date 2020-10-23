if (${IP} -eq "") {
  Write-Host Message: ${IP}
  Write-Error "Missing IP! Is the template connected to a Node?"
  exit 1
}

Function SecureStringToString($Value)
{
    [System.IntPtr] $Bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($value);
    try
    {
        [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($Bstr);
    }
    finally
    {
        [System.Runtime.InteropServices.Marshal]::FreeBSTR($Bstr);
    }
}
$Cred = Get-Credential -credential ${CREDENTIAL}

[string] $WebPassword = SecureStringToString $Cred.Password

$URL = "https://${IP}:8443/Equitrac/Config"

$Body = @{
  action   = "login"
  password = $WebPassword
}

## Allow self-signed certificates
# Src: https://gist.github.com/rchaganti/aae721ebccd25eaab0b8b3dd67ad4b9b
Add-Type @"
using System.Net;
using System.Security.Cryptography.X509Certificates;
public class TrustAllCertsPolicy : ICertificatePolicy {
    public bool CheckValidationResult(
    ServicePoint srvPoint, X509Certificate certificate,
    WebRequest request, int certificateProblem) {
        return true;
    }
}
"@

[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy

# Set Tls versions
$allProtocols = [System.Net.SecurityProtocolType]'Ssl3,Tls,Tls11,Tls12'
[System.Net.ServicePointManager]::SecurityProtocol = $allProtocols
## Self-signed end

$Response = try {
  Invoke-WebRequest -Method Post -Uri $URL -UseBasicParsing -ContentType "application/x-www-form-urlencoded" -Body $Body -ErrorAction Stop
  
}
catch {
  Write-Warning "Exception was caught: $($_.Exception.Message)"
  Write-Host "Statistic.ServerUrl: 0"
  Write-Host "Statistic.ManagerID: 0"
  Write-Host "Statistic.EmailOriginator: 0"
  Write-Host "Statistic.Network: 1"
  Write-Host "Message.Network: $($_.Exception.Message)"
  exit 1
}

function GetFormInput () {
  Param (
    [String]$InputName
  )

  [regex]::match($Response.Content,"name=`"$InputName`".*value=`"(.*)`"").Groups[1].Value
}


$ServerUrl = GetFormInput 'server_url'
$ManagerID = GetFormInput 'adminid'
$EmailOriginator = GetFormInput 'scanToEmailOriginator'

$ServerUrlError = 0
$ManagerIDError = 0
$EmailOriginatorError = 0

if ($ServerUrl.StartsWith("0.")) { $ServerUrlError = 1 }
if ($ManagerID.StartsWith("1234")) { $ManagerIDError = 1 }
if ($EmailOriginator -eq "") { $EmailOriginatorError = 1 }

Write-Host "Message.ServerUrl: $ServerUrl"
Write-Host "Message.ManagerID: $ManagerId"
Write-Host "Message.EmailOriginator: $EmailOriginator"
Write-Host "Message.Network: OK"

Write-Host "Statistic.ServerUrl: $ServerUrlError"
Write-Host "Statistic.ManagerID: $ManagerIDError"
Write-Host "Statistic.EmailOriginator: $EmailOriginatorError"
Write-Host "Statistic.Network: 0"
exit