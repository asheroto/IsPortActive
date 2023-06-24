<#PSScriptInfo
.VERSION 1.0.0

.GUID 7ec65ff2-79a3-4ff1-be3c-2dc6b6a3a3d7

.AUTHOR asheroto

.COMPANYNAME asheroto

.TAGS PowerShell Windows port active network check program listening

.RELEASENOTES
[Version 0.0.1] - Initial Release.
[Version 0.0.2] - Removed function.
[Version 0.0.3] - Improved description.
[Version 0.0.4] - Fix example.
[Version 0.0.5] - Added code signing cert.
[Version 1.0.0] - Totally refactored script. Added support for UDP ports. Added support for checking by process name and process ID. Added support for returning service/display name if it's svchost. Added -Help, -CheckForUpdate, and -Version.
#>

<#
.SYNOPSIS
    Checks if a port is currently active or in use.
.DESCRIPTION
    This script checks if a port is currently active or in use. It checks for active TCP and UDP connections on a specified port, by process name, or by a process ID.

	Here are key switches to guide the script's behavior:
	  -Port to specify the port number to check for active connections.
	  -ProcessName to specify the name of the process to check for active connections.
	  -ProcessId to specify the process ID to check for active connections.

	Additional utilities include:
	  -Version switch displays the current version of the script.
	  -Help switch brings up the help information for the script usage.
	  -CheckForUpdate switch verifies if the current script version is up-to-date.
.PARAMETER Port
    Specifies the port number to check for active connections.
.PARAMETER ProcessName
    Specifies the name of the process to check for active connections.
.PARAMETER ProcessId
    Specifies the process ID to check for active connections.
.PARAMETER Version
    Displays the version of the script.
.PARAMETER Help
    Displays the help information for the script.
.PARAMETER CheckForUpdate
    Checks for updates of the script.
.EXAMPLE
    # Check if port 443 is active
    IsPortActive -Port 443
.EXAMPLE
    # Check if port 80 is active using process name
    IsPortActive -ProcessName "httpd"
.EXAMPLE
    # Check if port 8080 is active using process ID
    IsPortActive -ProcessId 1234
.NOTES
    Version      : 1.0.0
    Created by   : asheroto
#>

#Requires -RunAsAdministrator

[CmdletBinding()]
param (
	[Int32]$Port,
	[String]$ProcessName,
	[Int32]$ProcessId,
	[switch]$Version,
	[switch]$Help,
	[switch]$CheckForUpdate
)

# Version
$CurrentVersion = '1.0.0'
$RepoOwner = 'asheroto'
$RepoName = 'IsPortActive'

# Make sure that -Port, -ProcessName, or -ProcessId are not specified together
if (($Port -and $ProcessName) -or ($Port -and $ProcessId) -or ($ProcessName -and $ProcessId)) {
	Write-Error "You can only specify one of the following parameters: -Port, -ProcessName, or -ProcessId"
	exit 1
}

# Check if -Version is specified
if ($Version.IsPresent) {
	Write-Output "$RepoName $CurrentVersion"
	exit 0
}

# Line separator
function LineSeparator {
	Return ("─" * 80)
}

# Help
if ($Help) {
	Get-Help -Name $MyInvocation.MyCommand.Source -Full
	exit 0
}

# Check the GitHub release for the latest version
function Check-GitHubRelease {
	param (
		[string]$Owner,
		[string]$Repo
	)
	try {
		$url = "https://api.github.com/repos/$Owner/$Repo/releases/latest"
		$response = Invoke-RestMethod -Uri $url -ErrorAction Stop

		$latestVersion = $response.tag_name
		$publishedAt = $response.published_at
		$UtcDateTimeFormat = "MM/dd/yyyy HH:mm:ss"

		# Convert UTC time string to local time
		$UtcDateTime = [DateTime]::ParseExact($publishedAt, $UtcDateTimeFormat, $null)
		$PublishedLocalDateTime = $UtcDateTime.ToLocalTime()

		[PSCustomObject]@{
			LatestVersion     = $latestVersion
			PublishedDateTime = $PublishedLocalDateTime
		}
	} catch {
		Write-Error "Unable to check for updates. Error: $_"
		exit 1
	}
}

# Check for updates
if ($CheckForUpdate) {
	$Data = Check-GitHubRelease -Owner $RepoOwner -Repo $RepoName

	if ($Data.LatestVersion -gt $CurrentVersion) {
		Write-Warning "$RepoName is out of date.`n"
		Write-Output "Current version: $CurrentVersion. Latest version: $($Data.LatestVersion). Published at: $($Data.PublishedDateTime).`n"
		Write-Output "You can download the latest version from https://github.com/$RepoOwner/$RepoName/releases`n"
		Write-Output "If you have PowerShell 5 or later, you can run"
		Write-Output "`tInstall-Script -Name $RepoName -Force"
		Write-Output "to install the latest version.`n"
	} else {
		Write-Output "`n$RepoName is up to date.`n"
		Write-Output "Current version: $CurrentVersion. Latest version: $($Data.LatestVersion). Published at: $($Data.PublishedDateTime).`n"
		Write-Output "Repository: https://github.com/$RepoOwner/$RepoName/releases`n"
		Write-Output "PowerShell Gallery: https://www.powershellgallery.com/packages/$RepoName"
	}
	exit 0
}
function Get-Connections {
	param (
		[int]$ProcessId,
		[string]$ProcessName,
		[int]$Port
	)

	$tcpConnections = Get-NetTCPConnection
	$udpEndpoints = Get-NetUDPEndpoint

	if ($ProcessId) {
		$tcpConnections = $tcpConnections | Where-Object { $_.OwningProcess -eq $ProcessId }
		$udpEndpoints = $udpEndpoints | Where-Object { $_.OwningProcess -eq $ProcessId }
	}

	if ($ProcessName) {
		$processes = Get-Process | Where-Object { $_.Name -eq $ProcessName } -ErrorAction SilentlyContinue
		$processIds = $processes.Id

		$tcpConnections = $tcpConnections | Where-Object { $processIds -contains $_.OwningProcess }
		$udpEndpoints = $udpEndpoints | Where-Object { $processIds -contains $_.OwningProcess }
	}

	if ($Port) {
		$tcpConnections = $tcpConnections | Where-Object { $_.LocalPort -eq $Port }
		$udpEndpoints = $udpEndpoints | Where-Object { $_.LocalPort -eq $Port }
	}

	$Connections = @{}

	# Get all services
	$services = Get-WmiObject -Query "SELECT * FROM Win32_Service" -ErrorAction SilentlyContinue

	# Create a hashtable of service objects
	$serviceHashtable = @{}
	foreach ($service in $services) {
		$serviceHashtable[$service.ProcessID] = $service
	}

	$tcpConnections | Group-Object -Property LocalAddress | ForEach-Object {
		$localAddress = $_.Name
		if (-not $Connections.ContainsKey($localAddress)) {
			$Connections[$localAddress] = @()
		}
		$_.Group | ForEach-Object {
			$OwningProcess = $_.OwningProcess
			$ProcessName = (Get-Process -Id $OwningProcess -ErrorAction SilentlyContinue).Name
			$Path = (Get-Process -Id $OwningProcess -ErrorAction SilentlyContinue).Path
			$service = $serviceHashtable[$OwningProcess]

			if ($ProcessName -eq 'svchost' -and $service) {
				$Connection = [PSCustomObject][ordered]@{
					"Service Name"   = $service.Name
					"Display Name"   = $service.DisplayName
					"Process Name"   = $ProcessName
					"Process ID"     = $OwningProcess
					"Path"           = $Path
					"Local Address"  = $_.LocalAddress
					"Local Port"     = $_.LocalPort
					"Remote Address" = $_.RemoteAddress
					"Remote Port"    = $_.RemotePort
					"State"          = $_.State
					"Protocol"       = "TCP"
				}
			} else {
				$Connection = [PSCustomObject][ordered]@{
					"Process Name"   = $ProcessName
					"Process ID"     = $OwningProcess
					"Path"           = $Path
					"Local Address"  = $_.LocalAddress
					"Local Port"     = $_.LocalPort
					"Remote Address" = $_.RemoteAddress
					"Remote Port"    = $_.RemotePort
					"State"          = $_.State
					"Protocol"       = "TCP"
				}
			}

			$Connections[$localAddress] += $Connection
		}
	}

	$udpEndpoints | Group-Object -Property LocalAddress | ForEach-Object {
		$localAddress = $_.Name
		if (-not $Connections.ContainsKey($localAddress)) {
			$Connections[$localAddress] = @()
		}
		$_.Group | ForEach-Object {
			$OwningProcess = $_.OwningProcess
			$ProcessName = (Get-Process -Id $OwningProcess -ErrorAction SilentlyContinue).Name
			$Path = (Get-Process -Id $OwningProcess -ErrorAction SilentlyContinue).Path
			$service = $serviceHashtable[$OwningProcess]

			if ($ProcessName -eq 'svchost' -and $service) {
				$Connection = [PSCustomObject][ordered]@{
					"Service Name"  = $service.Name
					"Display Name"  = $service.DisplayName
					"Process Name"  = $ProcessName
					"Process ID"    = $OwningProcess
					"Path"          = $Path
					"Local Address" = $_.LocalAddress
					"Local Port"    = $_.LocalPort
					"Protocol"      = "UDP"
				}
			} else {
				$Connection = [PSCustomObject][ordered]@{
					"Process Name"  = $ProcessName
					"Process ID"    = $OwningProcess
					"Path"          = $Path
					"Local Address" = $_.LocalAddress
					"Local Port"    = $_.LocalPort
					"Protocol"      = "UDP"
				}
			}

			$Connections[$localAddress] += $Connection
		}
	}

	return $Connections
}

# Update note
Write-Output "$RepoName $CurrentVersion"
Write-Output "To check for updates, run $RepoName -CheckForUpdate`n"

# Validate parameters
if ($Port -gt 0 -and -not [string]::IsNullOrWhiteSpace($ProcessName)) {
	Write-Error "You must specify either -Port or -ProcessName, but not both."
	Write-Output ""
	exit 1
}

# ProcessId is specified, ignore other parameters
if ($ProcessId -gt 0) {
	$Connections = Get-Connections -ProcessId $ProcessId
} else {
	# Port or ProcessName is specified
	if ($Port -gt 0) {
		$Connections = Get-Connections -Port $Port
	} elseif (-not [string]::IsNullOrWhiteSpace($ProcessName)) {
		$Connections = Get-Connections -ProcessName $ProcessName
	} else {
		Write-Error "You must specify a port number or provide a process name or process ID."
		Write-Output ""
		exit 1
	}
}

# Output connections grouped by local address
$hasActiveConnections = $false

foreach ($localAddress in $Connections.Keys) {
	$localConnections = $Connections[$localAddress]

	if ($localConnections.Count -gt 0) {
		$hasActiveConnections = $true
		LineSeparator
		Write-Output "Local Address: $localAddress"
		LineSeparator

		$localConnections | ForEach-Object {
			$_ | Write-Output
		}
	}
}

if (-not $hasActiveConnections) {
	Write-Output "No active connections found."
}