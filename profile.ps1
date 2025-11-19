# This file is executed when the function app starts.
# You can use it to run initialization commands.

if ($env:MSI_SECRET) {
    Write-Host "Managed identity is enabled for this function app."
} else {
    Write-Host "Managed identity is not enabled for this function app."
}

Write-Host "PowerShell profile executed."
