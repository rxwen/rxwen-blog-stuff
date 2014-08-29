setx PATH "C:\tools\cygwin64\bin;%PATH%;C:\Windows\Microsoft.NET\Framework\v4.0.30319;" /m
setx PATH "C:\tools\apps"
md c:\tools\
xcopy C:\src\windows_tools\vim c:\tools\vim\ /O /E /Y
reg import windbg_context_menu.reg
