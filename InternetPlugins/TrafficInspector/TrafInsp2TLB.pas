unit TrafInsp2TLB;

interface

uses Windows, ActiveX, Classes, Graphics, OleServer, StdVCL, Variants;

type
  APIListType = TOleEnum;
const
  itIPInterface = 1;	// ������� ����������
  itUserGroup = 2;	//������ ��������
  itUser = 3;		//�������
  itUserFilter = 4;	//�������
  itFw = 5;		//������� �������� �������� ������
  itExtCont = 6;		//������� �������������� ��������
  itExtInfo = 7;		//������� �������������� ��������
  itContentGroup = 8;	//�������� ����� ������
  itCacheRule = 9;	//������� �����������
  itReserved = 10;
  itSMTPServRule = 11;	//������� SMTP �������
  itWWWServConfig = 12;	//������� WWW �������
  itWWWServRedirect = 13;//������� ��������� SMTP �������
  itNSUserPol = 14;	//������� ���������� �� ��������� ������� �������
  itAdminList = 15;	//������������ (�����������������)
  itAdminGroup = 16;	//������ ������������� (�����������������)
  itIPNetDesc = 21;	//IP ����
  itURLDesc = 22;	//URL ������
  itProxyRoute = 23;	//������� ������ - �������
  itPlugins = 24;	//�������
  itModules = 25;	//������ ����������
  itProblems = 26;	//��������������
  itIntNetRule = 27;	//������� �����
  itTariffDesc = 28;	//������
  itMaintenance = 29;	//������������
  itAccGroup = 30;	//��������� �����
  itExtAllCounter = 31;	//������� ������ ������� ���������
  itScriptDef = 32;	//�������
  itScriptQueue = 32;	//������� ������� ����������� ��������
  itDeviceDef = 33;	//�������� ��������� (������ ������������)
  itMappingRule = 34;	//������� ��������������� TCP ����������
  itAdvAttr = 35;	//�������� ���������


type
  ConfigAttrLevelType = TOleEnum;
const
  conf_AttrLevelNormal = 0;   //���������������� ��������
  conf_AttrLevelForSave = 1;  //�������� ������������ � �������� ��� ���������� ��������, ����� ���������� �� ������ �� ��������� conf_AttrLevelNormal
  conf_AttrLevelCaption = 2;  //����������� ����� ��������� - ������ GUID � DisplayName
  conf_AttrLevelRootOnly = 3; //������ �������� ��������, ���� � ������ �������� �������� �� �������������, �� ����� ������� ������ ������ (��. �������� ������� � ������������ APIListType)
  conf_AttrLevelWORoot = 4;   //������ �������� ������ ��� �������� ���������
  conf_AttrLevelDetail = 5;   //��� �������� (���������������� � ���������)
  conf_AttrLevelPreview = 6;  //����������� ����� ���������, �������������� � ��������� �������
  conf_AttrLevelState = 7;    //�������� ��������� (����� ��������� ��������� �������� ������������)


implementation

end.
