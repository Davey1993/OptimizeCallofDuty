@echo off
echo Deleting all temporary files...
del /q /f /s "%temp%\*" 2>nul
for /d %%x in ("%temp%\*") do @rd /s /q "%%x" 2>nul

for /r C:\ %%a in (shadercache) do (
    if exist "%%a" (
        echo Found shader cache folder at %%a
        echo Deleting contents of the shader cache...
        del /q /f /s "%%a\*" 2>nul
        for /d %%y in ("%%a\*") do @rd /s /q "%%y" 2>nul
    )
)

echo Looking for High Performance Power plan
for /f "tokens=2 delims=:(" %%i in ('powercfg -list ^| findstr /C:"High performance"') do (
    set "highPerfGUID=%%i"
)
set "highPerfGUID=%highPerfGUID:~1,-1%"
echo High Performance GUID is %highPerfGUID%
echo Switching to High Performance Power plan
powercfg -setactive %highPerfGUID%
echo Defragging disk...
defrag C: /O /U /V

echo Checking for COD process...
tasklist /FI "IMAGENAME eq cod.exe" 2>NUL | find /I /N "cod.exe">NUL
if "%ERRORLEVEL%"=="0" (
    echo Setting Process Priority to "high priority"
    wmic process where name="cod.exe" CALL setpriority "high priority"
) else (
    echo COD process not found, not setting priority.
)

echo Flush DNS cache
ipconfig /flushdns

echo Cleanup complete.
pause
