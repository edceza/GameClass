unit uCardReader;

interface

type
  TPCardReader = class
    private
      function GetRuning: boolean;
      procedure OnReadTimer(Sender: TObject);
    public
      PortName:string;
      StopAfterReadCode:Boolean;
      CallBackReadCodeProc: procedure(code:string); stdcall;
      property Runing: boolean read GetRuning;

      constructor Create();
      destructor Destroy; override;
      function Start():boolean; virtual; abstract;//��������� ����������
      function Stop():boolean; virtual; abstract;//��������� ����������

  end;


Procedure LocalCallBackReadCodeProc(code:string);

implementation

Procedure LocalCallBackReadCodeProc(code:string);
begin
end;

{ TCardReader }

constructor TPCardReader.Create;
begin
  CallBackReadCodeProc := @LocalCallBackReadCodeProc;
end;

destructor TPCardReader.Destroy;
begin

  inherited;
end;

function TPCardReader.GetRuning: boolean;
begin
  Result := False
end;

procedure TPCardReader.OnReadTimer(Sender: TObject);
begin

end;



end.
