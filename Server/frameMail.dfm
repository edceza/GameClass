object framMail: TframMail
  Left = 0
  Top = 0
  Width = 449
  Height = 430
  TabOrder = 0
  object gbSMTP: TGroupBox
    Left = 0
    Top = 0
    Width = 425
    Height = 193
    Caption = #1055#1072#1088#1072#1084#1077#1090#1088#1099' SMTP '#1089#1077#1088#1074#1077#1088#1072
    TabOrder = 0
    object ledHost: TLabeledEdit
      Left = 8
      Top = 32
      Width = 201
      Height = 21
      EditLabel.Width = 36
      EditLabel.Height = 13
      EditLabel.Caption = 'ledHost'
      TabOrder = 0
      OnChange = ledHostChange
    end
    object ledPort: TLabeledEdit
      Left = 216
      Top = 31
      Width = 201
      Height = 21
      EditLabel.Width = 34
      EditLabel.Height = 13
      EditLabel.Caption = 'ledPort'
      TabOrder = 1
      OnChange = ledPortChange
    end
    object chbAuthentication: TCheckBox
      Left = 8
      Top = 56
      Width = 113
      Height = 17
      Caption = 'chbAuthentication'
      TabOrder = 2
      OnClick = chbAuthenticationClick
    end
    object ledUserName: TLabeledEdit
      Left = 8
      Top = 88
      Width = 201
      Height = 21
      EditLabel.Width = 63
      EditLabel.Height = 13
      EditLabel.Caption = 'ledUserName'
      TabOrder = 3
      OnChange = ledUserNameChange
    end
    object ledPassword: TLabeledEdit
      Left = 216
      Top = 88
      Width = 201
      Height = 21
      EditLabel.Width = 60
      EditLabel.Height = 13
      EditLabel.Caption = 'ledPassword'
      PasswordChar = '*'
      TabOrder = 4
      OnChange = ledPasswordChange
    end
    object ledFrom: TLabeledEdit
      Left = 8
      Top = 130
      Width = 201
      Height = 21
      EditLabel.Width = 38
      EditLabel.Height = 13
      EditLabel.Caption = 'ledFrom'
      TabOrder = 5
      OnChange = ledFromChange
    end
    object ledTo: TLabeledEdit
      Left = 216
      Top = 130
      Width = 201
      Height = 21
      EditLabel.Width = 26
      EditLabel.Height = 13
      EditLabel.Caption = 'ledTo'
      TabOrder = 6
      OnChange = ledToChange
    end
    object butTest: TButton
      Left = 344
      Top = 160
      Width = 75
      Height = 25
      Caption = 'test'
      TabOrder = 7
      OnClick = butTestClick
    end
  end
end
