unit uPercoCardReader;

interface

uses uCardReader, uComPort,ExtCtrls;

type
  TPercoCardReader = class (TPCardReader)
    private
      ComPort: TMyComPort;
      ReadTimer:TTimer;
      procedure OnReadTimer(Sender: TObject);
      function GetRuning():boolean;
    public
      property Runing: boolean
        read GetRuning;
      constructor Create();
      destructor Destroy; override;

      function Start():boolean; override; //��������� ����������
      function Stop():boolean; override;//��������� ����������

  end;

Var
  InitBufer: array [1..7] of byte = ($F2, $FF, $03, $01, $00, $40, $42);  // ��� ������ ���� ���������
  InitByte: byte = $55;                                                   // ��� ������ ���� ���������
  GetCodeBufer: array [1..5] of byte  = ($F2, $FF, $01, $02, $03);

  CardReader:TPCardReader;

implementation

uses SysUtils,Math;

{ TPercoCardReader }

constructor TPercoCardReader.Create;
begin
  inherited;
  ComPort:= TMyComPort.Create;
  ReadTimer:= TTimer.Create(nil);
  ReadTimer.Interval := 100;
  ReadTimer.OnTimer := OnReadTimer;
  ReadTimer.Enabled :=False;

  StopAfterReadCode :=true; //��������������� ����� ��������� ����
  PortName := 'COM1';

  ComPort.com_dcb.BaudRate := 9600;
  ComPort.com_dcb.StopBits := 0;
  ComPort.com_dcb.Parity := 0;
  ComPort.com_dcb.ByteSize := 8;
  ComPort.com_CommTimeouts.ReadTotalTimeoutConstant := 100;
  ComPort.com_CommTimeouts.ReadIntervalTimeout := 0;
  ComPort.com_CommTimeouts.ReadTotalTimeoutMultiplier := 0;
  ComPort.com_CommTimeouts.WriteTotalTimeoutMultiplier := 0;
  ComPort.com_CommTimeouts.WriteTotalTimeoutConstant := 0;

end;

destructor TPercoCardReader.Destroy;
begin
  FreeAndNil(ComPort);
  FreeAndNil(ReadTimer);
  inherited;
end;

function TPercoCardReader.GetRuning: boolean;
begin
  result:= ComPort.PortOpened;
end;

procedure TPercoCardReader.OnReadTimer(Sender: TObject);
var
  ByteArrRx: array [1..11] of byte;
  Code:LongInt;
begin
  if not ComPort.PortOpened then exit;

  ComPort.FlushBuffer;
  ComPort.WriteData( GetCodeBufer,Length(GetCodeBufer));
  Sleep(10);
  ComPort.ReadData(ByteArrRx,5);
  if ByteArrRx[5]=$02 then                                        //��������� ��������� �������������
  begin
    ComPort.FlushBuffer;
    ComPort.WriteData( InitBufer,Length(InitBufer) );
    Sleep(10);
    ComPort.ReadData( ByteArrRx,6);
  end;
  if ByteArrRx[5]=$80 then                                        //�������� ������� ����� ����
  begin
    Sleep(10);
    ComPort.ReadData(ByteArrRx,11);
    Code:= ByteArrRx[3];
    Code:= Code + Trunc(IntPower($100,1))*ByteArrRx[4];
    Code:= Code + Trunc(IntPower($100,2))*ByteArrRx[5];
    Code:= Code + Trunc(IntPower($100,3))*ByteArrRx[6];
    Code:= Code + Trunc(IntPower($100,4))*ByteArrRx[7];
    CallBackReadCodeProc(IntToStr(Code));
    if StopAfterReadCode then
    begin
      Stop;
    end;
  end;
end;

function TPercoCardReader.Start: boolean;
var
  ByteArrRx: array [1..6] of byte;
begin
  result:=false;
  if ComPort.PortOpened then raise Exception.Create('Port is already open');
  if not ComPort.OpenPort(PortName) then raise Exception.Create('Can not open port');
  ComPort.Set_RTS;
  ComPort.WriteData( InitByte,1);
  ComPort.Set_RTS;
  ComPort.Clear_RTS;
  ComPort.FlushBuffer;
  ComPort.WriteData( InitBufer,Length(InitBufer) );
  ComPort.ReadData( ByteArrRx,6);

  ReadTimer.Enabled := True;
  OnReadTimer(nil);
  result:= True;
  start:= result;

end;

function TPercoCardReader.Stop: boolean;
begin
  ReadTimer.Enabled :=False;
  if ComPort.PortOpened then ComPort.ClosePort;
end;



end.
