object FormPrincipal: TFormPrincipal
  Left = 0
  Top = 0
  Caption = 'Demo Simples TEF - Multiplus Card'
  ClientHeight = 441
  ClientWidth = 624
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  TextHeight = 15
  object Button1: TButton
    Left = 8
    Top = 8
    Width = 608
    Height = 57
    Caption = 'TEF D'#233'bito R$1,00'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Panel1: TPanel
    Left = 8
    Top = 80
    Width = 608
    Height = 41
    Caption = 'Panel1'
    TabOrder = 1
  end
  object Memo1: TMemo
    Left = 8
    Top = 136
    Width = 361
    Height = 297
    Lines.Strings = (
      'LOG')
    ScrollBars = ssVertical
    TabOrder = 2
  end
  object Memo2: TMemo
    Left = 383
    Top = 136
    Width = 233
    Height = 297
    Lines.Strings = (
      'Comprovante')
    ScrollBars = ssVertical
    TabOrder = 3
  end
  object MultiplusCardTef1: TMultiplusCardTef
    Configuracoes.NomeDLL = 'TefClientmc.dll'
    Configuracoes.UsaFormPadrao = False
    LogSimplificado = False
    OnRegistrarLog = MultiplusCardTef1RegistrarLog
    OnMsg = MultiplusCardTef1Msg
    OnGerarComprovante = MultiplusCardTef1GerarComprovante
    Left = 152
    Top = 232
  end
end
