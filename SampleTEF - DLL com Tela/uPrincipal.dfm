object FormPrincipal: TFormPrincipal
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Exemplo Componente via DLL com Tela - Delphi'
  ClientHeight = 738
  ClientWidth = 906
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -15
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  TextHeight = 20
  object lbStatus: TLabel
    Left = 0
    Top = 0
    Width = 906
    Height = 20
    Align = alTop
    Alignment = taCenter
    ExplicitWidth = 4
  end
  object tabOperacoes: TPageControl
    Left = 8
    Top = 175
    Width = 593
    Height = 320
    ActivePage = tabAdministracao
    TabOrder = 0
    object tabCartoes: TTabSheet
      Caption = 'Cart'#245'es'
      object tabModalidadesCartoes: TPageControl
        Left = 0
        Top = 0
        Width = 585
        Height = 285
        ActivePage = tabCredito
        Align = alClient
        TabOrder = 0
        ExplicitLeft = 4
        ExplicitTop = 4
        object tabCredito: TTabSheet
          Caption = 'Cr'#233'dito'
          object btnCreditoParcLoja: TButton
            Left = 307
            Top = 24
            Width = 211
            Height = 56
            Caption = 'Cr'#233'dito Parcelado Loja'
            TabOrder = 1
            OnClick = btnCreditoParcLojaClick
          end
          object btnCredito: TButton
            Left = 48
            Top = 24
            Width = 211
            Height = 56
            Caption = 'Cr'#233'dito'
            TabOrder = 0
            OnClick = btnCreditoClick
          end
          object btnCreditoAVista: TButton
            Left = 48
            Top = 104
            Width = 211
            Height = 56
            Caption = 'Cr'#233'dito a Vista'
            TabOrder = 2
            OnClick = btnCreditoAVistaClick
          end
          object btnCreditoParcAdm: TButton
            Left = 307
            Top = 104
            Width = 211
            Height = 56
            Caption = 'Cr'#233'dito Parcelado Adm'
            TabOrder = 3
            OnClick = btnCreditoParcAdmClick
          end
        end
        object tabDebito: TTabSheet
          Caption = 'D'#233'bito'
          ImageIndex = 1
          object btnDebitoAVista: TButton
            Left = 307
            Top = 24
            Width = 211
            Height = 56
            Caption = 'D'#233'bito a Vista'
            TabOrder = 1
            OnClick = btnDebitoAVistaClick
          end
          object btnDebito: TButton
            Left = 48
            Top = 24
            Width = 211
            Height = 56
            Caption = 'D'#233'bito'
            TabOrder = 0
            OnClick = btnDebitoClick
          end
        end
        object tabGenerica: TTabSheet
          Caption = 'Gen'#233'rica'
          ImageIndex = 2
          object btnVendaGenerica: TButton
            Left = 48
            Top = 24
            Width = 211
            Height = 56
            Caption = 'Venda Gen'#233'rica'
            TabOrder = 0
            OnClick = btnVendaGenericaClick
          end
        end
        object tabPrivateLabel: TTabSheet
          Caption = 'Private Label'
          ImageIndex = 3
          object btnPrivateLabel: TButton
            Left = 48
            Top = 24
            Width = 211
            Height = 56
            Caption = 'Private Label'
            TabOrder = 0
            OnClick = btnPrivateLabelClick
          end
        end
        object tabFrotaCompleto: TTabSheet
          Caption = 'Frota Completo'
          ImageIndex = 4
          object lbSKm: TLabel
            Left = 48
            Top = 104
            Width = 22
            Height = 20
            Caption = 'Km'
          end
          object lbSPlaca: TLabel
            Left = 147
            Top = 104
            Width = 35
            Height = 20
            Caption = 'Placa'
          end
          object lbSMatricula: TLabel
            Left = 279
            Top = 104
            Width = 62
            Height = 20
            Caption = 'Matricula'
          end
          object lbQtdeItens: TLabel
            Left = 425
            Top = 104
            Width = 68
            Height = 20
            Caption = 'Qtde Itens'
          end
          object lbSItens: TLabel
            Left = 48
            Top = 160
            Width = 31
            Height = 20
            Caption = 'Itens'
          end
          object btnFrotaCompleto: TButton
            Left = 48
            Top = 24
            Width = 211
            Height = 56
            Caption = 'Frota Completo'
            TabOrder = 0
            OnClick = btnFrotaCompletoClick
          end
          object txtSKm: TEdit
            Left = 48
            Top = 130
            Width = 93
            Height = 28
            TabOrder = 1
          end
          object txtSPlaca: TEdit
            Left = 147
            Top = 130
            Width = 126
            Height = 28
            TabOrder = 2
          end
          object txtSMatricula: TEdit
            Left = 279
            Top = 130
            Width = 140
            Height = 28
            TabOrder = 3
          end
          object txtQtdeItens: TEdit
            Left = 425
            Top = 130
            Width = 93
            Height = 28
            TabOrder = 4
          end
          object txtSItens: TEdit
            Left = 49
            Top = 186
            Width = 469
            Height = 28
            TabOrder = 5
          end
        end
      end
    end
    object tabLinkDePagamento: TTabSheet
      Caption = 'Link Pagamento'
      ImageIndex = 1
      object tabModalidadesLinkPagamento: TPageControl
        Left = 0
        Top = 0
        Width = 585
        Height = 285
        ActivePage = tabGerarLinkPagamento
        Align = alClient
        TabOrder = 0
        object tabGerarLinkPagamento: TTabSheet
          Caption = 'Gerar Link'
          object lbSItensLink: TLabel
            Left = 48
            Top = 146
            Width = 31
            Height = 20
            Caption = 'Itens'
          end
          object lbSTelefone: TLabel
            Left = 48
            Top = 206
            Width = 57
            Height = 20
            Caption = 'Telefone'
          end
          object lbSTexto: TLabel
            Left = 147
            Top = 205
            Width = 36
            Height = 20
            Caption = 'Texto'
          end
          object lbQtdeItensLink: TLabel
            Left = 48
            Top = 86
            Width = 68
            Height = 20
            Caption = 'Qtde Itens'
          end
          object btnGerarLink: TButton
            Left = 48
            Top = 24
            Width = 211
            Height = 56
            Caption = 'Gerar Link'
            TabOrder = 0
            OnClick = btnGerarLinkClick
          end
          object txtSItensLink: TEdit
            Left = 48
            Top = 172
            Width = 469
            Height = 28
            TabOrder = 2
          end
          object txtSTexto: TEdit
            Left = 147
            Top = 231
            Width = 370
            Height = 28
            TabOrder = 4
          end
          object txtSTelefone: TEdit
            Left = 48
            Top = 232
            Width = 93
            Height = 28
            TabOrder = 3
          end
          object txtQtdeItensLink: TEdit
            Left = 48
            Top = 112
            Width = 93
            Height = 28
            TabOrder = 1
          end
        end
        object tabAdmLinkDePagamento: TTabSheet
          Caption = 'Administra'#231#227'o'
          ImageIndex = 1
          object btnManutencaoLink: TButton
            Left = 307
            Top = 24
            Width = 211
            Height = 56
            Caption = 'Manuten'#231#227'o Link'
            TabOrder = 1
            OnClick = btnManutencaoLinkClick
          end
          object btnListarLink: TButton
            Left = 48
            Top = 24
            Width = 211
            Height = 56
            Caption = 'Listar Link'
            TabOrder = 0
            OnClick = btnListarLinkClick
          end
        end
      end
    end
    object tabPIX: TTabSheet
      Caption = 'PIX'
      ImageIndex = 2
      object btnPIX: TButton
        Left = 50
        Top = 32
        Width = 211
        Height = 56
        Caption = 'PIX'
        TabOrder = 0
        OnClick = btnPIXClick
      end
    end
    object tabRecargaCelular: TTabSheet
      Caption = 'Recarga Celular'
      ImageIndex = 5
      object btnRecargaCelular: TButton
        Left = 50
        Top = 32
        Width = 211
        Height = 56
        Caption = 'Recarga de Celular'
        TabOrder = 0
        OnClick = btnRecargaCelularClick
      end
    end
    object tabParceleMais: TTabSheet
      Caption = 'Parcele Mais'
      ImageIndex = 4
      object btnParceleMais: TButton
        Left = 50
        Top = 32
        Width = 211
        Height = 56
        Caption = 'Parcele Mais'
        TabOrder = 0
        OnClick = btnParceleMaisClick
      end
    end
    object tabAdministracao: TTabSheet
      Caption = 'Administra'#231#227'o'
      ImageIndex = 3
      object btnReimpressaoDireto: TButton
        Left = 50
        Top = 120
        Width = 211
        Height = 56
        Caption = 'Reimpress'#227'o Direto'
        TabOrder = 2
        OnClick = btnReimpressaoDiretoClick
      end
      object btnAtv: TButton
        Left = 311
        Top = 120
        Width = 211
        Height = 56
        Caption = 'ATV'
        TabOrder = 3
        OnClick = btnAtvClick
      end
      object btnReimpressao: TButton
        Left = 50
        Top = 32
        Width = 211
        Height = 56
        Caption = 'Reimpress'#227'o'
        TabOrder = 0
        OnClick = btnReimpressaoClick
      end
      object btnRelatorio: TButton
        Left = 311
        Top = 208
        Width = 211
        Height = 56
        Caption = 'Relat'#243'rio de Vendas'
        TabOrder = 5
        OnClick = btnRelatorioClick
      end
      object btnAdm: TButton
        Left = 50
        Top = 208
        Width = 211
        Height = 56
        Caption = 'ADM'
        TabOrder = 4
        OnClick = btnAdmClick
      end
      object btnCancelamento: TButton
        Left = 311
        Top = 32
        Width = 211
        Height = 56
        Caption = 'Cancelamento'
        TabOrder = 1
        OnClick = btnCancelamentoClick
      end
    end
  end
  object memoLog: TMemo
    Left = 8
    Top = 501
    Width = 892
    Height = 237
    Lines.Strings = (
      'memoLog')
    ScrollBars = ssBoth
    TabOrder = 1
  end
  object memoComprovante: TMemo
    Left = 607
    Top = 26
    Width = 293
    Height = 469
    Lines.Strings = (
      'memoComprovante')
    ScrollBars = ssBoth
    TabOrder = 2
  end
  object pDadosOperacao: TPanel
    Left = 8
    Top = 26
    Width = 593
    Height = 143
    BorderStyle = bsSingle
    TabOrder = 3
    object lbIParcela: TLabel
      Left = 407
      Top = 11
      Width = 47
      Height = 20
      Caption = 'Parcela'
    end
    object lbDValor: TLabel
      Left = 223
      Top = 11
      Width = 75
      Height = 20
      Caption = 'Valor (0,00)'
    end
    object lbICupom: TLabel
      Left = 63
      Top = 11
      Width = 48
      Height = 20
      Caption = 'Cupom'
    end
    object lbSControle: TLabel
      Left = 43
      Top = 71
      Width = 128
      Height = 20
      Caption = 'Controle (Cancelar)'
    end
    object lbSNsu: TLabel
      Left = 412
      Top = 71
      Width = 85
      Height = 20
      Caption = 'Nsu (Reimp.)'
    end
    object lbData: TLabel
      Left = 224
      Top = 71
      Width = 138
      Height = 20
      Caption = 'Data (Reimp. Direto)'
    end
    object txtIParcela: TEdit
      Left = 407
      Top = 37
      Width = 121
      Height = 28
      TabOrder = 2
    end
    object txtDValor: TEdit
      Left = 223
      Top = 37
      Width = 121
      Height = 28
      TabOrder = 1
    end
    object txtICupom: TEdit
      Left = 63
      Top = 37
      Width = 97
      Height = 28
      TabOrder = 0
    end
    object txtSControle: TEdit
      Left = 43
      Top = 97
      Width = 138
      Height = 28
      TabOrder = 3
    end
    object txtSNsu: TEdit
      Left = 412
      Top = 97
      Width = 136
      Height = 28
      TabOrder = 5
    end
    object txtData: TEdit
      Left = 224
      Top = 97
      Width = 145
      Height = 28
      TabOrder = 4
    end
  end
  object MultiplusCardTefGP1: TMultiplusCardTefGP
    Configuracoes.NomeDLL = 'TefClientmc.dll'
    Configuracoes.ILeitor = 0
    OnRegistrarLog = MultiplusCardTefGP1RegistrarLog
    OnMsg = MultiplusCardTefGP1Msg
    OnGerarComprovante = MultiplusCardTefGP1GerarComprovante
    OnFalhaOperacao = MultiplusCardTefGP1FalhaOperacao
    Left = 840
    Top = 32
  end
end
