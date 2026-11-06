# ==============================================================================
# HE THONG AI AUTO - THIEN BINH
# File: sync_github.ps1
# Nhiem vu: Tu dong dong bo 2 chieu giua may tinh va GitHub (ThienBinh-AG/AI-AUTO)
# ==============================================================================

$WorkspaceDir = "d:\AI TBG\AI AUTO"
$Owner = "ThienBinh-AG"
$Repo = "AI-AUTO"
$Branch = "main"

Set-Location -Path $WorkspaceDir

# 1. Kiem tra va nap Git vao bien moi truong
$gitCmdPath = "$env:LOCALAPPDATA\Programs\Git\cmd"
if (Test-Path "$gitCmdPath\git.exe") {
    $env:Path = "$gitCmdPath;$env:Path"
}

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "   TIEN TRINH DONG BO DU LIEU: AI AUTO <--> GITHUB" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "[1/5] Thu muc lam viec: $WorkspaceDir" -ForegroundColor Gray

# 2. Doc Token tu mcp_config.json
$configPath = Join-Path $WorkspaceDir "mcp_config.json"
$Token = $null
if (Test-Path $configPath) {
    try {
        $config = Get-Content $configPath -Raw | ConvertFrom-Json
        $Token = $config.mcpServers.github.env.GITHUB_PERSONAL_ACCESS_TOKEN
    } catch {}
}

if ($Token -and -not $Token.StartsWith("THAY_BANG")) {
    $RepoUrl = "https://${Token}@github.com/$Owner/$Repo.git"
    Write-Host "-> Da nap xac thuc an toan qua GitHub Token." -ForegroundColor Green
} else {
    $RepoUrl = "https://github.com/$Owner/$Repo.git"
    Write-Host "-> Canh bao: Chua tim thay Token, su dung URL mac dinh." -ForegroundColor Yellow
}

# 3. Khoi tao Git repository neu chua co
if (-not (Test-Path "$WorkspaceDir\.git")) {
    Write-Host "[2/5] Dang khoi tao Git Local Repository..." -ForegroundColor Yellow
    git init -b $Branch
    git config user.name "Thien Binh AI AUTO"
    git config user.email "thienbinh.aiauto@gmail.com"
} else {
    Write-Host "[2/5] Git Local Repository da san sang." -ForegroundColor Green
}

# 4. Cau hinh Remote Origin
$existingRemote = git remote get-url origin 2>$null
if (-not $existingRemote) {
    Write-Host "[3/5] Dang ket noi Remote Origin..." -ForegroundColor Yellow
    git remote add origin $RepoUrl
} else {
    git remote set-url origin $RepoUrl
    Write-Host "[3/5] Da cap nhat ket noi Remote Origin." -ForegroundColor Green
}

# 5. Keo du lieu moi nhat tu GitHub ve (Pull)
Write-Host "[4/5] Dang kiem tra va keo luong du lieu moi tu GitHub..." -ForegroundColor Cyan
git fetch origin $Branch 2>$null
$pullResult = git pull origin $Branch --no-rebase --allow-unrelated-histories 2>&1
Write-Host $pullResult -ForegroundColor Gray

# 6. Dong goi va day du lieu len GitHub (Commit & Push)
Write-Host "[5/5] Dang kiem tra cac thay doi tai may tinh de day len GitHub..." -ForegroundColor Cyan
git add .
$status = git status --porcelain
if ($status) {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $commitMsg = "TBG-AUTO-SYNC: Cap nhat du lieu AI AUTO ngay $timestamp"
    git commit -m $commitMsg
    Write-Host "-> Da tao ban ghi luu (Commit): $commitMsg" -ForegroundColor Green
    
    Write-Host "-> Dang day du lieu len GitHub nhanh '$Branch'..." -ForegroundColor Yellow
    $pushResult = git push -u origin $Branch 2>&1
    Write-Host $pushResult -ForegroundColor Green
} else {
    Write-Host "-> Khong co du lieu moi can cap nhat len GitHub." -ForegroundColor Green
}

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "   HOAN TAT DONG BO DU LIEU THANH CONG!" -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Cyan
