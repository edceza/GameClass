rem @echo off
rem -------------------- ��砫� 蠯�� ------------------------------------
rem ��室 � ��୥��� ��४��� �஥�
for /l %%i in (1,1,8) do if not exist rootdir cd ..
rem ��砫�� ࠡ�稩 ��⠫�� ��� ��� ������� 䠩��� - ��୥��� 
rem ��४��� �஥�� (Current\ ��� 3.XX\)
rem ����������� � ���� ���᪠ Install\Src\Batch
if not -%GCMakePath%==- goto PathAlreadySet
for /d %%i in (Install\Src\Batch\) do set GCMakePath=%%~dpi
set Path=%GCMakePath%;%Path%
:PathAlreadySet
rem -------------------- ����� 蠯�� ------------------------------------

echo ������������� release-���ᨨ:

set DelphiPath=c:\Program Files\Embarcadero\RAD Studio\11.0
rem set DCCLib="%DelphiPath%\Lib\win32\release";"%DelphiPath%\Imports";"%DelphiPath%\include";"C:\Program Files\FastReports\LibD18";"C:\Program Files\Raize\CS5\Lib\RS-XE4\Win32";"C:\Program Files\Embarcadero\RAD Studio\11.0\Components\EhLib\Lib\Win32\Release";"C:\Project\Imports\y2kControls\Current\Product\Src\dcu";"C:\Project\Imports\Win32API";"c:\Project\Imports\Rxlib\units\";"C:\Project\Imports\ExtControll";"C:\Project\Imports\y2kControls\Current\Product\Src";"c:\Project\Imports\VirtualTreeView\Source\";"c:\Project\Imports\SynEdit\Source\";"c:\Project\Imports\FastMM\";"c:\Project\Imports\dcef3-4888ed525e22\packages\";"c:\Program Files\madCollection\madBasic\BDS11\win32\";"c:\Project\Imports\dcef3-4888ed525e22\packages\Win32\Debug\";"c:\Project\Imports\Win2KTray\";"C:\Program Files\madCollection\madBasic\BDS11\win32";"C:\Program Files\madCollection\madDisAsm\BDS11\win32";"C:\Program Files\madCollection\madExcept\BDS11\win32";"C:\Program Files\madCollection\madExcept\..\Plugins\win32";"C:\Program Files\madCollection\madKernel\BDS11\win32";"C:\Program Files\madCollection\madSecurity\BDS11\win32";"C:\Program Files\madCollection\madShell\BDS11\win32";"c:\Project\Imports\"
set DCCLib="%DelphiPath%\Lib\Debug";"%DelphiPath%\lib\Win32\release";"C:\Users\max\Documents\RAD Studio\11.0\Imports";"%DelphiPath%\Imports";"C:\Users\Public\Documents\RAD Studio\11.0\Dcp";"%DelphiPath%\include";"C:\Program Files\FastReports\LibD18";"C:\Program Files\Raize\CS5\Lib\RS-XE4\Win32";"%DelphiPath%\Components\EhLib\Lib\Win32\Release";C:\Project\Imports\y2kControls\Current\Product\Src\dcu;C:\Project\Imports\Win32API;c:\Project\Imports\Rxlib\units;C:\Project\Imports\ExtControll;C:\Project\Imports\y2kControls\Current\Product\Src;c:\Project\Imports\VirtualTreeView\Source;c:\Project\Imports\SynEdit\Source;c:\Project\Imports\FastMM;c:\Project\Imports\dcef3-4888ed525e22\packages;"c:\Program Files\madCollection\madBasic\BDS11\win32";c:\Project\Imports\dcef3-4888ed525e22\packages\Win32\Debug;c:\Project\Imports\Win2KTray;"C:\Program Files\madCollection\madBasic\BDS11\win32";"C:\Program Files\madCollection\madDisAsm\BDS11\win32";"C:\Program Files\madCollection\madExcept\BDS11\win32";"C:\Program Files\madCollection\madExcept\..\Plugins\win32";"C:\Program Files\madCollection\madKernel\BDS11\win32";"C:\Program Files\madCollection\madSecurity\BDS11\win32";"C:\Program Files\madCollection\madShell\BDS11\win32";c:\Project\Imports

rem set DCCLib="%DelphiPath%\Lib;%DelphiPath%\Bin;%DelphiPath%\Imports;%DelphiPath%\Projects\Bpl;%DelphiPath%\Rave5\Lib;C:\Projects\Imports\Delphi7\EhLibRus\Common;C:\Projects\Imports\Delphi7\EhLibRus\DataService;C:\Projects\Imports\Delphi7\RxLibrary 2.75 d7\Units;C:\Projects\Imports\Delphi7\synedit\Packages;C:\Projects\Imports\Delphi7\Win2KTray;C:\Projects\Imports\Delphi7\y2kControls\Current\Product\Src\dcu;C:\Projects\Imports\Delphi7\synedit\Source;C:\Projects\Imports\Win32API;C:\Projects\Imports\Delphi7\ASP;C:\Projects\Imports\IE;C:\Projects\Imports\Delphi7\y2kControls\Current\Product\Src;C:\Projects\Imports\Delphi7;C:\Program Files\Balmsoft Polyglot\Delphi 7\Lib;C:\Projects\Imports;C:\Projects\Imports\Virtual Treeview\Source;C:\Projects\Imports\Delphi7\DBImage;c:\Projects\webkitdelphi\src"
set DCCLogs=Install\Src\Logs
set DCCOutput=Output\Release
set DCCDcu=Output\Dcu\Release
set DCC32="%DelphiPath%\bin\dcc32.exe"

rem ����塞 exe � dcu
del %DCCOutput%\*.* /q 2>nul
del %DCCDcu%\*.* /q 2>nul
rem ���樠������ ��ࠡ�⪨ ���-䠩��
del %DCCLogs%\ErrorCheck.txt 2>nul
Set error_check=

rem ���������
set DCCFlags=GC3SERVER,ASPROTECT
set DCCProjectPath=Server
set DCCProjectName=GCServer.dpr
set DCCReturnPath=..
call Install\Src\Batch\compile_project

set DCCFlags=GCCL,ASPROTECT
set DCCProjectPath=Client
set DCCProjectName=gccl
call Install\Src\Batch\compile_project.bat

set DCCFlags=GCCLSRV,ASPROTECT
set DCCProjectPath=ClientService
set DCCProjectName=gcclsrv
call Install\Src\Batch\compile_project.bat

set DCCFlags=ASPROTECT
set DCCProjectPath=Security\OSql
set DCCProjectName=GCOsql
set DCCReturnPath=..\..
call Install\Src\Batch\compile_project.bat

set DCCFlags=ASPROTECT
set DCCProjectPath=Parts\winhkg
set DCCProjectName=winhkg
set DCCReturnPath=..\..
call Install\Src\Batch\compile_project.bat

set DCCFlags=ASPROTECT
set DCCProjectPath=BackupRestore
set DCCProjectName=GCBackupRestore
set DCCReturnPath=..
call Install\Src\Batch\compile_project.bat

set DCCFlags=ASPROTECT
set DCCProjectPath=Parts\ProcessSupervisor
set DCCProjectName=ProcUtils
set DCCReturnPath=..\..
call Install\Src\Batch\compile_project.bat
rem �� ��������� ���㫥�

for /f %%i in (%DCCLogs%\ErrorCheck.txt) DO @SET error_check=%%i
if "%error_check%"=="" goto no_error
echo �訡�� �������樨 !
pause
more %DCCLogs%\ErrorCheck.txt
pause
exit
:no_error
echo ��������� �����襭� �ᯥ譮.
del %DCCLogs%\ErrorCheck.txt >nul
