//////////////////////////////////////////////////////////////////////////////
//
// ����� �������� �� ����������.
//
// ���� �������� ������� ���������� � ������ ���������,
// �� ���� ������� ����������� ������.
//
//////////////////////////////////////////////////////////////////////////////

unit uProcessSupervisor;

interface

uses
  // system units
  Windows,
  Classes,
  // project units
  uProcessesDescriptions,
  uY2KRunAs;


type

  //
  // TProcessSupervisor
  //

  TProcessSupervisor = class(TObject)
  private
    // fields
    FhSupervisorThread: THandle;
    FProcessesDescriptions: TProcessesDescriptions;
    FCurrentProcess: TProcessesDescriptions;
    FbRescanProcess: Boolean;

    // threads methods
    procedure _DoSupervision();

    // private helper methods
    procedure _CheckAndRunProcesses();
    procedure _ExecuteApp(const AstrExeFile: String);
    function _IsProcessFound(const AstrProcessName: string): boolean;
    function _GetProcessHandle(const AstrProcessName: String): THandle;
    function _GetThreadId(const AdwProcessId: DWORD): DWORD;
    procedure _ProcessReport(const AbRescanProcess: Boolean;
        var AlstRunnedProcess: TStringList;
        var AlstTerminatedProcess: TStringList);
    procedure _SendReport;

  public
    // constructor / destructor
    constructor Create();
    destructor Destroy(); override;

    // public methods
    procedure StartSupervision();
    procedure StopSupervision();

    procedure AddProcessInfo(
        const AstrName: string; const AstrExeFile: string);
    procedure RemoveProcessInfo(const AstrName: string);
    procedure ClearProcessInfo();
    procedure NeedRescanProcess;

  end; // TProcessSupervisor

  // ����� ������
  function KillTask(const AstrTaskList: String;
      const AbExclude: Boolean = False): Boolean;

  // �������� ������ �����
  function GetTasksList(): string; overload;

  // �������� ������ �����, �� ������� ������ �� ������ AExclusions
  function GetTasksList(const AExclusions: array of string): string; overload;

  function CheckExecutedProcess(AstrProcessName:string):boolean;

implementation

uses
  // system units
  SysUtils,
  StrUtils,
  ShellApi,
  Tlhelp32,
  Dialogs,
  // project units
  uDebugLog,
  uClientOptions,
  uClientOptionsConst,
  uAnswerRemoteCommand,
  usrvGCCL,
  uProtocol,
  uClientInfo,
  uProcUtils,
  System.UITypes;


const
  TIMEOUT_DEF = 120000; // ����� � ������ ���������


// ����� ������������ ��� ���������� ����� �������� �������
// ��. �������� API-������� QueueUserAPC
procedure ExitThreadAPC(AdwParam: DWORD); stdcall;
begin
//
end; // ExitThreadAPC


// �� ���� ��� ������ ���� ����� ������, �� ��� ������� ���������
// ����� ������ � ��������� ������ ���������� ���������
// � �������� � ���������� �������� ��� �������� ���������
function DoSupervision(Ap: TProcessSupervisor): DWORD;
begin
  Ap._DoSupervision();
  Result := 0;
end; // DoPrintersNotifies


//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
// TProcessSupervisor

//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
// constructor / destructor

constructor TProcessSupervisor.Create();
begin
  inherited Create();

  FhSupervisorThread := 0;
  FProcessesDescriptions := TProcessesDescriptions.Create();
  FCurrentProcess := TProcessesDescriptions.Create();

end; // TProcessSupervisor.Create


destructor TProcessSupervisor.Destroy();
begin
  FreeAndNil(FProcessesDescriptions);
  FreeAndNil(FCurrentProcess);
  inherited Destroy();
end; // TProcessSupervisor.Destroy


//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
// public methods

procedure TProcessSupervisor.StartSupervision();
var
  nThreadId: cardinal;
begin
  ASSERT(Assigned(FProcessesDescriptions));

  FhSupervisorThread := BeginThread(
      nil, 0, @DoSupervision, Pointer(Self), 0, nThreadId);
  ASSERT(FhSupervisorThread <> INVALID_HANDLE_VALUE);

end; // TProcessSupervisor.StartThreads


procedure TProcessSupervisor.StopSupervision();
begin
  ASSERT(Assigned(FProcessesDescriptions));
  try
    if (FhSupervisorThread <> INVALID_HANDLE_VALUE)
        and (FhSupervisorThread <> 0) then begin
      QueueUserAPC(@ExitThreadAPC, FhSupervisorThread, 0);
      Debug.Trace0('wait...');
      WaitForSingleObject(FhSupervisorThread, INFINITE);
      Debug.Trace0('wait complete!');
      CloseHandle(FhSupervisorThread);
    end;
  finally

  end;
end; // TProcessSupervisor.StopThreads


procedure TProcessSupervisor.AddProcessInfo(
    const AstrName: string; const AstrExeFile: string);
var
  nFoundIndex: integer;
begin
  ASSERT(Assigned(FProcessesDescriptions));

  nFoundIndex := FProcessesDescriptions.FindByName(AstrName);
  if nFoundIndex = PROCESS_DESCRIPTION_NOT_FOUND then begin
    with FProcessesDescriptions.Add() do begin
      Name := AstrName;
      ExeFile := AstrExeFile;
    end;
  end;

end; // TProcessSupervisor.AddProcessInfo


procedure TProcessSupervisor.RemoveProcessInfo(const AstrName: string);
var
  nFoundIndex: integer;
begin
  ASSERT(Assigned(FProcessesDescriptions));

  nFoundIndex := FProcessesDescriptions.FindByName(AstrName);
  if nFoundIndex <> PROCESS_DESCRIPTION_NOT_FOUND then begin
    FProcessesDescriptions.Delete(nFoundIndex);
  end;

end; // TProcessSupervisor.RemoveProcessInfo


procedure TProcessSupervisor.ClearProcessInfo();
begin
  ASSERT(Assigned(FProcessesDescriptions));

  FProcessesDescriptions.Clear();

end; // TProcessSupervisor.ClearProcessInfo


//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
// threads methods

procedure TProcessSupervisor._DoSupervision();
var
  dwWaitStatus: DWORD;
begin
  while(TRUE) do begin
    dwWaitStatus := SleepEx(TIMEOUT_DEF, TRUE);

    if (WAIT_IO_COMPLETION = dwWaitStatus) then begin
      break;
    end;
    _CheckAndRunProcesses();
    _SendReport;
  end;
end; // TProcessSupervisor._DoSupervision


//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
// private helper methods

procedure TProcessSupervisor._CheckAndRunProcesses();
var
  bIsProcessFound: Boolean;
  i: Integer;
begin
  for i := 0 to FProcessesDescriptions.Count - 1 do begin
    bIsProcessFound := _IsProcessFound(FProcessesDescriptions[i].Name);
//    GClientInfo.GCCLNotStarted := not bIsProcessFound;                // ����������� ��� �������� ����!!!
    if not bIsProcessFound then begin
      if FileExists(FProcessesDescriptions[i].ExeFile) then begin
        _ExecuteApp(FProcessesDescriptions[i].ExeFile);
      end;
    end;
  end;
end; // TProcessSupervisor._CheckAndRunProcesses

//�������� ����� ���� � �������� ���������� � ���� �������
procedure TProcessSupervisor._ExecuteApp(const AstrExeFile: String);
var
  hProcess: THandle;
  hToken: THandle;
  hNewToken: THandle;
begin
  hProcess := _GetProcessHandle(IfThen(
      (GClientOptions.ShellMode = ShellMode_Unknown), 'explorer.exe',
      'rshell.exe'));
  if hProcess = 0 then exit;
  if hProcess <> 0 then begin
    if OpenProcessToken(hProcess,
        TOKEN_QUERY or TOKEN_DUPLICATE or TOKEN_IMPERSONATE,
        hToken) then begin
      if DuplicateTokenEx(hToken, MAXIMUM_ALLOWED, nil,
          SecurityImpersonation, TokenPrimary, hNewToken) then begin
        if hToken <> INVALID_HANDLE_VALUE then begin
          if 0 <> StartInteractiveClientProcess(hNewToken, AstrExeFile, TRUE) then begin
            MessageDlg('StartInteractiveClientProcess error: ' + IntToStr(GetLastError()), mtError, [mbOK], 0);
          end;
          CloseHandle(hToken);
        end;
      end else begin
        MessageDlg('DuplicateToken error:' + IntToStr(GetLastError()), mtError, [mbOK], 0);
      end;
    end;
  end;

end; // TProcessSupervisor._ExecuteApp



function TProcessSupervisor._GetThreadId(
    const AdwProcessId: DWORD): DWORD;
const
  DESKTOP_DESIRED_ACCESS = READ_CONTROL
      or WRITE_DAC
      or DESKTOP_WRITEOBJECTS
      or DESKTOP_READOBJECTS;
var
  ThreadEntry32: TThreadEntry32;
  hSnapshot: THandle;
  bIsThreadPresent: Boolean;
begin
  Result := 0;
 { TODO : ����������� ��� ���� ��� }
{  hSnapshot := CreateToolhelp32Snapshot(TH32CS_SNAPTHREAD, 0);
  if hSnapshot = INVALID_HANDLE_VALUE then begin
    Exit;
  end;
}
  ThreadEntry32.dwSize := sizeof(ThreadEntry32);

  bIsThreadPresent := Thread32First(hSnapshot, ThreadEntry32);
  while bIsThreadPresent do begin

    if ThreadEntry32.th32OwnerProcessID = AdwProcessId then begin
      Result := ThreadEntry32.th32ThreadID;
    end;

    bIsThreadPresent := Thread32Next(hSnapshot, ThreadEntry32);
  end; // while

  CloseHandle(hSnapshot);

end; // TProcessSupervisor._GetThreadId

procedure TProcessSupervisor._SendReport;
var
  lstRunnedProcess: TStringList;
  lstTerminatedProcess: TStringList;
  cmd: TAnswerRemoteCommand;
begin
  lstRunnedProcess := TStringList.Create;
  lstTerminatedProcess := TStringList.Create;
  _ProcessReport(FbRescanProcess, lstRunnedProcess, lstTerminatedProcess);
  if (lstRunnedProcess.Count > 0) or (lstTerminatedProcess.Count > 0) then begin
    if (Length(srvGCCL.ServerHost) > 0) then begin
      cmd := TAnswerRemoteCommand.Create(srvGCCL.ServerHost);
      cmd.SendData := STR_CMD_RET_PROCESSLIST + '=' + BoolToStr(FbRescanProcess)
          + '/' + lstRunnedProcess.Text
          + '/' + lstTerminatedProcess.Text;
      cmd.Execute;
      cmd.Free;
      FbRescanProcess := False;
    end;
  end;
  lstRunnedProcess.Free;
  lstTerminatedProcess.Free;
end;

procedure TProcessSupervisor.NeedRescanProcess;
begin
  FbRescanProcess := True;
end;

function TProcessSupervisor._GetProcessHandle(
    const AstrProcessName: String): THandle;
begin
  Result := GProcUtils.GetProcessHandle(AstrProcessName);
end; // TProcessSupervisor._GetProcessHandle

function TProcessSupervisor._IsProcessFound(
    const AstrProcessName: String): Boolean;
{var
  strExplorerProcessName: String;}
begin
{  strExplorerProcessName := IfThen(
      (GClientOptions.ShellMode = ShellMode_Unknown), 'explorer.exe',
      'rshell.exe');
  Result := GProcUtils.IsProcessFound(AstrProcessName, strExplorerProcessName);}
  Result := CheckExecutedProcess(AstrProcessName);
end; // TProcessSupervisor._IsProcessFound

procedure TProcessSupervisor._ProcessReport(const AbRescanProcess: Boolean;
    var AlstRunnedProcess: TStringList;
    var AlstTerminatedProcess: TStringList);
begin
  GProcUtils.ProcessReport(AbRescanProcess, AlstRunnedProcess,
      AlstTerminatedProcess);
end; // TProcessSupervisor._ProcessReport

// ����� ������
function KillTask(const AstrTaskList: String;
    const AbExclude: Boolean = False): Boolean;
begin
  Result := GProcUtils.KillTask(AstrTaskList, AbExclude);
end; // KillTask


function GetTasksList(): string;
begin
  Result := GetTasksList([]);
end; // GetTasksList


function GetTasksList(const AExclusions: array of string): string;
begin
  Result := GProcUtils.GetTasksList(AExclusions);
end; // GetTasksList

function CheckExecutedProcess(AstrProcessName:string):boolean;
{var
  strExplorerProcessName: String;
begin
  strExplorerProcessName := IfThen(
      (GClientOptions.ShellMode = ShellMode_Unknown), 'explorer.exe',
      'rshell.exe');
  Result := GProcUtils.IsProcessFound(AstrProcessName, strExplorerProcessName);
end;}
var
  han: THandle;
  ProcStruct: PROCESSENTRY32; // from "tlhelp32" in uses clause
  sID: string;
begin
  Result := false;
  // Get a snapshot of the system
  han := CreateToolhelp32Snapshot(TH32CS_SNAPALL, 0);
  if han = 0 then
    exit;
  // Loop thru the processes until we find it or hit the end
  ProcStruct.dwSize := sizeof(PROCESSENTRY32);
  if Process32First(han, ProcStruct) then
  begin
    repeat
      sID := ExtractFileName(ProcStruct.szExeFile);
      // Check only against the portion of the name supplied, ignoring case
      if uppercase(copy(sId, 1, length(AstrProcessName))) = uppercase(AstrProcessName) then
      begin
        // Report we found it
        Result := true;
        Break;
      end;
    until not Process32Next(han, ProcStruct);
  end;
  // clean-up
  CloseHandle(han);
end;


end.
