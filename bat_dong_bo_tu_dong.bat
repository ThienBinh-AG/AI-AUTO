@echo off
chcp 65001 > nul
title BAT DONG BO TU DONG AI AUTO - GITHUB
echo ==========================================================
echo    KICH HOAT DONG BO TU DONG: AI AUTO <--> GITHUB
echo ==========================================================

powershell -NoProfile -ExecutionPolicy Bypass -Command "$action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument '-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -Command \"& ''d:\AI TBG\AI AUTO\sync_github.ps1'' *^>^> ''d:\AI TBG\AI AUTO\sync.log''\"'; $triggerLogon = New-ScheduledTaskTrigger -AtLogOn -User $env:USERNAME; $triggerRepeat = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Minutes 30); $principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive; $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable; Register-ScheduledTask -TaskName 'TBG_AI_AUTO_Sync' -Action $action -Trigger @($triggerLogon, $triggerRepeat) -Principal $principal -Settings $settings -Force; Write-Host '-> DA KICH HOAT DONG BO NGANH MOI 30 PHUT & KHI MO MAY THANH CONG!' -ForegroundColor Green"

echo.
echo ==========================================================
echo Nhan phim bat ky de thoat...
pause > nul
