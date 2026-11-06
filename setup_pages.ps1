$WorkspaceDir = "D:\AI TBG\AI AUTO"
$configPath = Join-Path $WorkspaceDir "mcp_config.json"
$config = Get-Content $configPath -Raw | ConvertFrom-Json
$token = $config.mcpServers.github.env.GITHUB_PERSONAL_ACCESS_TOKEN

$headers = @{
    "Authorization" = "token $token"
    "Accept" = "application/vnd.github.v3+json"
    "User-Agent" = "TBG-Script"
}

try {
    $res = Invoke-RestMethod -Uri "https://api.github.com/repos/ThienBinh-AG/AI-AUTO/pages" -Headers $headers -Method Get
    Write-Host "PAGES_FOUND"
    Write-Host "URL: $($res.html_url)"
    Write-Host "STATUS: $($res.status)"
} catch {
    Write-Host "PAGES_NOT_FOUND_OR_DISABLED: $($_.Exception.Message)"
    # Try enabling Pages
    $body = @{
        source = @{
            branch = "main"
            path = "/docs"
        }
    } | ConvertTo-Json
    
    try {
        $enableRes = Invoke-RestMethod -Uri "https://api.github.com/repos/ThienBinh-AG/AI-AUTO/pages" -Headers $headers -Method Post -Body $body -ContentType "application/json"
        Write-Host "ENABLE_SUCCESS"
        Write-Host "URL: $($enableRes.html_url)"
        Write-Host "STATUS: $($enableRes.status)"
    } catch {
        Write-Host "ENABLE_FAILED: $($_.Exception.Message)"
    }
}
