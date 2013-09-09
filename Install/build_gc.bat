@echo off
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

set BASE_VERSION=3.85.7
set APP_VERSION=3.85.7 Alpha
set CLIENT_VERSION=3.85.7
set SQL_SCRIPT_VERSION=3857

rem Install\src\Batch\gc_replace_versions.vbs "%BASE_VERSION%" "%APP_VERSION%"
echo ����ࠥ��� ����� %APP_VERSION%
rem ToDo need compile GameClass.chm

rem ��������� exe-䠩���
call compile_release_gc.bat

rem ���ᡮઠ Russion.lng
echo ���ᡮઠ Russion.lng
copy Docs\Russian.lng Output\Release\
Tools\LngRecoder\LngRecoder.exe Output\Release\Russian.lng Server\GCServer.drc

rem �����⮢�� 䠩��� ��� ᮧ����� ����ਡ�⨢�:
call copy_packages_files.bat

rem ����஢���� sql-䠩��� � sqp
call encode_sql.bat

rem cd Install\Src\INS
rem "c:\Program Files\Inno Setup 5\ISCC.exe" Client.iss
rem "c:\Program Files\Inno Setup 5\ISCC.exe" All.iss
rem cd ..\..\..

rem cd Install\Src\GI
rem "C:\Program Files\Ethalone\Ghost Installer\Bin\GIBuild.exe" gcsetup.gpr
rem cd ..\..\..

cd Install\Src\NSIS
"c:\Program Files\NSIS\makensis.exe" All.nsi

