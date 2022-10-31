@echo off
fltmc>nul
if "%errorlevel%" NEQ "0" (goto UACPrompt) else (goto UACAdmin)
:UACPrompt
%1 start "" mshta vbscript:createobject("shell.application").shellexecute("""%~0""","::",,"runas",1)(window.close)&exit
exit /B
:UACAdmin

title WindowsOptimize

ver | find "0.22" && set OSVER=win11
ver | find "0.19" && set OSVER=win10

if %OSVER%=="" (
    echo Unsupported OS!
    pause
    exit /B
)

goto :main


:win10_optimize
    @REM win10关闭更新后显示推荐和建议
    reg add HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager                  /v SubscribedContent-310093Enabled             /t REG_DWORD /d 0 /f
    @REM win10关闭偶尔在开始菜单中显示建议
    reg add HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager                  /v SubscribedContent-338388Enabled             /t REG_DWORD /d 0 /f
    @REM win10关闭任务栏资讯
    reg add HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Feeds                                   /v ShellFeedsTaskbarViewMode                   /t REG_DWORD /d 2 /f
goto:eof


:win11_optimize
    @REM win11关闭小组件
    reg add HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced                    /v TaskbarDa             /t REG_DWORD /d 0 /f
    @REM win11关闭任务栏多任务按钮
    reg add HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced                    /v ShowTaskViewButton    /t REG_DWORD /d 0 /f
    @REM win11关闭windows跟踪应用启动，如果使用windows搜索则不推荐关闭
    @REM reg add HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced                  /v Start_TrackProgs      /t REG_DWORD /d 0 /f
    @REM win11关闭二级菜单
    reg add "HKEY_CURRENT_USER\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /v /f /ve
goto:eof



:common_optimize
    @REM 桌面显示此电脑图标
    reg add HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel /v {20D04FE0-3AEA-1069-A2D8-08002B30309D}      /t REG_DWORD /d 0 /f
    @REM 显示已知扩展名
    reg add HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced                       /v HideFileExt                                 /t REG_DWORD /d 0 /f
goto:eof


:remove_app
powershell -ExecutionPolicy Unrestricted -Command "& { Get-AppxPackage *OneNote* | Remove-AppxPackage }"
powershell -ExecutionPolicy Unrestricted -Command "& { Get-AppxPackage *3d* | Remove-AppxPackage }"
powershell -ExecutionPolicy Unrestricted -Command "& { Get-AppxPackage *communi* | Remove-AppxPackage }"
powershell -ExecutionPolicy Unrestricted -Command "& { Get-AppxPackage *Clipchamp* | Remove-AppxPackage }"
powershell -ExecutionPolicy Unrestricted -Command "& { Get-AppxPackage *ZuneMusic* | Remove-AppxPackage }"
powershell -ExecutionPolicy Unrestricted -Command "& { Get-AppxPackage *bing* | Remove-AppxPackage }"
@REM powershell -ExecutionPolicy Unrestricted -Command "& { Get-AppxPackage *people* | Remove-AppxPackage }"
powershell -ExecutionPolicy Unrestricted -Command "& { Get-AppxPackage *phone* | Remove-AppxPackage }"
powershell -ExecutionPolicy Unrestricted -Command "& { Get-AppxPackage *solit* | Remove-AppxPackage }"
powershell -ExecutionPolicy Unrestricted -Command "& { Get-AppxPackage *Sticky* | Remove-AppxPackage }"
powershell -ExecutionPolicy Unrestricted -Command "& { Get-AppxPackage *Feedback* | Remove-AppxPackage }"
powershell -ExecutionPolicy Unrestricted -Command "& { Get-AppxPackage *Todos* | Remove-AppxPackage }"
powershell -ExecutionPolicy Unrestricted -Command "& { Get-AppxPackage *Alarms* | Remove-AppxPackage }"
powershell -ExecutionPolicy Unrestricted -Command "& { Get-AppxPackage *GetHelp* | Remove-AppxPackage }"
powershell -ExecutionPolicy Unrestricted -Command "& { Get-AppxPackage *WindowsMaps* | Remove-AppxPackage }"
powershell -ExecutionPolicy Unrestricted -Command "& { Get-AppxPackage *Getstarted* | Remove-AppxPackage }"
powershell -ExecutionPolicy Unrestricted -Command "& { Get-AppxPackage *OfficeHub* | Remove-AppxPackage }"
powershell -ExecutionPolicy Unrestricted -Command "& { Get-AppxPackage *GamingApp* | Remove-AppxPackage }"
powershell -ExecutionPolicy Unrestricted -Command "& { Get-AppxPackage *549981C3F5F10* | Remove-AppxPackage }"
powershell -ExecutionPolicy Unrestricted -Command "& { Get-AppxPackage *SkypeApp* | Remove-AppxPackage }"
powershell -ExecutionPolicy Unrestricted -Command "& { Get-AppxPackage *MixedReality* | Remove-AppxPackage }"
powershell -ExecutionPolicy Unrestricted -Command "& { Get-AppxPackage *MSPaint* | Remove-AppxPackage }"

@REM powershell -ExecutionPolicy Unrestricted -Command "& { Get-AppXProvisionedPackage -online | Remove-AppxProvisionedPackage -online }"
set onedrivePath=
for /f "tokens=*" %%i in ('dir %localappdata%\Microsoft\OneDrive\ /AD /B') do (
    if exist "%localappdata%\Microsoft\OneDrive\%%i\OneDriveSetup.exe" (
        set onedrivePath="%localappdata%\Microsoft\OneDrive\%%i\OneDriveSetup.exe"
    )
)
if "%onedrivePath%" NEQ "" (
    %onedrivePath% /uninstall
    timeout /T 3 /NOBREAK
    taskkill /f /im OneDrive.exe
    taskkill /f /im explorer.exe
    del /Q "%localappdata%\Microsoft\OneDrive\"
    start explorer.exe
)       

goto:eof


:main
taskkill /f /im explorer.exe
if "%OSVER%"=="win10" (
    echo win 10
    call :win10_optimize
)
if "%OSVER%"=="win11" (
    echo win 11
    call :win11_optimize
)
call :common_optimize
start explorer.exe
call :remove_app
start explorer.exe
pause 
goto:eof
