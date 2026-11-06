$WorkspaceDir = "D:\AI TBG\AI AUTO"
$config = Get-Content (Join-Path $WorkspaceDir "mcp_config.json") -Raw | ConvertFrom-Json
$token = $config.mcpServers.github.env.GITHUB_PERSONAL_ACCESS_TOKEN
$headers = @{
    "Authorization" = "token $token"
    "Accept" = "application/vnd.github.v3+json"
    "User-Agent" = "TBG-Script"
}

$builds = Invoke-RestMethod -Uri "https://api.github.com/repos/ThienBinh-AG/AI-AUTO/pages/builds" -Headers $headers -Method Get
$builds | Select-Object -First 3 | ForEach-Object {
    Write-Host "COMMIT: $($_.commit) | STATUS: $($_.status) | CREATED: $($_.created_at) | ERROR: $($_.error.message)"
}
