object FormPrincipal: TFormPrincipal
  Left = 0
  Top = 0
  Caption = 'Demo Simples PINPDV - Multiplus Card'
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
    Height = 33
    Caption = 'POS TEF D'#233'bito R$0,10'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Memo1: TMemo
    Left = 8
    Top = 136
    Width = 361
    Height = 297
    Lines.Strings = (
      'LOG')
    ScrollBars = ssVertical
    TabOrder = 1
  end
  object Memo2: TMemo
    Left = 383
    Top = 136
    Width = 233
    Height = 297
    Lines.Strings = (
      'Comprovante')
    ScrollBars = ssVertical
    TabOrder = 2
  end
  object Panel1: TPanel
    Left = 8
    Top = 80
    Width = 608
    Height = 41
    Caption = 'Panel1'
    TabOrder = 3
  end
  object Button2: TButton
    Left = 8
    Top = 47
    Width = 608
    Height = 33
    Caption = 'PRE VENDA D'#233'bito R$0,10'
    TabOrder = 4
    OnClick = Button2Click
  end
  object MultiplusCardPinPDV1: TMultiplusCardPinPDV
    OnSolicitarImpressao = MultiplusCardPinPDV1SolicitarImpressao
    OnGerarComprovante = MultiplusCardPinPDV1GerarComprovante
    OnRegistrarLog = MultiplusCardPinPDV1RegistrarLog
    OnMsg = MultiplusCardPinPDV1Msg
    Configuracoes.BaseURL = 'https://api.pinpdv.com.br'
    Configuracoes.UsaFormPadrao = False
    Configuracoes.IntervaloVerificacaoAutomatica = 5000
    Left = 576
    Top = 88
  end
end
