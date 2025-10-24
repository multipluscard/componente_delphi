object Form2: TForm2
  Left = 0
  Top = 0
  Caption = 'Exemplo Componente PINPDV Manual - Delphi'
  ClientHeight = 560
  ClientWidth = 869
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -15
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  DesignSize = (
    869
    560)
  TextHeight = 20
  object memoResultados: TMemo
    Left = 8
    Top = 192
    Width = 845
    Height = 360
    Anchors = [akLeft, akTop, akRight, akBottom]
    Lines.Strings = (
      'memoResultados')
    ScrollBars = ssBoth
    TabOrder = 0
    ExplicitWidth = 843
    ExplicitHeight = 352
  end
  object pageOperacoes: TPageControl
    Left = 4
    Top = 8
    Width = 853
    Height = 178
    ActivePage = tabPosVenda
    Anchors = [akTop]
    TabOrder = 1
    ExplicitLeft = 3
    object tabDispositivos: TTabSheet
      Caption = 'Dispositivos'
      DesignSize = (
        845
        143)
      object btnListarDispositivosPinPDV: TButton
        Left = 174
        Top = 120
        Width = 195
        Height = 25
        Cursor = crHandPoint
        Anchors = [akTop]
        Caption = 'Listar Dispositivos PinPDV'
        TabOrder = 0
        OnClick = btnListarDispositivosPinPDVClick
      end
      object btnListarDispositivosPinPDVJSON: TButton
        Left = 441
        Top = 120
        Width = 240
        Height = 25
        Cursor = crHandPoint
        Anchors = [akTop]
        Caption = 'Listar Dispositivos PinPDV JSON'
        TabOrder = 1
        OnClick = btnListarDispositivosPinPDVJSONClick
      end
    end
    object tabPreVenda: TTabSheet
      Caption = 'Pre Venda'
      ImageIndex = 1
      object lbPreVendaIdentificador: TLabel
        Left = 3
        Top = -2
        Width = 85
        Height = 20
        Caption = 'Identificador'
      end
      object lbPreVendaDescricao: TLabel
        Left = 199
        Top = -2
        Width = 65
        Height = 20
        Caption = 'Descricao'
      end
      object lbPreVendaValor: TLabel
        Left = 443
        Top = -2
        Width = 34
        Height = 20
        Caption = 'Valor'
      end
      object lbPreVendaParcelas: TLabel
        Left = 570
        Top = -2
        Width = 53
        Height = 20
        Caption = 'Parcelas'
      end
      object lbPreVendaPinPdvId: TLabel
        Left = 3
        Top = 54
        Width = 62
        Height = 20
        Caption = 'ID PinPdv'
      end
      object lbPreVendaTipoPagamento: TLabel
        Left = 697
        Top = -2
        Width = 109
        Height = 20
        Caption = 'Tipo Pagamento'
      end
      object btnAbortarPreVenda: TButton
        Left = 495
        Top = 115
        Width = 130
        Height = 25
        Cursor = crHandPoint
        Caption = 'Abortar Pre Venda'
        TabOrder = 10
        OnClick = btnAbortarPreVendaClick
      end
      object btnAbortarPreVendaRetentativa: TButton
        Left = 631
        Top = 115
        Width = 211
        Height = 25
        Cursor = crHandPoint
        Caption = 'Abortar Pre Venda Retentativa'
        TabOrder = 11
        OnClick = btnAbortarPreVendaRetentativaClick
      end
      object btnCadastrarPreVenda: TButton
        Left = 3
        Top = 115
        Width = 142
        Height = 25
        Cursor = crHandPoint
        Caption = 'Cadastrar Pre Venda'
        TabOrder = 7
        OnClick = btnCadastrarPreVendaClick
      end
      object btnConsultarPreVenda: TButton
        Left = 151
        Top = 115
        Width = 146
        Height = 25
        Cursor = crHandPoint
        Caption = 'Consultar Pre Venda'
        TabOrder = 8
        OnClick = btnConsultarPreVendaClick
      end
      object btnConsultarPreVendaJSON: TButton
        Left = 303
        Top = 115
        Width = 186
        Height = 25
        Cursor = crHandPoint
        Caption = 'Consultar Pre Venda JSON'
        TabOrder = 9
        OnClick = btnConsultarPreVendaJSONClick
      end
      object txtPreVendaIdentificador: TEdit
        Left = 3
        Top = 24
        Width = 190
        Height = 28
        TabOrder = 0
      end
      object txtPreVendaDescricao: TEdit
        Left = 199
        Top = 24
        Width = 238
        Height = 28
        TabOrder = 1
      end
      object txtPreVendaValor: TEdit
        Left = 443
        Top = 24
        Width = 121
        Height = 28
        TabOrder = 2
      end
      object txtPreVendaParcelas: TEdit
        Left = 570
        Top = 24
        Width = 121
        Height = 28
        TabOrder = 3
      end
      object txtPreVendaPinPdvId: TEdit
        Left = 3
        Top = 80
        Width = 121
        Height = 28
        TabOrder = 5
      end
      object cbPreVendaTipoPagamento: TComboBox
        Left = 697
        Top = 24
        Width = 145
        Height = 28
        Cursor = crHandPoint
        Style = csDropDownList
        TabOrder = 4
      end
      object checkGerarIdentificadorPreVendaAleatorio: TCheckBox
        Left = 130
        Top = 85
        Width = 223
        Height = 17
        Caption = 'Gerar Identificador Aleat'#243'rio'
        TabOrder = 6
      end
    end
    object tabPosVenda: TTabSheet
      Caption = 'Pos Venda'
      ImageIndex = 2
      object lbPosVendaTipoPagamento: TLabel
        Left = 697
        Top = -2
        Width = 109
        Height = 20
        Caption = 'Tipo Pagamento'
      end
      object lbPosVendaParcela: TLabel
        Left = 570
        Top = -2
        Width = 53
        Height = 20
        Caption = 'Parcelas'
      end
      object lbPosVendaDescricao: TLabel
        Left = 199
        Top = -2
        Width = 65
        Height = 20
        Caption = 'Descricao'
      end
      object lbPosVendaValor: TLabel
        Left = 443
        Top = -2
        Width = 34
        Height = 20
        Caption = 'Valor'
      end
      object lbPosVendaPinPdvId: TLabel
        Left = 3
        Top = 54
        Width = 62
        Height = 20
        Caption = 'ID PinPdv'
      end
      object lbPosVendaIdentificador: TLabel
        Left = 3
        Top = -2
        Width = 85
        Height = 20
        Caption = 'Identificador'
      end
      object btnAbortarPosVenda: TButton
        Left = 696
        Top = 84
        Width = 146
        Height = 25
        Cursor = crHandPoint
        Caption = 'Abortar POS Venda'
        TabOrder = 10
        OnClick = btnAbortarPosVendaClick
      end
      object btnAbortarPosVendaRetentativa: TButton
        Left = 600
        Top = 115
        Width = 242
        Height = 25
        Cursor = crHandPoint
        Caption = 'Abortar POS Venda Retentativa'
        TabOrder = 11
        OnClick = btnAbortarPosVendaRetentativaClick
      end
      object btnCadastrarPosVenda: TButton
        Left = 3
        Top = 115
        Width = 150
        Height = 25
        Cursor = crHandPoint
        Caption = 'Cadastrar POS Venda'
        TabOrder = 7
        OnClick = btnCadastrarPosVendaClick
      end
      object btnConsultarPosVenda: TButton
        Left = 183
        Top = 115
        Width = 154
        Height = 25
        Cursor = crHandPoint
        Caption = 'Consultar POS Venda'
        TabOrder = 8
        OnClick = btnConsultarPosVendaClick
      end
      object btnConsultarPosVendaJSON: TButton
        Left = 370
        Top = 115
        Width = 194
        Height = 25
        Cursor = crHandPoint
        Caption = 'Consultar POS Venda JSON'
        TabOrder = 9
        OnClick = btnConsultarPosVendaJSONClick
      end
      object checkGerarIdentificadorPosVendaAleatorio: TCheckBox
        Left = 130
        Top = 85
        Width = 223
        Height = 17
        Caption = 'Gerar Identificador Aleat'#243'rio'
        TabOrder = 6
      end
      object cbPosVendaTipoPagamento: TComboBox
        Left = 692
        Top = 24
        Width = 150
        Height = 28
        Cursor = crHandPoint
        Style = csDropDownList
        TabOrder = 4
      end
      object txtPosVendaParcelas: TEdit
        Left = 570
        Top = 24
        Width = 116
        Height = 28
        TabOrder = 3
      end
      object txtPosVendaDescricao: TEdit
        Left = 199
        Top = 24
        Width = 238
        Height = 28
        TabOrder = 1
      end
      object txtPosVendaPinPdvId: TEdit
        Left = 3
        Top = 80
        Width = 121
        Height = 28
        TabOrder = 5
      end
      object txtPosVendaValor: TEdit
        Left = 443
        Top = 24
        Width = 121
        Height = 28
        TabOrder = 2
      end
      object txtPosVendaIdentificador: TEdit
        Left = 3
        Top = 24
        Width = 190
        Height = 28
        TabOrder = 0
      end
    end
  end
  object MultiplusCardPinPDV1: TMultiplusCardPinPDV
    OnSolicitarImpressao = MultiplusCardPinPDV1SolicitarImpressao
    OnGerarComprovante = MultiplusCardPinPDV1GerarComprovante
    OnFalhaOperacao = MultiplusCardPinPDV1FalhaOperacao
    OnRegistrarLog = MultiplusCardPinPDV1RegistrarLog
    OnMsg = MultiplusCardPinPDV1Msg
    Configuracoes.BaseURL = 'https://api.pinpdv.com.br'
    Configuracoes.UsaFormPadrao = False
    Configuracoes.IntervaloVerificacaoAutomatica = 5000
    Left = 752
    Top = 480
  end
end
