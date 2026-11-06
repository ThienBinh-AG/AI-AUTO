@echo off
chcp 65001 > nul
title TAT DONG BO TU DONG AI AUTO - GITHUB
echo ==========================================================
echo    TAT DONG BO TU DONG: AI AUTO <--> GITHUB
echo ==========================================================

powershell -NoProfile -ExecutionPolicy Bypass -Command "Unregister-ScheduledTask -TaskName 'TBG_AI_AUTO_Sync' -Confirm:$false -ErrorAction SilentlyContinue; Write-Host '-> DA HUY BO TAC VU DONG BO TU DONG NGANH.' -ForegroundColor Yellow"

echo.
echo ==========================================================
echo Nhan phim bat ky de thoat...
pause > nul
