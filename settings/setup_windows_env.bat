set TOOLS_PATH=C:\tools
set GOROOT_VARIABLE=%TOOLS_PATH%\go
REM setx PATH "%TOOLS_PATH%\cygwin64\bin;%PATH%;C:\Windows\Microsoft.NET\Framework\v4.0.30319;" /m
setx GOROOT=%GOROOT_VARIABLE%
setx PATH "%TOOLS_PATH%\apps;%TOOLS_PATH%\Python27;%TOOLS_PATH%\Debuggers\x64;%TOOLS_PATH%\nmap;%TOOLS_PATH%\GnuPG;%TOOLS_PATH%\graphviz\bin;%TOOLS_PATH%\java_sdk\bin;%TOOLS_PATH%\LLVM\bin;%TOOLS_PATH%\pandoc;%TOOLS_PATH%\Sysinternals;%TOOLS_PATH%\;%TOOLS_PATH%\texlive\bin\win32;%GOROOT_VARIABLE%\bin;"
REM md %TOOLS_PATH%
REM xcopy C:\src\windows_tools\vim c:\tools\vim\ /O /E /Y
REM reg import windbg_context_menu.reg
