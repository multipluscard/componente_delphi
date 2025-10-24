unit uPrincipal;

interface

uses
  Winapi.Windows, System.JSON, Winapi.Messages, System.TypInfo, System.StrUtils, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, MultiplusCardPinPDV, MultiplusCardCommons, Vcl.ComCtrls, System.Generics.Collections;


type
  TForm2 = class(TForm)
    MultiplusCardPinPDV1: TMultiplusCardPinPDV;
    btnListarDispositivosPinPDV: TButton;
    memoResultados: TMemo;
    btnCadastrarPreVenda: TButton;
    btnListarDispositivosPinPDVJSON: TButton;
    btnConsultarPreVenda: TButton;
    btnConsultarPreVendaJSON: TButton;
    btnAbortarPreVenda: TButton;
    btnAbortarPosVenda: TButton;
    btnCadastrarPosVenda: TButton;
    btnConsultarPosVenda: TButton;
    btnConsultarPosVendaJSON: TButton;
    btnAbortarPreVendaRetentativa: TButton;
    btnAbortarPosVendaRetentativa: TButton;
    pageOperacoes: TPageControl;
    tabDispositivos: TTabSheet;
    tabPreVenda: TTabSheet;
    tabPosVenda: TTabSheet;
    lbPreVendaIdentificador: TLabel;
    txtPreVendaIdentificador: TEdit;
    txtPreVendaDescricao: TEdit;
    lbPreVendaDescricao: TLabel;
    lbPreVendaValor: TLabel;
    txtPreVendaValor: TEdit;
    txtPreVendaParcelas: TEdit;
    lbPreVendaParcelas: TLabel;
    txtPreVendaPinPdvId: TEdit;
    lbPreVendaPinPdvId: TLabel;
    cbPreVendaTipoPagamento: TComboBox;
    lbPreVendaTipoPagamento: TLabel;
    checkGerarIdentificadorPreVendaAleatorio: TCheckBox;
    checkGerarIdentificadorPosVendaAleatorio: TCheckBox;
    lbPosVendaTipoPagamento: TLabel;
    cbPosVendaTipoPagamento: TComboBox;
    lbPosVendaParcela: TLabel;
    txtPosVendaParcelas: TEdit;
    lbPosVendaDescricao: TLabel;
    txtPosVendaDescricao: TEdit;
    lbPosVendaValor: TLabel;
    lbPosVendaPinPdvId: TLabel;
    txtPosVendaPinPdvId: TEdit;
    txtPosVendaValor: TEdit;
    txtPosVendaIdentificador: TEdit;
    lbPosVendaIdentificador: TLabel;

    // Listar Dispositivos
    procedure btnListarDispositivosPinPDVClick(Sender: TObject);
    procedure btnListarDispositivosPinPDVJSONClick(Sender: TObject);

    // Pre Venda
    procedure btnCadastrarPreVendaClick(Sender: TObject);
    procedure btnConsultarPreVendaClick(Sender: TObject);
    procedure btnConsultarPreVendaJSONClick(Sender: TObject);
    procedure btnAbortarPreVendaClick(Sender: TObject);
    procedure btnAbortarPreVendaRetentativaClick(Sender: TObject);

    // POS Venda
    procedure btnCadastrarPosVendaClick(Sender: TObject);
    procedure btnConsultarPosVendaClick(Sender: TObject);
    procedure btnConsultarPosVendaJSONClick(Sender: TObject);
    procedure btnAbortarPosVendaClick(Sender: TObject);
    procedure btnAbortarPosVendaRetentativaClick(Sender: TObject);

    // Metodos Auxiliares
    function MapearOperacaoPinPDVParaTipoPagamento(AOperacaoPinPDV: Integer): TTipoPagamento;
    procedure PopularComboOperacoesPinPDV(cbPagamento: TComboBox);
    function GetOperacaoPinPDVSelecionada(cbPagamento: TComboBox): Integer;
    function TipoPagamentoToStr(Tipo: TTipoPagamento): string;
    procedure FormCreate(Sender: TObject);

    // Eventos Componente
    procedure MultiplusCardPinPDV1FalhaOperacao(Sender: TObject;
      const Conteudo: string);
    procedure MultiplusCardPinPDV1GerarComprovante(Sender: TObject;
      const Retorno: TMultiplusCardRetorno);
    procedure MultiplusCardPinPDV1Msg(Sender: TObject; const Conteudo: string);
    procedure MultiplusCardPinPDV1RegistrarLog(Sender: TObject;
      const Conteudo: string);
    procedure MultiplusCardPinPDV1SolicitarImpressao(Sender: TObject;
      const PreVenda: TPreVenda);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

{$R *.dfm}
// ==========================================
// Configurações Iniciais
// ==========================================

procedure TForm2.FormCreate(Sender: TObject);
begin
  MultiplusCardPinPDV1.Configuracoes.BaseURL := 'BaseURL';
  MultiplusCardPinPDV1.Configuracoes.Token := 'Token';

  // Preencher combo box
  PopularComboOperacoesPinPDV(cbPreVendaTipoPagamento);
  PopularComboOperacoesPinPDV(cbPosVendaTipoPagamento);
end;


// ==========================================
// LISTAR EQUIPAMENTOS
// ==========================================

procedure TForm2.btnListarDispositivosPinPDVClick(Sender: TObject);
var
  Dispositivos: TListaPinPDV;
  i : integer;
begin
  Dispositivos :=  MultiplusCardPinPDV1.ListarDispositivosPinPDV;
  memoResultados.Lines.Add('=== LISTA DE DISPOSITIVOS PINPDV ===');
  memoResultados.Lines.Add('');
  memoResultados.Lines.Add('');
  for i := 0 to Dispositivos.Data.Count -1 do
  begin
      // Adicionar apenas dispositivos ativos
      if Dispositivos.Data[I].IsAtivo then
      begin
        memoResultados.Lines.Add('ID: ' + IntToStr(Dispositivos.Data[I].Id));
        memoResultados.Lines.Add('Código: ' + Dispositivos.Data[I].Codigo);
        memoResultados.Lines.Add('Nome: ' + Dispositivos.Data[I].Nome);
        memoResultados.Lines.Add('Ativo: ' + IfThen(Dispositivos.Data[I].IsAtivo, 'Sim', 'Não'));
        memoResultados.Lines.Add('Heartbeat: ' + Dispositivos.Data[I].Heartbeat);
        memoResultados.Lines.Add('');
      end;
  end;

end;

procedure TForm2.btnListarDispositivosPinPDVJSONClick(Sender: TObject);
var
  Dispositivos: TJSONObject;
begin
  Dispositivos :=  MultiplusCardPinPDV1.ListarDispositivosPinPDVJSON;
  memoResultados.Lines.Add('=== LISTA DE DISPOSITIVOS PINPDV JSON ===');
  memoResultados.Lines.Add(Dispositivos.Format);
  memoResultados.Lines.Add('');
end;


// ==========================================
// PRE VENDA
// ==========================================

procedure TForm2.btnAbortarPreVendaClick(Sender: TObject);
var
  abortarPreVenda: boolean;
begin
  abortarPreVenda := MultiplusCardPinPDV1.AbortarPreVenda(txtPreVendaIdentificador.Text);
  memoResultados.Lines.Add('AbortarPreVenda('+txtPreVendaIdentificador.Text+')');
  if abortarPreVenda then
    memoResultados.Lines.Add('Pre Venda abortada com sucesso!')
  else
    memoResultados.Lines.Add('Erro ao abortar Pre Venda!');
end;

procedure TForm2.btnAbortarPreVendaRetentativaClick(Sender: TObject);
var
  abortarPreVenda: boolean;
begin
  abortarPreVenda := MultiplusCardPinPDV1.AbortarPreVendaRetry(txtPreVendaIdentificador.Text);
  memoResultados.Lines.Add('AbortarPreVendaRetry('+txtPreVendaIdentificador.Text+')');
  if abortarPreVenda then
    memoResultados.Lines.Add('Pre Venda abortada com sucesso!')
  else
    memoResultados.Lines.Add('Erro ao abortar Pre Venda!');
end;

procedure TForm2.btnCadastrarPreVendaClick(Sender: TObject);
var
  identificador, descricao: string;
  valor: currency;
  TransacaoId, parcelas, pinPdvId, OperacaoSelecionada: integer;
  temp: Double;
  TipoPagamento: TTipoPagamento;
begin

  // Atribuindo valores as variáveis
  if (checkGerarIdentificadorPreVendaAleatorio.Checked) then
    identificador := FormatDateTime('yyyymmddhhnnsszzz', Now)
  else
    identificador := txtPreVendaIdentificador.Text;
  txtPreVendaIdentificador.Text := identificador;
  descricao := txtPreVendaDescricao.Text;
  if TryStrToFloat(txtPreVendaValor.Text, temp) then
    valor := temp
  else
    valor := 0;
  if not TryStrToInt(txtPreVendaParcelas.Text, parcelas) then parcelas := 0;
  if not TryStrToInt(txtPreVendapinPdvId.Text, pinPdvId) then pinPdvId := 0;
  // Mapeia operação selecionada
  OperacaoSelecionada := GetOperacaoPinPDVSelecionada(cbPreVendaTipoPagamento);
  TipoPagamento := MapearOperacaoPinPDVParaTipoPagamento(OperacaoSelecionada);

  TransacaoId := MultiplusCardPinPDV1.CadastrarPreVenda(identificador, descricao, valor, parcelas, TipoPagamento, pinPdvId);

  memoResultados.Lines.Add(
    Format('CadastrarPreVenda("%s", "%s", %.2f, %d, %s, %d);',
      [identificador,
       descricao,
       valor,
       parcelas,
       TipoPagamentoToStr(TipoPagamento),
       pinPdvId])
  );
  memoResultados.Lines.Add('TransacaoId: ' + IntToStr(TransacaoId));
end;

procedure TForm2.btnConsultarPreVendaClick(Sender: TObject);
var
  PreVenda: TPreVenda;
  Venda: TVenda;
  Transacao: TTransacao;
begin
  PreVenda := MultiplusCardPinPDV1.ConsultarPreVenda(txtPreVendaIdentificador.Text);
  memoResultados.Lines.Add('ConsultarPreVenda('+txtPreVendaIdentificador.Text+')');
  if PreVenda = nil then
  begin
    memoResultados.Lines.Add('Nenhuma pré-venda encontrada.');
    Exit;
  end;

  memoResultados.Lines.Add('=== DADOS DA PRÉ-VENDA ===');
  memoResultados.Lines.Add(Format('ID: %d', [PreVenda.Id]));
  memoResultados.Lines.Add('Identificador: ' + PreVenda.Identificador);
  memoResultados.Lines.Add('Descrição: ' + PreVenda.Descricao);
  memoResultados.Lines.Add(Format('Valor: %.2f', [PreVenda.Valor]));
  memoResultados.Lines.Add(Format('Parcelas: %d', [PreVenda.Parcelas]));
  memoResultados.Lines.Add('Tipo Pagamento: ' + IntToStr(Ord(PreVenda.TipoPagamento)));
  memoResultados.Lines.Add('Status: ' + IntToStr(Ord(PreVenda.Status)));

  memoResultados.Lines.Add('');
  memoResultados.Lines.Add('=== VENDAS ===');

  if (PreVenda.Vendas = nil) or (PreVenda.Vendas.Count = 0) then
  begin
    memoResultados.Lines.Add('Nenhuma venda encontrada.');
    Exit;
  end;

  for Venda in PreVenda.Vendas do
  begin
    memoResultados.Lines.Add(Format('  Venda ID: %d', [Venda.Id]));
    memoResultados.Lines.Add('  Identificador: ' + Venda.Identificador);
    memoResultados.Lines.Add(Format('  Valor: %.2f', [Venda.Valor]));
    memoResultados.Lines.Add('  Status: ' + IntToStr(Ord(Venda.Status)));

    memoResultados.Lines.Add('  === TRANSACOES ===');
    if (Venda.Transacoes <> nil) and (Venda.Transacoes.Count > 0) then
    begin
      for Transacao in Venda.Transacoes do
      begin
        memoResultados.Lines.Add(Format('    Transação ID: %d', [Transacao.Id]));
        memoResultados.Lines.Add(Format('    Valor: %.2f', [Transacao.Valor]));
        memoResultados.Lines.Add(Format('    Parcelas: %d', [Transacao.Parcelas]));
        memoResultados.Lines.Add('    Tipo Pagamento: ' + IntToStr(Ord(Transacao.TipoPagamento)));
        memoResultados.Lines.Add('    Status: ' + IntToStr(Ord(Transacao.Status)));

        if Assigned(Transacao.Dados) then
          memoResultados.Lines.Add('    Dados Transação: ...'); // aqui você pode detalhar TDadosTransacao
      end;
    end
    else
      memoResultados.Lines.Add('    Nenhuma transação encontrada.');

    memoResultados.Lines.Add('');
  end;
end;

procedure TForm2.btnConsultarPreVendaJSONClick(Sender: TObject);
var
  PreVenda: TJSONObject;
begin
  PreVenda := MultiplusCardPinPDV1.ConsultarPreVendaJSON(txtPreVendaIdentificador.Text);
  memoResultados.Lines.Add('ConsultarPreVendaJSON('+txtPreVendaIdentificador.Text+')');

  memoResultados.Lines.Add('=== CONSULTAR PRE VENDA JSON ===');
  memoResultados.Lines.Add(PreVenda.Format);
  memoResultados.Lines.Add('');
end;

// ==========================================
// POS Venda
// ==========================================

procedure TForm2.btnCadastrarPosVendaClick(Sender: TObject);
var
  identificador, descricao: string;
  valor: currency;
  TransacaoId, parcelas, pinPdvId, OperacaoSelecionada: integer;
  temp: Double;
  TipoPagamento: TTipoPagamento;
begin

  // Atribuindo valores as variáveis
  if (checkGerarIdentificadorPosVendaAleatorio.Checked) then
    identificador := FormatDateTime('yyyymmddhhnnsszzz', Now)
  else
    identificador := txtPosVendaIdentificador.Text;
  txtPosVendaIdentificador.Text := identificador;
  descricao := txtPosVendaDescricao.Text;
  if TryStrToFloat(txtPosVendaValor.Text, temp) then
    valor := temp
  else
    valor := 0;
  if not TryStrToInt(txtPosVendaParcelas.Text, parcelas) then parcelas := 0;
  if not TryStrToInt(txtPosVendapinPdvId.Text, pinPdvId) then pinPdvId := 0;
  // Mapeia operação selecionada
  OperacaoSelecionada := GetOperacaoPinPDVSelecionada(cbPosVendaTipoPagamento);
  TipoPagamento := MapearOperacaoPinPDVParaTipoPagamento(OperacaoSelecionada);

  TransacaoId := MultiplusCardPinPDV1.CadastrarPosVenda(pinPdvId, identificador, descricao, valor, TipoPagamento, parcelas);

  memoResultados.Lines.Add(
    Format('CadastrarPosVenda(%d, "%s", "%s", %.2f, %s, %d);',
      [pinPdvId,
       identificador,
       descricao,
       valor,
       TipoPagamentoToStr(TipoPagamento),
       parcelas])
  );
  memoResultados.Lines.Add('TransacaoId: ' + IntToStr(TransacaoId));
end;

procedure TForm2.btnConsultarPosVendaClick(Sender: TObject);
var
  PosVenda: TPosVenda;
  Venda: TVenda;
  Transacao: TTransacao;
begin
  PosVenda := MultiplusCardPinPDV1.ConsultarPosVenda(txtPosVendaIdentificador.Text);
  memoResultados.Lines.Add('ConsultarPosVenda('+txtPosVendaIdentificador.Text+')');
  if PosVenda = nil then
  begin
    memoResultados.Lines.Add('Nenhuma pré-venda encontrada.');
    Exit;
  end;

  memoResultados.Lines.Add('=== DADOS DA POS-VENDA ===');
  memoResultados.Lines.Add(Format('ID: %d', [PosVenda.Id]));
  memoResultados.Lines.Add('Identificador: ' + PosVenda.Identificador);
  memoResultados.Lines.Add('Descrição: ' + PosVenda.Descricao);
  memoResultados.Lines.Add(Format('Valor: %.2f', [PosVenda.Valor]));
  memoResultados.Lines.Add(Format('Parcelas: %d', [PosVenda.Parcelas]));
  memoResultados.Lines.Add('Tipo Pagamento: ' + IntToStr(Ord(PosVenda.TipoPagamento)));
  memoResultados.Lines.Add('Status: ' + IntToStr(Ord(PosVenda.Status)));

  memoResultados.Lines.Add('');
  memoResultados.Lines.Add('=== VENDAS ===');

  if (PosVenda.Vendas = nil) or (PosVenda.Vendas.Count = 0) then
  begin
    memoResultados.Lines.Add('Nenhuma venda encontrada.');
    Exit;
  end;

  for Venda in PosVenda.Vendas do
  begin
    memoResultados.Lines.Add(Format('  Venda ID: %d', [Venda.Id]));
    memoResultados.Lines.Add('  Identificador: ' + Venda.Identificador);
    memoResultados.Lines.Add(Format('  Valor: %.2f', [Venda.Valor]));
    memoResultados.Lines.Add('  Status: ' + IntToStr(Ord(Venda.Status)));

    memoResultados.Lines.Add('  === TRANSACOES ===');
    if (Venda.Transacoes <> nil) and (Venda.Transacoes.Count > 0) then
    begin
      for Transacao in Venda.Transacoes do
      begin
        memoResultados.Lines.Add(Format('    Transação ID: %d', [Transacao.Id]));
        memoResultados.Lines.Add(Format('    Valor: %.2f', [Transacao.Valor]));
        memoResultados.Lines.Add(Format('    Parcelas: %d', [Transacao.Parcelas]));
        memoResultados.Lines.Add('    Tipo Pagamento: ' + IntToStr(Ord(Transacao.TipoPagamento)));
        memoResultados.Lines.Add('    Status: ' + IntToStr(Ord(Transacao.Status)));

        if Assigned(Transacao.Dados) then
          memoResultados.Lines.Add('    Dados Transação: ...'); // aqui você pode detalhar TDadosTransacao
      end;
    end
    else
      memoResultados.Lines.Add('    Nenhuma transação encontrada.');

    memoResultados.Lines.Add('');
  end;
end;

procedure TForm2.btnConsultarPosVendaJSONClick(Sender: TObject);
var
  PosVenda: TJSONObject;
begin
  PosVenda := MultiplusCardPinPDV1.ConsultarPosVendaJSON(txtPosVendaIdentificador.Text);
  memoResultados.Lines.Add('ConsultarPosVendaJSON('+txtPosVendaIdentificador.Text+')');

  memoResultados.Lines.Add('=== CONSULTAR POS VENDA JSON ===');
  memoResultados.Lines.Add(PosVenda.Format);
  memoResultados.Lines.Add('');
end;

procedure TForm2.btnAbortarPosVendaClick(Sender: TObject);
var
  abortarPosVenda: boolean;
begin
  abortarPosVenda := MultiplusCardPinPDV1.AbortarPosVenda(txtPosVendaIdentificador.Text);
  memoResultados.Lines.Add('AbortarPosVenda('+txtPosVendaIdentificador.Text+')');
  if abortarPosVenda then
    memoResultados.Lines.Add('Pos Venda abortada com sucesso!')
  else
    memoResultados.Lines.Add('Erro ao abortar Pos Venda!');
end;

procedure TForm2.btnAbortarPosVendaRetentativaClick(Sender: TObject);
var
  abortarPosVenda: boolean;
begin
  abortarPosVenda := MultiplusCardPinPDV1.AbortarRetry(txtPosVendaIdentificador.Text);
  memoResultados.Lines.Add('AbortarRetry('+txtPosVendaIdentificador.Text+')');
  if abortarPosVenda then
    memoResultados.Lines.Add('Pos Venda abortada com sucesso!')
  else
    memoResultados.Lines.Add('Erro ao abortar Pos Venda!');
end;

// ==========================================
// METODOS AUXILIARES
// ==========================================
procedure TForm2.PopularComboOperacoesPinPDV(cbPagamento: TComboBox);
begin
  cbPagamento.Clear;

  // Adiciona as operações com nomes
  cbPagamento.Items.AddObject('Não Informado', TObject(Ord(tpiComandoPinpdv_NAO_INFORMADO)));
  cbPagamento.Items.AddObject('Dinheiro', TObject(Ord(tpiComandoPinpdv_DINHEIRO)));
  cbPagamento.Items.AddObject('Pix', TObject(Ord(tpiComandoPinpdv_PIX)));
  cbPagamento.Items.AddObject('Débito', TObject(Ord(tpiComandoPinpdv_DEBITO)));
  cbPagamento.Items.AddObject('Crédito à Vista', TObject(Ord(tpiComandoPinpdv_CREDITO_A_VISTA )));
  cbPagamento.Items.AddObject('Crédito Parc. LOJA', TObject(Ord(tpiComandoPinpdv_CREDITO_PARC_LOJA)));
  cbPagamento.Items.AddObject('Voucher', TObject(Ord(tpiComandoPinpdv_VOUCHER)));

  // Seleciona o primeiro item por padrão
  if cbPagamento.Items.Count > 0 then
    cbPagamento.ItemIndex := 0;
end;

function TForm2.MapearOperacaoPinPDVParaTipoPagamento(AOperacaoPinPDV: Integer): TTipoPagamento;
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

procedure TForm2.MultiplusCardPinPDV1FalhaOperacao(Sender: TObject;
  const Conteudo: string);
begin
  memoResultados.Lines.Add('[OnFalhaOperacao] - ' + Conteudo);
end;

procedure TForm2.MultiplusCardPinPDV1GerarComprovante(Sender: TObject;
  const Retorno: TMultiplusCardRetorno);
begin
  memoResultados.Lines.Add('[OnGerarComprovante]');
  memoResultados.Lines.Clear;
  memoResultados.Lines.Add('=== COMPROVANTE PINPDV ===');
  memoResultados.Lines.Add(Retorno.COMPROVANTE);
  memoResultados.Lines.Add('=========================');

  memoResultados.Lines.Add('CUPOM: '                  + Retorno.CUPOM);
  memoResultados.Lines.Add('VALOR: '                  + Retorno.VALOR);
  memoResultados.Lines.Add('COD_BANDEIRA: '           + Retorno.COD_BANDEIRA);
  memoResultados.Lines.Add('COD_REDE: '               + Retorno.COD_REDE);
  memoResultados.Lines.Add('COD_AUTORIZACAO: '        + Retorno.COD_AUTORIZACAO);
  memoResultados.Lines.Add('NSU: '                    + Retorno.NSU);
  memoResultados.Lines.Add('QTDE_PARCELAS: '          + Retorno.QTDE_PARCELAS);
  memoResultados.Lines.Add('TAXA_SERVICO: '           + Retorno.TAXA_SERVICO);
  memoResultados.Lines.Add('BIN_CARTAO: '             + Retorno.BIN_CARTAO);
  memoResultados.Lines.Add('ULTIMOS_DIGITOS_CARTAO: ' + Retorno.ULTIMOS_DIGITOS_CARTAO);
  memoResultados.Lines.Add('CNPJ_AUTORIZADORA: '      + Retorno.CNPJ_AUTORIZADORA);
  memoResultados.Lines.Add('NOME_CLIENTE: '           + Retorno.NOME_CLIENTE);
  memoResultados.Lines.Add('NSU_REDE: '               + Retorno.NSU_REDE);
  memoResultados.Lines.Add('NUM_VIAS_COMPROVANTE: '   + Retorno.NUM_VIAS_COMPROVANTE);
  memoResultados.Lines.Add('VENCTO_CARTAO: '          + Retorno.VENCTO_CARTAO);
  memoResultados.Lines.Add('NOME_BANDEIRA: '          + Retorno.NOME_BANDEIRA);
  memoResultados.Lines.Add('NOME_REDE: '              + Retorno.NOME_REDE);
  memoResultados.Lines.Add('CARTAO_PRE_PAGO: '        + Retorno.CARTAO_PRE_PAGO);
  memoResultados.Lines.Add('COD_TIPO_TRANSACAO: '     + Retorno.COD_TIPO_TRANSACAO);
  memoResultados.Lines.Add('DESC_TIPO_TRANSACAO: '    + Retorno.DESC_TIPO_TRANSACAO);
end;

procedure TForm2.MultiplusCardPinPDV1Msg(Sender: TObject;
  const Conteudo: string);
begin
  memoResultados.Lines.Add('[OnMsg] - ' + Conteudo);
end;

procedure TForm2.MultiplusCardPinPDV1RegistrarLog(Sender: TObject;
  const Conteudo: string);
begin
  memoResultados.Lines.Add('[OnRegistrarLog] - ' + Conteudo);
end;

procedure TForm2.MultiplusCardPinPDV1SolicitarImpressao(Sender: TObject;
  const PreVenda: TPreVenda);
begin
   MultiplusCardPinPDV1.EnviaDocumentoImpressao('Finalizou!'+ sLineBreak + 'Segunda Linha!'+ sLineBreak + 'Terceira Linha!');
end;

function TForm2.GetOperacaoPinPDVSelecionada(cbPagamento: TComboBox): Integer;
begin
  Result := 0; // padrão

  if (cbPagamento.ItemIndex >= 0) and (cbPagamento.ItemIndex < cbPagamento.Items.Count) then
  begin
    Result := Integer(cbPagamento.Items.Objects[cbPagamento.ItemIndex]);
  end;
end;

function TForm2.TipoPagamentoToStr(Tipo: TTipoPagamento): string;
begin
  case Tipo of
    tpNone:            Result := 'tpNone';
    tpDinheiro:        Result := 'tpDinheiro';
    tpCredito:         Result := 'tpCredito';
    tpDebito:          Result := 'tpDebito';
    tpPix:             Result := 'tpPix';
    tpValeRefeicao:    Result := 'tpValeRefeicao';
    tpValeAlimentacao: Result := 'tpValeAlimentacao';
  else
    Result := 'Desconhecido';
  end;
end;

end.
