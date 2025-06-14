Param(
    [Parameter(Mandatory = $true)]
    [string]$AccountName
)

# Remove the domain part if the user supplied an email address
$SanitizedAccountName = $AccountName.Split('@')[0]

$SearchBase = "OU=Temporary Accounts,OU=User Accounts,OU=User Directory,DC=swaf27,DC=local"

# Retrieve the Azure Automation credential used for Active Directory queries
$Credential = Get-AutomationPSCredential -Name "YourAutomationCredential"

if ($null -eq $Credential) {
    Write-Error "Credential 'YourAutomationCredential' not found in Azure Automation."
    throw
}

try {
    $user = Get-ADUser -Filter "SamAccountName -eq '$SanitizedAccountName'" -SearchBase $SearchBase -Credential $Credential -Properties DisplayName,Mail
    if ($null -eq $user) {
        Write-Output "UserNotFound:$SanitizedAccountName"
    } else {
        $result = [pscustomobject]@{
            AccountName = $user.SamAccountName
            DisplayName = $user.DisplayName
            Mail        = $user.Mail
        }
        $result | ConvertTo-Json -Compress
    }
}
catch {
    Write-Error "Failed to retrieve user: $_"
}

