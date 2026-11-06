@echo off
chcp 65001 > nul
title DONG BO DU LIEU AI AUTO - GITHUB THIEN BINH
echo ==========================================================
echo    KHOI CHAY DONG BO DU LIEU AI AUTO VA GITHUB
echo ==========================================================
cd /d "d:\AI TBG\AI AUTO"

powershell -NoProfile -ExecutionPolicy Bypass -File "d:\AI TBG\AI AUTO\sync_github.ps1"

echo.
echo ==========================================================
echo Nhan phim bat ky de ket thuc...
pause > nul
