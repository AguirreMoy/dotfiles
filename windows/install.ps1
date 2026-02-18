# windows/install.ps1
# This script sets up symlinks for dotfiles and installs VS Code extensions on Windows.

# --- Configuration ---
$DotfilesToSync = @(
    @{Source = "..\.config\nvim"; Target = "$env:APPDATA\nvim"},
    @{Source = "..\.config\starship.toml"; Target = "$env:USERPROFILE\.config\starship.toml"},
    @{Source = "..\.config\kitty"; Target = "$env:APPDATA\kitty"},
    @{Source = "..\.config\hellwal"; Target = "$env:APPDATA\hellwal"},
    @{Source = "..\.config\hellwal"; Target = "$env:LOCALAPPDATA\hellwal"},
    @{Source = "..\.gitconfig"; Target = "$env:USERPROFILE\.gitconfig"},
    @{Source = "..\.paths"; Target = "$env:USERPROFILE\.paths"},
    @{Source = "..\vscode\settings.json"; Target = "$env:APPDATA\Code\User\settings.json"}
)

function Log-Info($msg) { Write-Host "[INFO] $msg" -ForegroundColor Blue }
function Log-Success($msg) { Write-Host "[SUCCESS] $msg" -ForegroundColor Green }
function Log-Warn($msg) { Write-Host "[WARNING] $msg" -ForegroundColor Yellow }
function Log-Error($msg) { Write-Host "[ERROR] $msg" -ForegroundColor Red; exit 1 }

# --- Symlink Creation ---
foreach ($item in $DotfilesToSync) {
    $src = Join-Path $PSScriptRoot $item.Source
    $dest = $item.Target
    if (!(Test-Path $src)) { Log-Warn "Source not found: $src"; continue }
    $destDir = Split-Path $dest
    if (!(Test-Path $destDir)) { New-Item -ItemType Directory -Path $destDir | Out-Null }
    if (Test-Path $dest) {
        if ((Get-Item $dest).LinkType -eq 'SymbolicLink') { Remove-Item $dest }
        else { Rename-Item $dest "$($dest).bak-$(Get-Date -Format yyyyMMddHHmmss)" }
    }
    New-Item -ItemType SymbolicLink -Path $dest -Target $src | Out-Null
    Log-Success "Symlinked $src -> $dest"
}

# --- VS Code Extensions ---
$ExtensionsFile = Join-Path $PSScriptRoot "..\vscode\extensions.txt"
if (Test-Path $ExtensionsFile) {
    if (!(Get-Command code -ErrorAction SilentlyContinue)) {
        Log-Warn "'code' command not found. Skipping VS Code extensions."
    } else {
        Log-Info "Installing VS Code extensions..."
        Get-Content $ExtensionsFile | ForEach-Object {
            $ext = $_.Trim()
            if ($ext -eq "") { return }
            $already = code --list-extensions | Where-Object { $_ -eq $ext }
            if ($already) {
                Log-Info "  $ext is already installed. Skipping."
            } else {
                Log-Info "  Installing $ext"
                code --install-extension $ext
            }
        }
        Log-Success "VS Code extensions installation complete."
    }
} else {
    Log-Warn "VS Code extension list not found. Skipping."
}

Log-Success "Dotfile synchronization complete."
Log-Warn "Please remember to manually install your paid fonts from your private repository."

# --- Cross-platform tools (optional) ---
# Install cross-platform CLI tools via winget if available
$tools = @(
    'tldr-pages.tldr',      # tldr
    'Neovim.Neovim',        # neovim
    'lsd.lsd',              # lsd
    'BurntSushi.ripgrep',   # ripgrep
    'sharkdp.fd',           # fd
    'sharkdp.bat',          # bat
    'ajeetdsouza.zoxide',   # zoxide
    'junegunn.fzf'          # fzf
)
foreach ($tool in $tools) {
    Log-Info "Installing $tool via winget..."
    winget install --id $tool --silent
}
Log-Success "Cross-platform tools installation complete."

function Install-VictorMonoNerdFont {
    Log-Info "Installing VictorMono Nerd Font..."
    $url = "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/VictorMono.zip"
    $tempDir = Join-Path $env:TEMP "VictorMonoNerdFont"
    if (Test-Path $tempDir) { Remove-Item $tempDir -Recurse -Force }
    New-Item -ItemType Directory -Path $tempDir | Out-Null
    $zipFile = Join-Path $tempDir "VictorMono.zip"
    Invoke-WebRequest -Uri $url -OutFile $zipFile
    Expand-Archive -Path $zipFile -DestinationPath $tempDir
    
    $fontFiles = Get-ChildItem -Path $tempDir -Filter "*.ttf"
    # This installs for the current user
    $fontsFolder = (New-Object -ComObject Shell.Application).Namespace(0x14)
    foreach ($file in $fontFiles) {
        if (-not (Test-Path "C:\Windows\Fonts\$($file.Name)")) {
            Log-Info "  Installing $($file.Name)"
            $fontsFolder.CopyHere($file.FullName)
        } else {
            Log-Info "  $($file.Name) already installed. Skipping."
        }
    }
    Remove-Item $tempDir -Recurse -Force
    Log-Success "VictorMono Nerd Font installed."
}

Install-VictorMonoNerdFont
