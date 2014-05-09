@ECHO off
SETLOCAL ENABLEEXTENSIONS
REM modify hosts access rights current user can change the file contents

call :hostfileperms _perms
echo Permissins on hosts for user %USERNAME%: %_perms%

If "%_perms%" == "F"    goto :PERM_OK
If "%_perms%" == "M"    goto :PERM_OK
If "%_perms%" == "RX,W" goto :PERM_OK
If "%_perms%" == "R,W"  goto :PERM_OK
If "%_perms%" == "W"    goto :PERM_OK

If "%_perms%" == ":"    goto :PERM_INSUFFICIENT
If "%_perms%" == "R"    goto :PERM_INSUFFICIENT
If "%_perms%" == "RX"   goto :PERM_INSUFFICIENT

echo Unhandled "%_perms%", raising.
goto :PERM_INSUFFICIENT

:PERM_INSUFFICIENT
echo|set /p=Raising permissions...
call win-hosts-set.cmd
echo|set /p=done.
call :hostfileperms _perms_new
echo  New permissins are: %_perms_new%
IF "%_perms%" == "%_perms_new%" (
    echo Changing permissions failed. Exiting.
    exit /b 1
)

:PERM_OK
echo Suffice. Exiting.
goto :EOF

:hostfileperms
setlocal
set _icacls_cmd=Icacls %SystemRoot%\system32\drivers\etc\hosts /T
FOR /f "tokens=2" %%G IN ('%_icacls_cmd% ^|find "%USERNAME%"') DO set _permission_info=%%G
set "_permission_perms=%_permission_info:*:=%"
set _permission=%_permission_perms:~1,-1%

( endlocal
  set "%1=%_permission%"
)
exit /b
