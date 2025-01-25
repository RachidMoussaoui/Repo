# Object ID of the enterprise application
$ObjectId = "19626b0d-9830-48ef-bcb6-6b9804efd75d"

# Define the Defender for Endpoint scopes to grant
$defenderScopes = @(
    
    "Machine.ReadWrite.All"
)

# Connect to Microsoft Graph with the required permissions
Connect-MgGraph -Scope "AppRoleAssignment.ReadWrite.All"

# Get the Defender for Endpoint service principal
$defenderAPI = Get-MgServicePrincipal -Filter "DisplayName eq 'WindowsDefenderATP'"

# Loop through each scope and assign it
foreach ($scope in $defenderScopes) {
    # Get the Defender app role corresponding to the current scope
    $defenderAppRole = $defenderAPI.AppRoles | Where-Object { $_.Value -eq $scope }

    if (-not $defenderAppRole) {
        Write-Warning "App role for scope '$scope' not found. Skipping..."
        continue
    }

    # Prepare the app role assignment as a hashtable
    $appRoleAssignment = @{
        principalId = $ObjectId      # The enterprise application's Object ID
        resourceId  = $defenderAPI.Id  # The Defender service principal ID
        appRoleId   = $defenderAppRole.Id # The specific app role ID for the scope
    }

    # Grant the app role to the enterprise application
    try {
        New-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $ObjectId -BodyParameter $appRoleAssignment | Out-Null
        Write-Output "Successfully assigned scope: $scope"
    } catch {
        Write-Error "Failed to assign scope '$scope': $_"
    }
}

Write-Output "All scopes processed."
