# ==============================================================================
# HỆ THỐNG AI AUTO — THIÊN BÌNH
# File: sync_github_api.ps1
# Đồng bộ trực tiếp qua GitHub REST API (Không cần cài Git CLI)
# ==============================================================================

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$WorkspaceDir = "d:\AI TBG\AI AUTO"
$Owner = "ThienBinh-AG"
$Repo = "AI-AUTO"
$Branch = "main"

# Đọc token từ mcp_config.json
$configPath = Join-Path $WorkspaceDir "mcp_config.json"
if (-not (Test-Path $configPath)) {
    Write-Host "[LỖI] Không tìm thấy file mcp_config.json!" -ForegroundColor Red
    exit 1
}

$config = Get-Content $configPath -Raw | ConvertFrom-Json
$Token = $config.mcpServers.github.env.GITHUB_PERSONAL_ACCESS_TOKEN

if (-not $Token -or $Token.StartsWith("THAY_BANG")) {
    Write-Host "[LỖI] Token chưa được cấu hình hợp lệ trong mcp_config.json!" -ForegroundColor Red
    exit 1
}

$Headers = @{
    "Authorization" = "Bearer $Token"
    "User-Agent"    = "Antigravity-AI-AUTO"
    "Accept"        = "application/vnd.github+json"
}

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "   TIẾN TRÌNH ĐỒNG BỘ REST API: AI AUTO <--> GITHUB" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

# 1. Kiểm tra kết nối
try {
    $repoInfo = Invoke-RestMethod -Uri "https://api.github.com/repos/$Owner/$Repo" -Headers $Headers
    Write-Host "[1/3] Kết nối Repo thành công: $($repoInfo.full_name) (Nhánh: $Branch)" -ForegroundColor Green
} catch {
    Write-Host "[LỖI] Không thể kết nối tới GitHub Repo: $_" -ForegroundColor Red
    exit 1
}

# 2. Danh sách các file markdown & cấu hình cần đồng bộ
$filesToSync = Get-ChildItem -Path $WorkspaceDir -File | Where-Object {
    $_.Extension -in @(".md", ".json", ".bat", ".ps1") -and
    $_.Name -notlike ".*" -and
    $_.Name -notlike "~$*"
}

Write-Host "[2/3] Bắt đầu đẩy $($filesToSync.Count) file lên GitHub..." -ForegroundColor Cyan

foreach ($file in $filesToSync) {
    $relativePath = $file.Name
    $contentBytes = [System.IO.File]::ReadAllBytes($file.FullName)
    $contentBase64 = [System.Convert]::ToBase64String($contentBytes)
    
    # Kiểm tra xem file đã tồn tại trên GitHub chưa để lấy SHA
    $sha = $null
    try {
        $existing = Invoke-RestMethod -Uri "https://api.github.com/repos/$Owner/$Repo/contents/$relativePath`?ref=$Branch" -Headers $Headers -ErrorAction SilentlyContinue
        $sha = $existing.sha
    } catch {
        # File chưa tồn tại trên GitHub -> Tạo mới
    }
    
    $body = @{
        message = "TBG-AUTO-SYNC: Cập nhật $relativePath"
        content = $contentBase64
        branch  = $Branch
    }
    if ($sha) {
        $body["sha"] = $sha
    }
    
    $jsonBody = $body | ConvertTo-Json
    
    try {
        $upload = Invoke-RestMethod -Uri "https://api.github.com/repos/$Owner/$Repo/contents/$relativePath" -Method Put -Headers $Headers -Body ([System.Text.Encoding]::UTF8.GetBytes($jsonBody)) -ContentType "application/json; charset=utf-8"
        Write-Host " -> Đã đồng bộ: $relativePath" -ForegroundColor Green
    } catch {
        Write-Host " -> Lỗi đẩy file $relativePath : $_" -ForegroundColor Yellow
    }
}

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "   HOÀN TẤT ĐỒNG BỘ DỮ LIỆU QUA API THÀNH CÔNG!" -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Cyan
