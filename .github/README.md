[![GitHub Release Date - Published_At](https://img.shields.io/github/release-date/asheroto/IsPortActive)](https://github.com/asheroto/IsPortActive/releases)
[![GitHub Downloads - All Releases](https://img.shields.io/github/downloads/asheroto/IsPortActive/total)](https://github.com/asheroto/IsPortActive/releases)
[![GitHub Sponsor](https://img.shields.io/github/sponsors/asheroto?label=Sponsor&logo=GitHub)](https://github.com/sponsors/asheroto)
[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/asheroto)

# IsPortActive

This script checks if a port is currently active or in use. It can check for active TCP and UDP connections on a specified port, by process name, or by process ID.

If the process name is `svchost`, the script will find the service and display name in addition to the process name.

## Installing

You can either download the PS1 script from here, or install using...

```powershell
Install-Script IsPortActive -Force
```

Answer **Yes** to any prompts. `-Force` is optional, but it will force the script to update if it is outdated.

This script is published on [PowerShell Gallery](https://www.powershellgallery.com/packages/IsPortActive).

## Usage

```plaintext
IsPortActive [-Port <int>] [-ProcessName <string>] [-ProcessId <int>] [-Version] [-Help] [-CheckForUpdate]
```

## Parameters

Only one of the following parameters can be used at a time.

| Parameter | Description |
| --- | --- |
| `-Port` | Specifies the port number to check for active connections. |
| `-ProcessName` | Specifies the name of the process to check for active connections. |
| `-ProcessId` | Specifies the process ID to check for active connections. |
| `-Version` | Displays the version of the script. |
| `-Help` | Displays the help information for the script. |
| `-CheckForUpdate` | Checks for updates of the script. |

## Examples

| Description | Command |
| --- | --- |
| Check if port 443 is active | `IsPortActive -Port 443` |
| Check what ports are being used by process `httpd` | `IsPortActive -ProcessName "httpd"` |
| Check what ports are being used by process ID `1234` | `IsPortActive -ProcessId 1234` |

## Screenshots

### Check Port
![image](https://github.com/asheroto/IsPortActive/assets/49938263/7c0fe7c1-42fc-4514-b8e7-99b932442cd5)

### Check Process Name
![image](https://github.com/asheroto/IsPortActive/assets/49938263/2d40cd96-92eb-42c2-8e04-9cf75657c726)

### Check Process ID
![image](https://github.com/asheroto/IsPortActive/assets/49938263/547cb1e1-b10b-4389-b319-24d06e0a6048)