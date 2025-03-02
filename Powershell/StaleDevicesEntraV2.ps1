Param(
    [Switch]$nonInteractive=$false
)

$daysForDisable = -180
$daysForRemoval = -210
$webhookUrl = "https://prod-128.westeurope.logic.azure.com:443/workflows/a242d86942c945b7ac6bbb7a35fe9010/triggers/manual/paths/invoke?api-version=2016-06-01&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=ROr_6Dej9ZJhKMrTaqCE636Pvo5wPk-2kv05PQMalmo"

# Authenticate and connect to Azure
if ($nonInteractive) {
    Connect-MgGraph -Identity
} else {
    Connect-MgGraph -Scopes "Device.ReadWrite.All", "Group.ReadWrite.All", "Team.ReadBasic.All"
}

# Calculate cut-off dates
$cutoffForDisable = (Get-Date).ToUniversalTime().AddDays($daysForDisable).ToString("yyyy-MM-ddTHH:mm:ssZ")
$cutoffForRemoval = (Get-Date).ToUniversalTime().AddDays($daysForRemoval).ToString("yyyy-MM-ddTHH:mm:ssZ")

# Initialize an array to hold all devices
$allDevices = @()

# Fetch and process devices
try {
    $devicesToDisable = Get-MgDevice -Filter "approximateLastSignInDateTime le $cutoffForDisable and accountEnabled eq true" -All | Where-Object {
        $_.PhysicalIds -is [array] -and -not ($_.PhysicalIds | Where-Object { $_ -match 'ZTDID' })
    }

    foreach ($device in $devicesToDisable) {
        # Update-MgDevice -DeviceId $device.Id -AccountEnabled:$false
        $device | Add-Member -MemberType NoteProperty -Name "Action" -Value "Disable"
        $device | Add-Member -MemberType NoteProperty -Name "Name" -Value $device.DisplayName
        $device | Add-Member -MemberType NoteProperty -Name "LastSignInDate" -Value $device.ApproximateLastSignInDateTime
        $allDevices += $device
    }

    $devicesToRemove = Get-MgDevice -Filter "approximateLastSignInDateTime le $cutoffForRemoval and accountEnabled eq false" -All | Where-Object {
        $_.PhysicalIds -is [array] -and -not ($_.PhysicalIds | Where-Object { $_ -match 'ZTDID' })
    }

    foreach ($device in $devicesToRemove) {
        # Remove-MgDevice -DeviceId $device.Id -Confirm:$false
        $device | Add-Member -MemberType NoteProperty -Name "Action" -Value "Remove"
        $device | Add-Member -MemberType NoteProperty -Name "Name" -Value $device.DisplayName
        $device | Add-Member -MemberType NoteProperty -Name "LastSignInDate" -Value $device.ApproximateLastSignInDateTime
        $allDevices += $device
    }

    # Constructing FactSet for readable table format in one message
    $facts = @()
    foreach ($device in $allDevices) {
        $facts += @{
            "title" = "$($device.Name)"
            "value" = "**$($device.Action)** | Last Sign-in: $($device.LastSignInDate)"
        }
    }

    $teamsMessage = @{
        type = "message"
        attachments = @(@{
            contentType = "application/vnd.microsoft.card.adaptive"
            content = @{
                "$schema" = "http://adaptivecards.io/schemas/adaptive-card.json"
                "type" = "AdaptiveCard"
                "version" = "1.4"
                "body" = @(
                    @{
                        "type" = "TextBlock"
                        "size" = "Large"
                        "weight" = "Bolder"
                        "text" = "Device Cleanup Report"
                    },
                    @{
                        "type" = "TextBlock"
                        "text" = "The following devices have been processed:"
                        "wrap" = $true
                    },
                    @{
                        "type" = "FactSet"
                        "facts" = $facts
                    }
                )
            }
        })
    }

    # Send the Adaptive Card to Teams in a single message
    Invoke-RestMethod -Uri $webhookUrl -Method Post -Body ($teamsMessage | ConvertTo-Json -Depth 10) -ContentType "application/json"

} catch {
    Write-Host "Error: $_"
}
