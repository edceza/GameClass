unit uGCStrUtils;

interface

function FilterString(instr: string):string;

implementation

// ��������� ������ �� ������ ��������
function FilterString(instr: string):string;
var
  i: integer;
begin
  for i:= 1 to Length(instr) do
  begin
    { ������������ ������ � s - ������ ������������ ����� }
             { TODO : ����������, �.�. �������� �������� }
    if not (instr[i] in ['a'..'z', 'A'..'Z','�'..'�', '�'..'�', '0'..'9', '_', '-', '.', ' ']) then
      instr[i] := '*';
  end;
  FilterString := instr;
end;

end.
 