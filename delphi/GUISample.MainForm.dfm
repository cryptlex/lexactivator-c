object GUISampleForm: TGUISampleForm
  Left = 407
  Top = 237
  Width = 609
  Height = 210
  Caption = 'Sample application'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object lblProductKey: TLabel
    Left = 24
    Top = 32
    Width = 59
    Height = 13
    Caption = 'License key:'
  end
  object lblExtraData: TLabel
    Left = 24
    Top = 120
    Width = 56
    Height = 13
    Caption = 'Extra Data:'
  end
  object edtLicenseKey: TEdit
    Left = 96
    Top = 24
    Width = 361
    Height = 21
    TabOrder = 0
    Text = ''
  end
  object statStatusBar: TStatusBar
    Left = 0
    Top = 153
    Width = 593
    Height = 19
    Panels = <
      item
        Width = 50
      end>
  end
  object btnActivateTrial: TButton
    Left = 16
    Top = 64
    Width = 121
    Height = 25
    Caption = 'Activate Trial'
    TabOrder = 1
    OnClick = btnActivateTrialClick
  end
  object btnActivate: TButton
    Left = 160
    Top = 64
    Width = 113
    Height = 25
    Caption = 'Activate'
    TabOrder = 2
    OnClick = btnActivateClick
  end
  object edtExtraData: TEdit
    Left = 96
    Top = 112
    Width = 361
    Height = 21
    TabOrder = 4
    Text = 'testdata'
  end
end
