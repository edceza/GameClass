unit uGCDevices;

interface

uses Classes,
     uClientInfoConst;
type
  // ��� ����������
  TDevicetype = ( DeviceType_PC,              // ����
                  DeviceType_SNMP,            // SNMP-�������
                  DeviceType_Uncnoun );

  IGCDevice = interface
    function GetDiviceType:TDevicetype;     // ��������� ���� ����������
    procedure SetState(State:TClientState); // ��������� ��������� ����������

    function SendData(data:WideString):boolean;
    function PowerOff: Boolean;
    function PowerOn: Boolean;
    function Reboot: Boolean;
    function Logoff: Boolean;

    function GetOnline:Boolean;
    function GetControled:Boolean;
    function GetIP:string;

    property online:Boolean read GetOnline;
    property controled:Boolean read GetControled;
    property ipaddr:string read GetIP;
  end;

  TGCDevicePC = class(TInterfacedObject, IGCDevice)
    private
      function GetOnline:Boolean;
      function GetControled:Boolean;
      function GetIP:string;
    public
      constructor Create;
      function GetDiviceType:TDevicetype;     // ��������� ���� ����������
      procedure SetState(State:TClientState); // ��������� ��������� ����������

      function SendData(data:WideString):boolean;
      function PowerOff: Boolean;
      function PowerOn: Boolean;
      function Reboot: Boolean;
      function Logoff: Boolean;

      property online:Boolean read GetOnline;
      property controled:Boolean read GetControled;
      property ipaddr:string read GetIP;

  end;

implementation

  {
  TGCDevice = class
    public
      online:Boolean;                         // ���������� � ����
      controled: Boolean;                     // ���������� �����������
      constructor Create;
      function GetDiviceType:TDevicetype;     // ��������� ���� ����������
      procedure SetState(State:TClientState); // ��������� ��������� ����������

      function SendData(data:WideString):boolean;
      function PowerOff: Boolean;
      function PowerOn: Boolean;
      function Reboot: Boolean;
      function Logoff: Boolean;
  end;




{ TDevice }
{
constructor TGCDevice.Create;
begin
  online:=false;
  controled:=false;
end;

function TGCDevice.GetDiviceType: TDevicetype;
begin
  result:=DeviceType_Uncnoun;
end;

function TGCDevice.Logoff: Boolean;
begin
  result := false;
end;

function TGCDevice.PowerOff: Boolean;
begin
  result := false;
end;

function TGCDevice.PowerOn: Boolean;
begin
  result := false;
end;

function TGCDevice.Reboot: Boolean;
begin
  result := false;
end;

function TGCDevice.SendData(data: WideString): boolean;
begin
  result := false;
end;

procedure TGCDevice.SetState(State: TClientState);
begin

end;
}
{ TGCDevice }


{ TGCDevicePC }

constructor TGCDevicePC.Create;
begin

end;

function TGCDevicePC.GetControled: Boolean;
begin
  Result:=false;
end;

function TGCDevicePC.GetDiviceType: TDevicetype;
begin
  Result:=DeviceType_Uncnoun;
end;

function TGCDevicePC.GetIP: string;
begin
  Result:='';
end;

function TGCDevicePC.GetOnline: Boolean;
begin
  Result:=false;
end;

function TGCDevicePC.Logoff: Boolean;
begin
  Result:=false;
end;

function TGCDevicePC.PowerOff: Boolean;
begin
  Result:=false;
end;

function TGCDevicePC.PowerOn: Boolean;
begin
  Result:=false;
end;

function TGCDevicePC.Reboot: Boolean;
begin
  Result:=false;
end;

function TGCDevicePC.SendData(data: WideString): boolean;
begin
  Result:=false;
end;

procedure TGCDevicePC.SetState(State: TClientState);
begin

end;

end.
