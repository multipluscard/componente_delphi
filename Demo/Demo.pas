unit Demo;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls,
  MultiplusCardTef, MultiplusCardPinPDV, MultiplusCardCommons, MultiplusCardUtils, System.Threading,StrUtils,
  System.Generics.Collections;

type
  TForm1 = class(TForm)
    btnExecutar: TButton;
    MultiplusCardTef1: TMultiplusCardTef;
    mRetornoComprovante: TMemo;
    lblRetornoComprovante: TLabel;
    lblLog: TLabel;
    mLog: TMemo;
    MultiplusCardPinPDV1: TMultiplusCardPinPDV;
    gpTipoCaptura: TGroupBox;
    rbDll: TRadioButton;
    rbPinpdvApi: TRadioButton;
    ProgressBar: TProgressBar;
    gpParametros: TGroupBox;
    lbValor: TLabel;
    lblNsu: TLabel;
    lbParcela: TLabel;
    lbOperacao: TLabel;
    lbCupom: TLabel;
    txbValor: TEdit;
    txbParcela: TEdit;
    txbNsu: TEdit;
    txbCupom: TEdit;
    cbxOperacoes: TComboBox;
    cbxPinpdvDispositivos: TComboBox;
    btnAtualizarPinpdv: TButton;
    lbPinpdvDispositivos: TLabel;
    pnlMensagem: TPanel;
    btnCancelar: TButton;
    btnTestarFormPadrao: TButton;
    btnTestarFormPersonalizado: TButton;
    txbIdentificadorPinpdv: TEdit;
    lblPinpdvPadrao: TLabel;
    lblIdentificadorUnico: TLabel;
    cbxPinpdvGerarIdAuto: TCheckBox;
    cbxOperacoesPinPDV: TComboBox;
    txbParametrosDll: TEdit;
    lblParametrosDll: TLabel;
    rbPinpdvApiPrevenda: TRadioButton;
    chbTipoForm: TCheckBox;

    // Eventos TEF DLL
    procedure MultiplusCardTef1CpfInformado(Sender: TObject;
      const Conteudo: string);
    procedure MultiplusCardTef1FalhaOperacao(Sender: TObject;
      const Conteudo: string);
    procedure MultiplusCardTef1RelatorioTransacoes(Sender: TObject;
      const Retorno: TMultiplusCardRetornoList);
    procedure MultiplusCardTef1GerarComprovante(Sender: TObject;
      const Retorno: TMultiplusCardRetorno);
    procedure MultiplusCardTef1Menssagem(Sender: TObject;
      const Conteudo: string);
    procedure MultiplusCardTef1Pinpad(Sender: TObject;
      const Conteudo: string);
    procedure MultiplusCardTef1RegistrarLog(Sender: TObject;
      const Conteudo: string);
    procedure MultiplusCardTef1QrCodeGerado(Sender: TObject;
      const Conteudo: string);
    procedure MultiplusCardTef1SolicitarInteracao(Sender: TObject;
      const Solicitacao: TSolicitacaoUsuario; var Resposta: TRespostaUsuario);

    // Eventos PinPDV API
    procedure MultiplusCardPinPDV1RegistrarLog(Sender: TObject;
      const Dados: string);
    procedure MultiplusCardPinPDV1FalhaOperacao(Sender: TObject;
      const Erro: string);
    procedure MultiplusCardPinPDV1Transacao(Sender: TObject;
      const Transacao: string);
    procedure MultiplusCardPinPDV1SolicitarCancelamento(Sender: TObject;
      const Identificador: string; Tentativa: Integer; var PermitirCancelar: Boolean);
    procedure MultiplusCardPinPDV1SolicitarInteracao(Sender: TObject;
      const Solicitacao: TSolicitacaoUsuario; var Resposta: TRespostaUsuario);
    procedure MultiplusCardPinPDV1GerarComprovante(Sender: TObject;
      const Retorno: TMultiplusCardRetorno);

    // Eventos de Controles de Interface
    procedure FormCreate(Sender: TObject);
    procedure btnExecutarClick(Sender: TObject);
    procedure btnAtualizarPinpdvClick(Sender: TObject);
    procedure btnCancelarClick(Sender: TObject);
    procedure btnTestarFormPadraoClick(Sender: TObject);
    procedure btnTestarFormPersonalizadoClick(Sender: TObject);
    procedure pnlMensagemClick(Sender: TObject);
    procedure MultiplusCardPinPDV1SolicitarImpressao(Sender: TObject;
      const PreVenda: TPreVenda);
    procedure chbTipoFormClick(Sender: TObject);

  private
    // Configuração de Componentes
    procedure ConfigurarComponenteDll;
    procedure ConfigurarComponentePinPDV;

    // Operações TEF DLL
    procedure ExecutarTransacaoDll;

    // Operações PinPDV API
    procedure ExecutarTransacaoPinpdvApi;
    procedure ExecutarTransacaoPinpdvApiPrevenda;

    // Controles de Interface
    procedure PopularComboOperacoes;
    procedure PopularComboOperacoesPinPDV;
    procedure AjustaVisualInciaTransacao(Ativa: Boolean);

    // Funções Auxiliares TEF DLL
    function GetOperacaoSelecionada: TOperacao;
    function GetNomeOperacao(AOperacao: TOperacao): string;

    // Funções Auxiliares PinPDV
    function GetOperacaoPinPDVSelecionada: Integer;
    function MapearOperacaoPinPDVParaTipoPagamento(AOperacaoPinPDV: Integer): TTipoPagamento;
    function ObterIdentificadorPinPDV: string;
    function GetDispositivoSelecionadoId: Integer;

  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

// =============================================================================
// CONFIGURAÇÃO E INICIALIZAÇÃO
// =============================================================================

procedure TForm1.FormCreate(Sender: TObject);
begin
  PopularComboOperacoes;
  PopularComboOperacoesPinPDV;
  // Seleciona DLL por padrão
  rbDll.Checked := True;
end;



procedure TForm1.ConfigurarComponenteDll;
begin
  MultiplusCardTef1.Configuracoes.CnpjEmpresa   := 'CnpjEmpresa';
  MultiplusCardTef1.Configuracoes.CodigoLoja    := 'CodigoLoja';
  MultiplusCardTef1.Configuracoes.Data          := FormatDateTime('yyyyMMdd', Now);
  MultiplusCardTef1.Configuracoes.PontoDeVenda  := 'PontoDeVenda';
//  MultiplusCardTef1.UsaFormPadrao               := False;
end;

procedure TForm1.ConfigurarComponentePinPDV;
begin
  MultiplusCardPinPDV1.Configuracoes.BaseURL := 'BaseURL';
  MultiplusCardPinPDV1.Configuracoes.Token := 'Token';
end;

// =============================================================================
// CONTROLES DE INTERFACE
// =============================================================================

procedure TForm1.PopularComboOperacoes;
begin
  cbxOperacoes.Clear;

  // Adiciona as operações com nomes amigáveis
  cbxOperacoes.Items.AddObject('Débito', TObject(Ord(tpiComando_DEBITO)));
  cbxOperacoes.Items.AddObject('Débito à Vista', TObject(Ord(tpiComando_DEBITO_A_VISTA)));
  cbxOperacoes.Items.AddObject('Crédito', TObject(Ord(tpiComando_CREDITO)));
  cbxOperacoes.Items.AddObject('Crédito à Vista', TObject(Ord(tpiComando_CREDITO_A_VISTA)));
  cbxOperacoes.Items.AddObject('Crédito Parc. Loja', TObject(Ord(tpiComando_CREDITO_PARC_LOJA)));
  cbxOperacoes.Items.AddObject('Crédito Parc. ADM', TObject(Ord(tpiComando_CREDITO_PARC_ADM)));
  cbxOperacoes.Items.AddObject('Frota', TObject(Ord(tpiComando_FROTA)));
  cbxOperacoes.Items.AddObject('Voucher', TObject(Ord(tpiComando_VOUCHER)));
  cbxOperacoes.Items.AddObject('Pré-Autorização', TObject(Ord(tpiComando_PRE_AUTORIZACAO)));
  cbxOperacoes.Items.AddObject('Confirmar Pré-Autorização', TObject(Ord(tpiComando_CONF_PRE_AUTORIZACAO)));
  cbxOperacoes.Items.AddObject('Cancelar Pré-Autorização', TObject(Ord(tpiComando_CANC_PRE_AUTORIZACAO)));
  cbxOperacoes.Items.AddObject('Consulta Saldo Crédito', TObject(Ord(tpiComando_CONSULTA_SALDO_CREDITO)));
  cbxOperacoes.Items.AddObject('Consulta Saldo Débito', TObject(Ord(tpiComando_CONSULTA_SALDO_DEBITO)));
  cbxOperacoes.Items.AddObject('Excluir BINS', TObject(Ord(tpiComando_EXCLUIR_BINS)));
  cbxOperacoes.Items.AddObject('Reimpressão', TObject(Ord(tpiComando_REIMPRESSAO)));
  cbxOperacoes.Items.AddObject('Coleta de CPF', TObject(Ord(tpiComando_COLETA_DE_CPF)));
  cbxOperacoes.Items.AddObject('PIX Opções PSP', TObject(Ord(tpiComando_OPCOES_PSP)));
  cbxOperacoes.Items.AddObject('PIX Cliente', TObject(Ord(tpiComando_PSP_CLIENTE)));

  cbxOperacoes.Items.AddObject('Cancelar/Estorno', TObject(Ord(tpiComando_ESTORNO)));
  cbxOperacoes.Items.AddObject('Cancelar/Estorno PIX', TObject(Ord(tpiComando_ESTORNO_PIX)));
  cbxOperacoes.Items.AddObject('Status Transação PIX', TObject(Ord(tpiComando_STATUS_TRANSACAO_PIX)));
  cbxOperacoes.Items.AddObject('Limpeza de Tabelas', TObject(Ord(tpiComando_LIMPEZA_TABELA)));
  cbxOperacoes.Items.AddObject('Relatório de Transações', TObject(Ord(tpiComando_REALATORIO_TRANSACOES)));
  cbxOperacoes.Items.AddObject('POS TEF', TObject(Ord(tpiComando_POS_TEF)));

  cbxOperacoes.Items.AddObject('Remove PIX', TObject(Ord(tpiComando_REMOVE_PIX)));
  cbxOperacoes.Items.AddObject('Reimpressão PIX', TObject(Ord(tpiComando_REIMPRESSAO_PIX)));
  cbxOperacoes.Items.AddObject('Comprovante POS', TObject(Ord(tpiComando_COMPROVANTE_POS)));
  cbxOperacoes.Items.AddObject('Status POS TEF', TObject(Ord(tpiComando_STATUS_POS_TEF)));
  cbxOperacoes.Items.AddObject('Cancelar POS TEF', TObject(Ord(tpiComando_CANCELAR_POS_TEF)));
  cbxOperacoes.Items.AddObject('Pré Venda', TObject(Ord(tpiComando_PRE_VENDA)));
  cbxOperacoes.Items.AddObject('Status Pré Venda', TObject(Ord(tpiComando_STATUS_PRE_VENDA)));
  cbxOperacoes.Items.AddObject('Cancelar Pré Venda', TObject(Ord(tpiComando_CANCELAR_PRE_VENDA)));
  cbxOperacoes.Items.AddObject('Confirma Transação', TObject(Ord(tpiComando_CONFIRMA_TRANSACAO)));
  cbxOperacoes.Items.AddObject('Desfaz Transaçao', TObject(Ord(tpiComando_DESFAZ_TRANSACAO)));

  cbxOperacoes.Items.AddObject('Status PINPAD', TObject(Ord(tpiComando_STATUS_PINPAD)));
  cbxOperacoes.Items.AddObject('Informações PINPAD', TObject(Ord(tpiComando_INFORMACAO_PINPAD)));
  // Seleciona o primeiro item por padrão
  if cbxOperacoes.Items.Count > 0 then
    cbxOperacoes.ItemIndex := 0;
end;

procedure TForm1.PopularComboOperacoesPinPDV;
begin
  cbxOperacoesPinPDV.Clear;

  // Adiciona as operações com nomes amigáveis
  cbxOperacoesPinPDV.Items.AddObject('Não Informado', TObject(Ord(tpiComandoPinpdv_NAO_INFORMADO)));
  cbxOperacoesPinPDV.Items.AddObject('Dinheiro', TObject(Ord(tpiComandoPinpdv_DINHEIRO)));
  cbxOperacoesPinPDV.Items.AddObject('Pix', TObject(Ord(tpiComandoPinpdv_PIX)));
  cbxOperacoesPinPDV.Items.AddObject('Débito', TObject(Ord(tpiComandoPinpdv_DEBITO)));
  cbxOperacoesPinPDV.Items.AddObject('Crédito à Vista', TObject(Ord(tpiComandoPinpdv_CREDITO_A_VISTA )));
  cbxOperacoesPinPDV.Items.AddObject('Crédito Parc. LOJA', TObject(Ord(tpiComandoPinpdv_CREDITO_PARC_LOJA)));
  cbxOperacoesPinPDV.Items.AddObject('Voucher', TObject(Ord(tpiComando_VOUCHER)));

  // Seleciona o primeiro item por padrão
  if cbxOperacoesPinPDV.Items.Count > 0 then
    cbxOperacoesPinPDV.ItemIndex := 0;
end;

procedure TForm1.AjustaVisualInciaTransacao(Ativa: Boolean);
begin
  if Ativa then
  begin
    // Ativa o "loading infinito"
    gpTipoCaptura.Enabled := False;
    ProgressBar.Style := pbstMarquee;
    ProgressBar.MarqueeInterval := 50;
    gpParametros.Enabled := False;
    btnExecutar.Enabled := False;
    btnCancelar.Enabled := True;
  end
  else
  begin
    // Desativa o "loading infinito"
    gpTipoCaptura.Enabled := True;
    ProgressBar.Style := pbstNormal;
    ProgressBar.Position := 0;  // Reseta a barra
    gpParametros.Enabled := True;
    btnExecutar.Enabled := True;
    btnCancelar.Enabled := False;
  end;
end;

procedure TForm1.btnExecutarClick(Sender: TObject);
begin
  try

    mRetornoComprovante.Clear;
    pnlMensagem.Caption := '';

    if rbDll.Checked then
      ExecutarTransacaoDll
    else if rbPinpdvApi.Checked then
      ExecutarTransacaoPinpdvApi
    else
      ExecutarTransacaoPinpdvApiPrevenda
  except
    on E: Exception do
    begin
      ShowMessage('Erro ao executar transação: ' + E.Message);
      mLog.Lines.Add('ERRO: ' + E.Message);
    end;
  end;
end;

procedure TForm1.btnCancelarClick(Sender: TObject);
var
  Identificador: string;
begin
  try
    if rbDll.Checked then
      MultiplusCardTef1.CancelarFluxo
    else
    begin
      MultiplusCardPinPDV1.CancelarFluxoPosTefMonitorado
    end;

  except
    on E: Exception do
    begin
      ShowMessage('Erro ao executar transação: ' + E.Message);
      mLog.Lines.Add('ERRO: ' + E.Message);
    end;
  end;
end;

procedure TForm1.btnAtualizarPinpdvClick(Sender: TObject);
var
  ListaDispositivos: TListaPinPDV;
  I: Integer;
begin
  try
    ConfigurarComponentePinPDV;
    cbxPinpdvDispositivos.Clear;
    cbxPinpdvDispositivos.Items.Add('');

    ListaDispositivos := MultiplusCardPinPDV1.ListarDispositivosPinPDV;

    try
      for I := 0 to ListaDispositivos.Data.Count - 1 do
      begin
        // Adicionar apenas dispositivos ativos
        if ListaDispositivos.Data[I].IsAtivo then
        begin
          cbxPinpdvDispositivos.Items.AddObject(
            Format('%s - %s', [
              ListaDispositivos.Data[I].Codigo,
              ListaDispositivos.Data[I].Nome
            ]),
            TObject(ListaDispositivos.Data[I].Id)
          );
        end;
      end;

      cbxPinpdvDispositivos.ItemIndex := 0;

    finally
      ListaDispositivos.Free;
    end;

  except
    on E: Exception do
    begin
      ShowMessage('Erro ao carregar dispositivos: ' + E.Message);
      cbxPinpdvDispositivos.Items.Clear;
      cbxPinpdvDispositivos.Items.Add('Erro ao carregar...');
      cbxPinpdvDispositivos.ItemIndex := 0;
    end;
  end;
end;

procedure TForm1.btnTestarFormPadraoClick(Sender: TObject);
begin
  MultiplusCardTef1.objUi.TestarFormularioPadrao;
end;

procedure TForm1.btnTestarFormPersonalizadoClick(Sender: TObject);
begin
  MultiplusCardTef1.objUi.TestarFormularioPersonalizado;
end;

procedure TForm1.chbTipoFormClick(Sender: TObject);
begin
  MultiplusCardTef1.Configuracoes.UsaFormPadrao := chbTipoForm.Checked;
  MultiplusCardPinPDV1.Configuracoes.UsaFormPadrao := chbTipoForm.Checked;
end;

procedure TForm1.pnlMensagemClick(Sender: TObject);
begin
  //pnlMensagem.Caption := '';
end;

// =============================================================================
// OPERAÇÕES TEF DLL
// =============================================================================

procedure TForm1.ExecutarTransacaoDll;
var
  OperacaoSelecionada: TOperacao;
  Cupom, Nsu, Valor,Parametros: string;
  Parcela: Integer;


begin
  OperacaoSelecionada := GetOperacaoSelecionada;
  ConfigurarComponenteDll;
  Cupom := txbCupom.Text;
  Nsu := txbNsu.Text;
  Parametros := txbParametrosDll.Text;
  Valor := txbValor.Text;
  Parcela := StrToInt(txbParcela.Text);
  Parametros := txbParametrosDll.Text;

  AjustaVisualInciaTransacao(true);

  TTask.Run(
    procedure
    var
      Resultado: Boolean;
      MsgErro: string;
    begin
      MsgErro := '';
      try
        Resultado := MultiplusCardTef1.EfetuaTransacao(
          OperacaoSelecionada,
          Cupom,
          Nsu,
          Valor,
          Parcela,
          Parametros
        );
      except
        on E: Exception do
        begin
          Resultado := False;
          MsgErro := E.Message;
        end;
      end;





      TThread.Synchronize(nil,
        procedure
        begin
          try
            if MsgErro <> '' then
              mLog.Lines.Add('Erro: ' + MsgErro)
            else if Resultado then
              mLog.Lines.Add('Transação concluída com sucesso')
            else
              mLog.Lines.Add('Transação cancelada ou falhou');
          finally
              AjustaVisualInciaTransacao(false);

          end;
        end);
    end);
end;

// =============================================================================
// OPERAÇÕES PINPDV API
// =============================================================================

procedure TForm1.ExecutarTransacaoPinpdvApi;
var
  DispositivoId: Integer;
  OperacaoSelecionada: Integer;
  TipoPagamento: TTipoPagamento;
  Identificador: string;
  Valor: Currency;
  Parcelas: Integer;
  TransacaoId: Integer;
begin
  // Configura componente e eventos
  ConfigurarComponentePinPDV;

  // Validações básicas
  DispositivoId := GetDispositivoSelecionadoId;
  if DispositivoId = 0 then
  begin
    ShowMessage('Selecione um dispositivo PinPDV primeiro!');
    Exit;
  end;

  // Captura dados da interface
  try
    var ValorTexto := Trim(txbValor.Text);
    ValorTexto := StringReplace(ValorTexto, '.', '', [rfReplaceAll]);
    ValorTexto := StringReplace(ValorTexto, ',', FormatSettings.DecimalSeparator, [rfReplaceAll]);
    Valor := StrToCurr(ValorTexto);
    if Valor <= 0 then
    begin
      ShowMessage('Valor deve ser maior que zero!');
      Exit;
    end;
  except
    on E: Exception do
    begin
      ShowMessage('Valor inválido: ' + txbValor.Text + sLineBreak + 'Erro: ' + E.Message);
      Exit;
    end;
  end;

  try
    Parcelas := StrToInt(txbParcela.Text);
    if Parcelas <= 0 then
      Parcelas := 1;
  except
    Parcelas := 1;
  end;

  // Mapeia operação selecionada
  OperacaoSelecionada := GetOperacaoPinPDVSelecionada;
  TipoPagamento := MapearOperacaoPinPDVParaTipoPagamento(OperacaoSelecionada);

  // Obtém identificador único
  Identificador := ObterIdentificadorPinPDV;
  Identificador := StringReplace(Identificador, '''', '', [rfReplaceAll]);


  mLog.Lines.Add('=== INICIANDO TRANSAÇÃO PINPDV COM MONITORAMENTO ===');
  mLog.Lines.Add('Dispositivo ID: ' + IntToStr(DispositivoId));
  mLog.Lines.Add('Identificador: ' + Identificador);
  mLog.Lines.Add('Valor: ' + CurrToStr(Valor));
  mLog.Lines.Add('Parcelas: ' + IntToStr(Parcelas));
  mLog.Lines.Add('Tipo Pagamento: ' + IntToStr(Ord(TipoPagamento)));

  // Inicia loading
  AjustaVisualInciaTransacao(True);
  try
    begin
      try
    // NOVA CHAMADA: Usa o método com monitoramento automático
      TransacaoId := MultiplusCardPinPDV1.CadastrarPosVendaComMonitoramento(
      DispositivoId,
      Identificador,
      'Transação Demo PinPDV',
      Valor,
      TipoPagamento,
      Parcelas
    );

  except
    on E: Exception do
    begin
      mLog.Lines.Add('ERRO ao cadastrar transação: ' + E.Message);
      ShowMessage('Erro na transação PinPDV: ' + E.Message);
      AjustaVisualInciaTransacao(False);
    end;
  end;
    end;
  finally
    AjustaVisualInciaTransacao(False);
  end;
end;

procedure TForm1.ExecutarTransacaoPinpdvApiPrevenda;
var
  DispositivoId: Integer;
  OperacaoSelecionada: Integer;
  TipoPagamento: TTipoPagamento;
  Identificador: string;
  Valor: Currency;
  Parcelas: Integer;
  TransacaoId: Integer;
begin
  // Configura componente e eventos
  ConfigurarComponentePinPDV;

  // Captura dados da interface
  try
    var ValorTexto := Trim(txbValor.Text);
    ValorTexto := StringReplace(ValorTexto, '.', '', [rfReplaceAll]);
    ValorTexto := StringReplace(ValorTexto, ',', FormatSettings.DecimalSeparator, [rfReplaceAll]);
    Valor := StrToCurr(ValorTexto);
    if Valor <= 0 then
    begin
      ShowMessage('Valor deve ser maior que zero!');
      Exit;
    end;
  except
    on E: Exception do
    begin
      ShowMessage('Valor inválido: ' + txbValor.Text + sLineBreak + 'Erro: ' + E.Message);
      Exit;
    end;
  end;

  try
    Parcelas := StrToInt(txbParcela.Text);
    if Parcelas <= 0 then
      Parcelas := 1;
  except
    Parcelas := 1;
  end;

  // Mapeia operação selecionada
  OperacaoSelecionada := GetOperacaoPinPDVSelecionada;
  TipoPagamento := MapearOperacaoPinPDVParaTipoPagamento(OperacaoSelecionada);

  // Obtém identificador único
  Identificador := ObterIdentificadorPinPDV;
  Identificador := StringReplace(Identificador, '''', '', [rfReplaceAll]);

  // Dispositivo é opcional para pré-venda
  DispositivoId := GetDispositivoSelecionadoId;

  mLog.Lines.Add('=== INICIANDO PRÉ-VENDA PINPDV COM MONITORAMENTO ===');
  mLog.Lines.Add('Dispositivo ID: ' + IntToStr(DispositivoId) + ' (opcional)');
  mLog.Lines.Add('Identificador: ' + Identificador);
  mLog.Lines.Add('Valor: ' + CurrToStr(Valor));
  mLog.Lines.Add('Parcelas: ' + IntToStr(Parcelas));
  mLog.Lines.Add('Tipo Pagamento: ' + IntToStr(Ord(TipoPagamento)));

  // Inicia loading
    AjustaVisualInciaTransacao(True);
  try
    begin

      try
      // NOVA CHAMADA: Usa o método de pré-venda com monitoramento automático
      TransacaoId := MultiplusCardPinPDV1.CadastrarPreVendaComMonitoramento(
        Identificador,           // Identificador único
        Identificador,           // Descrição
        Valor,                   // Valor
        Parcelas,                // Parcelas
        TipoPagamento,           // Tipo de pagamento
        DispositivoId            // ID do dispositivo (opcional, 0 = qualquer)
      );

      if TransacaoId > 0 then
        mLog.Lines.Add('Pré-venda cadastrada com ID: ' + IntToStr(TransacaoId))
      else
        mLog.Lines.Add('Falha ao cadastrar pré-venda');

    except
      on E: Exception do
      begin
        mLog.Lines.Add('ERRO ao cadastrar pré-venda: ' + E.Message);
        ShowMessage('Erro na pré-venda PinPDV: ' + E.Message);
      end;
    end;

    end;
  finally
    AjustaVisualInciaTransacao(False);
  end;
end;

// =============================================================================
// EVENTOS TEF DLL
// =============================================================================

procedure TForm1.MultiplusCardTef1CpfInformado(Sender: TObject;
  const Conteudo: string);
begin
  mRetornoComprovante.Lines.Clear;
  mRetornoComprovante.Lines.Clear;
  mRetornoComprovante.Lines.Add('===   COLETA DE CPF   ===');
  mRetornoComprovante.Lines.Add(Conteudo);
  mRetornoComprovante.Lines.Add('=========================');
end;

procedure TForm1.MultiplusCardTef1FalhaOperacao(Sender: TObject;
  const Conteudo: string);
begin
  mRetornoComprovante.Lines.Clear;
  mRetornoComprovante.Lines.Add('Erro: ' + Conteudo);
end;

procedure TForm1.MultiplusCardTef1GerarComprovante(Sender: TObject;
  const Retorno: TMultiplusCardRetorno);
begin
  mRetornoComprovante.Lines.Clear;
  mRetornoComprovante.Lines.Add('=== COMPROVANTE DLL TEF ===');
  mRetornoComprovante.Lines.Add(Retorno.COMPROVANTE);
  mRetornoComprovante.Lines.Add('=========================');
  mRetornoComprovante.Lines.Add(' ');
  mRetornoComprovante.Lines.Add('=== COMPROVANTE REDUZIDO DLL TEF ===');
  mRetornoComprovante.Lines.Add(Retorno.COMPROVANTE_REDUZIDO);
  mRetornoComprovante.Lines.Add('=========================');
  mRetornoComprovante.Lines.Add(' ');
  mRetornoComprovante.Lines.Add('=== COMPROVANTE CLIENTE DLL TEF ===');
  mRetornoComprovante.Lines.Add(Retorno.COMPROVANTE_CLIENTE);
  mRetornoComprovante.Lines.Add('=========================');
  mRetornoComprovante.Lines.Add(' ');
  mRetornoComprovante.Lines.Add('=== COMPROVANTE ESTABELECIMENTO DLL TEF ===');
  mRetornoComprovante.Lines.Add(Retorno.COMPROVANTE_ESTABELECIMENTO);
  mRetornoComprovante.Lines.Add('=========================');
  mRetornoComprovante.Lines.Add(' ');

  mRetornoComprovante.Lines.Add('CUPOM: '                  + Retorno.CUPOM);
  mRetornoComprovante.Lines.Add('VALOR: '                  + Retorno.VALOR);
  mRetornoComprovante.Lines.Add('COD_BANDEIRA: '           + Retorno.COD_BANDEIRA);
  mRetornoComprovante.Lines.Add('COD_REDE: '               + Retorno.COD_REDE);
  mRetornoComprovante.Lines.Add('COD_AUTORIZACAO: '        + Retorno.COD_AUTORIZACAO);
  mRetornoComprovante.Lines.Add('NSU: '                    + Retorno.NSU);
  mRetornoComprovante.Lines.Add('QTDE_PARCELAS: '          + Retorno.QTDE_PARCELAS);
  mRetornoComprovante.Lines.Add('TAXA_SERVICO: '           + Retorno.TAXA_SERVICO);
  mRetornoComprovante.Lines.Add('BIN_CARTAO: '             + Retorno.BIN_CARTAO);
  mRetornoComprovante.Lines.Add('ULTIMOS_DIGITOS_CARTAO: ' + Retorno.ULTIMOS_DIGITOS_CARTAO);
  mRetornoComprovante.Lines.Add('CNPJ_AUTORIZADORA: '      + Retorno.CNPJ_AUTORIZADORA);
  mRetornoComprovante.Lines.Add('NOME_CLIENTE: '           + Retorno.NOME_CLIENTE);
  mRetornoComprovante.Lines.Add('NSU_REDE: '               + Retorno.NSU_REDE);
  mRetornoComprovante.Lines.Add('NUM_VIAS_COMPROVANTE: '   + Retorno.NUM_VIAS_COMPROVANTE);
  mRetornoComprovante.Lines.Add('VENCTO_CARTAO: '          + Retorno.VENCTO_CARTAO);
  mRetornoComprovante.Lines.Add('NOME_BANDEIRA: '          + Retorno.NOME_BANDEIRA);
  mRetornoComprovante.Lines.Add('NOME_REDE: '              + Retorno.NOME_REDE);
  mRetornoComprovante.Lines.Add('CARTAO_PRE_PAGO: '        + Retorno.CARTAO_PRE_PAGO);
  mRetornoComprovante.Lines.Add('COD_TIPO_TRANSACAO: '     + Retorno.COD_TIPO_TRANSACAO);
  mRetornoComprovante.Lines.Add('DESC_TIPO_TRANSACAO: '    + Retorno.DESC_TIPO_TRANSACAO);
  mRetornoComprovante.Lines.Add('E2E (PIX): '              + Retorno.E2E);
end;

procedure TForm1.MultiplusCardTef1Menssagem(Sender: TObject; const Conteudo: string);
begin
  if StartsText('[MSG]', Conteudo) then
  begin
    pnlMensagem.Caption := Copy(Conteudo, 7, Length(Conteudo));
    pnlMensagem.Font.Color := clBlue;
  end
  else if StartsText('[ERRODISPLAY]', Conteudo) then
  begin
    pnlMensagem.Caption := Copy(Conteudo, 15, Length(Conteudo));
    pnlMensagem.Font.Color := clRed;
  end
else if StartsText('[ERROABORTAR]', Conteudo) then
  begin
    //
  end
else if StartsText('[RETORNO]', Conteudo) then
  begin
    pnlMensagem.Caption := 'Transação realizada com sucesso!';
    pnlMensagem.Font.Color := clBlue;
  end
else if StartsText('[MENU]', Conteudo) then
  begin
    pnlMensagem.Caption := 'Aguardando resposta do menu.';
    pnlMensagem.Font.Color := clGray;
  end
else if StartsText('[PERGUNTA]', Conteudo) then
  begin
    pnlMensagem.Caption := 'Aguardando resposta da pergunta.';
    pnlMensagem.Font.Color := clGray;
  end
else
  pnlMensagem.Caption := Conteudo;
  pnlMensagem.Font.Color := clBlack;
end;

procedure TForm1.MultiplusCardTef1Pinpad(Sender: TObject;
  const Conteudo: string);
begin
  mRetornoComprovante.Lines.Clear;
  mRetornoComprovante.Lines.Clear;
  mRetornoComprovante.Lines.Add('===      PINPAD       ===');
  mRetornoComprovante.Lines.Add(Conteudo);
  mRetornoComprovante.Lines.Add('=========================');
end;

procedure TForm1.MultiplusCardTef1QrCodeGerado(Sender: TObject;
  const Conteudo: string);
begin

 //ExibirQrCode no arquivo CliMC.ini
 {
    0 Retorno por string para a automação realizar a exibição em uma janela personalizada.
    1 Exibe no Pinpad e em uma janela padrão.  (JANELA CRIADA PELA DLL, SEM RELAÇÃO COM COMPONENTE)
    2 Exibe apenas na janela padrão.           (JANELA CRIADA PELA DLL, SEM RELAÇÃO COM COMPONENTE)
    3 Exibe apenas no Pinpad
 }
  mRetornoComprovante.Lines.Clear;
  mRetornoComprovante.Lines.Clear;
  mRetornoComprovante.Lines.Add('===      QR CODE      ===');
  mRetornoComprovante.Lines.Add(Conteudo);
  mRetornoComprovante.Lines.Add('=========================');

end;

procedure TForm1.MultiplusCardTef1RegistrarLog(Sender: TObject;
  const Conteudo: string);
begin
  mLog.Lines.Add(FormatDateTime('hh:nn:ss.zzz', Now) + ' [TEF DLL] - ' + Conteudo);
end;

procedure TForm1.MultiplusCardTef1RelatorioTransacoes(Sender: TObject;
  const Retorno: TMultiplusCardRetornoList);
var
  I: Integer;
  Transacao: TMultiplusCardRetorno;
begin
  mRetornoComprovante.Lines.Clear;
  mRetornoComprovante.Lines.Add('=== RETORNO RELATÓRIO ===');
  mRetornoComprovante.Lines.Add('Total de transações: ' + IntToStr(Retorno.Count));
  mRetornoComprovante.Lines.Add('=========================');

  mRetornoComprovante.Lines.Add('');

  // Verificar se há transações
  if Retorno.Count = 0 then
  begin
    mRetornoComprovante.Lines.Add('Nenhuma transação encontrada.');
    Exit;
  end;

  mRetornoComprovante.Lines.Add('=== TODAS AS TRANSAÇÕES ===');

  // Loop pela lista de transações
  for I := 0 to Retorno.Count - 1 do
  begin
    Transacao := Retorno[I];
    mRetornoComprovante.Lines.Add('--- TRANSAÇÃO ' + IntToStr(I + 1) + ' ---');
    mRetornoComprovante.Lines.Add('NOME_REDE: '              + Transacao.NOME_REDE);
    mRetornoComprovante.Lines.Add('NOME_BANDEIRA: '          + Transacao.NOME_BANDEIRA);
    mRetornoComprovante.Lines.Add('DESC_TIPO_TRANSACAO: '    + Transacao.DESC_TIPO_TRANSACAO);
    mRetornoComprovante.Lines.Add('NSU: '                    + Transacao.NSU);
    mRetornoComprovante.Lines.Add('DATA_HORA_ESTABELECIMENTO: '                    + Transacao.DATA_HORA_ESTABELECIMENTO);
    mRetornoComprovante.Lines.Add('DATA_HORA_ADMINISTRADORA: '                    + Transacao.DATA_HORA_ADMINISTRADORA);
    mRetornoComprovante.Lines.Add('VALOR: '                  + Transacao.VALOR);
    mRetornoComprovante.Lines.Add('TAXA_SERVICO: '           + Transacao.TAXA_SERVICO);
    mRetornoComprovante.Lines.Add('NUMERO_CARTAO: '           + Transacao.NUMERO_CARTAO);
    mRetornoComprovante.Lines.Add('COD_AUTORIZACAO: '        + Transacao.COD_AUTORIZACAO);
    mRetornoComprovante.Lines.Add('NSU_REDE: '               + Transacao.NSU_REDE);
    mRetornoComprovante.Lines.Add('STATUS: '               + Transacao.STATUS);
    mRetornoComprovante.Lines.Add('QTDE_PARCELAS: '          + Transacao.QTDE_PARCELAS);
    mRetornoComprovante.Lines.Add('TERMINAL: '          + Transacao.TERMINAL);
    mRetornoComprovante.Lines.Add('');
  end;
end;

procedure TForm1.MultiplusCardTef1SolicitarInteracao(Sender: TObject;
  const Solicitacao: TSolicitacaoUsuario; var Resposta: TRespostaUsuario);
begin
 var resp : TRespostaUsuario;
  case Solicitacao.Tipo of
    tsPergunta:
      begin
        var perguntaDll := ExtrairDadosPergunta(Solicitacao.Mensagem);
        var respostaTxt : String;
        var respondeu := InputQuery(perguntaDll.TextoPergunta, perguntaDll.TipoDado,respostaTxt);
        resp.RespTexto := respostaTxt;
        resp.Confirmou := respondeu;
      end;
    tsMensagem:
      begin
      MessageDlg(Solicitacao.Mensagem, mtInformation, [mbOk], 0);
        resp.RespTexto := '';
        resp.Confirmou := True;
      end;
    tsMenu:
      begin
        var menuDll := ExtrairDadosMenu(Solicitacao.Mensagem);
        var menuItensTxt : String;
        var respostaTxt : String;
        menuItensTxt := ArrayMenuParaTextoCustomizado(menuDll.Itens);
        var respondeu := InputQuery(menuDll.TituloMenu, menuItensTxt,respostaTxt);
        resp.RespTexto := respostaTxt;
        resp.Confirmou := respondeu;
      end;
    tsSimNao:
      begin
        var simNao := ExtrairDadosSimNao(Solicitacao.Mensagem);

        if MessageDlg(simNao.TituloMenu, mtConfirmation, [mbYes, mbNo], 0) = mrYes then
        begin
        resp.Confirmou := True;
        end
        else
        begin
        resp.Confirmou := False;
        end;

      end;
  end;
   MultiplusCardTef1.objUi.ResponderInteracao(resp);
end;

// =============================================================================
// EVENTOS PINPDV API
// =============================================================================

procedure TForm1.MultiplusCardPinPDV1FalhaOperacao(Sender: TObject;
  const Erro: string);
begin
  mRetornoComprovante.Lines.Clear;
  mRetornoComprovante.Lines.Add('ERRO PINPDV: ' + Erro);
  mLog.Lines.Add(FormatDateTime('hh:nn:ss', Now) + ' [PINPDV-ERRO] - ' + Erro);
end;

procedure TForm1.MultiplusCardPinPDV1GerarComprovante(Sender: TObject;
  const Retorno: TMultiplusCardRetorno);
begin
  mRetornoComprovante.Lines.Clear;
  mRetornoComprovante.Lines.Add('=== COMPROVANTE PINPDV ===');
  mRetornoComprovante.Lines.Add(Retorno.COMPROVANTE);
  mRetornoComprovante.Lines.Add('=========================');

  mRetornoComprovante.Lines.Add('CUPOM: '                  + Retorno.CUPOM);
  mRetornoComprovante.Lines.Add('VALOR: '                  + Retorno.VALOR);
  mRetornoComprovante.Lines.Add('COD_BANDEIRA: '           + Retorno.COD_BANDEIRA);
  mRetornoComprovante.Lines.Add('COD_REDE: '               + Retorno.COD_REDE);
  mRetornoComprovante.Lines.Add('COD_AUTORIZACAO: '        + Retorno.COD_AUTORIZACAO);
  mRetornoComprovante.Lines.Add('NSU: '                    + Retorno.NSU);
  mRetornoComprovante.Lines.Add('QTDE_PARCELAS: '          + Retorno.QTDE_PARCELAS);
  mRetornoComprovante.Lines.Add('TAXA_SERVICO: '           + Retorno.TAXA_SERVICO);
  mRetornoComprovante.Lines.Add('BIN_CARTAO: '             + Retorno.BIN_CARTAO);
  mRetornoComprovante.Lines.Add('ULTIMOS_DIGITOS_CARTAO: ' + Retorno.ULTIMOS_DIGITOS_CARTAO);
  mRetornoComprovante.Lines.Add('CNPJ_AUTORIZADORA: '      + Retorno.CNPJ_AUTORIZADORA);
  mRetornoComprovante.Lines.Add('NOME_CLIENTE: '           + Retorno.NOME_CLIENTE);
  mRetornoComprovante.Lines.Add('NSU_REDE: '               + Retorno.NSU_REDE);
  mRetornoComprovante.Lines.Add('NUM_VIAS_COMPROVANTE: '   + Retorno.NUM_VIAS_COMPROVANTE);
  mRetornoComprovante.Lines.Add('VENCTO_CARTAO: '          + Retorno.VENCTO_CARTAO);
  mRetornoComprovante.Lines.Add('NOME_BANDEIRA: '          + Retorno.NOME_BANDEIRA);
  mRetornoComprovante.Lines.Add('NOME_REDE: '              + Retorno.NOME_REDE);
  mRetornoComprovante.Lines.Add('CARTAO_PRE_PAGO: '        + Retorno.CARTAO_PRE_PAGO);
  mRetornoComprovante.Lines.Add('COD_TIPO_TRANSACAO: '     + Retorno.COD_TIPO_TRANSACAO);
  mRetornoComprovante.Lines.Add('DESC_TIPO_TRANSACAO: '    + Retorno.DESC_TIPO_TRANSACAO);
end;

procedure TForm1.MultiplusCardPinPDV1RegistrarLog(Sender: TObject;
  const Dados: string);
begin
  mLog.Lines.Add(FormatDateTime('hh:nn:ss.zzz', Now) + ' [PINPDV ] - ' + Dados);
end;

procedure TForm1.MultiplusCardPinPDV1Transacao(Sender: TObject; const Transacao: string);
begin
  mLog.Lines.Add(FormatDateTime('hh:nn:ss', Now) + ' [PINPDV-TRANSACAO] - ' + Transacao);
  // Aqui você pode processar os dados da transação se necessário
end;

procedure TForm1.MultiplusCardPinPDV1SolicitarCancelamento(Sender: TObject; const Identificador: string; Tentativa: Integer; var PermitirCancelar: Boolean);
var
  Resposta: Integer;
begin
  Resposta := MessageDlg(
    Format('Aguardando pagamento... (Tentativa #%d)' + sLineBreak +
           'Identificador: %s' + sLineBreak + sLineBreak +
           'Deseja continuar aguardando o pagamento?', [Tentativa, Identificador]),
    mtConfirmation,
    [mbYes, mbCancel],
    0
  );

  PermitirCancelar := (Resposta = mrCancel);

  if PermitirCancelar then
  begin
    mLog.Lines.Add('Usuário cancelou a verificação - Tentativa #' + IntToStr(Tentativa));
    AjustaVisualInciaTransacao(False);
    ShowMessage('Transação cancelada pelo usuário.');
  end
  else
  begin
    mLog.Lines.Add('Usuário optou por continuar aguardando - Tentativa #' + IntToStr(Tentativa));
  end;
end;

procedure TForm1.MultiplusCardPinPDV1SolicitarImpressao(Sender: TObject;
  const PreVenda: TPreVenda);
var
  Comprovante: string;
  TipoPgto: string;
  DataHora: string;
  NSU, Autorizacao, Bandeira, Adquirente: string;
  Valor: Currency;
  Parcelas: Integer;

  function CentralizarTexto(const Texto: string; Largura: Integer = 38): string;
  var
    Espacos: Integer;
  begin
    if Length(Texto) >= Largura then
      Result := Copy(Texto, 1, Largura)
    else
    begin
      Espacos := (Largura - Length(Texto)) div 2;
      Result := StringOfChar(' ', Espacos) + Texto;
    end;
  end;

  function AlinharDireita(const Texto: string; Largura: Integer = 38): string;
  var
    Espacos: Integer;
  begin
    if Length(Texto) >= Largura then
      Result := Copy(Texto, 1, Largura)
    else
    begin
      Espacos := Largura - Length(Texto);
      Result := StringOfChar(' ', Espacos) + Texto;
    end;
  end;

  function FormatarLinha(const Esquerda, Direita: string; Largura: Integer = 38): string;
  var
    EspacosLivres: Integer;
  begin
    EspacosLivres := Largura - Length(Esquerda) - Length(Direita);
    if EspacosLivres > 0 then
      Result := Esquerda + StringOfChar(' ', EspacosLivres) + Direita
    else
      Result := Copy(Esquerda + Direita, 1, Largura);
  end;

begin
  // Extrai informações da PreVenda
  if Assigned(PreVenda) and (PreVenda.Vendas.Count > 0) and
     (PreVenda.Vendas[0].Transacoes.Count > 0) then
  begin
    Valor := PreVenda.Vendas[0].Transacoes[0].Valor;
    Parcelas := PreVenda.Vendas[0].Transacoes[0].Parcelas;
    NSU := PreVenda.Vendas[0].Transacoes[0].Dados.NSU;
    Autorizacao := PreVenda.Vendas[0].Transacoes[0].Dados.Autorizacao;
    Bandeira := PreVenda.Vendas[0].Transacoes[0].Dados.Bandeira;
    Adquirente := PreVenda.Vendas[0].Transacoes[0].Dados.Adquirente;

    // Determina tipo de pagamento
    case PreVenda.Vendas[0].Transacoes[0].TipoPagamento of
      tpCredito: TipoPgto := 'CARTAO CREDITO';
      tpDebito: TipoPgto := 'CARTAO DEBITO';
      tpPix: TipoPgto := 'PIX';
      tpValeRefeicao: TipoPgto := 'VALE REFEICAO';
      tpValeAlimentacao: TipoPgto := 'VALE ALIMENTACAO';
      tpDinheiro: TipoPgto := 'DINHEIRO';
      else TipoPgto := 'OUTROS';
    end;
  end
  else
  begin
    // Dados padrão se não houver transação
    Valor := PreVenda.Valor;
    Parcelas := PreVenda.Parcelas;
    TipoPgto := 'NAO PROCESSADO';
    NSU := '';
    Autorizacao := '';
    Bandeira := '';
    Adquirente := '';
  end;

  DataHora := FormatDateTime('dd/mm/yyyy hh:nn:ss', Now);

  // Monta o comprovante
  Comprovante := '';

  Comprovante := Comprovante + '========= SEM VALOR FISCAL   =========' + #13#10;
  Comprovante := Comprovante + '========= SEM VALOR FISCAL   =========' + #13#10;
  Comprovante := Comprovante + '========= SEM VALOR FISCAL   =========' + #13#10;
  Comprovante := Comprovante + '========= SEM VALOR FISCAL   =========' + #13#10;

  // Cabeçalho
  Comprovante := Comprovante + '======================================' + #13#10;
  Comprovante := Comprovante + CentralizarTexto('EMPRESA EXEMPLO LTDA') + #13#10;
  Comprovante := Comprovante + CentralizarTexto('CNPJ: 12.345.678/0001-90') + #13#10;
  Comprovante := Comprovante + CentralizarTexto('RUA EXEMPLO, 123 - CENTRO') + #13#10;
  Comprovante := Comprovante + CentralizarTexto('CIDADE/UF - CEP: 12345-678') + #13#10;
  Comprovante := Comprovante + CentralizarTexto('TEL: (11) 1234-5678') + #13#10;
  Comprovante := Comprovante + '======================================' + #13#10;

  // Título do documento
  Comprovante := Comprovante + CentralizarTexto('CUPOM FISCAL ELETRONICO') + #13#10;
  Comprovante := Comprovante + CentralizarTexto('SAT No.: 123456789') + #13#10;
  Comprovante := Comprovante + '--------------------------------------' + #13#10;

  // Dados da venda
  Comprovante := Comprovante + FormatarLinha('Data/Hora:', DataHora) + #13#10;
  Comprovante := Comprovante + FormatarLinha('Identificador:', PreVenda.Identificador) + #13#10;
  Comprovante := Comprovante + '--------------------------------------' + #13#10;

  // Item exemplo
  Comprovante := Comprovante + 'ITEM             QTD  VL UNIT  VL TOTAL' + #13#10;
  Comprovante := Comprovante + PreVenda.Descricao + #13#10;
  if Length(PreVenda.Descricao) > 38 then
    Comprovante := Comprovante + Copy(PreVenda.Descricao, 39, Length(PreVenda.Descricao)) + #13#10;
  Comprovante := Comprovante + FormatarLinha('', Format('%7.2f', [Valor])) + #13#10;
  Comprovante := Comprovante + '--------------------------------------' + #13#10;

  // Totais
  Comprovante := Comprovante + FormatarLinha('SUBTOTAL R$:', Format('%.2f', [Valor])) + #13#10;
  Comprovante := Comprovante + FormatarLinha('DESCONTO R$:', '0,00') + #13#10;
  Comprovante := Comprovante + FormatarLinha('TOTAL GERAL R$:', Format('%.2f', [Valor])) + #13#10;
  Comprovante := Comprovante + '======================================' + #13#10;

  // Informações de pagamento
  Comprovante := Comprovante + CentralizarTexto('FORMA DE PAGAMENTO') + #13#10;
  Comprovante := Comprovante + '--------------------------------------' + #13#10;
  Comprovante := Comprovante + FormatarLinha('Tipo:', TipoPgto) + #13#10;

  if Parcelas > 1 then
    Comprovante := Comprovante + FormatarLinha('Parcelas:', IntToStr(Parcelas) + 'x') + #13#10;

  Comprovante := Comprovante + FormatarLinha('Valor R$:', Format('%.2f', [Valor])) + #13#10;

  // Dados da transação (se disponível)
  if (NSU <> '') or (Autorizacao <> '') then
  begin
    Comprovante := Comprovante + '--------------------------------------' + #13#10;
    if Bandeira <> '' then
      Comprovante := Comprovante + FormatarLinha('Bandeira:', Bandeira) + #13#10;
    if Adquirente <> '' then
      Comprovante := Comprovante + FormatarLinha('Adquirente:', Adquirente) + #13#10;
    if NSU <> '' then
      Comprovante := Comprovante + FormatarLinha('NSU:', NSU) + #13#10;
    if Autorizacao <> '' then
      Comprovante := Comprovante + FormatarLinha('Autorizacao:', Autorizacao) + #13#10;
  end;

  // Rodapé fiscal
  Comprovante := Comprovante + '======================================' + #13#10;
  Comprovante := Comprovante + CentralizarTexto('OBRIGADO PELA PREFERENCIA!') + #13#10;
  Comprovante := Comprovante + '--------------------------------------' + #13#10;
  Comprovante := Comprovante + CentralizarTexto('Lei 12345 - Valor Aprox.') + #13#10;
  Comprovante := Comprovante + CentralizarTexto('Tributos R$ ' + FormatFloat('#,##0.00', Valor * 0.1655)) + #13#10;
  Comprovante := Comprovante + CentralizarTexto('Fonte: IBPT') + #13#10;
  Comprovante := Comprovante + '--------------------------------------' + #13#10;
  Comprovante := Comprovante + CentralizarTexto('DOC No.: 123456789') + #13#10;
  Comprovante := Comprovante + CentralizarTexto(FormatDateTime('dd/mm/yyyy hh:nn:ss', Now)) + #13#10;
  Comprovante := Comprovante + '======================================' + #13#10;
  Comprovante := Comprovante + '========= SEM VALOR FISCAL   =========' + #13#10;
  Comprovante := Comprovante + '========= SEM VALOR FISCAL   =========' + #13#10;
  Comprovante := Comprovante + '========= SEM VALOR FISCAL   =========' + #13#10;
  Comprovante := Comprovante + '========= SEM VALOR FISCAL   =========' + #13#10;

  // Pula algumas linhas para corte
  Comprovante := Comprovante + #13#10 + #13#10 + #13#10;

  // Envia o comprovante para o componente
  MultiplusCardPinPDV1.EnviaDocumentoImpressao(Comprovante);
end;

procedure TForm1.MultiplusCardPinPDV1SolicitarInteracao(Sender: TObject;
  const Solicitacao: TSolicitacaoUsuario; var Resposta: TRespostaUsuario);
begin
 var resp : TRespostaUsuario;
  case Solicitacao.Tipo of
    tsPergunta:
      begin
        var perguntaDll := ExtrairDadosPergunta(Solicitacao.Mensagem);
        var respostaTxt : String;
        var respondeu := InputQuery(perguntaDll.TextoPergunta, perguntaDll.TipoDado,respostaTxt);
        resp.RespTexto := respostaTxt;
        resp.Confirmou := respondeu;
      end;
    tsMensagem:
      begin
      MessageDlg(Solicitacao.Mensagem, mtInformation, [mbOk], 0);
        resp.RespTexto := '';
        resp.Confirmou := True;
      end;
    tsMenu:
      begin
        var menuDll := ExtrairDadosMenu(Solicitacao.Mensagem);
        var menuItensTxt : String;
        var respostaTxt : String;
        menuItensTxt := ArrayMenuParaTextoCustomizado(menuDll.Itens);
        var respondeu := InputQuery(menuDll.TituloMenu, menuItensTxt,respostaTxt);
        resp.RespTexto := respostaTxt;
        resp.Confirmou := respondeu;
      end;
      tsSimNao:
      begin
        var simNao := ExtrairDadosSimNao(Solicitacao.Mensagem);

        if MessageDlg(simNao.TituloMenu, mtConfirmation, [mbYes, mbNo], 0) = mrYes then
        begin
        resp.Confirmou := True;
        end
        else
        begin
        resp.Confirmou := False;
        end;
      end

  end;
   MultiplusCardPinPDV1.objUi.ResponderInteracao(resp);
end;

// =============================================================================
// FUNÇÕES AUXILIARES
// =============================================================================

function TForm1.GetOperacaoSelecionada: TOperacao;
begin
  Result := tpiComando_CREDITO_A_VISTA; // padrão

  if (cbxOperacoes.ItemIndex >= 0) and (cbxOperacoes.ItemIndex < cbxOperacoes.Items.Count) then
  begin
    Result := TOperacao(Integer(cbxOperacoes.Items.Objects[cbxOperacoes.ItemIndex]));
  end;
end;

function TForm1.GetNomeOperacao(AOperacao: TOperacao): string;
begin
  case AOperacao of
    tpiComando_DEBITO                 : Result := 'Débito';
    tpiComando_DEBITO_A_VISTA         : Result := 'Débito à Vista';
    tpiComando_CREDITO                : Result := 'Crédito';
    tpiComando_CREDITO_A_VISTA        : Result := 'Crédito à Vista';
    tpiComando_CREDITO_PARC_LOJA      : Result := 'Crédito Parc. Loja';
    tpiComando_CREDITO_PARC_ADM       : Result := 'Crédito Parc. ADM';
    tpiComando_FROTA                  : Result := 'Frota';
    tpiComando_VOUCHER                : Result := 'Voucher';
    tpiComando_PRE_AUTORIZACAO        : Result := 'Pré-Autorização';
    tpiComando_CONF_PRE_AUTORIZACAO   : Result := 'Confirmar Pré-Autorização';
    tpiComando_CANC_PRE_AUTORIZACAO   : Result := 'Cancelar Pré-Autorização';
    tpiComando_CONSULTA_SALDO_CREDITO : Result := 'Consulta Saldo Crédito';
    tpiComando_CONSULTA_SALDO_DEBITO  : Result := 'Consulta Saldo Débito';
    tpiComando_EXCLUIR_BINS           : Result := 'Excluir BINS';
    tpiComando_REIMPRESSAO            : Result := 'Reimpressão';
    tpiComando_COLETA_DE_CPF          : Result := 'Coleta de CPF';
    tpiComando_OPCOES_PSP             : Result := 'Opções PSP';
    tpiComando_PSP_CLIENTE            : Result := 'PSP Cliente';
    tpiComando_MERCADO_PAGO           : Result := 'Mercado Pago';
    tpiComando_PICPAY                 : Result := 'PicPay';
    tpiComando_ESTORNO                : Result := 'Estorno';
    tpiComando_ESTORNO_PIX            : Result := 'Estorno PIX';
    tpiComando_STATUS_TRANSACAO_PIX   : Result := 'Status Transação PIX';
    tpiComando_LIMPEZA_TABELA         : Result := 'Limpeza de Tabelas';
    tpiComando_REALATORIO_TRANSACOES  : Result := 'Relatório de Transações';
    tpiComando_POS_TEF                : Result := 'POS TEF';
  else
    Result := 'Operação Desconhecida';
  end;
end;

function TForm1.GetDispositivoSelecionadoId: Integer;
begin
  if (cbxPinpdvDispositivos.ItemIndex > 0) and
     (cbxPinpdvDispositivos.ItemIndex < cbxPinpdvDispositivos.Items.Count) then
    Result := Integer(cbxPinpdvDispositivos.Items.Objects[cbxPinpdvDispositivos.ItemIndex])
  else
    Result := 0;
end;

function TForm1.GetOperacaoPinPDVSelecionada: Integer;
begin
  Result := 0; // padrão

  if (cbxOperacoesPinPDV.ItemIndex >= 0) and (cbxOperacoesPinPDV.ItemIndex < cbxOperacoesPinPDV.Items.Count) then
  begin
    Result := Integer(cbxOperacoesPinPDV.Items.Objects[cbxOperacoesPinPDV.ItemIndex]);
  end;
end;

function TForm1.MapearOperacaoPinPDVParaTipoPagamento(AOperacaoPinPDV: Integer): TTipoPagamento;
begin
  // Mapeia os valores do enum tpiComandoPinpdv_* para TTipoPagamento
  case AOperacaoPinPDV of
    Ord(tpiComandoPinpdv_NAO_INFORMADO)      : Result := tpNone;
    Ord(tpiComandoPinpdv_DINHEIRO)           : Result := tpDinheiro;
    Ord(tpiComandoPinpdv_PIX)                : Result := tpPix;
    Ord(tpiComandoPinpdv_DEBITO)             : Result := tpDebito;
    Ord(tpiComandoPinpdv_CREDITO_A_VISTA)    : Result := tpCredito;
    Ord(tpiComandoPinpdv_CREDITO_PARC_LOJA)  : Result := tpCredito;
    Ord(tpiComandoPinpdv_VOUCHER)            : Result := tpValeRefeicao; // ou tpValeAlimentacao dependendo do contexto
  else
    Result := tpNone;
  end;
end;

function TForm1.ObterIdentificadorPinPDV: string;
begin
  if cbxPinpdvGerarIdAuto.Checked then
  begin
    // Gera identificador único automaticamente
    // Formato: PINPDV_YYYYMMDD_HHNNSS_XXX
    Result := Format('PINPDV%s%s%s', [
      FormatDateTime('yyyymmdd', Now),
      FormatDateTime('hhnnss', Now),
      IntToStr(Random(999)).PadLeft(3, '0')
    ]);

    // Atualiza o campo de texto com o ID gerado
    txbIdentificadorPinpdv.Text := Result;
  end
  else
  begin
    // Usa o identificador manual do campo de texto
    Result := Trim(txbIdentificadorPinpdv.Text);

    // Se estiver vazio, gera um padrão básico
    if Result = '' then
    begin
      //Result := 'CUPOM_' + FormatDateTime('yyyymmddhhnnss', Now);
      txbIdentificadorPinpdv.Text := Result;
    end;
  end;
end;

end.
