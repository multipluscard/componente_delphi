object Form1: TForm1
  Left = 0
  Top = 0
  Cursor = crHandPoint
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Form1'
  ClientHeight = 637
  ClientWidth = 839
  Color = clSnow
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clBlack
  Font.Height = -13
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  TextHeight = 17
  object lblRetornoComprovante: TLabel
    Left = 8
    Top = 401
    Width = 49
    Height = 17
    Caption = 'Retorno'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -13
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object lblLog: TLabel
    Left = 280
    Top = 401
    Width = 23
    Height = 17
    Caption = 'Log'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -13
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object btnExecutar: TButton
    Left = 8
    Top = 312
    Width = 130
    Height = 44
    Cursor = crHandPoint
    Caption = 'Executar'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -13
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 0
    OnClick = btnExecutarClick
  end
  object mRetornoComprovante: TMemo
    Left = 8
    Top = 424
    Width = 266
    Height = 218
    Font.Charset = ANSI_CHARSET
    Font.Color = clBlack
    Font.Height = -12
    Font.Name = 'Consolas'
    Font.Style = []
    ParentFont = False
    ScrollBars = ssVertical
    TabOrder = 1
  end
  object mLog: TMemo
    Left = 280
    Top = 424
    Width = 557
    Height = 218
    Font.Charset = ANSI_CHARSET
    Font.Color = clBlack
    Font.Height = -12
    Font.Name = 'Consolas'
    Font.Style = []
    ParentFont = False
    ScrollBars = ssVertical
    TabOrder = 2
  end
  object gpTipoCaptura: TGroupBox
    Left = 8
    Top = 40
    Width = 829
    Height = 56
    Caption = 'Tipo de captura'
    DefaultHeaderFont = False
    HeaderFont.Charset = DEFAULT_CHARSET
    HeaderFont.Color = clBlack
    HeaderFont.Height = -13
    HeaderFont.Name = 'Segoe UI'
    HeaderFont.Style = [fsBold]
    TabOrder = 3
    object rbDll: TRadioButton
      Left = 16
      Top = 24
      Width = 161
      Height = 17
      Caption = 'DLL TEF CLIENT MC'
      TabOrder = 0
    end
    object rbPinpdvApi: TRadioButton
      Left = 232
      Top = 24
      Width = 178
      Height = 17
      Caption = 'PINPDV API - POS TEF'
      TabOrder = 1
    end
    object rbPinpdvApiPrevenda: TRadioButton
      Left = 472
      Top = 24
      Width = 241
      Height = 17
      Caption = 'PINPDV API - PRE VENDA'
      TabOrder = 2
    end
  end
  object ProgressBar: TProgressBar
    Left = 8
    Top = 390
    Width = 829
    Height = 5
    TabOrder = 4
  end
  object gpParametros: TGroupBox
    Left = 8
    Top = 102
    Width = 829
    Height = 204
    Caption = 'Par'#226'metros'
    DefaultHeaderFont = False
    HeaderFont.Charset = DEFAULT_CHARSET
    HeaderFont.Color = clBlack
    HeaderFont.Height = -13
    HeaderFont.Name = 'Segoe UI'
    HeaderFont.Style = [fsBold]
    TabOrder = 5
    object lbValor: TLabel
      Left = 16
      Top = 24
      Width = 30
      Height = 17
      Caption = 'Valor'
    end
    object lblNsu: TLabel
      Left = 288
      Top = 24
      Width = 26
      Height = 17
      Caption = 'NSU'
    end
    object lbParcela: TLabel
      Left = 152
      Top = 24
      Width = 48
      Height = 17
      Caption = 'Parcelas'
    end
    object lbOperacao: TLabel
      Left = 560
      Top = 80
      Width = 82
      Height = 17
      Caption = 'Opera'#231#227'o TEF'
    end
    object lbCupom: TLabel
      Left = 424
      Top = 24
      Width = 42
      Height = 17
      Caption = 'Cupom'
    end
    object lbPinpdvDispositivos: TLabel
      Left = 16
      Top = 80
      Width = 115
      Height = 17
      Caption = 'PinPDV Dispositivos'
    end
    object lblPinpdvPadrao: TLabel
      Left = 289
      Top = 80
      Width = 103
      Height = 17
      Caption = 'Opera'#231#227'o PinPDV'
    end
    object lblIdentificadorUnico: TLabel
      Left = 17
      Top = 145
      Width = 155
      Height = 17
      Caption = 'Identificador Unico PinPDV'
    end
    object lblParametrosDll: TLabel
      Left = 560
      Top = 25
      Width = 92
      Height = 17
      Caption = 'Par'#226'metros DLL'
    end
    object txbValor: TEdit
      Left = 16
      Top = 48
      Width = 121
      Height = 25
      TabOrder = 0
      Text = '1,89'
    end
    object txbParcela: TEdit
      Left = 152
      Top = 48
      Width = 121
      Height = 25
      TabOrder = 1
      Text = '1'
    end
    object txbNsu: TEdit
      Left = 288
      Top = 48
      Width = 122
      Height = 25
      TabOrder = 2
      Text = '123'
    end
    object txbCupom: TEdit
      Left = 424
      Top = 48
      Width = 121
      Height = 25
      TabOrder = 3
      Text = '456'
    end
    object cbxOperacoes: TComboBox
      Left = 560
      Top = 103
      Width = 256
      Height = 25
      Cursor = crHandPoint
      Style = csDropDownList
      TabOrder = 4
    end
    object cbxPinpdvDispositivos: TComboBox
      Left = 16
      Top = 103
      Width = 194
      Height = 25
      Cursor = crHandPoint
      Style = csDropDownList
      TabOrder = 5
    end
    object btnAtualizarPinpdv: TButton
      Left = 216
      Top = 104
      Width = 58
      Height = 24
      Cursor = crHandPoint
      Caption = 'Atualizar'
      TabOrder = 6
      OnClick = btnAtualizarPinpdvClick
    end
    object txbIdentificadorPinpdv: TEdit
      Left = 16
      Top = 168
      Width = 257
      Height = 25
      TabOrder = 7
    end
    object cbxPinpdvGerarIdAuto: TCheckBox
      Left = 288
      Top = 172
      Width = 178
      Height = 17
      Caption = 'Gerar Autom'#225'ticamente'
      TabOrder = 8
    end
    object cbxOperacoesPinPDV: TComboBox
      Left = 289
      Top = 104
      Width = 256
      Height = 25
      Cursor = crHandPoint
      Style = csDropDownList
      TabOrder = 9
    end
    object txbParametrosDll: TEdit
      Left = 560
      Top = 48
      Width = 256
      Height = 25
      TabOrder = 10
    end
  end
  object pnlMensagem: TPanel
    Left = 8
    Top = 360
    Width = 829
    Height = 30
    BevelEdges = []
    BevelOuter = bvNone
    Caption = '-'
    Color = clSilver
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -21
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentBackground = False
    ParentFont = False
    TabOrder = 6
    OnClick = pnlMensagemClick
  end
  object btnCancelar: TButton
    Left = 144
    Top = 310
    Width = 135
    Height = 44
    Cursor = crHandPoint
    Caption = 'Cancelar'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -13
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 7
    OnClick = btnCancelarClick
  end
  object btnTestarFormPadrao: TButton
    Left = 706
    Top = 319
    Width = 133
    Height = 25
    Cursor = crHandPoint
    Caption = 'Testar form padr'#227'o'
    TabOrder = 8
    OnClick = btnTestarFormPadraoClick
  end
  object btnTestarFormPersonalizado: TButton
    Left = 505
    Top = 319
    Width = 195
    Height = 25
    Cursor = crHandPoint
    Caption = 'Testar forms personalizados'
    TabOrder = 9
    OnClick = btnTestarFormPersonalizadoClick
  end
  object chbTipoForm: TCheckBox
    Left = 344
    Top = 323
    Width = 97
    Height = 17
    Caption = 'Form padr'#227'o'
    Checked = True
    State = cbChecked
    TabOrder = 10
    OnClick = chbTipoFormClick
  end
  object MultiplusCardTef1: TMultiplusCardTef
    Configuracoes.NomeDLL = 'TefClientmc.dll'
    Configuracoes.UsaFormPadrao = False
    LogSimplificado = False
    OnSolicitarInteracao = MultiplusCardTef1SolicitarInteracao
    OnRegistrarLog = MultiplusCardTef1RegistrarLog
    OnMsg = MultiplusCardTef1Menssagem
    OnGerarComprovante = MultiplusCardTef1GerarComprovante
    OnQrCodeGerado = MultiplusCardTef1QrCodeGerado
    OnCpfInformado = MultiplusCardTef1CpfInformado
    OnFalhaOperacao = MultiplusCardTef1FalhaOperacao
    OnPinpad = MultiplusCardTef1Pinpad
    OnRelatorioTransacoes = MultiplusCardTef1RelatorioTransacoes
  end
  object MultiplusCardPinPDV1: TMultiplusCardPinPDV
    OnSolicitarInteracao = MultiplusCardPinPDV1SolicitarInteracao
    OnSolicitarImpressao = MultiplusCardPinPDV1SolicitarImpressao
    OnGerarComprovante = MultiplusCardPinPDV1GerarComprovante
    OnFalhaOperacao = MultiplusCardPinPDV1FalhaOperacao
    OnRegistrarLog = MultiplusCardPinPDV1RegistrarLog
    OnMsg = MultiplusCardTef1Menssagem
    Configuracoes.BaseURL = 'https://api.pinpdv.com.br'
    Configuracoes.UsaFormPadrao = False
    Configuracoes.IntervaloVerificacaoAutomatica = 5000
    Left = 40
  end
end
