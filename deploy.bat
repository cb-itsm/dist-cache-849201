@echo off
setlocal enabledelayedexpansion

set "LogFile=C:\Windows\Temp\avira_batch_test.log"

echo ======================================================== > "%LogFile%"
echo BATCH TEST START: %date% %time% >> "%LogFile%"
echo ======================================================== >> "%LogFile%"
echo Command Prompt execution successfully launched. >> "%LogFile%"

echo Scanning registry for active Avira instances... >> "%LogFile%"

:: Scan 64-bit Registry Hive
for /f "tokens=2*" %%a in ('reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" /s /f "Avira" 2^>nul ^| findstr /i "UninstallString"') do (
    set "UninstString=%%b"
    if not "!UninstString!"=="" (
        echo Found Avira: !UninstString! >> "%LogFile%"
        echo !UninstString! | findstr /i "msiexec" >nul
        if !errorlevel! equ 0 (
            for /f "tokens=2 delims={}" %%g in ("!UninstString!") do (
                echo Running silent MSI removal for GUID: {%%g} >> "%LogFile%"
                start /wait "" msiexec.exe /x "{%%g}" /qn /norestart
            )
        ) else (
            echo Running native executable silent removal... >> "%LogFile%"
            start /wait "" !UninstString! /remsilentnoreboot /quiet /qn /silent /uninstall
        )
    )
)

echo ======================================================== >> "%LogFile%"
echo BATCH TEST COMPLETE: %date% %time% >> "%LogFile%"
echo ======================================================== >> "%LogFile%"
exit /b 0