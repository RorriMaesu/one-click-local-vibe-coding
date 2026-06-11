<#
.SYNOPSIS
    One-Click Local Vibe Coding - Environment Setup Wizard
    Author: RorriMaesu
    Description: Installs llama.cpp with CUDA support and configures the environment.
#>

# Set console output encoding to UTF-8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Visual Marker Helpers
function Show-Success ($message) {
    Write-Host "[SUCCESS] $message" -ForegroundColor Green
}

function Show-Warning ($message) {
    Write-Host "[WARNING] $message" -ForegroundColor Yellow
}

function Show-Info ($message) {
    Write-Host "[INFO] $message" -ForegroundColor Cyan
}

function Show-Error ($message) {
    Write-Host "[ERROR] $message" -ForegroundColor Red
}

Write-Host "=====================================================================" -ForegroundColor DarkCyan
Write-Host "            LOCAL VIBE CODING - ONE-CLICK INSTALLER                  " -ForegroundColor Cyan
Write-Host "            Created by: RorriMaesu                                    " -ForegroundColor Cyan
Write-Host "=====================================================================" -ForegroundColor DarkCyan

# 1. Drive Auto-Detection
Show-Info "Detecting system storage layout..."
$installDir = ""
$driveD = Get-PSDrive -Name D -ErrorAction SilentlyContinue

if ($driveD) {
    $installDir = "D:\llama-cpp"
    Show-Success "Secondary drive D: detected! Installing environment in: $installDir"
    Show-Info "This protects your primary system partition (C:) from large model footprints."
} else {
    $installDir = "C:\llama-cpp"
    Show-Warning "No D: drive detected. Defaulting installation to: $installDir"
}

# 2. Ensure Directories Exist
Show-Info "Creating folder structure..."
$binDir = "$installDir\bin"
$modelsDir = "$installDir\models"
$cacheDir = "$installDir\hf_cache"
$hubDir = "$cacheDir\hub"

foreach ($dir in ($installDir, $binDir, $modelsDir, $cacheDir, $hubDir)) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
}
Show-Success "Directory layout initialized."

# 3. GPU and CUDA Toolkit Detection
Show-Info "Checking system capabilities..."
$hasNvidia = $false
$hasCuda = $false
$cudaVersion = "12.4" # Default fallback version

# Check for NVIDIA Graphics Card
$gpus = Get-CimInstance -ClassName Win32_VideoController -ErrorAction SilentlyContinue
foreach ($gpu in $gpus) {
    if ($gpu.Name -like "*NVIDIA*") {
        $hasNvidia = $true
        break
    }
}

if (-not $hasNvidia -and (Get-Command nvidia-smi -ErrorAction SilentlyContinue)) {
    $hasNvidia = $true
}

# Check for CUDA Toolkit
if (Get-Command nvcc -ErrorAction SilentlyContinue) {
    $hasCuda = $true
    $nvccVersion = & nvcc --version
    if ($nvccVersion -match "release (\d+\.\d+)") {
        $cudaVersion = $Matches[1]
    }
} elseif ($env:CUDA_PATH) {
    $hasCuda = $true
    if ($env:CUDA_PATH -match "v(\d+\.\d+)") {
        $cudaVersion = $Matches[1]
    }
}

# Normalize CUDA version to available releases (12.4 or 13.3)
if ($cudaVersion -like "13.*") {
    $cudaVersion = "13.3"
} else {
    $cudaVersion = "12.4"
}

$buildType = "cuda"

if (-not $hasNvidia) {
    Show-Warning "No NVIDIA GPU was detected on this system."
    Write-Host ""
    $choice = Read-Host "[PROMPT] Enter 'Y' to download the CPU-optimized version, or any other key to abort (Y/N)"
    if ($choice -ne "Y" -and $choice -ne "y") {
        Show-Error "Installation aborted by the user."
        pause
        exit
    }
    $buildType = "cpu"
    Show-Info "Configuring installation for CPU-only execution."
} elseif (-not $hasCuda) {
    Show-Warning "NVIDIA GPU detected, but the NVIDIA CUDA Toolkit is missing from your system path."
    Show-Info "We will automatically download both llama.cpp CUDA binaries and the CUDA runtime DLLs (cudart)."
    Show-Info "This enables GPU-accelerated inference without a system-wide CUDA Toolkit installation."
    $cudaVersion = "12.4" # Default runtime DLL fallback
} else {
    Show-Success "NVIDIA CUDA Toolkit detected (version: $cudaVersion). GPU acceleration is fully active."
}

# 4. Pull Latest Release from GitHub API
Show-Info "Fetching latest llama.cpp release assets from ggml-org/llama.cpp..."
$apiUrl = "https://api.github.com/repos/ggml-org/llama.cpp/releases/latest"
$release = $null

try {
    # Set Security Protocol to TLS 1.2/1.3 for API call
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13
    $release = Invoke-RestMethod -Uri $apiUrl -Method Get -Headers @{ "User-Agent" = "RorriMaesu-Vibe-Coding" }
} catch {
    Show-Error "Failed to reach the GitHub API. Please check your internet connection."
    Show-Error "Error: $_"
    pause
    exit
}

if (-not $release) {
    Show-Error "Could not fetch release metadata from GitHub."
    pause
    exit
}

Show-Info "Latest Release Tag: $($release.tag_name)"

$mainAsset = $null
$runtimeAsset = $null

if ($buildType -eq "cuda") {
    # We need the main binary zip and the runtime zip matching the CUDA version
    $mainAsset = $release.assets | Where-Object { $_.name -like "llama-*-bin-win-cuda-$cudaVersion-x64.zip" } | Select-Object -First 1
    $runtimeAsset = $release.assets | Where-Object { $_.name -like "cudart-llama-bin-win-cuda-$cudaVersion-x64.zip" } | Select-Object -First 1
    
    if (-not $mainAsset) {
        # Fallback to general search if exact matches are not found
        $mainAsset = $release.assets | Where-Object { $_.name -like "*bin-win-cuda*-x64.zip" } | Select-Object -First 1
    }
} else {
    # CPU only binary zip
    $mainAsset = $release.assets | Where-Object { $_.name -like "llama-*-bin-win-cpu-x64.zip" } | Select-Object -First 1
}

if (-not $mainAsset) {
    Show-Error "Could not find compatible llama.cpp binaries for your system in the latest release."
    pause
    exit
}

# 5. Download and Extract Assets
$tempMainZip = "$installDir\temp_main.zip"
Show-Info "Downloading main package: $($mainAsset.name)..."
try {
    Invoke-WebRequest -Uri $mainAsset.browser_download_url -OutFile $tempMainZip -UserAgent "RorriMaesu-Vibe-Coding"
    Show-Success "Main binaries downloaded."
} catch {
    Show-Error "Failed to download main package from: $($mainAsset.browser_download_url)"
    pause
    exit
}

$tempRuntimeZip = "$installDir\temp_runtime.zip"
if ($buildType -eq "cuda" -and $runtimeAsset) {
    Show-Info "Downloading CUDA runtime package: $($runtimeAsset.name)..."
    try {
        Invoke-WebRequest -Uri $runtimeAsset.browser_download_url -OutFile $tempRuntimeZip -UserAgent "RorriMaesu-Vibe-Coding"
        Show-Success "CUDA runtime DLLs downloaded."
    } catch {
        Show-Warning "Could not download CUDA runtime DLL package. Attempting to proceed with main binaries only."
    }
}

Show-Info "Extracting files to installation directory..."
try {
    # Extract main package
    Expand-Archive -Path $tempMainZip -DestinationPath $binDir -Force
    
    # Extract runtime package if downloaded
    if ($buildType -eq "cuda" -and (Test-Path $tempRuntimeZip)) {
        Expand-Archive -Path $tempRuntimeZip -DestinationPath $binDir -Force
    }
    
    Show-Success "Extraction complete. Binaries are staged in: $binDir"
} catch {
    Show-Error "Extraction failed. There was a problem expanding the ZIP archives."
    Show-Error "Details: $_"
    pause
    exit
} finally {
    # Cleanup temp zip files
    if (Test-Path $tempMainZip) { Remove-Item $tempMainZip -Force }
    if (Test-Path $tempRuntimeZip) { Remove-Item $tempRuntimeZip -Force }
}

# 6. Dynamically Generate "run-server.bat"
Show-Info "Generating run-server.bat launcher..."
$batPath = "$installDir\run-server.bat"

# Set up launch string command parameters
$launchCmd = ""
if ($buildType -eq "cuda") {
    $launchCmd = "llama-server.exe -hf unsloth/gemma-4-12B-it-GGUF:Q4_K_M --spec-type draft-mtp --spec-draft-n-max 2 -fa on -c 32768 -ngl 99 --port 8080"
} else {
    # CPU Fallback excludes -ngl (GPU offloading) and draft-mtp (which benefits from GPU verification)
    $launchCmd = "llama-server.exe -hf unsloth/gemma-4-12B-it-GGUF:Q4_K_M -c 8192 --port 8080"
}

$batContent = @"
@echo off
setlocal enabledelayedexpansion

:: Local process-scoped environment variables to protect system C-drive
set "HF_HOME=$installDir\hf_cache"
set "HF_HUB_CACHE=$installDir\hf_cache\hub"

echo =====================================================================
echo             LOCAL VIBE CODING SERVER (llama.cpp)            
echo =====================================================================
echo [INFO] Target Model: Gemma 4 12B IT (Q4_K_M)
echo [INFO] Hugging Face Home Cache: %HF_HOME%
echo [INFO] Launcher Directory: %~dp0
echo =====================================================================
echo [INFO] Initializing server. First boot will automatically download the
echo        model weights from Hugging Face if not already cached.
echo =====================================================================

cd /d "$binDir"
$launchCmd

if %errorlevel% neq 0 (
    echo.
    echo [ERROR] Llama server exited with error code %errorlevel%.
    pause
)
"@

try {
    # Output batch file as UTF-8 without BOM to prevent CMD syntax issues
    [System.IO.File]::WriteAllText($batPath, $batContent)
    Show-Success "Launcher script created at: $batPath"
} catch {
    Show-Error "Failed to write launcher batch file."
    pause
    exit
}

# 7. Create Desktop Shortcut
Show-Info "Generating Desktop shortcut..."
try {
    $WshShell = New-Object -ComObject WScript.Shell
    $shortcutPath = [System.IO.Path]::Combine([System.Environment]::GetFolderPath("Desktop"), "Run Llama Server.lnk")
    $Shortcut = $WshShell.CreateShortcut($shortcutPath)
    $Shortcut.TargetPath = $batPath
    $Shortcut.WorkingDirectory = $installDir
    $Shortcut.Description = "Start Local Llama Server (Gemma 4 12B IT MTP)"
    $Shortcut.IconLocation = "cmd.exe"
    $Shortcut.Save()
    Show-Success "Desktop shortcut 'Run Llama Server' created successfully!"
} catch {
    Show-Warning "Failed to generate Desktop shortcut. You can launch the server by double-clicking: $batPath"
}

Write-Host ""
Write-Host "=====================================================================" -ForegroundColor DarkGreen
Write-Host "      INSTALLATION COMPLETED SUCCESSFULLY! READY FOR LOCAL VIBE" -ForegroundColor Green
Write-Host "=====================================================================" -ForegroundColor DarkGreen
Write-Host "To run the server, double click the 'Run Llama Server' shortcut on your Desktop." -ForegroundColor White
Write-Host "The server will listen on http://127.0.0.1:8080" -ForegroundColor White
Write-Host "All downloads and binaries are sandboxed in: $installDir" -ForegroundColor White
Write-Host ""
pause
