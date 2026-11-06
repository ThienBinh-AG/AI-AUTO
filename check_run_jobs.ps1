$WorkspaceDir = "D:\AI TBG\AI AUTO"
$config = Get-Content (Join-Path $WorkspaceDir "mcp_config.json") -Raw | ConvertFrom-Json
$token = $config.mcpServers.github.env.GITHUB_PERSONAL_ACCESS_TOKEN
$headers = @{
    "Authorization" = "token $token"
    "Accept" = "application/vnd.github.v3+json"
    "User-Agent" = "TBG-Script"
}

$jobs = Invoke-RestMethod -Uri "https://api.github.com/repos/ThienBinh-AG/AI-AUTO/actions/runs/42252894344/jobs" -Headers $headers -Method Get
$jobs.jobs | ForEach-Object {
    Write-Host "JOB: $($_.name) | STATUS: $($_.status) | CONCLUSION: $($_.conclusion)"
    $_.steps | ForEach-Object {
        Write-Host "  -> STEP: $($_.name) [$($_.status) / $($_.conclusion)]"
    }
}
