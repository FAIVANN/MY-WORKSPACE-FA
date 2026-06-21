<#
push_via_api.ps1
Uploads the current folder to a GitHub repository using the REST API (no git required), and enables GitHub Pages.
Run in the project folder:
  powershell -ExecutionPolicy Bypass -File .\push_via_api.ps1
Requires: PowerShell, internet, a GitHub Personal Access Token with `repo` scope.
#>

param()

function Read-SecureStringAsPlainText([SecureString]$s) {
    $ptr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($s)
    try { [Runtime.InteropServices.Marshal]::PtrToStringBSTR($ptr) } finally { [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($ptr) }
}

Write-Host "Upload current folder to GitHub via REST API (no git required)" -ForegroundColor Cyan

$defaultOwner = "FAIVANN"
$defaultRepo = "MY-WORKSPACE-FA"

$owner = Read-Host "GitHub owner/account [$defaultOwner]"
if ([string]::IsNullOrWhiteSpace($owner)) { $owner = $defaultOwner }

$repo = Read-Host "Repository name [$defaultRepo]"
if ([string]::IsNullOrWhiteSpace($repo)) { $repo = $defaultRepo }

Write-Host "Enter a GitHub Personal Access Token (PAT) with 'repo' scope:" -ForegroundColor Yellow
$securePat = Read-Host -AsSecureString
$pat = Read-SecureStringAsPlainText $securePat
if ([string]::IsNullOrWhiteSpace($pat)) { Write-Host "No PAT provided. Exiting."; exit 1 }

$headers = @{ Authorization = "token $pat"; 'User-Agent' = 'axxess-bar-uploader' }

# Create repo if it doesn't exist
$createBody = @{ name = $repo; description = "AXXESS BAR static site"; private = $false } | ConvertTo-Json
try {
    Write-Host "Creating repository $owner/$repo (if it already exists, this will fail but script will continue)" -ForegroundColor Green
    Invoke-RestMethod -Uri "https://api.github.com/user/repos" -Method Post -Headers $headers -ContentType 'application/json' -Body $createBody -ErrorAction Stop | Out-Null
    Write-Host "Repository created or exists." -ForegroundColor Green
} catch {
    Write-Host "Create repo: $_.Exception.Message" -ForegroundColor Yellow
}

# Collect files to upload
$cwd = Get-Location
Write-Host "Scanning files in $cwd (this may take a moment)..."
$files = Get-ChildItem -Recurse -File | Where-Object { $_.FullName -notmatch "\\.git\\" -and $_.Name -ne 'push_via_api.ps1' }
if ($files.Count -eq 0) { Write-Host "No files found to upload."; exit 1 }

# Upload each file via the Contents API
$index = 0
$total = $files.Count
foreach ($f in $files) {
    $index++
    $relative = $f.FullName.Substring($cwd.Path.Length).TrimStart('\') -replace '\\','/'
    $urlPath = [uri]::EscapeDataString($relative)
    $apiUrl = "https://api.github.com/repos/$owner/$repo/contents/$urlPath"

    Write-Host "[$index/$total] Uploading: $relative"

    $bytes = [System.IO.File]::ReadAllBytes($f.FullName)
    $content = [System.Convert]::ToBase64String($bytes)

    # Check if file exists to include sha (update) or create
    $sha = $null
    try {
        $existing = Invoke-RestMethod -Uri $apiUrl -Method Get -Headers $headers -ErrorAction Stop
        if ($existing -and $existing.sha) { $sha = $existing.sha }
    } catch {
        # not found -> will create
    }

    $body = @{ message = "Add $relative"; content = $content; branch = 'main' }
    if ($sha) { $body.sha = $sha }
    $bodyJson = $body | ConvertTo-Json -Depth 6

    try {
        Invoke-RestMethod -Uri $apiUrl -Method Put -Headers $headers -ContentType 'application/json' -Body $bodyJson -ErrorAction Stop | Out-Null
        Write-Host "  -> OK" -ForegroundColor Green
    } catch {
        Write-Host "  -> Failed: $($_.Exception.Message)" -ForegroundColor Red
        # continue with next
    }
}

# Enable GitHub Pages (main branch root)
Write-Host "Attempting to enable GitHub Pages (main branch, root)" -ForegroundColor Cyan
$pagesBody = @{ source = @{ branch = 'main'; path = '/' } } | ConvertTo-Json
try {
    Invoke-RestMethod -Uri "https://api.github.com/repos/$owner/$repo/pages" -Method Post -Headers $headers -ContentType 'application/json' -Body $pagesBody -ErrorAction Stop | Out-Null
    Write-Host "Pages request submitted." -ForegroundColor Green
} catch {
    Write-Host "Pages API: $($_.Exception.Message)" -ForegroundColor Yellow
}

# Get Pages status
try {
    $pages = Invoke-RestMethod -Uri "https://api.github.com/repos/$owner/$repo/pages" -Method Get -Headers $headers -ErrorAction Stop
    Write-Host "Pages status:" -ForegroundColor Green
    $pages | Format-List
} catch {
    Write-Host "Could not fetch Pages status: $($_.Exception.Message)" -ForegroundColor Yellow
}

# Clear PAT variable
Remove-Variable pat -ErrorAction SilentlyContinue
Write-Host "Done. Visit https://github.com/$owner/$repo to view the repo and Settings → Pages for the published URL." -ForegroundColor Cyan
```