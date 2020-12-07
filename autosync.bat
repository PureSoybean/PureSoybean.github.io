@echo off
REM %DATE:~0,10%  2017/07/06
set dd=%DATE:~0,10%
set tt=%time:~0,8%
set hour=%tt:~0,2%
echo =======================================================
echo          Starting automatic git commit push
echo =======================================================
REM change file directory
cd C:\Users\zhan8\OneDrive\github\PureSoybean.github.io\TeXt
REM start git script 
git add . && git commit -m "ScriptBack %dd:/=-% %tt%" &&git push -u origin master

pause