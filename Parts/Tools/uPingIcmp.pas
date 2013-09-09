unit uPingIcmp;

interface

uses
  winsock,Windows,IdGlobal,IdIcmpClient, System.SysUtils;

function PingICMP (Host:string):Boolean;

type
    ip_option_information = packed record  // ���������� ��������� IP (����������
				    // ���� ��������� � ������ ����� ������ � RFC791.
        Ttl : byte;			// ����� ����� (������������ traceroute-��)
        Tos : byte;			// ��� ������������, ������ 0
        Flags : byte;		// ����� ��������� IP, ������ 0
        OptionsSize : byte;		// ������ ������ � ���������, ������ 0, �������� 40
        OptionsData : Pointer;	// ��������� �� ������
    end;

   icmp_echo_reply = packed record
        Address : u_long; 	    	 // ����� �����������
        Status : u_long;	    	 // IP_STATUS (��. ����)
        RTTime : u_long;	    	 // ����� ����� ���-�������� � ���-�������
				         // � �������������
        DataSize : u_short; 	    	 // ������ ������������ ������
        Reserved : u_short; 	    	 // ���������������
        Data : Pointer; 		 // ��������� �� ������������ ������
        Options : ip_option_information; // ���������� �� ��������� IP
    end;

    PIPINFO = ^ip_option_information;
    PVOID = Pointer;

        function IcmpCreateFile() : THandle; stdcall; external 'ICMP.DLL' name 'IcmpCreateFile';
        function IcmpCloseHandle(IcmpHandle : THandle) : BOOL; stdcall; external 'ICMP.DLL'  name 'IcmpCloseHandle';
        function IcmpSendEcho(
                          IcmpHandle : THandle;    // handle, ������������ IcmpCreateFile()
                          DestAddress : u_long;    // ����� ���������� (� ������� �������)
                          RequestData : PVOID;     // ��������� �� ���������� ������
                          RequestSize : Word;      // ������ ���������� ������
                          RequestOptns : PIPINFO;  // ��������� �� ���������� ���������
                       		                   // ip_option_information (����� ���� nil)
                          ReplyBuffer : PVOID;     // ��������� �� �����, ���������� ������.
                          ReplySize : DWORD;       // ������ ������ �������
                          Timeout : DWORD          // ����� �������� ������ � �������������
                         ) : DWORD; stdcall; external 'ICMP.DLL' name 'IcmpSendEcho';

implementation


function PingICMP (Host:string):Boolean;

{var
  MyIdIcmpClient : TIdIcmpClient;
  ABuffer: String;
begin
  Result := True;

  MyIdIcmpClient := TIdIcmpClient.Create(nil);
  MyIdIcmpClient.ReceiveTimeout := 200;
  MyIdIcmpClient.Host := AnsiString(Host);
  MyIdIcmpClient.PacketSize := 24;
  MyIdIcmpClient.Protocol := 1;
  MyIdIcmpClient.IPVersion := Id_IPv4;
  ABuffer:=Host+StringOfChar(' ',255);
  try
    MyIdIcmpClient.Ping(ABuffer);
    // Application.ProcessMessages; // There's no need to call this!
  except
    Result := False;
    Exit;
  end;
  if MyIdIcmpClient.ReplyStatus.ReplyStatusType <> rsEcho Then result := False
    else result := True;

  FreeAndNil(MyIdIcmpClient);


end;}

var
    hIP : THandle;
    pingBuffer : array [0..31] of Char;
    pIpe : ^icmp_echo_reply;
    pHostEn : PHostEnt;
    wVersionRequested : WORD;
    lwsaData : WSAData;
    error : DWORD;
    destAddress : In_Addr;
begin
    Result := false;
    // ������� handle
    hIP := IcmpCreateFile();
    GetMem( pIpe, sizeof(icmp_echo_reply) + sizeof(pingBuffer));
    pIpe.Data := @pingBuffer;
    pIpe.DataSize := sizeof(pingBuffer);

    wVersionRequested := MakeWord(1,1);
    error := WSAStartup(wVersionRequested,lwsaData);
    if (error <> 0) then
    begin
      Result := false;
      IcmpCloseHandle(hIP);
      WSACleanup();
      FreeMem(pIpe);
      Exit;
    end;

    pHostEn := gethostbyname(pansichar( ansistring(Host)));
    error := GetLastError();
    if (error <> 0) then
    begin
      Result := false;
      IcmpCloseHandle(hIP);
      WSACleanup();
      FreeMem(pIpe);

      Exit;
    end;

     destAddress := PInAddr(pHostEn^.h_addr_list^)^;

    IcmpSendEcho(hIP,
                 destAddress.S_addr,
                 @pingBuffer,
                 sizeof(pingBuffer),
                 Nil,
                 pIpe,
                 sizeof(icmp_echo_reply) + sizeof(pingBuffer),
                 5000);

    error := GetLastError();
    if (error <> 0) then
    begin
      Result := false;
      IcmpCloseHandle(hIP);
      WSACleanup();
      FreeMem(pIpe);

      Exit;
    end;
    if pIpe.DataSize > 0 then
      Result := True;
{     // ������� ��������� �� ����������� ������
    Memo1.Lines.Add('Reply from '+
                IntToStr(LoByte(LoWord(pIpe^.Address)))+'.'+
                IntToStr(HiByte(LoWord(pIpe^.Address)))+'.'+
                IntToStr(LoByte(HiWord(pIpe^.Address)))+'.'+
                IntToStr(HiByte(HiWord(pIpe^.Address))));
    Memo1.Lines.Add('Reply time: '+IntToStr(pIpe.RTTime)+' ms');
 }
    IcmpCloseHandle(hIP);
    WSACleanup();
    FreeMem(pIpe);
end;
end.
