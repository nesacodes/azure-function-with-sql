# This file is executed when the function app starts.
# You can use it to run initialization commands.

# Azure Functions profile.ps1
# This profile is loaded on every cold start.
# Import-Module Az.Accounts -RequiredVersion '1.9.5'
# if ($env:MSI_SECRET) {
#     Disable-AzContextAutosave -Scope Process | Out-Null
#     Connect-AzAccount -Identity
# }

# Write-Host "PowerShell profile executed."

Write-Host "PowerShell profile executed (no Az modules)."