param (
    [Parameter(Mandatory = $true)]
    [string]$Username,

    [Parameter(Mandatory = $true)]
    [string]$Password,

    [Parameter(Mandatory = $true)]
    [ValidateSet("EDC2", "EDC3", "GGN-DC", "BLR-DC", "NADC-Prod", "NADC-Dev", "Spain")]
    [string]$DataCenter,

    [Parameter(Mandatory = $true)]
    [string]$SnapshotName,

    [Parameter(Mandatory = $true)]
    [string]$VMFilePath
)

# Import the module without SSL validation
$env:POWERSHELL_OPTIONS = "--SkipSSLValidation"
Import-Module VMware.VimAutomation.Core

# Define server mappings
$Servers = @{
    "EDC2"     = "fredcihhssc0004.global.publicisgroupe.net"
    "EDC3"     = "fredcihhssc0003.global.publicisgroupe.net"
    "GGN-DC"   = "inggnihhssc0001.global.publicisgroupe.net"
    "BLR-DC"   = "inblrihhssc0001.global.publicisgroupe.net"
    "NADC-Prod"= "vcsa-prod.global.publicisgroupe.net"
    "NADC-Dev" = "vcsa-dev.global.publicisgroupe.net"
    "Spain"    = "fredcihhssc0005.global.publicisgroupe.net"
}

# Get the server address based on the DataCenter parameter
$Server = $Servers[$DataCenter]

# Convert password to secure string
$SecurePassword = ConvertTo-SecureString $Password -AsPlainText -Force
$Credential = New-Object System.Management.Automation.PSCredential ($Username, $SecurePassword)

# Establish connection to vSphere server without SSL
Connect-VIServer -Server $Server -Credential $Credential -Protocol https -Force

# Check if the connection is successful
if ($?) {
    Write-Host "Connected to vSphere server successfully."
} else {
    Write-Host "Failed to connect to vSphere server. Exiting script."
    exit 1
}

# Read VM names from the file
$VMs = Get-Content $VMFilePath

# Take snapshots for each VM
foreach ($VM in $VMs) {
    New-Snapshot -VM $VM -Name $SnapshotName -Description "Created On $(Get-Date)"
}

# List snapshots for each VM
foreach ($VM in $VMs) {
    Get-VM -Name $VM | Get-Snapshot | Select-Object VM, Name, Created
}

# Disconnect from vSphere server
Disconnect-VIServer -Server $Server -Confirm:$false
