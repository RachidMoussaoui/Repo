# Object ID of the enterprise application
$ObjectId = "91a627b3-9401-4dc1-bed9-6412a4aff791"

# Define the Graph scopes to grant
$graphScopes = @("ADDyourGraphScpopes")
   )

# Connect to Microsoft Graph with the required permissions
Connect-MgGraph 

# Get the Microsoft Graph service principal
$graph = Get-MgServicePrincipal -Filter "AppId eq '00000003-0000-0000-c000-000000000000'"

# Loop through each scope and assign it
foreach ($scope in $graphScopes) {
    # Get the Graph app role corresponding to the current scope
    $graphAppRole = $graph.AppRoles | Where-Object { $_.Value -eq $scope }
    
    if (-not $graphAppRole) {
        Write-Warning "App role for scope '$scope' not found. Skipping..."
        continue
    }

    # Prepare the app role assignment as a hashtable
    $appRoleAssignment = @{
        principalId = $ObjectId      # The enterprise application's Object ID
        resourceId  = $graph.Id      # The Graph service principal ID
        appRoleId   = $graphAppRole.Id # The specific app role ID for the scope
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
