# Lets the Foundry portal (a public site) call Foundry over its private
# endpoint (10.0.5.x) from Edge on the jump box. Without this, Edge's local
# network access protection blocks the portal's background requests and the
# portal shows "Your request for data was not sent".
$sites = "https://ai.azure.com", "https://*.ai.azure.com"
foreach ($policy in "LocalNetworkAccessAllowedForUrls", "InsecurePrivateNetworkRequestsAllowedForUrls") {
  $key = "HKLM:\SOFTWARE\Policies\Microsoft\Edge\$policy"
  New-Item -Path $key -Force | Out-Null
  $i = 1
  foreach ($site in $sites) {
    New-ItemProperty -Path $key -Name "$i" -Value $site -PropertyType String -Force | Out-Null
    $i++
  }
}
Write-Output "Edge local network access policy set for: $($sites -join ', ')"
