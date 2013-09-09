//////////////////////////////////////////////////////////////////////////////
//
// TLocalCommandReceiver - �����, ����������� �������
// �� ������������ ����������, ����������� �� ��������� ����������.
//
//////////////////////////////////////////////////////////////////////////////

unit uLocalCommandReceiver;

interface

uses
  // system units
  Classes,
  IdSocketHandle,
  IdBaseComponent,
  IdComponent,
  IdContext,
  IdCustomTCPServer,
  IdTCPServer,
  IdSync,
  IdGlobal;




type

  // messages types
  TLocalDataReceivedProc = procedure (const AstrData: string) of object;


  //
  // TLocalCommandReceiver
  //

  TLocalCommandReceiver = class(TObject)
  private
    // fields
    FTCPServer: TIdTCPServer;
    FOnDataReceived: TLocalDataReceivedProc;

    // events handlers
    procedure _TCPServerRead(AContext: TIdContext);

    // private helper methods
    procedure _SendDataReceiveEvent(const AstrData: string);

  protected
    // properties methods
    // Port
    function GetPort(): integer;
    procedure SetPort(const AnPort: integer);

  public
    // constructor / destructor
    constructor Create();
    destructor Destroy(); override;

    // public methods
    procedure StartReceiveProcess();
    procedure StopReceiveProcess();

    // properties
    property OnDataReceived: TLocalDataReceivedProc
        read FOnDataReceived write FOnDataReceived;
    property Port: integer read GetPort write SetPort;

  end; // TLocalCommandReceiver

const
  DEF_PORT_FOR_TCPSERVER = 3776;

implementation

uses
  // system units
  SysUtils,
//  Dialogs,
  // project units
  uDebugLog,
{$IFDEF MSWINDOWS}
  uProtocolTcp,
{$ENDIF}
  uY2KCommon;




//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
// constructor / destructor

constructor TLocalCommandReceiver.Create();
begin
  inherited Create();
  FTCPServer := TIdTCPServer.Create(nil);
  FTCPServer.DefaultPort := DEF_PORT_FOR_TCPSERVER;
  FTCPServer.OnExecute := _TCPServerRead;
end; // TLocalCommandReceiver.Create


destructor TLocalCommandReceiver.Destroy();
begin
  FreeAndNilWithAssert(FTCPServer);
  inherited Destroy();
end; // TLocalCommandReceiver.Destroy


//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
// public methods

procedure TLocalCommandReceiver.StartReceiveProcess();
begin
  try
    FTCPServer.Active := TRUE;
  except
    on e: Exception do begin
      Debug.Trace0(
          'LocalCommandReceiver.StartReceiveProcess error! ' + e.Message);
    end;
  end;
end; // TLocalCommandReceiver.StartReceiveProcess


procedure TLocalCommandReceiver.StopReceiveProcess();
begin
  try
    FTCPServer.Active := FALSE;
  except
    on e: Exception do begin
      Debug.Trace0(
          'LocalCommandReceiver.StopReceiveProcess error!' + e.Message);
    end;
  end;
end; // TLocalCommandReceiver.StopReceiveProcess


//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
// events handlers
{$IFDEF MSWINDOWS}
procedure TLocalCommandReceiver._TCPServerRead(AContext: TIdContext);
var
{  strTest: string;
  strLine: string; }
{  nLength: integer;}
  CommBlock: TCommandPakage;
begin
  try
    try
//        strTest := ReadString(4);
//        if strTest = 'sYNc' then
        begin
        CommBlock.Command:='';
        CommBlock.Command := AContext.Connection.IOHandler.ReadLn;
{          nLength := ReadInteger();
          strLine := ReadString(nLength);
          strTest := ReadString(2);}
        end
    except
        AContext.Connection.Disconnect();
//      finally
//        Disconnect();
    end;

//    _SendDataReceiveEvent(strLine);
      _SendDataReceiveEvent(CommBlock.Command);
  except
    on e: Exception do begin
      Debug.Trace0('_TCPServerRead error! ' + e.Message);
    end;
  end;

end; // TLocalCommandReceiver._TCPServerRead
{$ENDIF}
{$IFDEF LINUX}
procedure TLocalCommandReceiver._TCPServerRead(AThread: TIdPeerThread);
var
  strTest: string;
  strLine: string;
  nLength: integer;
//  CommBlock: TCommandPakage;
begin
  try
    with AThread.Connection do
      try
        strTest := ReadString(4);
        if strTest = 'sYNc' then
        begin
          nLength := ReadInteger();
          strLine := ReadString(nLength);
          strTest := ReadString(2);
        end
      finally
        Disconnect();
      end;

    _SendDataReceiveEvent(strLine);

  except
    on e: Exception do begin
      Debug.Trace0('_TCPServerRead error! ' + e.Message);
    end;
  end;

end; // TLocalCommandReceiver._TCPServerRead
{$ENDIF}

//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
// properties methods

function TLocalCommandReceiver.GetPort(): integer;
begin
  Result := FTCPServer.DefaultPort;
end; // TLocalCommandReceiver.GetPort


procedure TLocalCommandReceiver.SetPort(const AnPort: integer);
var
  IsTCPServerStarted: boolean;
begin
  try
    IsTCPServerStarted := FTCPServer.Active;
    FTCPServer.Active := FALSE;
    FTCPServer.DefaultPort := AnPort;
    FTCPServer.Active := IsTCPServerStarted;
  except
    on e: Exception do begin
      Debug.Trace0('CommandReceiver.SetPort error! ' + e.Message);
    end;
  end;
end; // TLocalCommandReceiver.SetPort


//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
// private helper methods

procedure TLocalCommandReceiver._SendDataReceiveEvent(
    const AstrData: string);
begin
  if Assigned(OnDataReceived) then
    OnDataReceived(AstrData);
end; // TLocalCommandReceiver._SendDataReceiveEvent


end. ////////////////////////// end of file //////////////////////////////////
