unit uMail;

interface

uses
  IdGlobal,
  IdSMTP,
  IdMessage,
  IdEMailAddress,
  SysUtils,
  IdCoderMIME;

type
  TSendMail = class
  private
    FSMTP:TIdSMTP;
    FMessage:TIdMessage;
    procedure _AddLog(str:string);
  public
    AddLog:procedure (str:string);
    property SMTP:TIdSMTP
      read FSMTP;
    property MailMessage:TIdMessage
      read FMessage;

    function AddAttachment(FileName:string):boolean;

    function Send:boolean;

    constructor Create;
    destructor Destroy; override;



  end;

function EncodeSubj(instr:string):string;

implementation

{ TSendMail }

function TSendMail.AddAttachment(FileName: string): boolean;
begin
  if FileExists(FileName) then
  begin
    //TIdAttachment.Create(FMessage.MessageParts,FileName);
    Result := True;
  end
  else
    Result := False;
end;

constructor TSendMail.Create;
begin
  FSMTP := TIdSMTP.Create(nil) ;
  FMessage := TIdMessage.Create(nil);
end;

destructor TSendMail.Destroy;
begin
  FMessage.Destroy;
  FSMTP.Destroy;
  inherited;
end;

function TSendMail.Send: boolean;
var
  res:Boolean;
  IdEmailAddressItem: TIdEmailAddressItem;
begin
  res := False;
  FMessage.Subject := EncodeSubj(FMessage.Subject);
  try
    try
      FSMTP.Connect;
      sleep(200);

      IdEmailAddressItem := FMessage.Recipients.Add;

      FSMTP.Send(FMessage);
      _AddLog('������ ����������!');
      res := True;

    except on E:Exception do
    begin
      sleep(200);
      _AddLog('������ ��������: ERROR - '+E.Message);
      _AddLog('������ �� ����������!');
      res := false;
    end;
    end;
  finally
    if FSMTP.Connected then FSMTP.Disconnect;
  end;
  Result := res;
  result:=false;
end;

procedure TSendMail._AddLog(str: string);
begin
 if @AddLog <> nil then
    AddLog(str);
end;

function EncodeSubj(instr:string):string;
var
  IdEncoderMIME: TIdEncoderMIME;
begin
  IdEncoderMIME := TIdEncoderMIME.Create(nil);
  Result := '=?Windows-1251?B?' + IdEncoderMIME.Encode(instr) + '?=';
  IdEncoderMIME.Free;
end;

end.
