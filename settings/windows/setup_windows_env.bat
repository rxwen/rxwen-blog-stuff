set TOOLS_PATH=C:\tools
set GOROOT_VARIABLE=%TOOLS_PATH%\go
set GOPATH_VARIABLE=%USERPROFILE%\projects\go
@REM setx PATH "%TOOLS_PATH%\vim\vim74;%TOOLS_PATH%\cygwin64\bin;%PATH%;C:\Windows\Microsoft.NET\Framework\v4.0.30319;" /M
setx GOPATH %GOPATH_VARIABLE%
setx GOBIN %GOPATH_VARIABLE%\bin
setx GOROOT %GOROOT_VARIABLE%
setx JAVA_HOME %TOOLS_PATH%\java_sdk\jdk1.8
setx JAVA7_HOME %TOOLS_PATH%\java_sdk\jdk1.7
setx JAVA8_HOME %TOOLS_PATH%\java_sdk\jdk1.8
setx PATH "%TOOLS_PATH%\apps;%TOOLS_PATH%\Python27;%TOOLS_PATH%\Python27\scripts;%TOOLS_PATH%\Debuggers\x64;%TOOLS_PATH%\nmap;%TOOLS_PATH%\GnuPG;%TOOLS_PATH%\graphviz\bin;%JAVA_HOME%\bin;%TOOLS_PATH%\LLVM\bin;%TOOLS_PATH%\wireshark;%TOOLS_PATH%\pandoc;%TOOLS_PATH%\Sysinternals;%TOOLS_PATH%\Mercurial;%TOOLS_PATH%\gradle\bin;%TOOLS_PATH%\texlive\bin\win32;%TOOLS_PATH%\ruby\bin;%GOROOT_VARIABLE%\bin;%GOBIN%";%TOOLS_PATH%\android_sdk\tools;%TOOLS_PATH%\android_sdk\platform-tools;%TOOLS_PATH%\android_sdk\ndk;%TOOLS_PATH%\Git\cmd;%TOOLS_PATH%\cmake\bin\;%TOOLS_PATH%\doxygen\bin;%TOOLS_PATH%\putty\;%TOOLS_PATH%\ffmpeg\bin\;
REM md %TOOLS_PATH%
REM xcopy C:\src\windows_tools\vim c:\tools\vim\ /O /E /Y
REM reg import windbg_context_menu.reg
