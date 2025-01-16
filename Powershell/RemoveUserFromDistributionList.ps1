Param
(
  [Parameter (Mandatory= $true)]
  [string] $identity,
  [Parameter (Mandatory= $true)]
  [string] $member
)

#Connect to Exchange Online
Connect-ExchangeOnline -ManagedIdentity -Organization "xperi.onmicrosoft.com"

#Remove Member
Remove-DistributionGroupMember -Identity $identity -Member $member

Disconnect-ExchangeOnline -Confirm:$false
