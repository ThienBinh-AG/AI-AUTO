@echo off
chcp 65001 > nul
title DONG BO REST API - AI AUTO VA GITHUB
echo ==========================================================
echo    DONG BO TRUC TIEP DU LIEU QUA GITHUB REST API
echo ==========================================================
cd /d "d:\AI TBG\AI AUTO"

powershell -NoProfile -ExecutionPolicy Bypass -File "d:\AI TBG\AI AUTO\sync_github_api.ps1"

echo.
echo ==========================================================
echo Nhan phim bat ky de ket thuc...
pause > nul
