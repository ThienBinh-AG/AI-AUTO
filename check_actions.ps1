$WorkspaceDir = "D:\AI TBG\AI AUTO"
$config = Get-Content (Join-Path $WorkspaceDir "mcp_config.json") -Raw | ConvertFrom-Json
$token = $config.mcpServers.github.env.GITHUB_PERSONAL_ACCESS_TOKEN
$headers = @{
    "Authorization" = "token $token"
    "Accept" = "application/vnd.github.v3+json"
    "User-Agent" = "TBG-Script"
}

try {
    $runs = Invoke-RestMethod -Uri "https://api.github.com/repos/ThienBinh-AG/AI-AUTO/actions/runs" -Headers $headers -Method Get
    Write-Host "TOTAL RUNS: $($runs.total_count)"
    $runs.workflow_runs | Select-Object -First 3 | ForEach-Object {
        Write-Host "NAME: $($_.name) | CONCLUSION: $($_.conclusion) | URL: $($_.html_url)"
    }
} catch {
    Write-Host "ACTIONS_ERROR: $($_.Exception.Message)"
}
