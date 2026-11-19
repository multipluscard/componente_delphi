unit MultiplusCardTef;

interface

uses
  Winapi.Windows,
  System.SysUtils,
  System.Types,
  System.Classes,
  system.StrUtils,
  System.RegularExpressions,
  system.IniFiles,
  System.Generics.Collections,
  System.JSON,
  System.DateUtils,

  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.Controls,
  vcl.ExtCtrls,
  Vcl.Buttons,
  Vcl.Graphics,

  MultiplusCardCommons,
  MultiplusCardUtils;

//==============================================================================
// TIPOS E ENUMERAÇÕES
//==============================================================================

type
  /// <summary>
  /// Define as operações TEF disponíveis no sistema
  /// </summary>
  TOperacao = (
    tpiComando_DEBITO_A_VISTA,
    tpiComando_DEBITO,
    tpiComando_CREDITO,
    tpiComando_CREDITO_A_VISTA,
    tpiComando_CREDITO_PARC_LOJA,
    tpiComando_CREDITO_PARC_ADM,
    tpiComando_FROTA,
    tpiComando_VOUCHER,
    tpiComando_PRE_AUTORIZACAO,
    tpiComando_CONF_PRE_AUTORIZACAO,
    tpiComando_CANC_PRE_AUTORIZACAO,
    tpiComando_CONSULTA_SALDO_CREDITO,
    tpiComando_CONSULTA_SALDO_DEBITO,
    tpiComando_EXCLUIR_BINS,
    tpiComando_REIMPRESSAO,
    tpiComando_COLETA_DE_CPF,
    tpiComando_OPCOES_PSP,
    tpiComando_PSP_CLIENTE,
    tpiComando_MERCADO_PAGO,
    tpiComando_PICPAY,
    tpiComando_ESTORNO,
    tpiComando_ESTORNO_PIX,
    tpiComando_STATUS_TRANSACAO_PIX,
    tpiComando_LIMPEZA_TABELA,
    tpiComando_REALATORIO_TRANSACOES,
    tpiComando_POS_TEF,
    tpiComando_REMOVE_PIX,
    tpiComando_REIMPRESSAO_PIX,
    tpiComando_COMPROVANTE_POS,
    tpiComando_STATUS_POS_TEF,
    tpiComando_CANCELAR_POS_TEF,
    tpiComando_PRE_VENDA,
    tpiComando_STATUS_PRE_VENDA,
    tpiComando_CANCELAR_PRE_VENDA,
    tpiComando_CONFIRMA_TRANSACAO,
    tpiComando_DESFAZ_TRANSACAO,
    tpiComando_STATUS_PINPAD,
    tpiComando_INFORMACAO_PINPAD
  );

  /// <summary>
  /// Eventos para tratamento de interações do sistema TEF
  /// </summary>
  TMultiplusLogEvent         = procedure(Sender: TObject; const Conteudo: string) of object;
  TMultiplusMensagemEvent    = procedure(Sender: TObject; const Conteudo: string) of object;
  TMultiplusComprovanteEvent = procedure(Sender: TObject; const Retorno: TMultiplusCardRetorno) of object;
  TMultiplusRelatorioEvent   = procedure(Sender: TObject; const Retorno: TMultiplusCardRetornoList) of object;
  TMultiplusQrCodeEvent      = procedure(Sender: TObject; const Conteudo: string) of object;
  TMultiplusPinpadEvent      = procedure(Sender: TObject; const Conteudo: string) of object;
  TMultiplusCpfEvent         = procedure(Sender: TObject; const Conteudo: string) of object;
  TMultiplusErroEvent        = procedure(Sender: TObject; const Conteudo: string) of object;

//==============================================================================
// COMPONENTE PRINCIPAL
//==============================================================================

type
  /// Classe de configuração DLL TEF
  TMultiplusCardConfig = class(TPersistent)
  private
    FPontoDeVenda    : string;
    FCnpjEmpresa     : string;
    FCodigoLoja      : string;
    FTipoComunicacao : string;
    FData            : string;
    FNomeDLL         : string;
    FUsaFormPadrao   : Boolean;

  published
    property TipoComunicacao : string read FTipoComunicacao write FTipoComunicacao;
    property CnpjEmpresa     : string read FCnpjEmpresa     write FCnpjEmpresa;
    property CodigoLoja      : string read FCodigoLoja      write FCodigoLoja;
    property Data            : string read FData            write FData;
    property PontoDeVenda    : string read FPontoDeVenda    write FPontoDeVenda;
    property NomeDLL         : string read FNomeDLL         write FNomeDLL;
    property UsaFormPadrao   : Boolean read FUsaFormPadrao  write FUsaFormPadrao;
  end;
  /// <summary>
  /// Componente principal para integração com TEF via DLL
  /// </summary>
  TMultiplusCardTef = class(TComponent)
  private
    // === INTEGRAÇÃO COM INTERFACE DE USUÁRIO ===
    FOnSolicitarInteracaoUi: MultiplusCardCommons.TOnSolicitarInteracao;
    FRespostaInteracao: MultiplusCardCommons.TRespostaUsuario;

    // === VARIÁVEIS DE CONTROLE ===
    Retorno: Integer;
    mydata: TDateTime;
    continuarExecucao: Boolean;
    utilizaJson: boolean;

    // === EVENTOS ===
    FOnRegistrarLog       : TMultiplusLogEvent;
    FOnMsg                : TMultiplusMensagemEvent;
    FOnGerarComprovante   : TMultiplusComprovanteEvent;
    FOnCpfInformado       : TMultiplusCpfEvent;
    FOnFalhaOperacao      : TMultiplusErroEvent;
    FOnQrCodeGerado       : TMultiplusQrCodeEvent;
    FOnPinpad             : TMultiplusPinpadEvent;
    FOnRelatorioTransacoes: TMultiplusRelatorioEvent;

    // === OBJETOS AUXILIARES ===
    FMultiplusCardConfig: TMultiplusCardConfig;
    FRetornoPgto: TMultiplusCardRetorno;
    FListaRetornos: TMultiplusCardRetornoList;
    FMensagemReduzida: Boolean;

    // === Métodos privados ===
    function VerificarDLL: Boolean;
    function GetListaRetornos: TMultiplusCardRetornoList;

    // === MÉTODOS PRIVADOS - DISPARADORES DE EVENTOS ===
    procedure DoRegistrarLog(Conteudo: string; MensagemReduzida: Boolean);
    procedure DoMsg(const Conteudo: string);
    procedure DoGerarComprovante(const Retorno: TMultiplusCardRetorno);
    procedure DoRelatorioTransacoes(const Retorno: TMultiplusCardRetornoList);
    procedure DoQrCodeGerado(const Conteudo: string);
    procedure DoCpfInformado(const Conteudo: string);
    procedure DoFalhaOperacao(const Conteudo: string);
    procedure DoPinpad(const Conteudo: string);

    // === TRATADORES DE INTERFACE DE USUÁRIO ===
    procedure TratarSolicitacaoInteracao(Sender: TObject; const Solicitacao: TSolicitacaoUsuario; var Resposta: TRespostaUsuario);
    procedure TratarMsg(Sender: TObject; const Conteudo: string);

  public
    var
      objUi: TMultiplusCardUi;

    // === CONSTRUTOR E DESTRUTOR ===
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    // === NOVOS MÉTODOS PARA GERENCIAR LISTA ===
    function AdicionarRetorno: TMultiplusCardRetorno;
    procedure LimparCacheRetornos;
    procedure RelatorioParaRetorno(const ATextoCompleto: string; UsaJson: Boolean);
    procedure ProcessarRelatorioCsv(const ConteudoCsv: string);
    procedure ProcessarRelatorioJson(const ConteudoJson: string);

    // Funções auxiliares para JSON
    function SafeGetString(JSONObj: TJSONObject; const Path: string): string;
    function SafeGetFloat(JSONObj: TJSONObject; const Path: string): Double;
    function SafeGetInt(JSONObj: TJSONObject; const Path: string): Integer;
    function AjustarFormatoIso8601(const DataStr: string): string;

    // === MÉTODOS PRINCIPAIS ===

    /// <summary>
    /// Executa uma transação TEF através da DLL
    /// </summary>
    /// <param name="Op">Tipo de operação a ser executada</param>
    /// <param name="Cupom">Número do cupom fiscal</param>
    /// <param name="Nsu">NSU da transação</param>
    /// <param name="Valor">Valor da transação no formato monetário</param>
    /// <param name="Parcela">Número de parcelas</param>
    /// <param name="Parametros">Parâmetros adicionais para a operação</param>
    /// <returns>True se a transação foi executada com sucesso</returns>
    function EfetuaTransacao(Op: TOperacao; Cupom, Nsu, Valor: string; Parcela: integer; Parametros: string): Boolean;

    /// <summary>
    /// Verifica o status de uma transação específica
    /// </summary>
    /// <param name="Cupom">Número do cupom fiscal</param>
    /// <param name="Nsu">NSU da transação</param>
    /// <param name="Valor">Valor da transação</param>
    /// <param name="Parcela">Número de parcelas</param>
    /// <returns>True se a transação está aprovada</returns>
    function VerificarStatusTransacao(Cupom, Nsu, Valor: string; Parcela: Integer): Boolean;

    /// <summary>
    /// Cancela o fluxo de transação em andamento
    /// </summary>
    procedure CancelarFluxo;

    /// <summary>
    /// Obtém a descrição textual de um código de erro da DLL
    /// </summary>
    /// <param name="codigo">Código numérico do erro</param>
    /// <returns>Descrição do erro</returns>
    function GetCodigoErro(const codigo: Integer): string;
    // === Dados de Retorno ===
    property RetornoPgto    : TMultiplusCardRetorno     read FRetornoPgto         write FRetornoPgto;
    property ListaRetornos  : TMultiplusCardRetornoList read GetListaRetornos;

  published
    // === CONFIGURAÇÕES ===
    property Configuracoes  : TMultiplusCardConfig      read FMultiplusCardConfig write FMultiplusCardConfig;
    property LogSimplificado: Boolean                   read FMensagemReduzida    write FMensagemReduzida;

    // === EVENTOS PRINCIPAIS ===
    property OnSolicitarInteracao  : TOnSolicitarInteracao      read FOnSolicitarInteracaoUi write FOnSolicitarInteracaoUi;
    property OnRegistrarLog        : TMultiplusLogEvent         read FOnRegistrarLog         write FOnRegistrarLog;
    property OnMsg                 : TMultiplusMensagemEvent    read FOnMsg                  write FOnMsg;
    property OnGerarComprovante    : TMultiplusComprovanteEvent read FOnGerarComprovante     write FOnGerarComprovante;
    property OnQrCodeGerado        : TMultiplusQrCodeEvent      read FOnQrCodeGerado         write FOnQrCodeGerado;
    property OnCpfInformado        : TMultiplusCpfEvent         read FOnCpfInformado         write FOnCpfInformado;
    property OnFalhaOperacao       : TMultiplusErroEvent        read FOnFalhaOperacao        write FOnFalhaOperacao;
    property OnPinpad              : TMultiplusPinpadEvent      read FOnPinpad               write FOnPinpad;
    property OnRelatorioTransacoes : TMultiplusRelatorioEvent   read FOnRelatorioTransacoes  write FOnRelatorioTransacoes;
  end;

//==============================================================================
// REGISTRO DO COMPONENTE
//==============================================================================

procedure Register;

implementation

//==============================================================================
// DECLARAÇÕES DLL EXTERNA
//==============================================================================

/// <summary>
/// Inicia uma função da DLL TEF de forma interativa
/// </summary>
function IniciaFuncaoMCInterativo(
  iComando: Integer;
  sCnpjCliente: PAnsiChar;
  iParcela: Integer;
  sCupom: PAnsiChar;
  sValor: PAnsiChar;
  sNsu: PAnsiChar;
  sData: PAnsiChar;
  sNumeroPDV: PAnsiChar;
  sCodigoLoja: PAnsiChar;
  sTipoComunicacao: Integer;
  sParametro: PAnsiChar
): Integer; stdcall; external 'TefClientmc.dll' delayed;

/// <summary>
/// Aguarda resposta da função TEF em andamento
/// </summary>
function AguardaFuncaoMCInterativo(): PAnsiChar; stdcall;
  external 'TefClientmc.dll' delayed;

/// <summary>
/// Continua execução da função TEF com informação fornecida
/// </summary>
function ContinuaFuncaoMCInterativo(sInformacao: PAnsiChar): Integer; stdcall;
  external 'TefClientmc.dll' delayed;

/// <summary>
/// Finaliza a execução de uma função TEF
/// </summary>
function FinalizaFuncaoMCInterativo(
  iComando: Integer;
  sCnpjCliente: PAnsiChar;
  iParcela: Integer;
  sCupom: PAnsiChar;
  sValor: PAnsiChar;
  sNsu: PAnsiChar;
  sData: PAnsiChar;
  sNumeroPDV: PAnsiChar;
  sCodigoLoja: PAnsiChar;
  sTipoComunicacao: Integer;
  sParametro: PAnsiChar
): Integer; stdcall; external 'TefClientmc.dll' delayed;

/// <summary>
/// Cancela o fluxo de execução TEF em andamento
/// </summary>
function CancelarFluxoMCInterativo(): Integer; stdcall;
  external 'TefClientmc.dll' delayed;

//==============================================================================
// REGISTRO
//==============================================================================

procedure Register;
begin
  RegisterComponents('Multiplus Card', [TMultiplusCardTef]);
end;

//==============================================================================
// CONSTRUTOR E DESTRUTOR
//==============================================================================

constructor TMultiplusCardTef.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FMultiplusCardConfig := TMultiplusCardConfig.Create;
  FMultiplusCardConfig.NomeDLL := 'TefClientmc.dll';
  FRetornoPgto := TMultiplusCardRetorno.Create;
  FListaRetornos := TMultiplusCardRetornoList.Create(True); // True = owns objects (gerencia memória)
  FMensagemReduzida := False;

  objUi := TMultiplusCardUi.Create(self);
  objUi.OnSolicitarInteracaoCm := TratarSolicitacaoInteracao;
  objUi.OnMsgCm := TratarMsg;
end;

destructor TMultiplusCardTef.Destroy;
begin
  // Limpar a lista antes de destruir
  if Assigned(FListaRetornos) then
  begin
    FListaRetornos.Clear;
    FreeAndNil(FListaRetornos);
  end;

  FMultiplusCardConfig.Free;
  FRetornoPgto.Free;

  inherited Destroy;
end;

//==============================================================================
// DISPARADORES DE EVENTOS
//==============================================================================

procedure TMultiplusCardTef.DoRegistrarLog(Conteudo: string; MensagemReduzida: Boolean);
var
  Posicao: integer;
begin
  if MensagemReduzida then
  begin
    Posicao := Pos('#', Conteudo);
    if Posicao > 0 then
      Conteudo := Copy(Conteudo, Posicao + 1, Length(Conteudo));
  end;
  if Assigned(FOnRegistrarLog) then
    FOnRegistrarLog(Self, Conteudo);
end;

procedure TMultiplusCardTef.DoMsg(const Conteudo: string);
var
  NovoConteudo: string;
begin
  NovoConteudo := Conteudo;
  if Assigned(FOnMsg) then
    FOnMsg(Self, NovoConteudo);
end;

procedure TMultiplusCardTef.DoGerarComprovante(const Retorno: TMultiplusCardRetorno);
begin
  if Assigned(FOnGerarComprovante) then
    FOnGerarComprovante(Self, Retorno);
end;

procedure TMultiplusCardTef.DoQrCodeGerado(const Conteudo: string);
begin
  if Assigned(FOnQrCodeGerado) then
    FOnQrCodeGerado(Self, Conteudo);
end;

procedure TMultiplusCardTef.DoCpfInformado(const Conteudo: string);
begin
  if Assigned(FOnCpfInformado) then
    FOnCpfInformado(Self, Conteudo);
end;

procedure TMultiplusCardTef.DoFalhaOperacao(const Conteudo: string);
begin
  if Assigned(FOnFalhaOperacao) then
    FOnFalhaOperacao(Self, Conteudo);
end;

procedure TMultiplusCardTef.DoPinpad(const Conteudo: string);
begin
  if Assigned(FOnPinpad) then
    FOnPinpad(Self, Conteudo);
end;

procedure TMultiplusCardTef.DoRelatorioTransacoes(const Retorno: TMultiplusCardRetornoList);
begin
  if Assigned(FOnRelatorioTransacoes) then
    FOnRelatorioTransacoes(Self, Retorno);
end;

//==============================================================================
// TRATADORES DE INTERFACE DE USUÁRIO
//==============================================================================

procedure TMultiplusCardTef.TratarSolicitacaoInteracao(Sender: TObject;
  const Solicitacao: TSolicitacaoUsuario; var Resposta: TRespostaUsuario);
begin
  if Assigned(FOnSolicitarInteracaoUi) then
    FOnSolicitarInteracaoUi(Self, Solicitacao, Resposta);
end;

procedure TMultiplusCardTef.TratarMsg(Sender: TObject; const Conteudo: string);
begin
  if Assigned(FOnMsg) then
    FOnMsg(Self, Conteudo);
end;

//==============================================================================
// MÉTODOS AUXILIARES
//==============================================================================

procedure TMultiplusCardTef.CancelarFluxo;
var
  retornoCancelarFluxoMCInterativo: Integer;
begin
  continuarExecucao := False;
  DoMsg('Cancelamento solicitado pelo operador.');
  DoRegistrarLog('Chamada CancelarFluxoMCInterativo()', false);
  retornoCancelarFluxoMCInterativo := CancelarFluxoMCInterativo;
  DoRegistrarLog('Retorno CancelarFluxoMCInterativo: ' + GetCodigoErro(retornoCancelarFluxoMCInterativo), false);
  while(retornoCancelarFluxoMCInterativo <> 0) and (retornoCancelarFluxoMCInterativo <> 37) and (retornoCancelarFluxoMCInterativo <> 42) do
  begin
    DoRegistrarLog('Chamada CancelarFluxoMCInterativo()', false);
    retornoCancelarFluxoMCInterativo := CancelarFluxoMCInterativo;
    DoRegistrarLog('Retorno CancelarFluxoMCInterativo: ' + GetCodigoErro(retornoCancelarFluxoMCInterativo), false);
  end;
end;

function TMultiplusCardTef.GetCodigoErro(const codigo: Integer): string;
begin
  case codigo of
    0:  Result := '0: Retorno OK (função foi executada sem erros)';
    1:  Result := 'Erro 1: Erro genérico na execução';
    30: Result := 'Erro 30: Não foi encontrado o caminho do ClientD.exe';
    31: Result := 'Erro 31: ConfigMC.ini está vazio';
    32: Result := 'Erro 32: ClientD.exe não encontrado';
    33: Result := 'Erro 33: ClientD.exe não está em execução';
    34: Result := 'Erro 34: Erro ao iniciar ClientD.exe';
    35: Result := 'Erro 35: Erro interno do ClientD.exe';
    36: Result := 'Erro 36: Erro interno do ClientD.exe';
    37: Result := 'Erro 37: Erro na leitura do arquivo ConfigMC.ini';
    38: Result := 'Erro 38: Valor da transação com formato incorreto';
    39: Result := 'Erro 39: Executável de envio de transações não encontrado';
    40: Result := 'Erro 40: CNPJ Inválido ou no formato incorreto';
    41: Result := 'Erro 41: ClientD.exe está em processo de atualização';
    42: Result := 'Erro 42: A automação não está sendo executada no modo administrador';
    43: Result := 'Erro 43: ClientD.exe está em execução devido a uma transação anterior';
    44: Result := 'Erro 44: Parâmetros ausentes em operação que utiliza o sParametro';
    45: Result := 'Erro 45: Parâmetros no formato incorreto em operação que utiliza o sParametro';
    46: Result := 'Erro 46: Erro ao identificar localização da DLL';
    47: Result := 'Erro 47: Não Foi encontrada a localização da DLL';
    48: Result := 'Erro 48: Não houve confirmação da conclusão da execução do ClientD';
    49: Result := 'Erro 49: Número de parcelas inválido';
    51: Result := 'Erro 51: Parâmetro iLimpaTb com valor inválido';
    52: Result := 'Erro 52: Código de operação inválido para a função';
  else
    Result := Format('Não foi identificado o código de erro "%d" nessa lista, favor consultar seu significado no Guia de Integração', [codigo]);
  end;
end;

function TMultiplusCardTef.AdicionarRetorno: TMultiplusCardRetorno;
begin
  if not Assigned(FListaRetornos) then
    raise Exception.Create('Lista de retornos não inicializada');

  Result := TMultiplusCardRetorno.Create;
  FListaRetornos.Add(Result);
end;

procedure TMultiplusCardTef.LimparCacheRetornos;
begin
  if Assigned(FListaRetornos) then
  begin
    try
      FListaRetornos.Clear; // Limpa e libera todos os objetos com segurança
    except
      on E: Exception do
        DoRegistrarLog('Erro ao limpar lista de retornos: ' + E.Message, False);
    end;
  end;
end;

procedure TMultiplusCardTef.RelatorioParaRetorno(const ATextoCompleto: string; UsaJson: Boolean);
begin
  // Limpar cache antes de processar
  LimparCacheRetornos;

  if UsaJson then
    ProcessarRelatorioJson(ATextoCompleto)
  else
    ProcessarRelatorioCsv(ATextoCompleto);
end;

procedure TMultiplusCardTef.ProcessarRelatorioCsv(const ConteudoCsv: string);
var
  Linhas, Colunas: TArray<string>;
  i: Integer;
  NovoRetorno: TMultiplusCardRetorno;
  FormatSettings: TFormatSettings;
  DataHoraStr: string;
begin
  // Configura formato para conversões numéricas
  FormatSettings := TFormatSettings.Create;
  FormatSettings.DecimalSeparator := ',';
  FormatSettings.ThousandSeparator := '.';
  FormatSettings.ShortDateFormat := 'dd/mm/yyyy';
  FormatSettings.DateSeparator := '/';
  FormatSettings.TimeSeparator := ':';
  FormatSettings.ShortTimeFormat := 'hh:nn:ss';

  // Divide o conteúdo em linhas
  Linhas := ConteudoCsv.Split([#13#10, #10, #13], TStringSplitOptions.ExcludeEmpty);

  // Verifica se há pelo menos o cabeçalho + 1 linha de dados
  if Length(Linhas) <= 1 then
    Exit;

  // Processa cada linha de dados (pula o cabeçalho na linha 0)
  for i := 1 to High(Linhas) do
  begin
    // Divide a linha em colunas usando ponto e vírgula
    Colunas := Linhas[i].Split([';']);

    // SEMPRE processa a linha, expandindo o array se necessário
    while Length(Colunas) < 14 do
    begin
      SetLength(Colunas, Length(Colunas) + 1);
      Colunas[High(Colunas)] := ''; // Adiciona string vazia para colunas faltantes
    end;

    // Criar novo objeto TMultiplusCardRetorno na lista
    NovoRetorno := AdicionarRetorno;

    // Mapear campos CSV para propriedades TMultiplusCardRetorno
    NovoRetorno.NOME_REDE := Trim(Colunas[0]);              // RedeNome
    NovoRetorno.NOME_BANDEIRA := Trim(Colunas[1]);          // BandeiraNome
    NovoRetorno.DESC_TIPO_TRANSACAO := Trim(Colunas[2]);    // ServicoDescricao
    NovoRetorno.NSU := Trim(Colunas[3]);                    // TransacaoNSU

    // Data/Hora Estabelecimento
    if Trim(Colunas[4]) <> '' then
    begin
      try
        DataHoraStr := DateTimeToStr(StrToDateTime(Trim(Colunas[4]), FormatSettings));
        NovoRetorno.DATA_HORA_ESTABELECIMENTO := DataHoraStr;
      except
        NovoRetorno.DATA_HORA_ESTABELECIMENTO := '';
      end;
    end;

    // Data/Hora Administradora
    if Trim(Colunas[5]) <> '' then
    begin
      try
        DataHoraStr := DateTimeToStr(StrToDateTime(Trim(Colunas[5]), FormatSettings));
        NovoRetorno.DATA_HORA_ADMINISTRADORA := DataHoraStr;
      except
        NovoRetorno.DATA_HORA_ADMINISTRADORA := '';
      end;
    end;

    // Valor da transação
    if Trim(Colunas[6]) <> '' then
    begin
      try
        NovoRetorno.VALOR := FormatFloat('0.00', StrToFloat(Trim(Colunas[6]), FormatSettings));
      except
        NovoRetorno.VALOR := '0,00';
      end;
    end;

    // Taxa de serviço
    if Trim(Colunas[7]) <> '' then
    begin
      try
        NovoRetorno.TAXA_SERVICO := FormatFloat('0.00', StrToFloat(Trim(Colunas[7]), FormatSettings));
      except
        NovoRetorno.TAXA_SERVICO := '0,00';
      end;
    end;

    NovoRetorno.NUMERO_CARTAO := Trim(Colunas[8]);          // TransacaoNumeroCartao
    NovoRetorno.COD_AUTORIZACAO := Trim(Colunas[9]);        // TransacaoCodigoAutorizacao
    NovoRetorno.NSU_REDE := Trim(Colunas[10]);              // TransacaoNsuHost
    NovoRetorno.STATUS := Trim(Colunas[11]);                // TransacaoStatus

    // Quantidade de parcelas
    if Trim(Colunas[12]) <> '' then
    begin
      try
        NovoRetorno.QTDE_PARCELAS := Trim(Colunas[12]);
      except
        NovoRetorno.QTDE_PARCELAS := '0';
      end;
    end;

    NovoRetorno.TERMINAL := Trim(Colunas[13]);              // TransacaoTerminal

    // Marcar como sucesso
    NovoRetorno.Sucesso := True;
  end;
end;

procedure TMultiplusCardTef.ProcessarRelatorioJson(const ConteudoJson: string);
var
  JSONValue: TJSONValue;
  JSONArray: TJSONArray;
  JSONObject: TJSONObject;
  i: Integer;
  NovoRetorno: TMultiplusCardRetorno;
  DataHoraStr: string;
begin
  JSONValue := TJSONObject.ParseJSONValue(ConteudoJson);
  try
    if JSONValue is TJSONObject then
    begin
      JSONObject := JSONValue as TJSONObject;

      if JSONObject.TryGetValue<TJSONArray>('Transacoes', JSONArray) then
      begin
        for i := 0 to JSONArray.Count - 1 do
        begin
          if JSONArray.Items[i] is TJSONObject then
          begin
            JSONObject := JSONArray.Items[i] as TJSONObject;

            // Criar novo objeto TMultiplusCardRetorno na lista
            NovoRetorno := AdicionarRetorno;

            // Mapear campos JSON para propriedades TMultiplusCardRetorno
            NovoRetorno.NOME_REDE := SafeGetString(JSONObject, 'RedeNome');
            NovoRetorno.NOME_BANDEIRA := SafeGetString(JSONObject, 'BandeiraNome');
            NovoRetorno.DESC_TIPO_TRANSACAO := SafeGetString(JSONObject, 'ServicoDescricao');
            NovoRetorno.NSU := SafeGetString(JSONObject, 'TransacaoNSU');

            // Conversão de datas ISO8601
            DataHoraStr := AjustarFormatoIso8601(SafeGetString(JSONObject, 'TransacaoDataHoraEstabelecimento'));
            if DataHoraStr <> '' then
            begin
              try
                NovoRetorno.DATA_HORA_ESTABELECIMENTO := DateTimeToStr(ISO8601ToDate(DataHoraStr));
              except
                NovoRetorno.DATA_HORA_ESTABELECIMENTO := '';
              end;
            end;

            DataHoraStr := AjustarFormatoIso8601(SafeGetString(JSONObject, 'TransacaoDataHoraAdministradora'));
            if DataHoraStr <> '' then
            begin
              try
                NovoRetorno.DATA_HORA_ADMINISTRADORA := DateTimeToStr(ISO8601ToDate(DataHoraStr));
              except
                NovoRetorno.DATA_HORA_ADMINISTRADORA := '';
              end;
            end;

            // Valores monetários
            NovoRetorno.VALOR := FormatFloat('0.00', SafeGetFloat(JSONObject, 'TransacaoValor'));
            NovoRetorno.TAXA_SERVICO := FormatFloat('0.00', SafeGetFloat(JSONObject, 'TransacaoValorTaxaServico'));

            NovoRetorno.NUMERO_CARTAO := SafeGetString(JSONObject, 'TransacaoNumeroCartao');
            NovoRetorno.COD_AUTORIZACAO := SafeGetString(JSONObject, 'TransacaoCodigoAutorizacao');
            NovoRetorno.NSU_REDE := SafeGetString(JSONObject, 'TransacaoNsuHost');
            NovoRetorno.STATUS := SafeGetString(JSONObject, 'TransacaoStatus');
            NovoRetorno.QTDE_PARCELAS := IntToStr(SafeGetInt(JSONObject, 'TransacaoQtdParcelas'));
            NovoRetorno.TERMINAL := SafeGetString(JSONObject, 'TransacaoTerminal');

            // Marcar como sucesso
            NovoRetorno.Sucesso := True;
          end;
        end;
      end;
    end;
  finally
    JSONValue.Free;
  end;
end;

// Funções auxiliares para JSON
function TMultiplusCardTef.SafeGetString(JSONObj: TJSONObject; const Path: string): string;
var
  JSONValue: TJSONValue;
begin
  Result := '';
  if JSONObj.TryGetValue<TJSONValue>(Path, JSONValue) and (JSONValue <> nil) and not (JSONValue is TJSONNull) then
    Result := JSONValue.Value;
end;

function TMultiplusCardTef.SafeGetFloat(JSONObj: TJSONObject; const Path: string): Double;
var
  JSONValue: TJSONValue;
  FloatStr: string;
  FormatSettings: TFormatSettings;
begin
  Result := 0.0;
  if JSONObj.TryGetValue<TJSONValue>(Path, JSONValue) and (JSONValue <> nil) and not (JSONValue is TJSONNull) then
  begin
    FloatStr := JSONValue.Value;
    FormatSettings := TFormatSettings.Create;
    FormatSettings.DecimalSeparator := '.';
    FormatSettings.ThousandSeparator := ',';
    if not TryStrToFloat(FloatStr, Result, FormatSettings) then
      Result := 0.0;
  end;
end;

function TMultiplusCardTef.SafeGetInt(JSONObj: TJSONObject; const Path: string): Integer;
var
  JSONValue: TJSONValue;
  IntStr: string;
begin
  Result := 0;
  if JSONObj.TryGetValue<TJSONValue>(Path, JSONValue) and (JSONValue <> nil) and not (JSONValue is TJSONNull) then
  begin
    IntStr := JSONValue.Value;
    if not TryStrToInt(IntStr, Result) then
      Result := 0;
  end;
end;

function TMultiplusCardTef.AjustarFormatoIso8601(const DataStr: string): string;
var
  PosPonto: Integer;
  ParteAntes, Milissegundos: string;
begin
  PosPonto := Pos('.', DataStr);
  if PosPonto > 0 then
  begin
    ParteAntes := Copy(DataStr, 1, PosPonto);
    Milissegundos := Copy(DataStr, PosPonto + 1, MaxInt);
    if Length(Milissegundos) < 3 then
      Milissegundos := Milissegundos + StringOfChar('0', 3 - Length(Milissegundos))
    else if Length(Milissegundos) > 3 then
      Milissegundos := Copy(Milissegundos, 1, 3);
    Result := ParteAntes + Milissegundos;
  end
  else
    Result := DataStr;
end;

//==============================================================================
// METODOS AUXILIARES
//==============================================================================

function TMultiplusCardTef.VerificarDLL: Boolean;
var
  CaminhoDLL: string;
begin
  Result := False;

  // Tenta encontrar a DLL no diretório do executável
  CaminhoDLL := ExtractFilePath(ParamStr(0)) + Configuracoes.NomeDLL;
  if FileExists(CaminhoDLL) then
  begin
    Result := True;
    Exit;
  end
  else
    DoRegistrarLog('DLL "'+ Configuracoes.NomeDLL +'" não localizada no diretório atual.', true);
end;

function TMultiplusCardTef.GetListaRetornos: TMultiplusCardRetornoList;
begin
  // Sempre retorna a lista interna
  Result := FListaRetornos;
end;


//==============================================================================
// MÉTODO PRINCIPAL - EXECUÇÃO DE TRANSAÇÕES TEF
//==============================================================================

function TMultiplusCardTef.EfetuaTransacao(Op: TOperacao; Cupom, Nsu, Valor: string; Parcela: Integer; Parametros: string): Boolean;
var
  retornoIniciaFuncaoMCInterativo: Integer;
  retornoContinuaFuncaoMCInterativo: Integer;
  retornoFinalizaFuncaoMCInterativo: Integer;
  retornoCancelarFluxoMCInterativo: Integer;
  retornoAguardaFuncaoMCInterativo: string;
  retornoArrayAguardaFuncaoMCInterativo: TArray<string>;
  retornoTagAguardaFuncaoMCInterativo: string;
  retornoConteudoAguardaFuncaoMCInterativo: string;
  i, tamArray: Integer;
  partes: TArray<string>;
  conteudoRelatorio: string;
  respostaMensagem: string;
  iComando: Integer;
  continuarTentativaConfirmarVenda: Boolean;
begin
  Result := False;
  retornoTagAguardaFuncaoMCInterativo := '';

  try
    // === CONVERSÃO DO ENUM PARA CÓDIGO NUMÉRICO ===
    case Op of
      tpiComando_DEBITO                 : iComando := 4;
      tpiComando_DEBITO_A_VISTA         : iComando := 20;
      tpiComando_CREDITO                : iComando := 1;
      tpiComando_CREDITO_A_VISTA        : iComando := 0;
      tpiComando_CREDITO_PARC_LOJA      : iComando := 2;
      tpiComando_CREDITO_PARC_ADM       : iComando := 3;
      tpiComando_FROTA                  : iComando := 11;
      tpiComando_VOUCHER                : iComando := 18;
      tpiComando_CONSULTA_SALDO_CREDITO : iComando := 9;
      tpiComando_CONSULTA_SALDO_DEBITO  : iComando := 10;
      tpiComando_PRE_AUTORIZACAO        : iComando := 15;
      tpiComando_CONF_PRE_AUTORIZACAO   : iComando := 16;
      tpiComando_CANC_PRE_AUTORIZACAO   : iComando := 17;
      tpiComando_EXCLUIR_BINS           : iComando := 110;
      tpiComando_REIMPRESSAO            : iComando := 6;
      tpiComando_COLETA_DE_CPF          : iComando := 200;
      tpiComando_OPCOES_PSP             : iComando := 50;
      tpiComando_PSP_CLIENTE            : iComando := 51;
      tpiComando_MERCADO_PAGO           : iComando := 52;
      tpiComando_PICPAY                 : iComando := 53;
      tpiComando_ESTORNO                : iComando := 5;
      tpiComando_ESTORNO_PIX            : iComando := 54;
      tpiComando_REMOVE_PIX             : iComando := 55;
      tpiComando_STATUS_TRANSACAO_PIX   : iComando := 56;
      tpiComando_REIMPRESSAO_PIX        : iComando := 59;
      tpiComando_LIMPEZA_TABELA         : iComando := 110;
      tpiComando_REALATORIO_TRANSACOES  : iComando := 300;
      tpiComando_COMPROVANTE_POS        : iComando := 400;
      tpiComando_POS_TEF                : iComando := 401;
      tpiComando_STATUS_POS_TEF         : iComando := 402;
      tpiComando_CANCELAR_POS_TEF       : iComando := 403;
      tpiComando_PRE_VENDA              : iComando := 404;
      tpiComando_STATUS_PRE_VENDA       : iComando := 405;
      tpiComando_CANCELAR_PRE_VENDA     : iComando := 406;
      tpiComando_CONFIRMA_TRANSACAO     : iComando := 98;
      tpiComando_DESFAZ_TRANSACAO       : iComando := 99;
      tpiComando_STATUS_PINPAD          : iComando := 806;
      tpiComando_INFORMACAO_PINPAD      : iComando := 807;

    end;

    DoMsg('Iniciando...');

    // ========== VERIFICAÇÃO DA DLL ANTES DE INICIAR ==========
    if not VerificarDLL then
    begin
      DoMsg('Operação cancelada: DLL não encontrada.');
      DoFalhaOperacao('Operação cancelada: DLL não encontrada.');
      DoRegistrarLog('Operação cancelada: DLL não encontrada.', true);
      Exit;
    end;
    // =========================================================

    // Formata valor monetário para a DLL: sem separador de milhar e com vírgula decimal
    // (ex.: 1000,00), independente da configuração regional do Windows
    var FormatoValorDll := TFormatSettings.Invariant;
    FormatoValorDll.DecimalSeparator := ',';
    FormatoValorDll.ThousandSeparator := '.';
    Valor := FormatFloat('0.00', StrToFloat(Valor, FormatoValorDll), FormatoValorDll);

    // Chamando a função IniciaFuncaoMCInterativo para iniciar a operação
    retornoIniciaFuncaoMCInterativo := IniciaFuncaoMCInterativo(
      iComando,
      PAnsiChar(AnsiString(FMultiplusCardConfig.CnpjEmpresa.Replace('.','').Replace('-','').Replace('/','').Replace(' ',''))),
      Parcela,
      PAnsiChar(AnsiString(Cupom)),
      PAnsiChar(AnsiString(Valor)),
      PAnsiChar(AnsiString(Nsu)),
      PAnsiChar(AnsiString(FMultiplusCardConfig.Data)),
      PAnsiChar(AnsiString(FMultiplusCardConfig.PontoDeVenda)),
      PAnsiChar(AnsiString(FMultiplusCardConfig.CodigoLoja)),
      0,
      PAnsiChar(AnsiString(Parametros))
    );

    DoRegistrarLog('Chamada IniciaFuncaoMCInterativo( ' + IntToStr(iComando) + ', ' + FMultiplusCardConfig.CnpjEmpresa + ', ' +
          IntToStr(Parcela) + ', ' + Cupom + ', ' + Valor + ', ' + Nsu + ', ' + FMultiplusCardConfig.Data + ', ' +
          FMultiplusCardConfig.PontoDeVenda + ', ' + FMultiplusCardConfig.CodigoLoja + ', 0, )', false);

    if retornoIniciaFuncaoMCInterativo = 0 then
    begin
      continuarExecucao := True;
      DoRegistrarLog('Retorno IniciaFuncaoMCInterativo: ' + IntToStr(retornoIniciaFuncaoMCInterativo), false);

      while (retornoTagAguardaFuncaoMCInterativo <> '[ERROABORTAR]') and
            (retornoTagAguardaFuncaoMCInterativo <> '[ERRODISPLAY]') and
            (retornoTagAguardaFuncaoMCInterativo <> '[RETORNO]') and
            (continuarExecucao) do
      begin
        retornoConteudoAguardaFuncaoMCInterativo := '';
        retornoTagAguardaFuncaoMCInterativo := '';
        SetLength(retornoArrayAguardaFuncaoMCInterativo, 0);
        retornoAguardaFuncaoMCInterativo := string(AguardaFuncaoMCInterativo());

        // Verificando se o retorno possui conteúdo
        if Length(retornoAguardaFuncaoMCInterativo) > 2 then
        begin
          retornoArrayAguardaFuncaoMCInterativo := retornoAguardaFuncaoMCInterativo.Split(['#']);
          retornoTagAguardaFuncaoMCInterativo := retornoArrayAguardaFuncaoMCInterativo[0];

          DoRegistrarLog('Retorno AguardaFuncaoMCInterativo: ' + retornoAguardaFuncaoMCInterativo, false);
          DoMsg(retornoAguardaFuncaoMCInterativo);

          //if iComando <> 300 then
            //DoRegistrarLog('Retorno AguardaFuncaoMCInterativo <> 300: ' + retornoAguardaFuncaoMCInterativo, false);
            if ((iComando = 50) or (iComando = 51) or (iComando = 52)) and (StartsText('[MSG]#NSU=', retornoAguardaFuncaoMCInterativo)) then
              DoQrCodeGerado(retornoArrayAguardaFuncaoMCInterativo[1])
            else if (((iComando = 806) or (iComando = 807))and (StartsText('[RETORNO]', retornoAguardaFuncaoMCInterativo))) then
            begin
              DoPinpad(retornoArrayAguardaFuncaoMCInterativo[1]);
              Result := True;
            end;

        end;

        // === TRATAMENTO DE MENU ===
        if retornoTagAguardaFuncaoMCInterativo = '[MENU]' then
        begin
          retornoConteudoAguardaFuncaoMCInterativo := retornoArrayAguardaFuncaoMCInterativo[2];

          var r := objUi.CriarFormInterfaceDinamica(tsMenu, retornoAguardaFuncaoMCInterativo,Configuracoes.FUsaFormPadrao);

          if r.Confirmou then
          begin
            respostaMensagem := r.RespTexto;
            retornoContinuaFuncaoMCInterativo := ContinuaFuncaoMCInterativo(PAnsiChar(AnsiString(respostaMensagem)));

            DoRegistrarLog('Chamada ContinuaFuncaoMCInterativo("' + respostaMensagem + '")', false);
            DoRegistrarLog('Retorno ContinuaFuncaoMCInterativo: ' + GetCodigoErro(retornoContinuaFuncaoMCInterativo), false);
          end
          else
          begin
            DoMsg('Fluxo cancelado.');
            DoRegistrarLog('Chamada CancelarFluxoMCInterativo()', false);
            retornoCancelarFluxoMCInterativo := CancelarFluxoMCInterativo();
            DoRegistrarLog('Retorno CancelarFluxoMCInterativo: ' + GetCodigoErro(retornoCancelarFluxoMCInterativo), false);
            while(retornoCancelarFluxoMCInterativo <> 0) and (retornoCancelarFluxoMCInterativo <> 37) and (retornoCancelarFluxoMCInterativo <> 42) do
            begin
              DoRegistrarLog('Chamada CancelarFluxoMCInterativo()', false);
              retornoCancelarFluxoMCInterativo := CancelarFluxoMCInterativo;
              DoRegistrarLog('Retorno CancelarFluxoMCInterativo: ' + GetCodigoErro(retornoCancelarFluxoMCInterativo), false);
            end;
            continuarExecucao := False;
          end;
        end;

        // === TRATAMENTO DE PERGUNTA ===
        if retornoTagAguardaFuncaoMCInterativo = '[PERGUNTA]' then
        begin
          retornoConteudoAguardaFuncaoMCInterativo := retornoArrayAguardaFuncaoMCInterativo[1];
          var r := objUi.CriarFormInterfaceDinamica(tsPergunta, retornoAguardaFuncaoMCInterativo,Configuracoes.FUsaFormPadrao);
          if r.Confirmou then
          begin
            respostaMensagem := r.RespTexto;
            retornoContinuaFuncaoMCInterativo := ContinuaFuncaoMCInterativo(PAnsiChar(AnsiString(respostaMensagem)));

            DoRegistrarLog('Chamada ContinuaFuncaoMCInterativo("' + respostaMensagem + '")', false);
            DoRegistrarLog('Retorno ContinuaFuncaoMCInterativo: ' + GetCodigoErro(retornoContinuaFuncaoMCInterativo), false);
          end
          else
          begin
            DoMsg('Fluxo cancelado.');
            DoRegistrarLog('Chamada CancelarFluxoMCInterativo()', false);
            retornoCancelarFluxoMCInterativo := CancelarFluxoMCInterativo();
            DoRegistrarLog('Retorno CancelarFluxoMCInterativo: ' + GetCodigoErro(retornoCancelarFluxoMCInterativo), false);
            while(retornoCancelarFluxoMCInterativo <> 0) and (retornoCancelarFluxoMCInterativo <> 37) and (retornoCancelarFluxoMCInterativo <> 42) do
            begin
              DoRegistrarLog('Chamada CancelarFluxoMCInterativo()', false);
              retornoCancelarFluxoMCInterativo := CancelarFluxoMCInterativo;
              DoRegistrarLog('Retorno CancelarFluxoMCInterativo: ' + GetCodigoErro(retornoCancelarFluxoMCInterativo), false);
            end;
            continuarExecucao := False;
          end;
        end;
      end;

      // === VERIFICA SE DEVE CANCELAR FLUXO APÓS LOOP ===
      if (retornoTagAguardaFuncaoMCInterativo = '[ERROABORTAR]') or (retornoTagAguardaFuncaoMCInterativo = '[ERRODISPLAY]') then
      begin
        DoMsg('Fluxo cancelado.');
        DoRegistrarLog('Chamada CancelarFluxoMCInterativo()', false);
        retornoCancelarFluxoMCInterativo := CancelarFluxoMCInterativo();
        DoRegistrarLog('Retorno CancelarFluxoMCInterativo: ' + GetCodigoErro(retornoCancelarFluxoMCInterativo), false);
        while(retornoCancelarFluxoMCInterativo <> 0) and (retornoCancelarFluxoMCInterativo <> 37) and (retornoCancelarFluxoMCInterativo <> 42) do
        begin
        DoRegistrarLog('Chamada CancelarFluxoMCInterativo()', false);
          retornoCancelarFluxoMCInterativo := CancelarFluxoMCInterativo;
          DoRegistrarLog('Retorno CancelarFluxoMCInterativo: ' + GetCodigoErro(retornoCancelarFluxoMCInterativo), false);
        end;
        Exit(False);
      end;

      // === PROCESSAMENTO DO RETORNO FINAL ===
      if (retornoTagAguardaFuncaoMCInterativo = '[RETORNO]') then
      begin
        if (iComando <> 806) and (iComando <> 807) and (iComando <> 200) and
           (iComando <> 300) and (iComando <> 402) and (iComando <> 405) and
           (iComando <> 406) and (iComando <> 56) and (iComando <> 110)  then
        begin
          // === PROCESSAMENTO PADRÃO DE TRANSAÇÕES ===
          tamArray := Length(retornoArrayAguardaFuncaoMCInterativo);
          if tamArray > 1 then
          begin
            for i := 0 to tamArray - 2 do
              retornoArrayAguardaFuncaoMCInterativo[i] := retornoArrayAguardaFuncaoMCInterativo[i + 1];
            SetLength(retornoArrayAguardaFuncaoMCInterativo, tamArray - 1);
          end;

          // Carrega os campos de retorno
          FRetornoPgto.DllParaRetorno(retornoAguardaFuncaoMCInterativo);

          Nsu := FRetornoPgto.NSU;

          // Retornar dados do comprovante
          DoGerarComprovante(FRetornoPgto);

          // Confirmar transação (código 98)
          DoRegistrarLog('Chamada FinalizaFuncaoMCInterativo( 98, ' + FMultiplusCardConfig.CnpjEmpresa + ', ' +
                IntToStr(Parcela) + ', ' + Cupom + ', ' + Valor + ', ' + Nsu + ', ' + FMultiplusCardConfig.Data + ', ' +
                FMultiplusCardConfig.PontoDeVenda + ', ' + FMultiplusCardConfig.CodigoLoja + ', 0, )', false);

          retornoFinalizaFuncaoMCInterativo := FinalizaFuncaoMCInterativo(
            98,
            PAnsiChar(AnsiString(FMultiplusCardConfig.CnpjEmpresa.Replace('.','').Replace('-','').Replace('/','').Replace(' ',''))),
            Parcela,
            PAnsiChar(AnsiString(Cupom)),
            PAnsiChar(AnsiString(Valor)),
            PAnsiChar(AnsiString(Nsu)),
            PAnsiChar(AnsiString(FMultiplusCardConfig.Data)),
            PAnsiChar(AnsiString(FMultiplusCardConfig.PontoDeVenda)),
            PAnsiChar(AnsiString(FMultiplusCardConfig.CodigoLoja)),
            0,
            PAnsiChar(AnsiString(''))
          );

          DoRegistrarLog('Retorno FinalizaFuncaoMCInterativo: ' + GetCodigoErro(retornoFinalizaFuncaoMCInterativo), false);

          // === TRATAMENTO ESPECIAL PARA ERRO 48 ===
          if retornoFinalizaFuncaoMCInterativo = 48 then
          begin
            continuarTentativaConfirmarVenda := True;
            While (continuarTentativaConfirmarVenda) do
            begin               
              if VerificarStatusTransacao(Cupom, Nsu, Valor, Parcela) then
              begin
                Result := True;
                continuarTentativaConfirmarVenda := False;
              end
              else
              begin
                var r := objUi.CriarFormInterfaceDinamica(tsSimNao, 'Falha ao confirmar transação. Tentar novamente?', Configuracoes.FUsaFormPadrao);
                if r.Confirmou then
                begin
                  DoMsg('Tentando confirmar a venda novamente.');               
                  DoRegistrarLog('Chamada CancelarFluxoMCInterativo()', false);
                  retornoCancelarFluxoMCInterativo := CancelarFluxoMCInterativo();
                  DoRegistrarLog('Retorno CancelarFluxoMCInterativo: ' + GetCodigoErro(retornoCancelarFluxoMCInterativo), false);
                  while(retornoCancelarFluxoMCInterativo <> 0) and (retornoCancelarFluxoMCInterativo <> 37) and (retornoCancelarFluxoMCInterativo <> 42) do
                  begin
                    DoRegistrarLog('Chamada CancelarFluxoMCInterativo()', false);
                    retornoCancelarFluxoMCInterativo := CancelarFluxoMCInterativo;
                    DoRegistrarLog('Retorno CancelarFluxoMCInterativo: ' + GetCodigoErro(retornoCancelarFluxoMCInterativo), false);
                  end;         

                  DoRegistrarLog('Chamada FinalizaFuncaoMCInterativo( 98, ' + FMultiplusCardConfig.CnpjEmpresa + ', ' +
                        IntToStr(Parcela) + ', ' + Cupom + ', ' + Valor + ', ' + Nsu + ', ' + FMultiplusCardConfig.Data + ', ' +
                        FMultiplusCardConfig.PontoDeVenda + ', ' + FMultiplusCardConfig.CodigoLoja + ', 0, )', false);

                  // Confirmar transação (código 98)
                  retornoFinalizaFuncaoMCInterativo := FinalizaFuncaoMCInterativo(
                    98,
                    PAnsiChar(AnsiString(FMultiplusCardConfig.CnpjEmpresa.Replace('.','').Replace('-','').Replace('/','').Replace(' ',''))),
                    Parcela,
                    PAnsiChar(AnsiString(Cupom)),
                    PAnsiChar(AnsiString(Valor)),
                    PAnsiChar(AnsiString(Nsu)),
                    PAnsiChar(AnsiString(FMultiplusCardConfig.Data)),
                    PAnsiChar(AnsiString(FMultiplusCardConfig.PontoDeVenda)),
                    PAnsiChar(AnsiString(FMultiplusCardConfig.CodigoLoja)),
                    0,
                    PAnsiChar(AnsiString(''))
                  );

                  DoRegistrarLog('Retorno FinalizaFuncaoMCInterativo: ' + GetCodigoErro(retornoFinalizaFuncaoMCInterativo), false);

                  if retornoFinalizaFuncaoMCInterativo = 0 then
                  begin
                    Result := True;
                    continuarTentativaConfirmarVenda := False;
                  end;
                end
                else
                begin
                  var contagemDesfazimento := 0;
                  While (contagemDesfazimento < 3) do
                  begin
                    DoRegistrarLog('Chamada FinalizaFuncaoMCInterativo( 99, ' + FMultiplusCardConfig.CnpjEmpresa + ', ' +
                          IntToStr(Parcela) + ', ' + Cupom + ', ' + Valor + ', ' + Nsu + ', ' + FMultiplusCardConfig.Data + ', ' +
                          FMultiplusCardConfig.PontoDeVenda + ', ' + FMultiplusCardConfig.CodigoLoja + ', 0, )', false);

                    // Desfazer transação (código 99)
                    retornoFinalizaFuncaoMCInterativo := FinalizaFuncaoMCInterativo(
                      99,
                      PAnsiChar(AnsiString(FMultiplusCardConfig.CnpjEmpresa.Replace('.','').Replace('-','').Replace('/','').Replace(' ',''))),
                      Parcela,
                      PAnsiChar(AnsiString(Cupom)),
                      PAnsiChar(AnsiString(Valor)),
                      PAnsiChar(AnsiString(Nsu)),
                      PAnsiChar(AnsiString(FMultiplusCardConfig.Data)),
                      PAnsiChar(AnsiString(FMultiplusCardConfig.PontoDeVenda)),
                      PAnsiChar(AnsiString(FMultiplusCardConfig.CodigoLoja)),
                      0,
                      PAnsiChar(AnsiString(''))
                    );

                    DoRegistrarLog('Retorno FinalizaFuncaoMCInterativo: ' + GetCodigoErro(retornoFinalizaFuncaoMCInterativo), false);
                    
                    if retornoFinalizaFuncaoMCInterativo = 0 then 
                    begin                      
                      DoMsg('Venda desfeita.');
                      contagemDesfazimento := 3
                    end
                    else 
                      Inc(contagemDesfazimento);

                  end;                    
                  Result := False;
                  continuarTentativaConfirmarVenda := False;
                                   
                end;
              end;               
            end;
          end
          else if retornoFinalizaFuncaoMCInterativo = 0 then
          begin
            Result := True;
          end;

        end
        else if iComando = 200 then
        begin
          // === PROCESSAMENTO DE COLETA DE CPF ===
          tamArray := Length(retornoArrayAguardaFuncaoMCInterativo);
          if tamArray > 1 then
          begin
            for i := 0 to tamArray - 2 do
              retornoArrayAguardaFuncaoMCInterativo[i] := retornoArrayAguardaFuncaoMCInterativo[i + 1];
            SetLength(retornoArrayAguardaFuncaoMCInterativo, tamArray - 1);
          end;

          if Length(retornoArrayAguardaFuncaoMCInterativo) > 0 then
          begin
            partes := retornoArrayAguardaFuncaoMCInterativo[0].Split(['=']);
            if Length(partes) > 1 then
            begin
              DoRegistrarLog('CPF Digitado: ' + partes[1], false);
              DoCpfInformado(partes[1]);
              Result := True;
            end;
          end;
        end
        else if iComando = 300 then
        begin
          // === PROCESSAMENTO DE RELATÓRIO ===
          tamArray := Length(retornoArrayAguardaFuncaoMCInterativo);
          if tamArray > 1 then
          begin
            for i := 0 to tamArray - 2 do
              retornoArrayAguardaFuncaoMCInterativo[i] := retornoArrayAguardaFuncaoMCInterativo[i + 1];
            SetLength(retornoArrayAguardaFuncaoMCInterativo, tamArray - 1);
          end;

          conteudoRelatorio := '';
          for i := 0 to Length(retornoArrayAguardaFuncaoMCInterativo) - 1 do
          begin
            if i > 0 then
              conteudoRelatorio := conteudoRelatorio + sLineBreak;
            conteudoRelatorio := conteudoRelatorio + retornoArrayAguardaFuncaoMCInterativo[i];
          end;

          // Verifica se a string contém "JSON=SIM" (ignorando maiúsculas/minúsculas)
          utilizaJson := Pos('JSON=SIM', UpperCase(Parametros)) > 0;

          RelatorioParaRetorno(conteudoRelatorio, utilizaJson);

          DoRegistrarLog('Relatório processado com sucesso', false);
          DoRelatorioTransacoes(FListaRetornos);
          Result := True;
        end
        else if (iComando = 402) or (iComando = 405) or (iComando = 406) or (iComando = 56) or (iComando = 110) then
        begin
          // === PROCESSAMENTO DE CONSULTAS ===
          // Confirmar transação
          DoRegistrarLog('Chamada FinalizaFuncaoMCInterativo( 98, ' + FMultiplusCardConfig.CnpjEmpresa + ', ' +
                        IntToStr(Parcela) + ', ' + Cupom + ', ' + Valor + ', ' + Nsu + ', ' + FMultiplusCardConfig.Data + ', ' +
                        FMultiplusCardConfig.PontoDeVenda + ', ' + FMultiplusCardConfig.CodigoLoja + ', 0, )', false);

          retornoFinalizaFuncaoMCInterativo := FinalizaFuncaoMCInterativo(
            98,
            PAnsiChar(AnsiString(FMultiplusCardConfig.CnpjEmpresa.Replace('.','').Replace('-','').Replace('/','').Replace(' ',''))),
            Parcela,
            PAnsiChar(AnsiString(Cupom)),
            PAnsiChar(AnsiString(Valor)),
            PAnsiChar(AnsiString(Nsu)),
            PAnsiChar(AnsiString(FMultiplusCardConfig.Data)),
            PAnsiChar(AnsiString(FMultiplusCardConfig.PontoDeVenda)),
            PAnsiChar(AnsiString(FMultiplusCardConfig.CodigoLoja)),
            0,
            PAnsiChar(AnsiString(''))
          );

          DoRegistrarLog('Retorno FinalizaFuncaoMCInterativo: ' + GetCodigoErro(retornoFinalizaFuncaoMCInterativo), false);

          if retornoFinalizaFuncaoMCInterativo = 0 then
            Result := True;
        end;
      end;
    end
    else
    begin
      DoRegistrarLog('Retorno IniciaFuncaoMCInterativo: ' + GetCodigoErro(retornoIniciaFuncaoMCInterativo),false);
      DoMsg(GetCodigoErro(retornoIniciaFuncaoMCInterativo));

      DoMsg('Fluxo cancelado.');
      DoRegistrarLog('Chamada CancelarFluxoMCInterativo()', false);
      retornoCancelarFluxoMCInterativo := CancelarFluxoMCInterativo();
      DoRegistrarLog('Retorno CancelarFluxoMCInterativo: ' + GetCodigoErro(retornoCancelarFluxoMCInterativo), false);

      while(retornoCancelarFluxoMCInterativo <> 0) and (retornoCancelarFluxoMCInterativo <> 37) and (retornoCancelarFluxoMCInterativo <> 42) do
      begin
        DoRegistrarLog('Chamada CancelarFluxoMCInterativo()', false);
        retornoCancelarFluxoMCInterativo := CancelarFluxoMCInterativo;
        DoRegistrarLog('Retorno CancelarFluxoMCInterativo: ' + GetCodigoErro(retornoCancelarFluxoMCInterativo), false);
      end;

      Exit(False);
    end;

  except
    on E: Exception do
    begin
      DoRegistrarLog('Ocorreram erros ao processar a operação: ' + E.Message, false);
    end;
  end;
end;

//==============================================================================
// VERIFICAÇÃO DE STATUS DE TRANSAÇÃO
//==============================================================================

function TMultiplusCardTef.VerificarStatusTransacao(Cupom, Nsu, Valor: string; Parcela: Integer): Boolean;
var
  retornoStatus, retornoCancelarFluxoMCInterativo: Integer;
  retornoAguarda: string;
  retornoArray: TArray<string>;
  retornoTag: string;
  retornoConteudo: string;
begin
  Result := False;

  retornoStatus := IniciaFuncaoMCInterativo(
    700,
    PAnsiChar(AnsiString(FMultiplusCardConfig.CnpjEmpresa.Replace('.','').Replace('-','').Replace('/','').Replace(' ',''))),
    Parcela,
    PAnsiChar(AnsiString(Cupom)),
    PAnsiChar(AnsiString(Valor)),
    PAnsiChar(AnsiString(Nsu)),
    PAnsiChar(AnsiString(FMultiplusCardConfig.Data)),
    PAnsiChar(AnsiString(FMultiplusCardConfig.PontoDeVenda)),
    PAnsiChar(AnsiString(FMultiplusCardConfig.CodigoLoja)),
    0,
    PAnsiChar(AnsiString(''))
  );

  DoRegistrarLog('Chamada IniciaFuncaoMCInterativo( 700 ) para verificar status', false);

  if retornoStatus = 0 then
  begin
    while (retornoTag <> '[ERROABORTAR]') and (retornoTag <> '[ERRODISPLAY]') and (retornoTag <> '[RETORNO]') do
    begin
      retornoConteudo := '';
      retornoTag := '';
      SetLength(retornoArray, 0);
      retornoAguarda := string(AguardaFuncaoMCInterativo());

      if Length(retornoAguarda) > 2 then
      begin
        retornoArray := retornoAguarda.Split(['#']);
        retornoTag := retornoArray[0];
        DoRegistrarLog('Retorno AguardaFuncaoMCInterativo: ' + retornoAguarda, false);
      end;
    end;

    if (retornoTag = '[ERROABORTAR]') or (retornoTag = '[ERRODISPLAY]') then
    begin
      DoRegistrarLog('Chamada CancelarFluxoMCInterativo()', false);
      CancelarFluxoMCInterativo();
      Exit(False);
    end;

    if (retornoTag = '[RETORNO]') then
    begin
      retornoConteudo := Trim(retornoArray[1]);

      if retornoConteudo = '00-APROVADA' then
      begin
        DoRegistrarLog('Venda aprovada.', false);
        Exit(True);
      end
      else if retornoConteudo = '86-DESFEITA' then
      begin
        DoRegistrarLog('Venda desfeita.', false);
        Exit(True);
      end
      else if retornoConteudo = '78-CANCELADA' then
      begin
        DoRegistrarLog('Venda cancelada.', false);
        Exit(True);
      end
      else if retornoConteudo = '77-PENDENTE' then
      begin
        DoRegistrarLog('Venda pendente.', false);
        Exit(False);
      end;
    end;
    Exit(False);
  end
  else
  begin
    DoRegistrarLog('Retorno IniciaFuncaoMCInterativo: ' + GetCodigoErro(retornoStatus),false);
    DoMsg('Fluxo cancelado.');
    DoRegistrarLog('Chamada CancelarFluxoMCInterativo()', false);
    retornoCancelarFluxoMCInterativo := CancelarFluxoMCInterativo();
    DoRegistrarLog('Retorno CancelarFluxoMCInterativo: ' + GetCodigoErro(retornoCancelarFluxoMCInterativo), false);
    Exit(False);
  end;

  Application.ProcessMessages;
end;

end.

