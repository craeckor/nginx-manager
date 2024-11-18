if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe -ArgumentList "-NoProfile", "-ExecutionPolicy Bypass", "-Command", "cd `"$($PWD.Path)`"; .\ps2exe.ps1" -Verb RunAs; exit }

$workpath = $PSScriptRoot

Set-Location -Path $workpath

# Do not prompt user for confirmations
Set-Variable -Name 'ConfirmPreference' -Value 'None' -Scope Global

Install-PackageProvider NuGet -Scope AllUsers -ForceBootstrap -Confirm:$false -Force
$nuget = Get-PackageProvider -Name "NuGet" -ErrorAction SilentlyContinue

if ($nuget) {
    $psgallery = (Get-PSRepository -Name "PSGallery").InstallationPolicy
    if ($psgallery -eq "Trusted") {
        $ps2exe = Get-Module -Name "ps2exe"
        if (!($ps2exe)) {
            Install-Module ps2exe -Repository PSGallery -Scope AllUsers -SkipPublisherCheck -Force
            Import-Module -Name "ps2exe" -Force
        } else {
            Import-Module -Name "ps2exe" -Force
        }
    } else {
        Set-PSRepository PSGallery -InstallationPolicy Trusted
        if (!($ps2exe)) {
            Install-Module ps2exe -Repository PSGallery -Scope AllUsers -SkipPublisherCheck -Force
            Import-Module -Name "ps2exe" -Force
        } else {
            Import-Module -Name "ps2exe" -Force
        }
    }
} else {
    Install-PackageProvider NuGet -Scope AllUsers -ForceBootstrap -Confirm:$false -Force
    Set-PSRepository PSGallery -InstallationPolicy Trusted
    Install-Module ps2exe -Repository PSGallery -Force -Scope AllUsers -SkipPublisherCheck -Force
    Import-Module -Name "ps2exe" -Force
}

Import-Module -Name "ps2exe" -Force
ps2exe .\Nginx-Manager.ps1 .\Nginx-Manager.exe -x64 -noConsole -UNICODEEncoding -iconFile .\nginx.ico -title "Nginx Manager" -description "Nginx Manager" -product "Nginx Manager" -version 1.0.0.0 -noOutput -exitOnCancel -DPIAware -winFormsDPIAware
