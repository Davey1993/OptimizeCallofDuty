@echo off
cls
echo Starting system cleanup and optimization...

:: Check for administrative privileges
net session >nul 2>&1
if %errorlevel% == 1 (
    echo You must run this script as an Administrator!
    pause
    goto endScript
)

:: Delete temporary and log files
echo Deleting temporary and log files...
del /q /f /s "%temp%\*"
for /d %%x in ("%temp%\*") do @rd /s /q "%%x"
del /q /f /s "C:\WINDOWS\Temp\*.*"
rd /s /q "C:\WINDOWS\Temp"
md "C:\WINDOWS\Temp"
del /q /f /s "C:\WINDOWS\Prefetch\*.*"
del /a /s /q *.log
deltree /y "C:\WINDOWS\tempor~1"
deltree /y "C:\WINDOWS\tmp"
deltree /y "C:\WINDOWS\ff*.tmp"
deltree /y "C:\WINDOWS\history"
deltree /y "C:\WINDOWS\cookies"
deltree /y "C:\WINDOWS\recent"
deltree /y "C:\WINDOWS\spool\printers"
echo Temporary files deleted.
pause

:: Handle Shader Cache
echo Handling shader cache...
for /r C:\ %%a in (shadercache) do (
    if exist "%%a" (
        echo Found shader cache folder at %%a
        del /q /f /s "%%a\*"
        for /d %%y in ("%%a\*") do @rd /s /q "%%y"
    )
)
echo Shader cache handled.
pause

:: SSD Check and Disk Defragmentation
echo Checking if the disk type is SSD for C: drive...
wmic diskdrive where "DeviceID like '%C:%'" get MediaType | findstr /C:"Fixed hard disk media" > nul
if "%ERRORLEVEL%"=="0" (
    echo HDD detected, proceeding with defragmentation...
    defrag C: /O /U /V
) else (
    echo SSD detected, skipping defragmentation.
)
pause

:: High Performance Power Plan
echo Configuring High Performance Power plan...
for /f "tokens=2 delims=:(" %%i in ('powercfg -list ^| findstr /C:"High performance"') do (
    set "highPerfGUID=%%i"
)
set "highPerfGUID=%highPerfGUID:~1,-1%"
echo High Performance GUID is %highPerfGUID%
powercfg -setactive %highPerfGUID%
echo Power plan set.
pause

:: Process Priority for COD
echo Checking for COD process...
tasklist /FI "IMAGENAME eq cod.exe" 2>NUL | find /I /N "cod.exe">NUL
if "%ERRORLEVEL%"=="0" (
    echo Setting Process Priority to "high priority"
    wmic process where name="cod.exe" CALL setpriority "high priority"
) else (
    echo COD process not found, not setting priority.
)
pause

:: DNS Cache
echo Flushing DNS cache...
ipconfig /flushdns
echo DNS cache flushed.
pause

:: Windows tweaks
echo Applying Windows tweaks...
reg add HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR /v AppCaptureEnabled /t REG_DWORD /d 0 /f
reg add HKCU\Software\Microsoft\GameBar /v UseNexusForGameBarEnabled /t REG_DWORD /d 1 /f
reg add HKLM\SOFTWARE\Microsoft\DirectX /v DXGKernelHAGSEnable /t REG_DWORD /d 0 /f
reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize /v EnableTransparency /t REG_DWORD /d 0 /f
reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize /v DisableStartMenuBlur /t REG_DWORD /d 1 /f
reg add HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications /v Migrated /t REG_DWORD /d 1 /f
echo Tweaks applied.
pause

:: Event Log Clearance
echo Attempting to clear event logs...
FOR /F "tokens=*" %%G IN ('wevtutil.exe el') DO (
    echo Clearing log: %%G
    wevtutil.exe cl "%%G" 2>nul
    IF ERRORLEVEL 1 echo Failed to clear log: %%G
)
echo Event logs cleared.
pause

:endScript
echo Cleanup and optimization complete. Reboot your system for good measure.
pause
