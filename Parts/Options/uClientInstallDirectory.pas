//////////////////////////////////////////////////////////////////////////////
//
// ������ �������� ��������� GetInstallDirectory.
//
//////////////////////////////////////////////////////////////////////////////

unit uClientInstallDirectory;

interface

    //����� � ���. ���������� ������
    function InstallDirectory: String;


implementation
uses
  SysUtils,
  Forms,
  uClientOptionsConst,
  Windows,
  Registry,
  uY2KCommon;

var
  GstrInstallDirectory: String;


function GetInstallDirectory: String;
var
  Reg: TRegIniFile;
  FstrKey: String;
  AstrValue: String;
begin
  Result := '';
  FstrKey := '\' + 'Software' + '\' + PRODUCT_NAME;
{$IFOPT D+}
  Result := ExtractFileDir(Application.ExeName);
{$Else}
  Reg := TRegIniFile.Create();
  try
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    Reg.Access := KEY_ALL_ACCESS;
    if Reg.OpenKey(FstrKey, TRUE) then begin
      AstrValue := Reg.ReadString(OPTIONS_GENERAL_FOLDER, 'InstallDirectory',
          ExtractFileDir(Application.ExeName));
      Result := AstrValue;
      Reg.CloseKey();
    end;
  finally
    FreeAndNilWithAssert(Reg);
  end
{$ENDIF}
end;

function InstallDirectory: String;
begin
  Result := GstrInstallDirectory;
end;


initialization
  GstrInstallDirectory := GetInstallDirectory;


end.


