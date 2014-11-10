@ECHO OFF

REM Configure your favorite diff program here.
SET DIFF="d:\vim\gvimdiff.bat"
SET DIFF="d:\winmerge\winmergeu.exe"

REM Subversion provides the paths we need as the sixth and seventh parameters.
SET LEFT=%7
SET RIGHT=%6
SET LEFTVERSION=%5
SET RIGHTVERSION=%3
SET OPTION=/B /e /u /maximize /dl %LEFTVERSION% /dr %RIGHTVERSION% 
ECHO %3

REM Call the diff command (change the following line to make sense for your merge program).
%DIFF% %LEFT% %RIGHT% %OPTION%

REM Return an errorcode of 0 if no differences were detected, 1 if some were.
REM Any other errorcode will be treated as fatal.
