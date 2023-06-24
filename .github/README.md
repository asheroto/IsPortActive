[![GitHub Release Date - Published_At](https://img.shields.io/github/release-date/asheroto/IsPortActive)](https://github.com/asheroto/IsPortActive/releases)
[![GitHub Downloads - All Releases](https://img.shields.io/github/downloads/asheroto/IsPortActive/total)](https://github.com/asheroto/IsPortActive/releases)
[![GitHub Sponsor](https://img.shields.io/github/sponsors/asheroto?label=Sponsor&logo=GitHub)](https://github.com/sponsors/asheroto)
[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/asheroto)

# IsPortActive

## Description

This script checks if a port is currently active or in use. It can check for active TCP and UDP connections on a specified port, by process name, or by process ID.

## Installing

You can either download the PS1 script from here, or install using...

```powershell
Install-Script IsPortActive -Force
```

Answer **Yes** to any prompts. `-Force` is optional, but it will force the script to update if it is outdated.

This script is published on [PowerShell Gallery](https://www.powershellgallery.com/packages/IsPortActive).

The code is signed, so if you want to change it, just removed the `# SIG # Begin signature block` line and everything beneath it.

## Usage

```plaintext
IsPortActive [-Port <int>] [-ProcessName <string>] [-ProcessId <int>] [-Version] [-Help] [-CheckForUpdate]
```

## Parameters

| Parameter | Required | Description |
| --- | --- | --- |
| `-Port` | No | Specifies the port number to check for active connections. |
| `-ProcessName` | No | Specifies the name of the process to check for active connections. |
| `-ProcessId` | No | Specifies the process ID to check for active connections. |
| `-Version` | No | Displays the version of the script. |
| `-Help` | No | Displays the help information for the script. |
| `-CheckForUpdate` | No | Checks for updates of the script. |

## Examples

| Description | Command |
| --- | --- |
| Check if port 443 is active | `IsPortActive -Port 443` |
| Check if port 80 is active using process name | `IsPortActive -ProcessName "httpd"` |
| Check if port 8080 is active using process ID | `IsPortActive -ProcessId 1234` |