param(
    [switch]$Report,
    [switch]$Disable,
    [switch]$Delete
)

# --- Admin Check ---
$IsAdmin = ([Security.Principal.WindowsPrincipal] `
        [Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $IsAdmin) {
    Write-Error("This script must be run as Administrator.")
    exit 1
}

# --- Color Support ---
$UseColor = -not [Console]::IsOutputRedirected
function Color {
    param($Text, $Color)
    if ($UseColor) { return "`e[${Color}m$Text`e[0m" }
    return $Text
}

# --- Enumerate Rules ---
$rules = Get-NetFirewallRule -PolicyStore ActiveStore | Where-Object { $_.Action -eq 'Allow' } |
ForEach-Object {
    $app = Get-NetFirewallApplicationFilter -AssociatedNetFirewallRule $_ -ErrorAction SilentlyContinue
    if ($app.Program -or $app.Service) {
        [PSCustomObject]@{
            Rule = $_
            App  = $app
        }
    }
}

foreach ($entry in $rules) {
    $rule = $entry.Rule
    $app = $entry.App

    $exists = $false
    $target = $null

    if ($app.Program) {
        $target = $app.Program
        $exists = (Test-Path $target) -or ($target -eq "Any") -or ($target -eq "System")
    }
    elseif ($app.Service) {
        $target = $app.Service
        $exists = Get-Service -Name $target -ErrorAction SilentlyContinue
    }

    if (-not $exists) {
        $msg = "Rule '$($rule.DisplayName)' references missing target: $target"
        Write-Output (Color $msg "31")

        if ($Report) { continue }

        if ($Disable) {
            Write-Output (Color "Disabling rule..." "33")
            Set-NetFirewallRule -Name $rule.Name -Enabled False
        }

        if ($Delete) {
            Write-Output (Color "Deleting rule..." "31")
            Remove-NetFirewallRule -Name $rule.Name
        }
    }
}