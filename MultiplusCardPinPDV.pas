unit MultiplusCardPinPDV;

interface

uses
  System.SysUtils,
  System.Classes,
  System.JSON,
  System.StrUtils,
  System.Threading,
  System.Generics.Collections,

  REST.Client,
  REST.Types,

  MultiplusCardCommons,

  Vcl.Graphics,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.Controls,
  vcl.ExtCtrls,
  Vcl.Buttons,

  MultiplusCardUtils;

//==============================================================================
// TIPOS E ENUMERAÇÕES
//==============================================================================

type
  /// <summary>
  /// Define as possíveis operações do PINPDV
  /// </summary>
  TComandoPinpdv = (
    tpiComandoPinpdv_NAO_INFORMADO,
    tpiComandoPinpdv_PIX,
    tpiComandoPinpdv_DEBITO,
    tpiComandoPinpdv_CREDITO_PARC_LOJA,
    tpiComandoPinpdv_CREDITO_A_VISTA,
    tpiComandoPinpdv_VOUCHER,
    tpiComandoPinpdv_DINHEIRO
  );

  /// <summary>
  /// Define os possíveis status de uma venda no sistema PinPDV
  /// </summary>
  TVendaStatus = (
    vsRealizada = 0,  // Venda foi realizada com sucesso
    vsCancelada = 8,  // Venda foi cancelada
    vsError = 9       // Erro ocorreu durante o processo de venda
  );

  /// <summary>
  /// Define os possíveis status de pagamento durante o processamento
  /// </summary>
  TPagamentoStatus = (
    psAguardando = 0,   // Pagamento está aguardando processamento
    psProcessando = 1,  // Pagamento está sendo processado
    psConcluido = 2     // Pagamento foi concluído
  );

  /// <summary>
  /// Tipos de pagamento suportados pelo sistema PinPDV
  /// </summary>
  TTipoPagamento = (
    tpNone = 0,             // Nenhum tipo específico definido
    tpDinheiro = 1,         // Pagamento em dinheiro
    tpCredito = 2,          // Cartão de crédito
    tpDebito = 3,           // Cartão de débito
    tpPix = 4,              // Pagamento via PIX
    tpValeRefeicao = 6,     // Vale refeição
    tpValeAlimentacao = 7   // Vale alimentação
  );

  /// <summary>
  /// Status da transação após processamento
  /// </summary>
  TTransacaoStatus = (
    tsAprovada = 0,   // Transação foi aprovada
    tsNegada = 1,     // Transação foi negada
    tsCancelada = 2   // Transação foi cancelada
  );


//==============================================================================
// CLASSES DE MODELO
//==============================================================================

  /// <summary>
  /// Representa um dispositivo PinPDV conectado ao sistema
  /// </summary>
  TPinPDV = class
  private
    FId: Integer;
    FCodigo: string;
    FNome: string;
    FIsAtivo: Boolean;
    FHeartbeat: string;
  public
    property Id: Integer read FId write FId;
    property Codigo: string read FCodigo write FCodigo;
    property Nome: string read FNome write FNome;
    property IsAtivo: Boolean read FIsAtivo write FIsAtivo;
    property Heartbeat: string read FHeartbeat write FHeartbeat;
  end;

  /// <summary>
  /// Container para lista de dispositivos PinPDV
  /// Gerencia automaticamente a memória dos objetos TPinPDV
  /// </summary>
  TListaPinPDV = class
  private
    FData: TObjectList<TPinPDV>;
  public
    constructor Create;
    destructor Destroy; override;
    property Data: TObjectList<TPinPDV> read FData;
  end;

  /// <summary>
  /// Contém dados detalhados de uma transação processada
  /// </summary>
  TDadosTransacao = class
  private
    FDataHora: string;
    FNSU: string;
    FAutorizacao: string;
    FBandeira: string;
    FAdquirente: string;
  public
    property DataHora: string read FDataHora write FDataHora;
    property NSU: string read FNSU write FNSU;
    property Autorizacao: string read FAutorizacao write FAutorizacao;
    property Bandeira: string read FBandeira write FBandeira;
    property Adquirente: string read FAdquirente write FAdquirente;
  end;

  /// <summary>
  /// Representa uma transação individual de pagamento
  /// </summary>
  TTransacao = class
  private
    FId: Integer;
    FValor: Currency;
    FParcelas: Integer;
    FStatus: TTransacaoStatus;
    FTipoPagamento: TTipoPagamento;
    FDados: TDadosTransacao;
  public
    constructor Create;
    destructor Destroy; override;
    property Id: Integer read FId write FId;
    property Valor: Currency read FValor write FValor;
    property Parcelas: Integer read FParcelas write FParcelas;
    property Status: TTransacaoStatus read FStatus write FStatus;
    property TipoPagamento: TTipoPagamento read FTipoPagamento write FTipoPagamento;
    property Dados: TDadosTransacao read FDados;
  end;

  /// <summary>
  /// Representa uma venda finalizada no sistema
  /// </summary>
  TVenda = class
  private
    FId: Integer;
    FIdentificador: string;
    FValor: Currency;
    FComprovante: string;
    FStatus: TVendaStatus;
    FTransacoes: TObjectList<TTransacao>;
  public
    constructor Create;
    destructor Destroy; override;
    property Id: Integer read FId write FId;
    property Identificador: string read FIdentificador write FIdentificador;
    property Valor: Currency read FValor write FValor;
    property Comprovante: string read FComprovante write FComprovante;
    property Status: TVendaStatus read FStatus write FStatus;
    property Transacoes: TObjectList<TTransacao> read FTransacoes;
  end;

  /// <summary>
  /// Representa uma pré-venda cadastrada no sistema
  /// </summary>
  TPreVenda = class
  private
    FId: Integer;
    FIdentificador: string;
    FDescricao: string;
    FValor: Currency;
    FParcelas: Integer;
    FTipoPagamento: TTipoPagamento;
    FStatus: TPagamentoStatus;
    FVendas: TObjectList<TVenda>;
  public
    constructor Create;
    destructor Destroy; override;
    property Id: Integer read FId write FId;
    property Identificador: string read FIdentificador write FIdentificador;
    property Descricao: string read FDescricao write FDescricao;
    property Valor: Currency read FValor write FValor;
    property Parcelas: Integer read FParcelas write FParcelas;
    property TipoPagamento: TTipoPagamento read FTipoPagamento write FTipoPagamento;
    property Status: TPagamentoStatus read FStatus write FStatus;
    property Vendas: TObjectList<TVenda> read FVendas;
  end;

  /// <summary>
  /// Representa uma pós-venda (transação direta no dispositivo)
  /// </summary>
  TPosVenda = class
  private
    FId: Integer;
    FIdentificador: string;
    FDescricao: string;
    FValor: Currency;
    FParcelas: Integer;
    FTipoPagamento: TTipoPagamento;
    FStatus: TPagamentoStatus;
    FVendas: TObjectList<TVenda>;
  public
    constructor Create;
    destructor Destroy; override;
    property Id: Integer read FId write FId;
    property Identificador: string read FIdentificador write FIdentificador;
    property Descricao: string read FDescricao write FDescricao;
    property Valor: Currency read FValor write FValor;
    property Parcelas: Integer read FParcelas write FParcelas;
    property TipoPagamento: TTipoPagamento read FTipoPagamento write FTipoPagamento;
    property Status: TPagamentoStatus read FStatus write FStatus;
    property Vendas: TObjectList<TVenda> read FVendas;
  end;

  /// <summary>
  /// Eventos para tratamento de interações do sistema PinPDV
  /// </summary>
  TMultiplusLogEvent         = procedure(Sender: TObject; const Conteudo: string) of object;
  TMultiplusMensagemEvent    = procedure(Sender: TObject; const Conteudo: string) of object;
  TMultiplusErroEvent        = procedure(Sender: TObject; const Conteudo: string) of object;
  TMultiplusComprovanteEvent = procedure(Sender: TObject; const Retorno: TMultiplusCardRetorno) of object;
  TOnSolicitaImpressao       = procedure(Sender: TObject; const PreVenda: TPreVenda) of object;
//==============================================================================
// COMPONENTE PRINCIPAL
//==============================================================================

  // === CONFIGURAÇÃO ===
  TMultiplusCardConfigPinPDV = class(TPersistent)
  private
    // implementar
    FBaseURL: string;
    FToken: string;
    FUsaFormPadrao      : Boolean;
    FIntervaloVerificacaoAutomatica: Integer;

  published
    // === CONFIGURAÇÕES DA API ===
    property BaseURL       : string                  read FBaseURL                        write FBaseURL;
    property Token         : string                  read FToken                          write FToken;
    property UsaFormPadrao : Boolean                 read FUsaFormPadrao                  write FUsaFormPadrao;
    property IntervaloVerificacaoAutomatica: Integer read FIntervaloVerificacaoAutomatica write FIntervaloVerificacaoAutomatica;
  end;
  /// <summary>
  /// Componente principal para integração com a API PinPDV
  /// </summary>
  TMultiplusCardPinPDV = class(TComponent)
  private
    // === INTEGRAÇÃO COM INTERFACE DE USUÁRIO ===
    FOnSolicitarInteracaoUi : MultiplusCardCommons.TOnSolicitarInteracao;
    FRespostaInteracao      : MultiplusCardCommons.TRespostaUsuario;

    // === CONFIGURAÇÃO DA API REST ===
    FClient: TRESTClient;
    FRequest: TRESTRequest;
    FResponse: TRESTResponse;

    // === CONFIGURAÇÕES DE MONITORAMENTO ===
    FInrrompePosTefMonitorado: Boolean;
    FInrrompePreVendaMonitorado: Boolean;

    FImpressaoDocumento : string;

    // === EVENTOS PRINCIPAIS ===
    FOnGerarComprovante   : TMultiplusComprovanteEvent;
    FOnFalhaOperacao      : TMultiplusErroEvent;
    FOnRegistrarLog       : TMultiplusLogEvent;
    FOnMsg                : TMultiplusMensagemEvent;
    FOnSolicitarImpressao : TOnSolicitaImpressao;

    // === OBJETOS AUXILIARES ===
    FRetornoPgto        : TMultiplusCardRetorno;
    FMensagemReduzida   : Boolean;

    // === OBJETOS AUXILIARES CONFIGURAÇÕES ===
    FMultiplusCardConfigPinPDV: TMultiplusCardConfigPinPDV;
    procedure SetMultiplusCardConfigPinPDV(const Value: TMultiplusCardConfigPinPDV);

    // === MÉTODOS DE CONFIGURAÇÃO REST ===
    procedure PrepareRequest(const AResource: string; AMethod: TRESTRequestMethod);
    function IsSuccessStatusCode(StatusCode: Integer): Boolean;
    procedure ProcessHttpError;
    function SafeParseJSON(const AContent: string): TJSONObject;
    function ExtractErrorMessage(const JSONContent: string): string;

    // === CONVERSORES JSON PARA OBJETOS ===
    function JSONToPinPDV(AJSON: TJSONObject): TPinPDV;
    function JSONToListaPinPDV(AJSON: TJSONObject): TListaPinPDV;
    function JSONToTransacao(AJSON: TJSONObject): TTransacao;
    function JSONToVenda(AJSON: TJSONObject): TVenda;
    function JSONToPreVenda(AJSON: TJSONObject): TPreVenda;
    function JSONToPosVenda(AJSON: TJSONObject): TPosVenda;
    function PinPdvPosTefParaRetorno(PosVenda: TPosVenda): TMultiplusCardRetorno;
    function PinPdvPreVendaParaRetorno(PreVenda: TPreVenda): TMultiplusCardRetorno;

    // === DISPARADORES DE EVENTOS ===
    procedure DoRegistrarLog(const Conteudo: string);
    procedure DoMsg(const Conteudo: string);
    procedure DoSolicitaImpressao(const PreVenda: TPreVenda);
    procedure DoFalhaOperacao(const Erro: string);
    procedure DoGerarComprovante(const Retorno: TMultiplusCardRetorno);

    // === TRATADORES DE INTERFACE DE USUÁRIO ===
    procedure TratarSolicitacaoInteracao(Sender: TObject; const Solicitacao: TSolicitacaoUsuario; var Resposta: TRespostaUsuario);
    procedure TratarMsg(Sender: TObject; const Conteudo: string);

    // === MÉTODOS DE MONITORAMENTO ===
    procedure IniciarMonitoramentoPagamento(const Identificador: string);
    procedure IniciarMonitoramentoPreVenda(const Identificador: string);

  public
    var
      objUi : TMultiplusCardUi;
      ProcessandoPosTefMonitorado : Boolean;
      ProcessandoPreVendaMonitorado : Boolean;

    // === CONSTRUTOR E DESTRUTOR ===
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    // === GERENCIAMENTO DE DISPOSITIVOS PINPDV ===
    function ListarDispositivosPinPDV: TListaPinPDV;
    function ListarDispositivosPinPDVJSON: TJSONObject;

    // === OPERAÇÕES DE PRÉ-VENDA ===
    function CadastrarPreVenda(const Identificador, Descricao: string; Valor: Currency;
                              Parcelas: Integer = 1; TipoPagamento: TTipoPagamento = tpNone;
                              PinPdvId: Integer = 0): Integer;
    function CadastrarPreVendaComMonitoramento(const Identificador, Descricao: string; Valor: Currency;
                              Parcelas: Integer = 1; TipoPagamento: TTipoPagamento = tpNone;
                              PinPdvId: Integer = 0): Integer;
    function ConsultarPreVenda(const Identificador: string): TPreVenda;
    function ConsultarPreVendaJSON(const Identificador: string): TJSONObject;
    function AbortarPreVenda(const Identificador: string; ForcaExcluir: Boolean = False): Boolean;
    function EnviarComprovanteVenda(const VendaIdentificador, Comprovante: string): Boolean;

    // === OPERAÇÕES DE PÓS-VENDA (POS TEF) ===
    function CadastrarPosVenda(PinPdvId: Integer; const Identificador, Descricao: string;
                              Valor: Currency; TipoPagamento: TTipoPagamento = tpNone;
                              Parcelas: Integer = 1): Integer;
    function CadastrarPosVendaComMonitoramento(PinPdvId: Integer; const Identificador, Descricao: string;
                              Valor: Currency; TipoPagamento: TTipoPagamento = tpNone;
                              Parcelas: Integer = 1): Integer;
    function ConsultarPosVenda(const Identificador: string): TPosVenda;
    function ConsultarPosVendaJSON(const Identificador: string): TJSONObject;
    function AbortarPosVenda(const Identificador: string; ForcaExcluir: Boolean = False): Boolean;

    // === MÉTODOS DE CONTROLE DE MONITORAMENTO ===
    procedure CancelarFluxoPosTefMonitorado;
    procedure CancelarFluxoPreVendaMonitorado;
    procedure EnviaDocumentoImpressao(const Documento:string);

    function AbortarRetry(const Identificador: string): Boolean;
    function AbortarPreVendaRetry(const Identificador: string): Boolean;
    // === Dados de Retorno ===
    property RetornoPgto                   : TMultiplusCardRetorno read FRetornoPgto                    write FRetornoPgto;

  published

    // === EVENTOS PRINCIPAIS ===
    property OnSolicitarInteracao: TOnSolicitarInteracao read FOnSolicitarInteracaoUi write FOnSolicitarInteracaoUi;
    property OnSolicitarImpressao: TOnSolicitaImpressao  read FOnSolicitarImpressao   write FOnSolicitarImpressao;

    property OnGerarComprovante  : TMultiplusComprovanteEvent  read FOnGerarComprovante write FOnGerarComprovante;
    property OnFalhaOperacao     : TMultiplusErroEvent         read FOnFalhaOperacao    write FOnFalhaOperacao;
    property OnRegistrarLog      : TMultiplusLogEvent          read FOnRegistrarLog     write FOnRegistrarLog;
    property OnMsg               : TMultiplusMensagemEvent     read FOnMsg              write FOnMsg;

    // === CONFIGURAÇÕES ===
    property Configuracoes : TMultiplusCardConfigPinPDV read FMultiplusCardConfigPinPDV write SetMultiplusCardConfigPinPDV;
  end;

procedure Register;

implementation

//==============================================================================
// REGISTRO DO COMPONENTE
//==============================================================================

procedure Register;
begin
  RegisterComponents('Multiplus Card', [TMultiplusCardPinPDV]);
end;

//==============================================================================
// IMPLEMENTAÇÃO DAS CLASSES DE MODELO
//==============================================================================

{ TListaPinPDV }

constructor TListaPinPDV.Create;
begin
  inherited;
  FData := TObjectList<TPinPDV>.Create(True);
end;

destructor TListaPinPDV.Destroy;
begin
  FData.Free;
  inherited;
end;

{ TTransacao }

constructor TTransacao.Create;
begin
  inherited;
  FDados := TDadosTransacao.Create;
end;

destructor TTransacao.Destroy;
begin
  FDados.Free;
  inherited;
end;

{ TVenda }

constructor TVenda.Create;
begin
  inherited;
  FTransacoes := TObjectList<TTransacao>.Create(True);
end;

destructor TVenda.Destroy;
begin
  FTransacoes.Free;
  inherited;
end;

{ TPreVenda }

constructor TPreVenda.Create;
begin
  inherited;
  FVendas := TObjectList<TVenda>.Create(True);
end;

destructor TPreVenda.Destroy;
begin
  FVendas.Free;
  inherited;
end;

{ TPosVenda }

constructor TPosVenda.Create;
begin
  inherited;
  FVendas := TObjectList<TVenda>.Create(True);
end;

destructor TPosVenda.Destroy;
begin
  FVendas.Free;
  inherited;
end;

//==============================================================================
// IMPLEMENTAÇÃO DO COMPONENTE PRINCIPAL
//==============================================================================

{ TMultiplusCardPinPDV }

constructor TMultiplusCardPinPDV.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FMultiplusCardConfigPinPDV := TMultiplusCardConfigPinPDV.Create;

  // Configurações padrão da API
  Configuracoes.FBaseURL := 'https://api.pinpdv.com.br';
  Configuracoes.FIntervaloVerificacaoAutomatica := 5000;

  // Inicialização REST Client
  FClient := TRESTClient.Create(Configuracoes.FBaseURL);
  FRequest := TRESTRequest.Create(nil);
  FResponse := TRESTResponse.Create(nil);
  FRetornoPgto := TMultiplusCardRetorno.Create;

  // Configura relacionamento entre objetos REST
  FRequest.Client := FClient;
  FRequest.Response := FResponse;

  // Inicialização da interface de usuário
  objUi := TMultiplusCardUi.Create(self);
  objUi.OnSolicitarInteracaoCm := TratarSolicitacaoInteracao;
  objUi.OnMsgCm := TratarMsg;
end;

destructor TMultiplusCardPinPDV.Destroy;
begin
  FRequest.Free;
  FResponse.Free;
  FClient.Free;
  FMultiplusCardConfigPinPDV.Free;
  inherited;
end;

procedure TMultiplusCardPinPDV.SetMultiplusCardConfigPinPDV(const Value: TMultiplusCardConfigPinPDV);
begin
  FMultiplusCardConfigPinPDV.Assign(Value);
end;

//==============================================================================
// MÉTODOS DE CONFIGURAÇÃO REST
//==============================================================================

procedure TMultiplusCardPinPDV.PrepareRequest(const AResource: string; AMethod: TRESTRequestMethod);
begin
  FClient.BaseURL := Configuracoes.FBaseURL;
  FRequest.Resource := AResource;
  FRequest.Method := AMethod;
  FRequest.Params.Clear;
  FRequest.AddParameter('Authorization', 'Bearer ' + Configuracoes.FToken, pkHTTPHEADER, [poDoNotEncode]);
  FRequest.Body.ClearBody;
end;

function TMultiplusCardPinPDV.IsSuccessStatusCode(StatusCode: Integer): Boolean;
begin
  Result := (StatusCode >= 200) and (StatusCode <= 299);
end;

procedure TMultiplusCardPinPDV.ProcessHttpError;
var
  ErrorMessage: string;
begin
  if (FResponse.StatusCode >= 400) and (FResponse.StatusCode <= 499) then
  begin
    ErrorMessage := '';
    if FResponse.Content <> '' then
      ErrorMessage := ExtractErrorMessage(FResponse.Content) + '(' + FResponse.StatusCode.ToString + ')'
    else
      ErrorMessage := ErrorMessage + ': ' + FResponse.StatusText;
    raise Exception.Create(ErrorMessage);
  end
  else
    raise Exception.Create('Erro HTTP ' + FResponse.StatusCode.ToString + ': ' + FResponse.StatusText);
end;

function TMultiplusCardPinPDV.SafeParseJSON(const AContent: string): TJSONObject;
var
  JSONValue: TJSONValue;
  DecodedContent: string;
begin
  Result := nil;

  if Trim(AContent) = '' then
    Exit;

  try
    DecodedContent := DecodeUnicodeEscapes(AContent);
    JSONValue := TJSONObject.ParseJSONValue(DecodedContent);
    if Assigned(JSONValue) and (JSONValue is TJSONObject) then
      Result := JSONValue as TJSONObject
    else if Assigned(JSONValue) then
      JSONValue.Free;
  except
    Result := nil;
  end;
end;

function TMultiplusCardPinPDV.ExtractErrorMessage(const JSONContent: string): string;
var
  JSONObj: TJSONObject;
  ErrorsObj: TJSONObject;
  ErrorArray: TJSONArray;
  ErrorValue: TJSONValue;
  I: Integer;
begin
  Result := JSONContent;

  JSONObj := SafeParseJSON(JSONContent);
  if not Assigned(JSONObj) then Exit;

  try
    // Prioridade 1: campo 'detail'
    Result := GetJSONStringValue(JSONObj, 'detail');
    if Result <> '' then Exit;

    // Prioridade 2: primeira mensagem do campo 'errors'
    ErrorValue := JSONObj.GetValue('errors');
    if Assigned(ErrorValue) and (ErrorValue is TJSONObject) then
    begin
      ErrorsObj := ErrorValue as TJSONObject;
      for I := 0 to ErrorsObj.Count - 1 do
      begin
        ErrorValue := ErrorsObj.Pairs[I].JsonValue;
        if (ErrorValue is TJSONArray) then
        begin
          ErrorArray := ErrorValue as TJSONArray;
          if ErrorArray.Count > 0 then
          begin
            Result := ErrorArray.Items[0].Value;
            Exit;
          end;
        end;
      end;
    end;

    // Prioridade 3: campo 'title'
    Result := GetJSONStringValue(JSONObj, 'title');
  finally
    JSONObj.Free;
  end;
end;

//==============================================================================
// GERENCIAMENTO DE DISPOSITIVOS PINPDV
//==============================================================================

function TMultiplusCardPinPDV.ListarDispositivosPinPDV: TListaPinPDV;
var
  ResponseJSON: TJSONObject;
begin
  try
    PrepareRequest('pinpdv', rmGET);

    try
      FRequest.Execute;
    except
      on E: Exception do
      begin
        if FResponse.StatusCode >= 400 then
        begin
          DoRegistrarLog('ListarDispositivosPinPDV - Status: ' + FResponse.StatusCode.ToString);
          ProcessHttpError;
        end
        else
          raise;
      end;
    end;

    DoRegistrarLog('ListarDispositivosPinPDV - Status: ' + FResponse.StatusCode.ToString);

    if not IsSuccessStatusCode(FResponse.StatusCode) then
      ProcessHttpError;

    ResponseJSON := SafeParseJSON(FResponse.Content);
    try
      Result := JSONToListaPinPDV(ResponseJSON);
    finally
      if Assigned(ResponseJSON) then
        ResponseJSON.Free;
    end;
  except
    on E: Exception do
    begin
      DoRegistrarLog('Erro ao listar dispositivos PinPDV: ' + E.Message);
      raise;
    end;
  end;
end;

function TMultiplusCardPinPDV.ListarDispositivosPinPDVJSON: TJSONObject;
begin
  try
    PrepareRequest('pinpdv', rmGET);

    try
      FRequest.Execute;
    except
      on E: Exception do
      begin
        if FResponse.StatusCode >= 400 then
        begin
          DoRegistrarLog('ListarDispositivosPinPDVJSON - Status: ' + FResponse.StatusCode.ToString);
          ProcessHttpError;
        end
        else
          raise;
      end;
    end;

    DoRegistrarLog('ListarDispositivosPinPDVJSON - Status: ' + FResponse.StatusCode.ToString);

    if not IsSuccessStatusCode(FResponse.StatusCode) then
      ProcessHttpError;

    Result := SafeParseJSON(FResponse.Content);
  except
    on E: Exception do
    begin
      DoRegistrarLog('Erro ao listar dispositivos PinPDV (JSON): ' + E.Message);
      raise;
    end;
  end;
end;

//==============================================================================
// OPERAÇÕES DE PRÉ-VENDA
//==============================================================================

function TMultiplusCardPinPDV.CadastrarPreVenda(const Identificador, Descricao: string; Valor: Currency;
                              Parcelas: Integer = 1; TipoPagamento: TTipoPagamento = tpNone;
                              PinPdvId: Integer = 0): Integer;
var
  JSON, ResponseJSON: TJSONObject;
begin
  try
    JSON := TJSONObject.Create;
    try
      JSON.AddPair('Identificador', Identificador);
      JSON.AddPair('Valor', TJSONNumber.Create(Valor));
      JSON.AddPair('Descricao', Descricao);
      JSON.AddPair('Parcelas', TJSONNumber.Create(Parcelas));

      if TipoPagamento <> tpNone then
        JSON.AddPair('TipoPagamento', TJSONNumber.Create(Ord(TipoPagamento)));

      if PinPdvId > 0 then
        JSON.AddPair('PinPdvId', TJSONNumber.Create(PinPdvId));

      PrepareRequest('pre-venda', rmPOST);
      FRequest.AddBody(JSON.ToJSON, TRESTContentType.ctAPPLICATION_JSON);

      try
        FRequest.Execute;
      except
        on E: Exception do
        begin
          if FResponse.StatusCode >= 400 then
          begin
            DoRegistrarLog('CadastrarPreVenda - Status: ' + FResponse.StatusCode.ToString);
            ProcessHttpError;
          end
          else
            raise;
        end;
      end;

      DoRegistrarLog('CadastrarPreVenda - Status: ' + FResponse.StatusCode.ToString);

      if not IsSuccessStatusCode(FResponse.StatusCode) then
        ProcessHttpError;

      ResponseJSON := SafeParseJSON(FResponse.Content);
      try
        if Assigned(ResponseJSON) then
          Result := GetJSONIntValue(ResponseJSON, 'id')
        else
          Result := 0;
      finally
        if Assigned(ResponseJSON) then
          ResponseJSON.Free;
      end;
    finally
      JSON.Free;
    end;
  except
    on E: Exception do
    begin
      DoRegistrarLog('Erro ao cadastrar pré-venda: ' + E.Message);
      raise;
    end;
  end;
end;

function TMultiplusCardPinPDV.CadastrarPreVendaComMonitoramento(const Identificador, Descricao: string; Valor: Currency;
                              Parcelas: Integer = 1; TipoPagamento: TTipoPagamento = tpNone;
                              PinPdvId: Integer = 0): Integer;
begin
  // Cadastra a pré-venda normalmente
  Result := CadastrarPreVenda(Identificador, Descricao, Valor, Parcelas, TipoPagamento, PinPdvId);

  // Se cadastrou com sucesso, inicia monitoramento automático
  if Result > 0 then
  begin
    DoMsg('Aguardando processamento da pré-venda: ' + Identificador);
    IniciarMonitoramentoPreVenda(Identificador);

    // Aguarda o processamento
    while ProcessandoPreVendaMonitorado do
    begin
      Application.ProcessMessages;
      Sleep(100);
    end;
  end
  else
  begin
    var r := objUi.CriarFormInterfaceDinamica(tsMensagem, 'Não foi possível criar pré-venda.', Configuracoes.FUsaFormPadrao);
  end;
end;

function TMultiplusCardPinPDV.ConsultarPreVenda(const Identificador: string): TPreVenda;
var
  ResponseJSON: TJSONObject;
begin
  try
    PrepareRequest('pre-venda/' + Identificador, rmGET);

    try
      FRequest.Execute;
    except
      on E: Exception do
      begin
        if FResponse.StatusCode >= 400 then
        begin
          DoRegistrarLog('ConsultarPreVenda - Status: ' + FResponse.StatusCode.ToString);
          ProcessHttpError;
        end
        else
          raise;
      end;
    end;

    DoRegistrarLog('ConsultarPreVenda - Status: ' + FResponse.StatusCode.ToString);

    if not IsSuccessStatusCode(FResponse.StatusCode) then
      ProcessHttpError;

    ResponseJSON := SafeParseJSON(FResponse.Content);
    try
      Result := JSONToPreVenda(ResponseJSON);
    finally
      if Assigned(ResponseJSON) then
        ResponseJSON.Free;
    end;
  except
    on E: Exception do
    begin
      DoRegistrarLog('Erro ao consultar pré-venda: ' + E.Message);
      raise;
    end;
  end;
end;

function TMultiplusCardPinPDV.ConsultarPreVendaJSON(const Identificador: string): TJSONObject;
begin
  try
    PrepareRequest('pre-venda/' + Identificador, rmGET);

    try
      FRequest.Execute;
    except
      on E: Exception do
      begin
        if FResponse.StatusCode >= 400 then
        begin
          DoRegistrarLog('ConsultarPreVendaJSON - Status: ' + FResponse.StatusCode.ToString);
          ProcessHttpError;
        end
        else
          raise;
      end;
    end;

    DoRegistrarLog('ConsultarPreVendaJSON - Status: ' + FResponse.StatusCode.ToString);

    if not IsSuccessStatusCode(FResponse.StatusCode) then
      ProcessHttpError;

    Result := SafeParseJSON(FResponse.Content);
  except
    on E: Exception do
    begin
      DoRegistrarLog('Erro ao consultar pré-venda (JSON): ' + E.Message);
      raise;
    end;
  end;
end;

function TMultiplusCardPinPDV.AbortarPreVenda(const Identificador: string; ForcaExcluir: Boolean = False): Boolean;
var
  Endpoint: string;
begin
  try
    Endpoint := 'pre-venda/' + Identificador;
    if ForcaExcluir then
      Endpoint := Endpoint + '?forca=true';

    PrepareRequest(Endpoint, rmDELETE);

    try
      FRequest.Execute;
    except
      on E: Exception do
      begin
        if FResponse.StatusCode >= 400 then
        begin
          DoRegistrarLog('AbortarPreVenda - Status: ' + FResponse.StatusCode.ToString);
          ProcessHttpError;
        end
        else
          raise;
      end;
    end;

    DoRegistrarLog('AbortarPreVenda - Status: ' + FResponse.StatusCode.ToString);

    Result := FResponse.StatusCode = 202;

    if not Result and not IsSuccessStatusCode(FResponse.StatusCode) then
      ProcessHttpError;
  except
    on E: Exception do
    begin
      DoRegistrarLog('Erro ao abortar pré-venda: ' + E.Message);
      Result := False;
    end;
  end;
end;
function TMultiplusCardPinPDV.EnviarComprovanteVenda(const VendaIdentificador, Comprovante: string): Boolean;
begin
  try
    PrepareRequest('venda/' + VendaIdentificador + '/comprovante', rmPUT);

    // Define explicitamente o Content-Type como text/plain
    FRequest.AddParameter('Content-Type', 'text/plain', pkHTTPHEADER, [poDoNotEncode]);
    FRequest.AddBody(Comprovante, TRESTContentType.ctTEXT_PLAIN);

    try
      FRequest.Execute;
    except
      on E: Exception do
      begin
        if FResponse.StatusCode >= 400 then
        begin
          DoRegistrarLog('EnviarComprovanteVenda - Status: ' + FResponse.StatusCode.ToString);
          ProcessHttpError;
        end
        else
          raise;
      end;
    end;

    DoRegistrarLog('EnviarComprovanteVenda - Status: ' + FResponse.StatusCode.ToString);
    Result := IsSuccessStatusCode(FResponse.StatusCode);

    if not Result then
      ProcessHttpError;
  except
    on E: Exception do
    begin
      DoRegistrarLog('Erro ao enviar comprovante da venda: ' + E.Message);
      Result := False;
    end;
  end;
end;
//==============================================================================
// OPERAÇÕES DE PÓS-VENDA (POS TEF)
//==============================================================================

function TMultiplusCardPinPDV.CadastrarPosVenda(PinPdvId: Integer; const Identificador, Descricao: string;
                              Valor: Currency; TipoPagamento: TTipoPagamento = tpNone;
                              Parcelas: Integer = 1): Integer;
var
  JSON, ResponseJSON: TJSONObject;
begin
  try
    JSON := TJSONObject.Create;
    try
      JSON.AddPair('PinPdvId', TJSONNumber.Create(PinPdvId));
      JSON.AddPair('Identificador', Identificador);
      JSON.AddPair('Valor', TJSONNumber.Create(Valor));
      JSON.AddPair('Descricao', Descricao);

      if TipoPagamento <> tpNone then
      begin
        JSON.AddPair('TipoPagamento', TJSONNumber.Create(Ord(TipoPagamento)));
        JSON.AddPair('Parcelas', TJSONNumber.Create(Parcelas));
      end;

      PrepareRequest('pos-venda', rmPOST);
      DoRegistrarLog('CadastrarPosVenda - JSON: ' + JSON.ToJSON);
      FRequest.AddBody(JSON.ToJSON, TRESTContentType.ctAPPLICATION_JSON);

      try
        FRequest.Execute;
      except
        on E: Exception do
        begin
          if FResponse.StatusCode >= 400 then
          begin
            DoRegistrarLog('CadastrarPosVenda - Status: ' + FResponse.StatusCode.ToString);
            ProcessHttpError;
          end
          else
            raise;
        end;
      end;

      DoRegistrarLog('CadastrarPosVenda - Status: ' + FResponse.StatusCode.ToString);

      if not IsSuccessStatusCode(FResponse.StatusCode) then
        ProcessHttpError;

      ResponseJSON := SafeParseJSON(FResponse.Content);
      try
        if Assigned(ResponseJSON) then
          Result := GetJSONIntValue(ResponseJSON, 'id')
        else
          Result := 0;
      finally
        if Assigned(ResponseJSON) then
          ResponseJSON.Free;
      end;
    finally
      JSON.Free;
    end;
  except
    on E: Exception do
    begin
      DoRegistrarLog('Erro ao cadastrar pos-venda: ' + E.Message);
      raise;
    end;
  end;
end;

function TMultiplusCardPinPDV.CadastrarPosVendaComMonitoramento(PinPdvId: Integer; const Identificador, Descricao: string;
  Valor: Currency; TipoPagamento: TTipoPagamento = tpNone; Parcelas: Integer = 1): Integer;
begin
  // Cadastra a pós-venda normalmente
  Result := CadastrarPosVenda(PinPdvId, Identificador, Descricao, Valor, TipoPagamento, Parcelas);

  // Se cadastrou com sucesso, inicia monitoramento automático
  if Result > 0 then
  begin
    DoMsg('Aguardando pagamento POS-TEF: ' + Identificador);
    IniciarMonitoramentoPagamento(Identificador);

    // Aguarda o processamento
    while ProcessandoPosTefMonitorado do
    begin
      Application.ProcessMessages;
      Sleep(100);
    end;
  end
  else
  begin
    var r := objUi.CriarFormInterfaceDinamica(tsMensagem, 'Não foi possível criar pagamento.', Configuracoes.FUsaFormPadrao);
  end;
end;

function TMultiplusCardPinPDV.ConsultarPosVenda(const Identificador: string): TPosVenda;
var
  ResponseJSON: TJSONObject;
begin
  try
    PrepareRequest('pos-venda/' + Identificador, rmGET);

    try
      FRequest.Execute;
    except
      on E: Exception do
      begin
        if FResponse.StatusCode >= 400 then
        begin
          DoRegistrarLog('ConsultarPosVenda - Status: ' + FResponse.StatusCode.ToString);
          ProcessHttpError;
        end
        else
          raise;
      end;
    end;

    DoRegistrarLog('ConsultarPosVenda - Status: ' + FResponse.StatusCode.ToString);

    if not IsSuccessStatusCode(FResponse.StatusCode) then
      ProcessHttpError;

    ResponseJSON := SafeParseJSON(FResponse.Content);
    try
      Result := JSONToPosVenda(ResponseJSON);
    finally
      if Assigned(ResponseJSON) then
        ResponseJSON.Free;
    end;
  except
    on E: Exception do
    begin
      DoRegistrarLog('Erro ao consultar pos-venda: ' + E.Message);
      raise;
    end;
  end;
end;

function TMultiplusCardPinPDV.ConsultarPosVendaJSON(const Identificador: string): TJSONObject;
begin
  try
    PrepareRequest('pos-venda/' + Identificador, rmGET);

    try
      FRequest.Execute;
    except
      on E: Exception do
      begin
        if FResponse.StatusCode >= 400 then
        begin
          DoRegistrarLog('ConsultarPosVendaJSON - Status: ' + FResponse.StatusCode.ToString);
          ProcessHttpError;
        end
        else
          raise;
      end;
    end;

    DoRegistrarLog('ConsultarPosVendaJSON - Status: ' + FResponse.StatusCode.ToString);

    if not IsSuccessStatusCode(FResponse.StatusCode) then
      ProcessHttpError;

    Result := SafeParseJSON(FResponse.Content);
  except
    on E: Exception do
    begin
      DoRegistrarLog('Erro ao consultar pos-venda (JSON): ' + E.Message);
      raise;
    end;
  end;
end;

function TMultiplusCardPinPDV.AbortarPosVenda(const Identificador: string; ForcaExcluir: Boolean = False): Boolean;
var
  Endpoint: string;
begin
  try
    Endpoint := 'pos-venda/' + Identificador;
    if ForcaExcluir then
      Endpoint := Endpoint + '?forca=true';

    PrepareRequest(Endpoint, rmDELETE);

    try
      FRequest.Execute;
    except
      on E: Exception do
      begin
        if FResponse.StatusCode >= 400 then
        begin
          DoRegistrarLog('AbortarPosVenda - Status: ' + FResponse.StatusCode.ToString);
        end
        else
          raise;
      end;
    end;

    DoRegistrarLog('AbortarPosVenda - Status: ' + FResponse.StatusCode.ToString);

    Result := IsSuccessStatusCode(FResponse.StatusCode);

    if not Result and not IsSuccessStatusCode(FResponse.StatusCode) then
      ProcessHttpError;
  except
    on E: Exception do
    begin
      DoRegistrarLog('Erro ao abortar pos-venda: ' + E.Message);
      Result := False;
    end;
  end;
end;

//==============================================================================
// MÉTODOS DE CONTROLE DE MONITORAMENTO
//==============================================================================

procedure TMultiplusCardPinPDV.CancelarFluxoPosTefMonitorado;
begin
  FInrrompePosTefMonitorado := True;
end;

procedure TMultiplusCardPinPDV.CancelarFluxoPreVendaMonitorado;
begin
  FInrrompePreVendaMonitorado := True;
end;

procedure TMultiplusCardPinPDV.EnviaDocumentoImpressao(const Documento:string);
begin
  FImpressaoDocumento := Documento;
end;

function TMultiplusCardPinPDV.AbortarRetry(const Identificador: string): Boolean;
var
  sucesso: Boolean;
begin
  sucesso := False;
  try
    if AbortarPosVenda(Identificador) then
    begin
      sucesso := True;
      DoRegistrarLog('Transação abortada: ' + Identificador);
    end;

    while not sucesso do
    begin
      DoRegistrarLog('Falha ao abortar transação: ' + Identificador);
      var r := objUi.CriarFormInterfaceDinamica(tsSimNao, 'Solicitação não foi removida. Deseja forçar a remoção?', Configuracoes.FUsaFormPadrao);
      if r.Confirmou then
      begin
        if (AbortarPosVenda(Identificador, True)) then
        begin
          DoRegistrarLog('Sucesso ao abortar transação forçada: ' + Identificador);
          sucesso := True;
        end
        else
          sucesso := False;
      end
      else
      begin
        Result := False;
        Exit;
      end;
    end;

    Result := sucesso;
  except
    on E: Exception do
    begin
      //DoFalhaOperacao('Erro ao abortar transação retry: ' + E.Message);
      Result := False;
    end;
  end;
end;

function TMultiplusCardPinPDV.AbortarPreVendaRetry(const Identificador: string): Boolean;
var
  sucesso: Boolean;
begin
  sucesso := False;
  try
    if AbortarPreVenda(Identificador) then
    begin
      sucesso := True;
      DoRegistrarLog('Pré-venda abortada: ' + Identificador);
    end;

    while not sucesso do
    begin
      DoRegistrarLog('Falha ao abortar pré-venda: ' + Identificador);
      var r := objUi.CriarFormInterfaceDinamica(tsSimNao, 'Solicitação não foi removida. Deseja forçar a remoção?', Configuracoes.FUsaFormPadrao);
      if r.Confirmou then
        if (AbortarPreVenda(Identificador, True)) then
        begin
          DoRegistrarLog('Sucesso ao abortar pré-venda forçada: ' + Identificador);
          sucesso := True;
        end
        else
          sucesso := False;
    end;

    Result := sucesso;
  except
    on E: Exception do
    begin
      //DoFalhaOperacao('Erro ao abortar pré-venda retry: ' + E.Message);
      Result := False;
    end;
  end;
end;

procedure TMultiplusCardPinPDV.IniciarMonitoramentoPagamento(const Identificador: string);
begin
  ProcessandoPosTefMonitorado := True;
  TTask.Run(
    procedure
    var
      PosVenda: TPosVenda;
      TransacaoConcluida: Boolean;
      ContinuarVerificando: Boolean;
      TentativaVerificacao: Integer;
      Comprovante: string;
    begin
      Self.FInrrompePosTefMonitorado := False;
      TransacaoConcluida := False;
      ContinuarVerificando := True;
      TentativaVerificacao := 0;

      // Loop de monitoramento
      while (ContinuarVerificando and not TransacaoConcluida) do
      begin
        // Verifica se deve interromper
        if Self.FInrrompePosTefMonitorado then
        begin
          ContinuarVerificando := False;
          Break;
        end;

        Sleep(Configuracoes.FIntervaloVerificacaoAutomatica);
        Inc(TentativaVerificacao);

        try
          // Consulta status atual da transação
          PosVenda := ConsultarPosVenda(Identificador);

          if not Assigned(PosVenda) then
          begin
            TThread.Synchronize(nil,
              procedure
              begin
                DoMsg('Erro na verificação #' + IntToStr(TentativaVerificacao) + ': Falha ao consultar status');
                var r := objUi.CriarFormInterfaceDinamica(tsSimNao, 'Deseja cancelar a requisição?', Configuracoes.FUsaFormPadrao);
                ContinuarVerificando := not r.RespondeuSolicitacao;
              end);
            Continue;
          end;

          try
            // Verifica se foi finalizada (aprovada ou negada)
            if ((PosVenda.Status = psConcluido) and (PosVenda.Vendas[0].Transacoes[0].Status = tsAprovada)) then
            begin
              TransacaoConcluida := True;
              Comprovante := '';
              if (PosVenda.Vendas.Count > 0) and (PosVenda.Vendas[0].Comprovante <> '') then
                Comprovante := PosVenda.Vendas[0].Comprovante;

              RetornoPgto := FRetornoPgto.Create;
              RetornoPgto := PinPdvPosTefParaRetorno(PosVenda);

              TThread.Synchronize(nil,
                procedure
                begin
                  DoGerarComprovante(RetornoPgto);
                end);
            end
            else if ((PosVenda.Status = psConcluido) and (PosVenda.Vendas[0].Transacoes[0].Status <> tsAprovada)) then
            begin
              TransacaoConcluida := True;
              Comprovante := '';
              if (PosVenda.Vendas.Count > 0) and (PosVenda.Vendas[0].Comprovante <> '') then
                Comprovante := PosVenda.Vendas[0].Comprovante;

              RetornoPgto := FRetornoPgto.Create;
              RetornoPgto := PinPdvPosTefParaRetorno(PosVenda);

              TThread.Synchronize(nil,
                procedure
                begin
                  DoGerarComprovante(RetornoPgto);
                end);
            end
            else
            begin
              // Transação ainda não foi concluída
              TThread.Synchronize(nil,
                procedure
                begin
                  if not Self.FInrrompePosTefMonitorado then
                  begin
                    var r := objUi.CriarFormInterfaceDinamica(tsSimNao, 'Pagamento não identificado. Deseja continuar?', Configuracoes.FUsaFormPadrao);
                    ContinuarVerificando := r.Confirmou;
                  end
                  else
                    ContinuarVerificando := False;

                  if not ContinuarVerificando then
                    if not AbortarRetry(Identificador) then
                    begin
                      DoMsg('Não foi possível remover a solicitação POS TEF ' + Identificador);
                      ContinuarVerificando := True;
                    end;
                end);
            end;

          finally
            PosVenda.Free;
          end;

        except
          on E: Exception do
          begin
            TThread.Synchronize(nil,
              procedure
              begin
                DoMsg('Erro na verificação #' + IntToStr(TentativaVerificacao) + ': ' + E.Message);
                var r := objUi.CriarFormInterfaceDinamica(tsSimNao, 'Deseja cancelar a requisição?', Configuracoes.FUsaFormPadrao);
                ContinuarVerificando := not r.RespondeuSolicitacao;
              end);
          end;
        end;
      end;

      // Log final do resultado do monitoramento
      TThread.Synchronize(nil,
        procedure
        begin
          if TransacaoConcluida and (RetornoPgto.Sucesso) then
          begin
            DoMsg('Pagamento confirmado: ' + Identificador + '... AUTH' + RetornoPgto.COD_AUTORIZACAO);
            DoRegistrarLog('Monitoramento finalizado - Pagamento confirmado: ' + Identificador + '... AUTH' + RetornoPgto.COD_AUTORIZACAO)
          end
          else
          begin
            DoMsg('Sem pagamento identificado: ' + Identificador);
            DoRegistrarLog('Monitoramento finalizado - Sem pagamento identificado: ' + Identificador);
          end;

          Self.ProcessandoPosTefMonitorado := False;
        end);
    end);
end;

procedure TMultiplusCardPinPDV.IniciarMonitoramentoPreVenda(const Identificador: string);
var
  Comprovante: string;
begin
  ProcessandoPreVendaMonitorado := True;
  TTask.Run(
    procedure
    var
      PreVenda: TPreVenda;
      TransacaoConcluida: Boolean;
      ContinuarVerificando: Boolean;
      TentativaVerificacao: Integer;
      VendaIdentificador: string;
    begin
      Self.FInrrompePreVendaMonitorado := False;
      TransacaoConcluida := False;
      ContinuarVerificando := True;
      TentativaVerificacao := 0;

      // Loop de monitoramento
      while (ContinuarVerificando and not TransacaoConcluida) do
      begin
        // Verifica se deve interromper
        if Self.FInrrompePreVendaMonitorado then
        begin
          ContinuarVerificando := False;
          Break;
        end;

        Sleep(Configuracoes.FIntervaloVerificacaoAutomatica);
        Inc(TentativaVerificacao);

        try
          // Consulta status atual da pré-venda
          PreVenda := ConsultarPreVenda(Identificador);

          if not Assigned(PreVenda) then
          begin
            TThread.Synchronize(nil,
              procedure
              begin
                DoMsg('Erro na verificação #' + IntToStr(TentativaVerificacao) + ': Falha ao consultar status');
                var r := objUi.CriarFormInterfaceDinamica(tsSimNao, 'Deseja cancelar a requisição?', Configuracoes.FUsaFormPadrao);
                ContinuarVerificando := not r.RespondeuSolicitacao;
              end);
            Continue;
          end;

          try
            // Verifica se há vendas aprovadas
            if (PreVenda.Status = psConcluido) and (PreVenda.Vendas.Count > 0) and
               (PreVenda.Vendas[0].Status = vsRealizada) and (PreVenda.Vendas[0].Transacoes.Count > 0) and
               (PreVenda.Vendas[0].Transacoes[0].Status = tsAprovada) then
            begin
              TransacaoConcluida := True;
              VendaIdentificador := PreVenda.Vendas[0].Identificador;

              RetornoPgto := FRetornoPgto.Create;
              RetornoPgto := PinPdvPreVendaParaRetorno(PreVenda);

              TThread.Synchronize(nil,
                procedure
                begin
                  DoSolicitaImpressao(PreVenda);
                  DoMsg('Solicitando conteúdo de impressão.');
                  RetornoPgto.COMPROVANTE := '';
                  while Self.FImpressaoDocumento = '' do
                  begin
                     Sleep(2000);
                  end;
                  DoMsg('Recebido conteúdo de impressão.');
                  if EnviarComprovanteVenda(VendaIdentificador, FImpressaoDocumento) then
                    DoRegistrarLog('Comprovante enviado com sucesso para venda: ' + VendaIdentificador)
                  else
                    DoMsg('Erro ao enviar comprovante para venda: ' + VendaIdentificador);
                  PreVenda := ConsultarPreVenda(Identificador);  // Atualizar com o comprovante registrado na API
                  RetornoPgto.COMPROVANTE := PreVenda.Vendas[0].Comprovante;
                  DoGerarComprovante(RetornoPgto);
                end);
            end
            else if (PreVenda.Status = psConcluido) and (PreVenda.Vendas.Count > 0) and
                    (PreVenda.Vendas[0].Status = vsRealizada) and (PreVenda.Vendas[0].Transacoes.Count > 0) and
                    (PreVenda.Vendas[0].Transacoes[0].Status <> tsAprovada) then
            begin
              TransacaoConcluida := True;
              RetornoPgto.COMPROVANTE := '';

              RetornoPgto := FRetornoPgto.Create;
              RetornoPgto := PinPdvPreVendaParaRetorno(PreVenda);

              TThread.Synchronize(nil,
                procedure
                begin
                  PreVenda := ConsultarPreVenda(Identificador);  // Atualizar com o comprovante registrado na API
                  RetornoPgto.COMPROVANTE := PreVenda.Vendas[0].Comprovante;
                  DoGerarComprovante(RetornoPgto);
                end);
            end
            else
            begin
              // Pré-venda ainda não foi concluída
              TThread.Synchronize(nil,
                procedure
                begin
                  if not Self.FInrrompePreVendaMonitorado then
                  begin
                    var r := objUi.CriarFormInterfaceDinamica(tsSimNao, 'Pré-venda não processada. Deseja continuar?', Configuracoes.FUsaFormPadrao);
                    ContinuarVerificando := r.Confirmou;
                  end
                  else
                    ContinuarVerificando := False;

                  if not ContinuarVerificando then
                    if not AbortarPreVendaRetry(Identificador) then
                    begin
                      DoMsg('Não foi possível remover a pré-venda ' + Identificador);
                    end;
                end);
            end;

          finally
            PreVenda.Free;
          end;

        except
          on E: Exception do
          begin
            TThread.Synchronize(nil,
              procedure
              begin
                DoMsg('Erro na verificação #' + IntToStr(TentativaVerificacao) + ': ' + E.Message);
                var r := objUi.CriarFormInterfaceDinamica(tsSimNao, 'Deseja cancelar a requisição?', Configuracoes.FUsaFormPadrao);
                ContinuarVerificando := not r.RespondeuSolicitacao;
              end);
          end;
        end;
      end;

      // Log final do resultado do monitoramento
      TThread.Synchronize(nil,
        procedure
        begin
          if TransacaoConcluida and (RetornoPgto.Sucesso) then
            DoMsg('Pagamento confirmado: ' + Identificador + '... AUTH' + RetornoPgto.COD_AUTORIZACAO)
          else
            DoMsg('Sem pagamento identificado: ' + Identificador);

          Self.ProcessandoPreVendaMonitorado := False;
        end);
    end);
end;

//==============================================================================
// CONVERSORES JSON PARA OBJETOS
//==============================================================================

function TMultiplusCardPinPDV.JSONToPinPDV(AJSON: TJSONObject): TPinPDV;
begin
  Result := TPinPDV.Create;

  if not Assigned(AJSON) then
    Exit;

  Result.Id := GetJSONIntValue(AJSON, 'id');
  Result.Codigo := GetJSONStringValue(AJSON, 'codigo');
  Result.Nome := GetJSONStringValue(AJSON, 'nome');
  Result.IsAtivo := GetJSONBoolValue(AJSON, 'isAtivo');
  Result.Heartbeat := GetJSONStringValue(AJSON, 'heartbeat');
end;

function TMultiplusCardPinPDV.JSONToListaPinPDV(AJSON: TJSONObject): TListaPinPDV;
var
  DataArray: TJSONArray;
  I: Integer;
  PinPDVJSON: TJSONObject;
begin
  Result := TListaPinPDV.Create;
  if not Assigned(AJSON) then
    Exit;
  DataArray := AJSON.GetValue('data') as TJSONArray;
  if Assigned(DataArray) then
  begin
    for I := DataArray.Count - 1 downto 0 do  // <- ÚNICA MUDANÇA: downto ao invés de to
    begin
      PinPDVJSON := DataArray.Items[I] as TJSONObject;
      if Assigned(PinPDVJSON) then
        Result.Data.Add(JSONToPinPDV(PinPDVJSON));
    end;
  end;
end;

function TMultiplusCardPinPDV.JSONToTransacao(AJSON: TJSONObject): TTransacao;
var
  DadosJSON, StatusJSON: TJSONObject;
  StatusValue: Integer;
  TipoPagamentoValue: Integer;
  DadosValue: TJSONValue;
begin
  Result := TTransacao.Create;

  if not Assigned(AJSON) then
    Exit;

  Result.Id := GetJSONIntValue(AJSON, 'id');
  Result.Valor := GetJSONFloatValue(AJSON, 'valor');
  Result.Parcelas := GetJSONIntValue(AJSON, 'parcelas');

  StatusJSON := AJSON.GetValue('status') as TJSONObject;
  if Assigned(StatusJSON) then
  begin
    StatusValue := GetJSONIntValue(StatusJSON, 'key');
    Result.Status := TTransacaoStatus(StatusValue);
  end;

  TipoPagamentoValue := GetJSONIntValue(AJSON, 'tipoPagamento');
  Result.TipoPagamento := TTipoPagamento(TipoPagamentoValue);

  DadosValue := AJSON.GetValue('dados');
  if Assigned(DadosValue) and (DadosValue is TJSONObject) then
  begin
    DadosJSON := DadosValue as TJSONObject;
    Result.Dados.DataHora := GetJSONStringValue(DadosJSON, 'dataHora');
    Result.Dados.NSU := GetJSONStringValue(DadosJSON, 'nsu');
    Result.Dados.Autorizacao := GetJSONStringValue(DadosJSON, 'autorizacao');
    Result.Dados.Bandeira := GetJSONStringValue(DadosJSON, 'bandeira');
    Result.Dados.Adquirente := GetJSONStringValue(DadosJSON, 'adquirente');
  end;
end;

function TMultiplusCardPinPDV.JSONToVenda(AJSON: TJSONObject): TVenda;
var
  TransacoesArray: TJSONArray;
  StatusJSON: TJSONObject;
  I: Integer;
  StatusValue: Integer;
begin
  Result := TVenda.Create;

  if not Assigned(AJSON) then
    Exit;

  Result.Id := GetJSONIntValue(AJSON, 'id');
  Result.Identificador := GetJSONStringValue(AJSON, 'identificador');
  Result.Valor := GetJSONFloatValue(AJSON, 'valor');
  Result.Comprovante := GetJSONStringValue(AJSON, 'comprovante');

  StatusJSON := AJSON.GetValue('status') as TJSONObject;
  if Assigned(StatusJSON) then
  begin
    StatusValue := GetJSONIntValue(StatusJSON, 'key');
    Result.Status := TVendaStatus(StatusValue);
  end;

  TransacoesArray := AJSON.GetValue('transacoes') as TJSONArray;
  if Assigned(TransacoesArray) then
  begin
    for I := 0 to TransacoesArray.Count - 1 do
    begin
      if Assigned(TransacoesArray.Items[I]) then
        Result.Transacoes.Add(JSONToTransacao(TransacoesArray.Items[I] as TJSONObject));
    end;
  end;
end;

function TMultiplusCardPinPDV.JSONToPreVenda(AJSON: TJSONObject): TPreVenda;
var
  VendasArray: TJSONArray;
  StatusJSON: TJSONObject;
  I: Integer;
  StatusValue, TipoPagamentoValue: Integer;
begin
  Result := TPreVenda.Create;

  if not Assigned(AJSON) then
    Exit;

  Result.Id := GetJSONIntValue(AJSON, 'id');
  Result.Identificador := GetJSONStringValue(AJSON, 'identificador');
  Result.Descricao := GetJSONStringValue(AJSON, 'descricao');
  Result.Valor := GetJSONFloatValue(AJSON, 'valor');
  Result.Parcelas := GetJSONIntValue(AJSON, 'parcelas');

  TipoPagamentoValue := GetJSONIntValue(AJSON, 'tipoPagamento');
  Result.TipoPagamento := TTipoPagamento(TipoPagamentoValue);

  StatusJSON := AJSON.GetValue('status') as TJSONObject;
  if Assigned(StatusJSON) then
  begin
    StatusValue := GetJSONIntValue(StatusJSON, 'key');
    Result.Status := TPagamentoStatus(StatusValue);
  end;

  VendasArray := AJSON.GetValue('vendas') as TJSONArray;
  if Assigned(VendasArray) then
  begin
    for I := 0 to VendasArray.Count - 1 do
    begin
      if Assigned(VendasArray.Items[I]) then
        Result.Vendas.Add(JSONToVenda(VendasArray.Items[I] as TJSONObject));
    end;
  end;
end;

function TMultiplusCardPinPDV.JSONToPosVenda(AJSON: TJSONObject): TPosVenda;
var
  VendasArray: TJSONArray;
  StatusJSON: TJSONObject;
  I: Integer;
  StatusValue, TipoPagamentoValue: Integer;
begin
  Result := TPosVenda.Create;

  if not Assigned(AJSON) then
    Exit;

  Result.Id := GetJSONIntValue(AJSON, 'id');
  Result.Identificador := GetJSONStringValue(AJSON, 'identificador');
  Result.Descricao := GetJSONStringValue(AJSON, 'descricao');
  Result.Valor := GetJSONFloatValue(AJSON, 'valor');
  Result.Parcelas := GetJSONIntValue(AJSON, 'parcelas');

  TipoPagamentoValue := GetJSONIntValue(AJSON, 'tipoPagamento');
  Result.TipoPagamento := TTipoPagamento(TipoPagamentoValue);

  StatusJSON := AJSON.GetValue('status') as TJSONObject;
  if Assigned(StatusJSON) then
  begin
    StatusValue := GetJSONIntValue(StatusJSON, 'key');
    Result.Status := TPagamentoStatus(StatusValue);
  end;

  VendasArray := AJSON.GetValue('vendas') as TJSONArray;
  if Assigned(VendasArray) then
  begin
    for I := 0 to VendasArray.Count - 1 do
    begin
      if Assigned(VendasArray.Items[I]) then
        Result.Vendas.Add(JSONToVenda(VendasArray.Items[I] as TJSONObject));
    end;
  end;
end;

function TMultiplusCardPinPDV.PinPdvPosTefParaRetorno(PosVenda: TPosVenda): TMultiplusCardRetorno;
var
  retorno: TMultiplusCardRetorno;
begin
  retorno := TMultiplusCardRetorno.Create;

  if (PosVenda.Vendas.Count > 0) and (PosVenda.Vendas[0].Transacoes.Count > 0) then
  begin
    retorno.VALOR := CurrToStr(PosVenda.Vendas[0].Transacoes[0].Valor);
    retorno.COD_AUTORIZACAO := PosVenda.Vendas[0].Transacoes[0].Dados.Autorizacao;
    retorno.NSU := PosVenda.Vendas[0].Transacoes[0].Dados.NSU;
    retorno.E2E := PosVenda.Vendas[0].Transacoes[0].Dados.Autorizacao;
    retorno.QTDE_PARCELAS := IntToStr(PosVenda.Vendas[0].Transacoes[0].Parcelas);
    retorno.NSU_REDE := PosVenda.Vendas[0].Transacoes[0].Dados.NSU;
    retorno.NOME_BANDEIRA := PosVenda.Vendas[0].Transacoes[0].Dados.Bandeira;
    retorno.NOME_REDE := PosVenda.Vendas[0].Transacoes[0].Dados.Adquirente;
    retorno.Sucesso := PosVenda.Vendas[0].Transacoes[0].Status = tsAprovada;
  end
  else
  begin
    retorno.Sucesso := False;
  end;

  retorno.MensagemSucesso := '';
  retorno.MensagemErro := '';
  retorno.ConteudoOriginalSucesso := '';

  Result := retorno;
end;

function TMultiplusCardPinPDV.PinPdvPreVendaParaRetorno(PreVenda: TPreVenda): TMultiplusCardRetorno;
var
  retorno: TMultiplusCardRetorno;
begin
  retorno := TMultiplusCardRetorno.Create;

  if (PreVenda.Vendas.Count > 0) and (PreVenda.Vendas[0].Transacoes.Count > 0) then
  begin
    retorno.VALOR := CurrToStr(PreVenda.Vendas[0].Transacoes[0].Valor);
    retorno.COD_AUTORIZACAO := PreVenda.Vendas[0].Transacoes[0].Dados.Autorizacao;
    retorno.NSU := PreVenda.Vendas[0].Transacoes[0].Dados.NSU;
    retorno.E2E := PreVenda.Vendas[0].Transacoes[0].Dados.Autorizacao;
    retorno.QTDE_PARCELAS := IntToStr(PreVenda.Vendas[0].Transacoes[0].Parcelas);
    retorno.NSU_REDE := PreVenda.Vendas[0].Transacoes[0].Dados.NSU;
    retorno.NOME_BANDEIRA := PreVenda.Vendas[0].Transacoes[0].Dados.Bandeira;
    retorno.NOME_REDE := PreVenda.Vendas[0].Transacoes[0].Dados.Adquirente;
    retorno.Sucesso := PreVenda.Vendas[0].Transacoes[0].Status = tsAprovada;
  end
  else
  begin
    retorno.Sucesso := False;
  end;

  retorno.MensagemSucesso := '';
  retorno.MensagemErro := '';
  retorno.ConteudoOriginalSucesso := '';

  Result := retorno;
end;

//==============================================================================
// DISPARADORES DE EVENTOS
//==============================================================================

procedure TMultiplusCardPinPDV.DoRegistrarLog(const Conteudo: string);
begin
  if Assigned(FOnRegistrarLog) then
    FOnRegistrarLog(Self, Conteudo);
end;

procedure TMultiplusCardPinPDV.DoSolicitaImpressao(const PreVenda: TPreVenda);
begin
  if Assigned(FOnSolicitarImpressao) then
    FOnSolicitarImpressao(Self, PreVenda);
end;

procedure TMultiplusCardPinPDV.DoMsg(const Conteudo: string);
var
  NovoConteudo: string;
begin
  NovoConteudo := Conteudo;
  if Assigned(FOnMsg) then
    FOnMsg(Self, NovoConteudo);
end;

procedure TMultiplusCardPinPDV.DoFalhaOperacao(const Erro: string);
begin
  if Assigned(FOnFalhaOperacao) then
    FOnFalhaOperacao(Self, Erro);
end;

procedure TMultiplusCardPinPDV.DoGerarComprovante(const Retorno: TMultiplusCardRetorno);
begin
  Retorno.COMPROVANTE_REDUZIDO := RetornoPgto.COMPROVANTE;
  Retorno.COMPROVANTE_CLIENTE := RetornoPgto.COMPROVANTE;
  Retorno.COMPROVANTE_ESTABELECIMENTO := RetornoPgto.COMPROVANTE;
  if Assigned(FOnGerarComprovante) then
    FOnGerarComprovante(Self, Retorno);
end;

//==============================================================================
// TRATADORES DE INTERFACE DE USUÁRIO
//==============================================================================

procedure TMultiplusCardPinPDV.TratarSolicitacaoInteracao(Sender: TObject;
  const Solicitacao: TSolicitacaoUsuario; var Resposta: TRespostaUsuario);
begin
  if Assigned(FOnSolicitarInteracaoUi) then
    FOnSolicitarInteracaoUi(Self, Solicitacao, Resposta);
end;

procedure TMultiplusCardPinPDV.TratarMsg(Sender: TObject; const Conteudo: string);
begin
  if Assigned(FOnMsg) then
    FOnMsg(Self, Conteudo);
end;

end.
