set TOOLS_PATH=D:\tools
set PROJECT_PATH=D:\projects
set GOROOT_VARIABLE=%TOOLS_PATH%\go
set GOPATH_VARIABLE=%PROJECT_PATH%\go
REM setx GOPATH %GOPATH_VARIABLE%
REM setx GOBIN %GOPATH_VARIABLE%\bin
REM setx GOROOT %GOROOT_VARIABLE%
REM setx JAVA_HOME %TOOLS_PATH%\jdk-11.0.2

REM set PATHVAL=%PATH%
set PATHVAL=%TOOLS_PATH%\apps
set PATHVAL=%PATHVAL%;%TOOLS_PATH%\Python27;%TOOLS_PATH%\Python27\scripts
set PATHVAL=%PATHVAL%;%TOOLS_PATH%\windbg\x64
set PATHVAL=%PATHVAL%;%TOOLS_PATH%\nmap
set PATHVAL=%PATHVAL%;%JAVA_HOME%\bin
set PATHVAL=%PATHVAL%;%TOOLS_PATH%\LLVM\bin
set PATHVAL=%PATHVAL%;%TOOLS_PATH%\wireshark\App\Wireshark
set PATHVAL=%PATHVAL%;%TOOLS_PATH%\sysinternals
set PATHVAL=%PATHVAL%;%GOROOT_VARIABLE%\bin;%GOBIN%"
set PATHVAL=%PATHVAL%;%TOOLS_PATH%\Android_Sdk\tools;%TOOLS_PATH%\Android_Sdk\platform-tools;%TOOLS_PATH%\Android_Sdk\cmdline-tools\latest\bin;%TOOLS_PATH%\android_sdk\ndk\25.2.9519653
set PATHVAL=%PATHVAL%;%TOOLS_PATH%\Git\cmd
set PATHVAL=%PATHVAL%;%TOOLS_PATH%\Vim\vim90
set PATHVAL=%PATHVAL%;%TOOLS_PATH%\cmake\bin
set PATHVAL=%PATHVAL%;%TOOLS_PATH%\doxygen\bin
set PATHVAL=%PATHVAL%;%TOOLS_PATH%\putty
set PATHVAL=%PATHVAL%;%TOOLS_PATH%\nodejs
set PATHVAL=%PATHVAL%;%TOOLS_PATH%\ditto
set PATHVAL=%PATHVAL%;%TOOLS_PATH%\ffmpeg\bin
set PATHVAL=%PATHVAL%;%TOOLS_PATH%\flutter\bin
set PATHVAL=%PATHVAL%;%TOOLS_PATH%\everything
set PATHVAL=%PATHVAL%;%USERPROFILE%\AppData\Local\Programs\Python\Python311\Scripts;%USERPROFILE%\AppData\Local\Programs\Python\Python311
set PATHVAL=%PATHVAL%;%USERPROFILE%\AppData\Local\Microsoft\Windows\Apps
set PATHVAL=%PATHVAL%;%USERPROFILE%\AppData\Local\Programs\Microsoft VS Code
set PATHVAL=%PATHVAL%;%USERPROFILE%\AppData\Roaming\nmp
echo %PATHVAL%
setx PATH %PATHVAL%
REM md %TOOLS_PATH%
REM xcopy C:\src\windows_tools\vim c:\tools\vim\ /O /E /Y
REM reg import windbg_context_menu.reg
