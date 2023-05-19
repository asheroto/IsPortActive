<#PSScriptInfo

.VERSION 0.0.4

.GUID 7ec65ff2-79a3-4ff1-be3c-2dc6b6a3a3d7

.AUTHOR asherto

.COMPANYNAME asheroto

.TAGS PowerShell Windows port active network check program

.RELEASENOTES
[Version 0.0.1] - Initial Release.
[Version 0.0.2] - Removed function.
[Version 0.0.3] - Improved description.
[Version 0.0.4] - Fix example.

#>

<#
.SYNOPSIS
    Checks if a port is currently active or in use. Usage: IsPortActive.ps1 -Port <port>
.DESCRIPTION
    Checks if a port is currently active or in use. Usage: IsPortActive.ps1 -Port <port>
.EXAMPLE
    IsPortActive.ps1 -Port <port>
.NOTES
    Version      : 0.0.4
    Created by   : asheroto
#>


[CmdletBinding()]
param (
	[Parameter(Mandatory = $true)]
	[Int32]$Port
)

# Check if $Port was specified
if ($Port -eq 0)
{
	Write-Output ""
	Write-Output "Port was not specified."
	Write-Output ""
	Write-Output "Please use like this: .\IsPortActive.ps1 -Port <port>"
	Write-Output ""
	exit 1
}

# Check script elevation
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
	Write-Warning "Insufficient permissions to run this script. Open the PowerShell console as an administrator and run this script again."
	Break
}

# Get open ports
$Results = Get-NetTCPConnection | Where-Object { $_.LocalPort -eq "$Port" } | Select-Object @{Name = "Process"; Expression = { (Get-Process -Id $_.OwningProcess).ProcessName } }, @{Name = "Path"; Expression = { (Get-Process -Id $_.OwningProcess).Path } }, LocalAddress, LocalPort, RemoteAddress, RemotePort, State

# Return Results
Write-Output ""
if ($Results) {
	Write-Output "Port $Port is active!"
	$Results
} else {
	Write-Output "Port $Port is NOT active"
	Write-Output ""
}