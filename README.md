# Check for an active listening port

This script makes it easy to check if a port is actively listening or in use. 

# Installing

You can either download the PS1 script from here, or install using...

```powershell
Install-Script IsPortActive
```

This script is published on  [PowerShell Gallery](https://www.powershellgallery.com/packages/IsPortActive).

The code is signed, so if you want to change it, just removed the  `# SIG # Begin signature block`  line and everything beneath it.

# Usage

Checking if port `443` is listening...

```powershell
IsPortActive -Port 443
```

# Parameters
|Parameter|Required|Description|
|--|--|--|
|`-Port`|Yes|Port number to check|