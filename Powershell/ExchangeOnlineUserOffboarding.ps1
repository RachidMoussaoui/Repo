Param
(
  [Parameter (Mandatory= $true)]
  [string] $identity,
  [Parameter (Mandatory= $true)]
  [string] $user
)

#Connect to Exchange Online
Connect-ExchangeOnline -ManagedIdentity -Organization "xperi.onmicrosoft.com"

#Set Automatic Replies
Set-MailboxAutoReplyConfiguration -Identity $identity -AutoReplyState Enabled -InternalMessage "De gebruiker die u probeert te bereiken, is niet langer werkzaam bij het bedrijf." -ExternalMessage "De gebruiker die u probeert te bereiken, is niet langer werkzaam bij het bedrijf." -ExternalAudience All

#Convert to Shared Mailbox
Set-Mailbox -Identity $identity -Type Shared

#Hide from GAL
Set-mailbox -Identity $identity -HiddenFromAddressListsEnabled $true

#Add Mailbox Permissions if set
if($user){
  Add-MailboxPermission -Identity $identity -User $user -AccessRights FullAccess -InheritanceType All -AutoMapping $true
}

Disconnect-ExchangeOnline -Confirm:$false
