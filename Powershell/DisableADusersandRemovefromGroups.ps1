Param (
    [string] $FullAccountName
)

# Extract the username (sAMAccountName) by removing the domain part
$SAMAccountName = $FullAccountName.Split('@')[0]

# Retrieve the Azure Automation Credential. Make sure to replace YourAutomationcredential with your credential
$Credential = Get-AutomationPSCredential -Name "YourAutomationCredential"

if ($null -eq $Credential) {
    Write-Error "Credential 'YourAutomationCredential' not found in Azure Automation. Ensure it exists and is correctly configured."
    throw
}

# Ensure the Active Directory module is available
if (Get-Module -ListAvailable -Name ActiveDirectory) {
    Write-Output "ActiveDirectory PowerShell module already exists on host."
} else {
    Write-Output "ActiveDirectory PowerShell module does not exist on host. Installing..."
    try {
        Import-Module ActiveDirectory
    } catch {
        Write-Error "Error installing ActiveDirectory PowerShell module."
        throw $_
    }
    Write-Output "ActiveDirectory PowerShell module installed."
}

# Disable the user account and remove them from groups
Write-Output "Finding and disabling user $SAMAccountName"
try {
    # Disable the user directly using the retrieved credential
    Disable-ADAccount -Identity $SAMAccountName -Credential $Credential
    Write-Output "Successfully disabled user account $SAMAccountName"

    # Retrieve the user's group memberships
    Write-Output "Retrieving groups for user $SAMAccountName"
    $User = Get-ADUser -Identity $SAMAccountName -Credential $Credential -Properties MemberOf

    # Remove the user from all groups
    if ($User.MemberOf -ne $null) {
        foreach ($Group in $User.MemberOf) {
            Write-Output "Removing user $SAMAccountName from group $Group"
            Remove-ADGroupMember -Identity $Group -Members $SAMAccountName -Credential $Credential -Confirm:$false
        }
        Write-Output "Successfully removed user $SAMAccountName from all groups."
    } else {
        Write-Output "User $SAMAccountName is not a member of any groups."
    }
} catch {
    Write-Error "Error processing user account $SAMAccountName. $_"
    throw $_
}
