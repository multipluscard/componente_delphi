unit MultiplusCardTefGP;

interface

uses
  System.Classes, System.SysUtils, MultiplusCardCommons;

//==============================================================================
// TIPOS E ENUMERAÇÕES
//==============================================================================

type
  /// <summary>
  /// Define as operações TEF disponíveis no sistema
  /// </summary>
  TOperacao = (
    opCredito = 1,
    opCreditoAVista = 2,
    opCreditoParceladoLoja = 3,
    opCreditoParceladoAdm = 4,
    opDebito = 5,
    opDebitoAVista = 6,
    opVendaGenerica = 7,
    opMenuPrivate = 8,
    opFrotaCompleto = 9,
    opLinkPagamento = 10,
    opListarLinkPagamento = 11,
    opManutencaoLinkPagamento = 12,
    opCancelar = 13,
    opReimpressao = 14,
    opReimpressaoDireto = 15,
    opPix = 16,
    opRecargaCelular = 17,
    opParceleMais = 18,
    opRelatorio = 19,
    opAtv = 20,
    opAdm = 21
  );

  /// <summary>
  /// Eventos para tratamento de interações do sistema TEF
  /// </summary>
  TMultiplusLogEvent         = procedure(Sender: TObject; const Conteudo: string) of object;
  TMultiplusMensagemEvent    = procedure(Sender: TObject; const Conteudo: string) of object;
  TMultiplusComprovanteEvent = procedure(Sender: TObject; const Retorno: TMultiplusCardRetorno) of object;
  TMultiplusErroEvent        = procedure(Sender: TObject; const Conteudo: string) of object;

//==============================================================================
// RECORD PARA PARÂMETROS OPCIONAIS
//==============================================================================

type
  TParametrosTEF = record
    sCNPJCliente: string;
    sCNPJParceiro: string;
    dValor: Double;
    iCupom: Integer;
    iLeitor: Integer;
    sControle: string;
    sNSU: string;
    Data: string;
    iParcelas: Integer;
    sKM: string;
    sPlaca: string;
    sMatricula: string;
    QtdeItens: Integer;
    sItens: string;
    sTelefone: string;
    sTexto: string;
  end;

//==============================================================================
// COMPONENTE PRINCIPAL
//==============================================================================

type
  // === CONFIGURAÇÃO ===
  TMultiplusCardConfigGP = class(TPersistent)
  private
    FCnpjCliente  : string;
    FCnpjParceiro : string;
    FNomeDLL      : string;
    FILeitor      : integer;

  published
    property CnpjCliente  : string  read FCnpjCliente  write FCnpjCliente;
    property CnpjParceiro : string  read FCnpjParceiro write FCnpjParceiro;
    property NomeDLL      : string  read FNomeDLL      write FNomeDLL;
    property ILeitor      : integer read FILeitor      write FILeitor;
  end;

  /// <summary>
  /// Componente principal para integração com TEF via DLL com Gerenciador de Pagamentos
  /// </summary>
  TMultiplusCardTefGP = class(TComponent)
  private

    // === EVENTOS ===
    FOnRegistrarLog       : TMultiplusLogEvent;
    FOnMsg                : TMultiplusMensagemEvent;
    FOnGerarComprovante   : TMultiplusComprovanteEvent;
    FOnFalhaOperacao      : TMultiplusErroEvent;

    // === OBJETOS AUXILIARES ===
    FRetornoPgto: TMultiplusCardRetorno;
    FMultiplusCardConfigGP: TMultiplusCardConfigGP;
    procedure SetMultiplusCardConfigGP(const Value: TMultiplusCardConfigGP);

    // === Método privado para verificar DLL ===
    function VerificarDLL: Boolean;

    // === MÉTODOS PRIVADOS - DISPARADORES DE EVENTOS ===
    procedure DoRegistrarLog(Conteudo: string);
    procedure DoMsg(const Conteudo: string);
    procedure DoGerarComprovante(const Retorno: TMultiplusCardRetorno);
    procedure DoFalhaOperacao(const Conteudo: string);

    // === PROCESSAR OPERACOES ===
    function ProcessarOperacoes(Operacao: TOperacao; const Params: TParametrosTEF): boolean;

  public
    // === MÉTODOS OPERAÇÃO TEF ===
    function VendeCreditoGP(dValor : double; iCupom : integer): boolean;
    function VendeCreditoVistaGP(dValor : double; iCupom : integer): boolean;
    function VendeCreditoParcLojaGP(dValor : double; iCupom, iParcelas : integer): boolean;
    function VendeCreditoParcAdmGP(dValor : double; iCupom, iParcelas : integer): boolean;
    function VendeDebitoGP(dValor : double; iCupom : integer): boolean;
    function VendeDebitoAVistaGP(dValor : double; iCupom : integer): boolean;
    function VendaGenericaGP(dValor : double; iCupom : integer): boolean;
    function MenuPrivateGP(dValor : double; iCupom : integer): boolean;
    function VendeFrotaCompletoGP(dValor : double; iCupom, qtdeItens : integer; sKm, sPlaca,
      sMatricula, sItens : string): boolean;
    function LinkPagamentoGP(dValor : double; iCupom, iParcelas,
      qtdeItens : integer; sItens, sTelefone, sTexto : string): boolean;
    function ListarLinkPagamentoPagoGP(dValor : double; iCupom : integer): boolean;
    function ManutencaoLinkPagamentoGP: boolean;
    function CancelarGP(dValor : double; iCupom : integer; sControle : string): boolean;
    function ReimpressaoGP: boolean;
    function ReimpressaoDiretoGP(sNSU, Data : string; iCupom : integer): boolean;
    function VendeCarteiraDigitalPixGP(dValor : double; iCupom : integer): boolean;
    function RecargaCelularGP(iCupom : integer): boolean;
    function ParceleMaisGP(dValor : double; iCupom : integer): boolean;
    function RelatorioGP(iCupom : integer): boolean;
    function AtvGP(iCupom : integer): boolean;
    function AdmGP(dValor : double; iCupom : integer): boolean;

    // === CONSTRUTOR E DESTRUTOR ===
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    // === Dados de Retorno ===
    property RetornoPgto    : TMultiplusCardRetorno     read FRetornoPgto         write FRetornoPgto;

  published

    // === EVENTOS PRINCIPAIS ===
    property Configuracoes         : TMultiplusCardConfigGP       read FMultiplusCardConfigGP    write SetMultiplusCardConfigGP;
    property OnRegistrarLog        : TMultiplusLogEvent         read FOnRegistrarLog         write FOnRegistrarLog;
    property OnMsg                 : TMultiplusMensagemEvent    read FOnMsg                  write FOnMsg;
    property OnGerarComprovante    : TMultiplusComprovanteEvent read FOnGerarComprovante     write FOnGerarComprovante;
    property OnFalhaOperacao       : TMultiplusErroEvent        read FOnFalhaOperacao        write FOnFalhaOperacao;

  end;

//==============================================================================
// REGISTRO DO COMPONENTE
//==============================================================================

procedure Register;

implementation

//==============================================================================
// REGISTRO DO COMPONENTE
//==============================================================================

procedure Register;
begin
  RegisterComponents('Multiplus Card', [TMultiplusCardTefGP]);
end;

//==============================================================================
// DECLARAÇÕES DLL EXTERNA
//==============================================================================
function VendeCredito (
         sCNPJCliente :  PAnsiChar;
         sCNPJParceiro : PAnsiChar;
         dValor : double;
         iCupom : integer;
         iLeitor : integer
       ): PAnsiChar; stdcall;
          external 'TefClientmc.dll' delayed;

function VendeCreditoVista (
         sCNPJCliente :  PAnsiChar;
         sCNPJParceiro : PAnsiChar;
         dValor : double;
         iCupom : integer;
         iLeitor : integer
       ): PAnsiChar; stdcall;
          external 'TefClientmc.dll' delayed;

function VendeCreditoParcLoja (
         sCNPJCliente :  PAnsiChar;
         sCNPJParceiro : PAnsiChar;
         iParcelas : integer;
         dValor : double;
         iCupom : integer;
         iLeitor : integer
       ): PAnsiChar; stdcall;
          external 'TefClientmc.dll' delayed;

function VendeCreditoParcAdm (
         sCNPJCliente :  PAnsiChar;
         sCNPJParceiro : PAnsiChar;
         iParcelas : integer;
         dValor : double;
         iCupom : integer;
         iLeitor : integer
       ): PAnsiChar; stdcall;
          external 'TefClientmc.dll' delayed;

function VendeDebito (
         sCNPJCliente :  PAnsiChar;
         sCNPJParceiro : PAnsiChar;
         dValor : double;
         iCupom : integer;
         iLeitor : integer
       ): PAnsiChar; stdcall;
          external 'TefClientmc.dll' delayed;

function VendeDebitoAVista (
         sCNPJCliente :  PAnsiChar;
         sCNPJParceiro : PAnsiChar;
         dValor : double;
         iCupom : integer;
         iLeitor : integer
       ): PAnsiChar; stdcall;
          external 'TefClientmc.dll' delayed;

function VendaGenerica (
         sCNPJCliente :  PAnsiChar;
         sCNPJParceiro : PAnsiChar;
         dValor : double;
         iCupom : integer;
         iLeitor : integer
       ): PAnsiChar; stdcall;
          external 'TefClientmc.dll' delayed;

function MenuPrivate (
         sCNPJCliente :  PAnsiChar;
         sCNPJParceiro : PAnsiChar;
         dValor : double;
         iCupom : integer;
         iLeitor : integer
       ): PAnsiChar; stdcall;
          external 'TefClientmc.dll' delayed;

function VendeFrotaCompleto (
         sCNPJCliente :  PAnsiChar;
         sCNPJParceiro : PAnsiChar;
         dValor : double;
         sKM : PAnsiChar;
         sPlaca : PAnsiChar;
         sMatricula : PAnsiChar;
         QtdeItens : integer;
         sItens : PAnsiChar;
         iCupom : integer;
         iLeitor : integer
       ): PAnsiChar; stdcall;
          external 'TefClientmc.dll' delayed;

function LinkPagamento (
         sCNPJCliente :  PAnsiChar;
         sCNPJParceiro : PAnsiChar;
         iParcelas : integer;
         dValor : double;
         iCupom : integer;
         QtdeItens : integer;
         sItens : PAnsiChar;
         sTelefone : PAnsiChar;
         sTexto : PAnsiChar;
         iLeitor : integer
       ): PAnsiChar; stdcall;
          external 'TefClientmc.dll' delayed;

function ListarLinkPagamentoPago (
         sCNPJCliente :  PAnsiChar;
         sCNPJParceiro : PAnsiChar;
         dValor : double;
         iCupom : integer;
         iLeitor : integer
       ): PAnsiChar; stdcall;
          external 'TefClientmc.dll' delayed;

function ManutencaoLinkPagamento (
         sCNPJCliente :  PAnsiChar;
         sCNPJParceiro : PAnsiChar;
         iLeitor : integer
       ): PAnsiChar; stdcall;
          external 'TefClientmc.dll' delayed;

function Cancelar (
         sCNPJCliente :  PAnsiChar;
         sCNPJParceiro : PAnsiChar;
         dValor : double;
         iCupom : integer;
         sControle : PAnsiChar;
         iLeitor : integer
       ): PAnsiChar; stdcall;
          external 'TefClientmc.dll' delayed;

function Reimpressao (
         sCNPJCliente :  PAnsiChar;
         sCNPJParceiro : PAnsiChar;
         iLeitor : integer
       ): PAnsiChar; stdcall;
          external 'TefClientmc.dll' delayed;

function ReimpressaoDireto (
         sCNPJCliente :  PAnsiChar;
         sCNPJParceiro : PAnsiChar;
         sNSU : PAnsiChar;
         Data : PAnsiChar;
         iCupom : integer;
         iLeitor : integer
       ): PAnsiChar; stdcall;
          external 'TefClientmc.dll' delayed;

function VendeCarteiraDigitalPix (
         sCNPJCliente :  PAnsiChar;
         sCNPJParceiro : PAnsiChar;
         dValor : double;
         iCupom : integer;
         iLeitor : integer
       ): PAnsiChar; stdcall;
          external 'TefClientmc.dll' delayed;

function RecargaCelular (
         sCNPJCliente :  PAnsiChar;
         sCNPJParceiro : PAnsiChar;
         iCupom : integer;
         iLeitor : integer
       ): PAnsiChar; stdcall;
          external 'TefClientmc.dll' delayed;

function ParceleMais (
         sCNPJCliente :  PAnsiChar;
         sCNPJParceiro : PAnsiChar;
         dValor : double;
         iCupom : integer;
         iLeitor : integer
       ): PAnsiChar; stdcall;
          external 'TefClientmc.dll' delayed;

function Relatorio (
         sCNPJCliente :  PAnsiChar;
         sCNPJParceiro : PAnsiChar;
         iCupom : integer;
         iLeitor : integer
       ): PAnsiChar; stdcall;
          external 'TefClientmc.dll' delayed;

function Atv (
         sCNPJCliente :  PAnsiChar;
         sCNPJParceiro : PAnsiChar;
         iCupom : integer;
         iLeitor : integer
       ): PAnsiChar; stdcall;
          external 'TefClientmc.dll' delayed;

function Adm (
         sCNPJCliente :  PAnsiChar;
         sCNPJParceiro : PAnsiChar;
         dValor : double;
         iCupom : integer;
         iLeitor : integer
       ): PAnsiChar; stdcall;
          external 'TefClientmc.dll' delayed;

function Confirmar (
         sCNPJCliente :  PAnsiChar;
         sCNPJParceiro : PAnsiChar;
         iCupom : integer
       ): PAnsiChar; stdcall;
          external 'TefClientmc.dll' delayed;

function Desfazimento (
         sCNPJCliente :  PAnsiChar;
         sCNPJParceiro : PAnsiChar;
         iCupom : integer
       ): PAnsiChar; stdcall;
          external 'TefClientmc.dll' delayed;

//==============================================================================
// CONSTRUTOR E DESTRUTOR
//==============================================================================

constructor TMultiplusCardTefGP.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FRetornoPgto := TMultiplusCardRetorno.Create;
  FMultiplusCardConfigGP := TMultiplusCardConfigGP.Create;
  FMultiplusCardConfigGP.NomeDLL := 'TefClientmc.dll';
end;

destructor TMultiplusCardTefGP.Destroy;
begin
  FRetornoPgto.Free;
  FMultiplusCardConfigGP.Free;
  inherited Destroy;
end;

//==============================================================================
// DISPARADORES DE EVENTOS
//==============================================================================

procedure TMultiplusCardTefGP.SetMultiplusCardConfigGP(const Value: TMultiplusCardConfigGP);
begin
  FMultiplusCardConfigGP.Assign(Value);
end;

procedure TMultiplusCardTefGP.DoRegistrarLog(Conteudo: string);
var
  Posicao: integer;
begin
  if Assigned(FOnRegistrarLog) then
    FOnRegistrarLog(Self, Conteudo);
end;

procedure TMultiplusCardTefGP.DoMsg(const Conteudo: string);
begin
  if Assigned(FOnMsg) then
    FOnMsg(Self, Conteudo);
end;

procedure TMultiplusCardTefGP.DoGerarComprovante(const Retorno: TMultiplusCardRetorno);
begin
  if Assigned(FOnGerarComprovante) then
    FOnGerarComprovante(Self, Retorno);
end;

procedure TMultiplusCardTefGP.DoFalhaOperacao(const Conteudo: string);
begin
  if Assigned(FOnFalhaOperacao) then
    FOnFalhaOperacao(Self, Conteudo);
end;

//==============================================================================
// METODOS AUXILIARES
//==============================================================================

function TMultiplusCardTefGP.VerificarDLL: Boolean;
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
    DoRegistrarLog('DLL "'+ Configuracoes.NomeDLL +'" não localizada no diretório atual.');
end;

//==============================================================================
// MÉTODOS OPERAÇÃO TEF
//==============================================================================

function TMultiplusCardTefGP.VendeCreditoGP(dValor : double; iCupom : integer): boolean;
var
  Params: TParametrosTEF;
begin
  Result := False;

  Params := Default(TParametrosTEF);
  Params.dValor := dValor;
  Params.iCupom := iCupom;
  Params.sCNPJCliente := FMultiplusCardConfigGP.FCnpjCliente;
  Params.sCNPJParceiro := FMultiplusCardConfigGP.FCnpjParceiro;
  Params.iLeitor := FMultiplusCardConfigGP.FILeitor;

  Result := ProcessarOperacoes(opCredito, Params);

end;

function TMultiplusCardTefGP.VendeCreditoVistaGP(dValor : double; iCupom : integer): boolean;
var
  Params: TParametrosTEF;
begin
  Result := False;

  Params := Default(TParametrosTEF);
  Params.dValor := dValor;
  Params.iCupom := iCupom;
  Params.sCNPJCliente := FMultiplusCardConfigGP.FCnpjCliente;
  Params.sCNPJParceiro := FMultiplusCardConfigGP.FCnpjParceiro;
  Params.iLeitor := FMultiplusCardConfigGP.FILeitor;

  Result := ProcessarOperacoes(opCreditoAVista, Params);
end;

function TMultiplusCardTefGP.VendeCreditoParcLojaGP(dValor : double; iCupom, iParcelas : integer): boolean;
var
  Params: TParametrosTEF;
begin
  Result := False;

  Params := Default(TParametrosTEF);
  Params.dValor := dValor;
  Params.iCupom := iCupom;
  Params.iParcelas := iParcelas;
  Params.sCNPJCliente := FMultiplusCardConfigGP.FCnpjCliente;
  Params.sCNPJParceiro := FMultiplusCardConfigGP.FCnpjParceiro;
  Params.iLeitor := FMultiplusCardConfigGP.FILeitor;

  Result := ProcessarOperacoes(opCreditoParceladoLoja, Params);
end;

function TMultiplusCardTefGP.VendeCreditoParcAdmGP(dValor : double; iCupom, iParcelas : integer): boolean;
var
  Params: TParametrosTEF;
begin
  Result := False;

  Params := Default(TParametrosTEF);
  Params.dValor := dValor;
  Params.iCupom := iCupom;
  Params.iParcelas := iParcelas;
  Params.sCNPJCliente := FMultiplusCardConfigGP.FCnpjCliente;
  Params.sCNPJParceiro := FMultiplusCardConfigGP.FCnpjParceiro;
  Params.iLeitor := FMultiplusCardConfigGP.FILeitor;

  Result := ProcessarOperacoes(opCreditoParceladoAdm, Params);
end;

function TMultiplusCardTefGP.VendeDebitoGP(dValor : double; iCupom : integer): boolean;
var
  Params: TParametrosTEF;
begin
  Result := False;

  Params := Default(TParametrosTEF);
  Params.dValor := dValor;
  Params.iCupom := iCupom;
  Params.sCNPJCliente := FMultiplusCardConfigGP.FCnpjCliente;
  Params.sCNPJParceiro := FMultiplusCardConfigGP.FCnpjParceiro;
  Params.iLeitor := FMultiplusCardConfigGP.FILeitor;

  Result := ProcessarOperacoes(opDebito, Params);
end;

function TMultiplusCardTefGP.VendeDebitoAVistaGP(dValor : double; iCupom : integer): boolean;
var
  Params: TParametrosTEF;
begin
  Result := False;

  Params := Default(TParametrosTEF);
  Params.dValor := dValor;
  Params.iCupom := iCupom;
  Params.sCNPJCliente := FMultiplusCardConfigGP.FCnpjCliente;
  Params.sCNPJParceiro := FMultiplusCardConfigGP.FCnpjParceiro;
  Params.iLeitor := FMultiplusCardConfigGP.FILeitor;

  Result := ProcessarOperacoes(opDebitoAVista, Params);
end;

function TMultiplusCardTefGP.VendaGenericaGP(dValor : double; iCupom : integer): boolean;
var
  Params: TParametrosTEF;
begin
  Result := False;

  Params := Default(TParametrosTEF);
  Params.dValor := dValor;
  Params.iCupom := iCupom;
  Params.sCNPJCliente := FMultiplusCardConfigGP.FCnpjCliente;
  Params.sCNPJParceiro := FMultiplusCardConfigGP.FCnpjParceiro;
  Params.iLeitor := FMultiplusCardConfigGP.FILeitor;

  Result := ProcessarOperacoes(opVendaGenerica, Params);
end;

function TMultiplusCardTefGP.MenuPrivateGP(dValor : double; iCupom : integer): boolean;
var
  Params: TParametrosTEF;
begin
  Result := False;

  Params := Default(TParametrosTEF);
  Params.dValor := dValor;
  Params.iCupom := iCupom;
  Params.sCNPJCliente := FMultiplusCardConfigGP.FCnpjCliente;
  Params.sCNPJParceiro := FMultiplusCardConfigGP.FCnpjParceiro;
  Params.iLeitor := FMultiplusCardConfigGP.FILeitor;

  Result := ProcessarOperacoes(opMenuPrivate, Params);
end;

function TMultiplusCardTefGP.VendeFrotaCompletoGP(dValor : double; iCupom, qtdeItens : integer; sKm, sPlaca,
  sMatricula, sItens : string): boolean;
var
  Params: TParametrosTEF;
begin
  Result := False;

  Params := Default(TParametrosTEF);
  Params.dValor := dValor;
  Params.iCupom := iCupom;
  Params.sCNPJCliente := FMultiplusCardConfigGP.FCnpjCliente;
  Params.sCNPJParceiro := FMultiplusCardConfigGP.FCnpjParceiro;
  Params.iLeitor := FMultiplusCardConfigGP.FILeitor;

  Params.sKm := sKm;
  Params.sPlaca := sPlaca;
  Params.sMatricula := sMatricula;
  Params.qtdeItens := qtdeItens;
  Params.sItens := sItens;

  Result := ProcessarOperacoes(opFrotaCompleto, Params);
end;

function TMultiplusCardTefGP.LinkPagamentoGP(dValor : double; iCupom, iParcelas,
 qtdeItens : integer; sItens, sTelefone, sTexto : string): boolean;
var
  Params: TParametrosTEF;
begin
  Result := False;

  Params := Default(TParametrosTEF);
  Params.dValor := dValor;
  Params.iCupom := iCupom;
  Params.iParcelas := iParcelas;
  Params.sCNPJCliente := FMultiplusCardConfigGP.FCnpjCliente;
  Params.sCNPJParceiro := FMultiplusCardConfigGP.FCnpjParceiro;
  Params.iLeitor := FMultiplusCardConfigGP.FILeitor;

  Params.sTexto := sTexto;
  Params.sTelefone := sTelefone;
  Params.qtdeItens := qtdeItens;
  Params.sItens := sItens;

  Result := ProcessarOperacoes(opLinkPagamento, Params);
end;

function TMultiplusCardTefGP.ListarLinkPagamentoPagoGP(dValor : double; iCupom : integer): boolean;
var
  Params: TParametrosTEF;
begin
  Result := False;

  Params := Default(TParametrosTEF);
  Params.dValor := dValor;
  Params.iCupom := iCupom;
  Params.sCNPJCliente := FMultiplusCardConfigGP.FCnpjCliente;
  Params.sCNPJParceiro := FMultiplusCardConfigGP.FCnpjParceiro;
  Params.iLeitor := FMultiplusCardConfigGP.FILeitor;

  Result := ProcessarOperacoes(opListarLinkPagamento, Params);
end;

function TMultiplusCardTefGP.ManutencaoLinkPagamentoGP: boolean;
var
  Params: TParametrosTEF;
begin
  Result := False;

  Params := Default(TParametrosTEF);
  Params.sCNPJCliente := FMultiplusCardConfigGP.FCnpjCliente;
  Params.sCNPJParceiro := FMultiplusCardConfigGP.FCnpjParceiro;
  Params.iLeitor := FMultiplusCardConfigGP.FILeitor;

  Result := ProcessarOperacoes(opManutencaoLinkPagamento, Params);
end;

function TMultiplusCardTefGP.CancelarGP(dValor : double; iCupom : integer; sControle : string): boolean;
var
  Params: TParametrosTEF;
begin
  Result := False;

  Params := Default(TParametrosTEF);
  Params.dValor := dValor;
  Params.iCupom := iCupom;
  Params.sControle := sControle;
  Params.sCNPJCliente := FMultiplusCardConfigGP.FCnpjCliente;
  Params.sCNPJParceiro := FMultiplusCardConfigGP.FCnpjParceiro;
  Params.iLeitor := FMultiplusCardConfigGP.FILeitor;

  Result := ProcessarOperacoes(opCancelar, Params);
end;

function TMultiplusCardTefGP.ReimpressaoGP: boolean;
var
  Params: TParametrosTEF;
begin
  Result := False;

  Params := Default(TParametrosTEF);
  Params.sCNPJCliente := FMultiplusCardConfigGP.FCnpjCliente;
  Params.sCNPJParceiro := FMultiplusCardConfigGP.FCnpjParceiro;
  Params.iLeitor := FMultiplusCardConfigGP.FILeitor;

  Result := ProcessarOperacoes(opReimpressao, Params);
end;

function TMultiplusCardTefGP.ReimpressaoDiretoGP(sNSU, Data : string; iCupom : integer): boolean;
var
  Params: TParametrosTEF;
begin
  Result := False;

  Params := Default(TParametrosTEF);
  Params.sNSU := sNSU;
  Params.Data := Data;
  Params.iCupom := iCupom;
  Params.sCNPJCliente := FMultiplusCardConfigGP.FCnpjCliente;
  Params.sCNPJParceiro := FMultiplusCardConfigGP.FCnpjParceiro;
  Params.iLeitor := FMultiplusCardConfigGP.FILeitor;

  Result := ProcessarOperacoes(opReimpressaoDireto, Params);
end;

function TMultiplusCardTefGP.VendeCarteiraDigitalPixGP(dValor : double; iCupom : integer): boolean;
var
  Params: TParametrosTEF;
begin
  Result := False;

  Params := Default(TParametrosTEF);
  Params.dValor := dValor;
  Params.iCupom := iCupom;
  Params.sCNPJCliente := FMultiplusCardConfigGP.FCnpjCliente;
  Params.sCNPJParceiro := FMultiplusCardConfigGP.FCnpjParceiro;
  Params.iLeitor := FMultiplusCardConfigGP.FILeitor;

  Result := ProcessarOperacoes(opPix, Params);
end;

function TMultiplusCardTefGP.RecargaCelularGP(iCupom : integer): boolean;
var
  Params: TParametrosTEF;
begin
  Result := False;

  Params := Default(TParametrosTEF);
  Params.iCupom := iCupom;
  Params.sCNPJCliente := FMultiplusCardConfigGP.FCnpjCliente;
  Params.sCNPJParceiro := FMultiplusCardConfigGP.FCnpjParceiro;
  Params.iLeitor := FMultiplusCardConfigGP.FILeitor;

  Result := ProcessarOperacoes(opRecargaCelular, Params);
end;

function TMultiplusCardTefGP.ParceleMaisGP(dValor : double; iCupom : integer): boolean;
var
  Params: TParametrosTEF;
begin
  Result := False;

  Params := Default(TParametrosTEF);
  Params.dValor := dValor;
  Params.iCupom := iCupom;
  Params.sCNPJCliente := FMultiplusCardConfigGP.FCnpjCliente;
  Params.sCNPJParceiro := FMultiplusCardConfigGP.FCnpjParceiro;
  Params.iLeitor := FMultiplusCardConfigGP.FILeitor;

  Result := ProcessarOperacoes(opParceleMais, Params);
end;

function TMultiplusCardTefGP.RelatorioGP(iCupom : integer): boolean;
var
  Params: TParametrosTEF;
begin
  Result := False;

  Params := Default(TParametrosTEF);
  Params.iCupom := iCupom;
  Params.sCNPJCliente := FMultiplusCardConfigGP.FCnpjCliente;
  Params.sCNPJParceiro := FMultiplusCardConfigGP.FCnpjParceiro;
  Params.iLeitor := FMultiplusCardConfigGP.FILeitor;

  Result := ProcessarOperacoes(opRelatorio, Params);
end;

function TMultiplusCardTefGP.AtvGP(iCupom : integer): boolean;
var
  Params: TParametrosTEF;
begin
  Result := False;

  Params := Default(TParametrosTEF);
  Params.iCupom := iCupom;
  Params.sCNPJCliente := FMultiplusCardConfigGP.FCnpjCliente;
  Params.sCNPJParceiro := FMultiplusCardConfigGP.FCnpjParceiro;
  Params.iLeitor := FMultiplusCardConfigGP.FILeitor;

  Result := ProcessarOperacoes(opAtv, Params);
end;

function TMultiplusCardTefGP.AdmGP(dValor : double; iCupom : integer): boolean;
var
  Params: TParametrosTEF;
begin
  Result := False;

  Params := Default(TParametrosTEF);
  Params.iCupom := iCupom;
  Params.dValor := dValor;
  Params.sCNPJCliente := FMultiplusCardConfigGP.FCnpjCliente;
  Params.sCNPJParceiro := FMultiplusCardConfigGP.FCnpjParceiro;
  Params.iLeitor := FMultiplusCardConfigGP.FILeitor;

  Result := ProcessarOperacoes(opAdm, Params);
end;


//==============================================================================
// MÉTODO PRINCIPAL - EXECUÇÃO DE TRANSAÇÕES TEF
//==============================================================================

function TMultiplusCardTefGP.ProcessarOperacoes(Operacao: TOperacao; const Params: TParametrosTEF): boolean;
var
  sCNPJCliente, sCNPJParceiro, sKm, sPlaca, sMatricula,
   sItens, sTelefone, sTexto, sControle, sNSU, Data : PAnsiChar;
   dValor : double;
  iCupom, iLeitor, iParcelas, qtdeItens, PosInicio2Via : integer;
  vLinhas, vTipos: TStringList;
  sLinha: string;
  sRetorno, sRetornoStatusTransacao, sMensagemStatusTransacao : string;
  comprovante : string;
begin
  Result := False;
  // Exemplo de log
  DoRegistrarLog('Iniciando ProcessarOperacoes');

  // ========== VERIFICAÇÃO DA DLL ANTES DE INICIAR ==========
  if not VerificarDLL then
  begin
    DoMsg('Operação cancelada: DLL não encontrada.');
    DoFalhaOperacao('Operação cancelada: DLL não encontrada.');
    DoRegistrarLog('Operação cancelada: DLL não encontrada.');
    Exit;
  end;
  // =========================================================

  try
    // Limpar dados anteriores
    FRetornoPgto.LimparDados;

    // Atribuindo valores as variáveis
    sCNPJCliente := PAnsiChar(AnsiString(Params.sCNPJCliente));
    sCNPJParceiro := PAnsiChar(AnsiString(Params.sCNPJParceiro));
    iCupom := Params.iCupom;
    dValor := Params.dValor;
    iParcelas := Params.iParcelas;
    sNSU := PAnsiChar(AnsiString(Params.sNSU));
    sControle := PAnsiChar(AnsiString(Params.sControle));
    Data := PAnsiChar(AnsiString(Params.Data));
    iLeitor := Params.iLeitor;
    sKm := PAnsiChar(AnsiString(Params.sKm));
    sPlaca := PAnsiChar(AnsiString(Params.sPlaca));
    sMatricula := PAnsiChar(AnsiString(Params.sMatricula));
    qtdeItens := Params.qtdeItens;
    sItens := PAnsiChar(AnsiString(Params.sItens));
    sTexto := PAnsiChar(AnsiString(Params.sTexto));
    sTelefone := PAnsiChar(AnsiString(Params.sTelefone));


    // Processar a operação conforme recebido
    case Operacao of
      opCredito:
      begin
        DoMsg('Iniciando operação "CREDITO".');
        DoRegistrarLog('Iniciando operação "CREDITO".');
        if (dValor = 0) then
        begin
            DoRegistrarLog('Verifique o campo "Valor".');
            DoFalhaOperacao('Verifique o campo "Valor".');
            Exit;
        end;
        DoRegistrarLog('Chamou - VendeCredito('+sCNPJCliente+', '+sCNPJParceiro+', '+FloatToStr(dValor)+', '+IntToStr(iCupom)+', '+IntToStr(iLeitor)+')');
        sRetorno := VendeCredito(sCNPJCliente, sCNPJParceiro, dValor, iCupom, iLeitor);
      end;
      opCreditoAVista:
      begin
        DoMsg('Iniciando operação "CREDITO A VISTA".');
        DoRegistrarLog('Iniciando operação "CREDITO A VISTA".');
        if (dValor = 0) then
        begin
            DoRegistrarLog('Verifique o campo "Valor".');
            DoFalhaOperacao('Verifique o campo "Valor".');
            Exit;
        end;
        DoRegistrarLog('Chamou - VendeCreditoVista('+sCNPJCliente+', '+sCNPJParceiro+', '+FloatToStr(dValor)+', '+IntToStr(iCupom)+', '+IntToStr(iLeitor)+')');
        sRetorno := VendeCreditoVista(sCNPJCliente, sCNPJParceiro, dValor, iCupom, iLeitor);
      end;
      opCreditoParceladoLoja:
      begin
        DoMsg('Iniciando operação "CREDITO PARCELADO LOJA".');
        DoRegistrarLog('Iniciando operação "CREDITO PARCELADO LOJA".');
        if (dValor = 0) then
        begin
            DoRegistrarLog('Verifique o campo "Valor".');
            DoFalhaOperacao('Verifique o campo "Valor".');
            Exit;
        end;
        if (iParcelas = 0) then
          iParcelas := 1;

        DoRegistrarLog('Chamou - VendeCreditoParcLoja('+sCNPJCliente+', '+sCNPJParceiro+', '+IntToStr(iParcelas)+', '+FloatToStr(dValor)+', '+IntToStr(iCupom)+', '+IntToStr(iLeitor)+')');
        sRetorno := VendeCreditoParcLoja(sCNPJCliente, sCNPJParceiro, iParcelas, dValor, iCupom, iLeitor);
      end;
      opCreditoParceladoAdm:
      begin
        DoMsg('Iniciando operação "CREDITO PARCELADO ADM".');
        DoRegistrarLog('Iniciando operação "CREDITO PARCELADO ADM".');
        if (dValor = 0) then
        begin
            DoRegistrarLog('Verifique o campo "Valor".');
            DoFalhaOperacao('Verifique o campo "Valor".');
            Exit;
        end;
        if (iParcelas = 0) then
          iParcelas := 1;

        DoRegistrarLog('Chamou - VendeCreditoParcAdm('+sCNPJCliente+', '+sCNPJParceiro+', '+IntToStr(iParcelas)+', '+FloatToStr(dValor)+', '+IntToStr(iCupom)+', '+IntToStr(iLeitor)+')');
        sRetorno := VendeCreditoParcAdm(sCNPJCliente, sCNPJParceiro, iParcelas, dValor, iCupom, iLeitor);
      end;
      opDebito:
      begin
        DoMsg('Iniciando operação "DEBITO".');
        DoRegistrarLog('Iniciando operação "DEBITO".');
        if (dValor = 0) then
        begin
            DoRegistrarLog('Verifique o campo "Valor".');
            DoFalhaOperacao('Verifique o campo "Valor".');
            Exit;
        end;
        DoRegistrarLog('Chamou - VendeDebito('+sCNPJCliente+', '+sCNPJParceiro+', '+FloatToStr(dValor)+', '+IntToStr(iCupom)+', '+IntToStr(iLeitor)+')');
        sRetorno := VendeDebito(sCNPJCliente, sCNPJParceiro, dValor, iCupom, iLeitor);
      end;
      opDebitoAVista:
      begin
        DoMsg('Iniciando operação "DEBITO A VISTA".');
        DoRegistrarLog('Iniciando operação "DEBITO A VISTA".');
        if (dValor = 0) then
        begin
            DoRegistrarLog('Verifique o campo "Valor".');
            DoFalhaOperacao('Verifique o campo "Valor".');
            Exit;
        end;
        DoRegistrarLog('Chamou - VendeDebitoAVista('+sCNPJCliente+', '+sCNPJParceiro+', '+FloatToStr(dValor)+', '+IntToStr(iCupom)+', '+IntToStr(iLeitor)+')');
        sRetorno := VendeDebitoAVista(sCNPJCliente, sCNPJParceiro, dValor, iCupom, iLeitor);
      end;
      opVendaGenerica:
      begin
        DoMsg('Iniciando operação "VENDA GENERICA".');
        DoRegistrarLog('Iniciando operação "VENDA GENERICA".');
        if (dValor = 0) then
        begin
            DoRegistrarLog('Verifique o campo "Valor".');
            DoFalhaOperacao('Verifique o campo "Valor".');
            Exit;
        end;
        DoRegistrarLog('Chamou - VendaGenerica('+sCNPJCliente+', '+sCNPJParceiro+', '+FloatToStr(dValor)+', '+IntToStr(iCupom)+', '+IntToStr(iLeitor)+')');
        sRetorno := VendaGenerica(sCNPJCliente, sCNPJParceiro, dValor, iCupom, iLeitor);
      end;
      opMenuPrivate:
      begin
        DoMsg('Iniciando operação "MENU PRIVATE".');
        DoRegistrarLog('Iniciando operação "MENU PRIVATE".');
        if (dValor = 0) then
        begin
            DoRegistrarLog('Verifique o campo "Valor".');
            DoFalhaOperacao('Verifique o campo "Valor".');
            Exit;
        end;
        DoRegistrarLog('Chamou - MenuPrivate('+sCNPJCliente+', '+sCNPJParceiro+', '+FloatToStr(dValor)+', '+IntToStr(iCupom)+', '+IntToStr(iLeitor)+')');
        sRetorno := MenuPrivate(sCNPJCliente, sCNPJParceiro, dValor, iCupom, iLeitor);
      end;
      opFrotaCompleto:
      begin
        DoMsg('Iniciando operação "FROTA COMPLETO".');
        DoRegistrarLog('Iniciando operação "FROTA COMPLETO".');
        if (dValor = 0) then
        begin
            DoRegistrarLog('Verifique o campo "Valor".');
            DoFalhaOperacao('Verifique o campo "Valor".');
            Exit;
        end;
        if Trim(sKm) = '' then
        begin
          DoRegistrarLog('O campo "Km" não pode ficar vazio.');
          DoFalhaOperacao('O campo "Km" não pode ficar vazio.');
          Exit;
        end;
        if Trim(sPlaca) = '' then
        begin
          DoRegistrarLog('O campo "Placa" não pode ficar vazio.');
          DoFalhaOperacao('O campo "Placa" não pode ficar vazio.');
          Exit;
        end;
        if Trim(sMatricula) = '' then
        begin
          DoRegistrarLog('O campo "Matricula" não pode ficar vazio.');
          DoFalhaOperacao('O campo "Matricula" não pode ficar vazio.');
          Exit;
        end;
        if (qtdeItens = 0) then
        begin
          DoRegistrarLog('Verifique o campo "Qtde Itens".');
          DoFalhaOperacao('Verifique o campo "Qtde Itens".');
          Exit;
        end;
        if Trim(sItens) = '' then
        begin
          DoRegistrarLog('O campo "Itens" não pode ficar vazio.');
          DoFalhaOperacao('O campo "Itens" não pode ficar vazio.');
          Exit;
        end;
        DoRegistrarLog('Chamou - VendeFrotaCompleto('+sCNPJCliente+', '+sCNPJParceiro+', '+FloatToStr(dValor)+', '+sKm+', '+sPlaca+', '+sMatricula+', '+IntToStr(qtdeItens)+', '+sItens+', '+IntToStr(iCupom)+', '+IntToStr(iLeitor)+')');
        sRetorno := VendeFrotaCompleto(sCNPJCliente, sCNPJParceiro, dValor, sKm, sPlaca, sMatricula, qtdeItens, sItens, iCupom, iLeitor);
      end;
      opLinkPagamento:
      begin
        DoMsg('Iniciando operação "LINK PAGAMENTO".');
        DoRegistrarLog('Iniciando operação "LINK PAGAMENTO".');

        if (dValor = 0) then
        begin
            DoRegistrarLog('Verifique o campo "Valor".');
            DoFalhaOperacao('Verifique o campo "Valor".');
            Exit;
        end;
        if (iParcelas = 0) then
          iParcelas := 1;
        if Trim(sTelefone) = '' then
        begin
          DoRegistrarLog('O campo "Telefone" não pode ficar vazio.');
          DoFalhaOperacao('O campo "Telefone" não pode ficar vazio.');
          Exit;
        end;

        DoRegistrarLog('Chamou - LinkPagamento('+sCNPJCliente+', '+sCNPJParceiro+', '+IntToStr(iParcelas)+', '+FloatToStr(dValor)+', '+IntToStr(iCupom)+', '+IntToStr(qtdeItens)+', '+sItens+', '+sTelefone+', '+sTexto+', '+IntToStr(iLeitor)+')');
        sRetorno := LinkPagamento(sCNPJCliente, sCNPJParceiro, iParcelas, dValor, iCupom, qtdeItens, sItens, sTelefone, sTexto, iLeitor);
      end;
      opListarLinkPagamento:
      begin
        DoMsg('Iniciando operação "LISTAR LINK PAGAMENTO".');
        DoRegistrarLog('Iniciando operação "LISTAR LINK PAGAMENTO".');
        if (dValor = 0) then
        begin
            DoRegistrarLog('Verifique o campo "Valor".');
            DoFalhaOperacao('Verifique o campo "Valor".');
            Exit;
        end;
        DoRegistrarLog('Chamou - ListarLinkPagamentoPago('+sCNPJCliente+', '+sCNPJParceiro+', '+FloatToStr(dValor)+', '+IntToStr(iCupom)+', '+IntToStr(iLeitor)+')');
        sRetorno := ListarLinkPagamentoPago(sCNPJCliente, sCNPJParceiro, dValor, iCupom, iLeitor);
      end;
      opManutencaoLinkPagamento:
      begin
        DoMsg('Iniciando operação "MANUTENCAO LINK PAGAMENTO".');
        DoRegistrarLog('Iniciando operação "MANUTENCAO LINK PAGAMENTO".');
        DoRegistrarLog('Chamou - ManutencaoLinkPagamento('+sCNPJCliente+', '+sCNPJParceiro+', '+IntToStr(iLeitor)+')');
        sRetorno := ManutencaoLinkPagamento(sCNPJCliente, sCNPJParceiro, iLeitor);
      end;
      opCancelar:
      begin
        DoMsg('Iniciando operação "CANCELAR".');
        DoRegistrarLog('Iniciando operação "CANCELAR".');
        if (dValor = 0) then
        begin
            DoRegistrarLog('Verifique o campo "Valor".');
            DoFalhaOperacao('Verifique o campo "Valor".');
            Exit;
        end;
        DoRegistrarLog('Chamou - Cancelar('+sCNPJCliente+', '+sCNPJParceiro+', '+FloatToStr(dValor)+', '+IntToStr(iCupom)+', '+sControle+', '+IntToStr(iLeitor)+')');
        sRetorno := Cancelar(sCNPJCliente, sCNPJParceiro, dValor, iCupom, sControle, iLeitor);
      end;
      opReimpressao:
      begin
        DoMsg('Iniciando operação "REIMPRESSAO".');
        DoRegistrarLog('Iniciando operação "REIMPRESSAO".');
        DoRegistrarLog('Chamou - Reimpressao('+sCNPJCliente+', '+sCNPJParceiro+', '+IntToStr(iLeitor)+')');
        sRetorno := Reimpressao(sCNPJCliente, sCNPJParceiro, iLeitor);
      end;
      opReimpressaoDireto:
      begin
        DoMsg('Iniciando operação "REIMPRESSAO DIRETO".');
        DoRegistrarLog('Iniciando operação "REIMPRESSAO DIRETO".');
        DoRegistrarLog('Chamou - ReimpressaoDireto('+sCNPJCliente+', '+sCNPJParceiro+', '+sNSU+', '+Data+', '+IntToStr(iCupom)+', '+IntToStr(iLeitor)+')');
        sRetorno := ReimpressaoDireto(sCNPJCliente, sCNPJParceiro, sNSU, Data, iCupom, iLeitor);
      end;
      opPix:
      begin
        DoMsg('Iniciando operação "PIX".');
        DoRegistrarLog('Iniciando operação "PIX".');
        if (dValor = 0) then
        begin
            DoRegistrarLog('Verifique o campo "Valor".');
            DoFalhaOperacao('Verifique o campo "Valor".');
            Exit;
        end;
        DoRegistrarLog('Chamou - VendeCarteiraDigitalPix('+sCNPJCliente+', '+sCNPJParceiro+', '+FloatToStr(dValor)+', '+IntToStr(iCupom)+', '+IntToStr(iLeitor)+')');
        sRetorno := VendeCarteiraDigitalPix(sCNPJCliente, sCNPJParceiro, dValor, iCupom, iLeitor);
      end;
      opRecargaCelular:
      begin
        DoMsg('Iniciando operação "RECARGA CELULAR".');
        DoRegistrarLog('Iniciando operação "RECARGA CELULAR".');
        DoRegistrarLog('Chamou - RecargaCelular('+sCNPJCliente+', '+sCNPJParceiro+', '+IntToStr(iCupom)+', '+IntToStr(iLeitor)+')');
        sRetorno := RecargaCelular(sCNPJCliente, sCNPJParceiro, iCupom, iLeitor);
      end;
      opParceleMais:
      begin
        DoMsg('Iniciando operação "PARCELE MAIS".');
        DoRegistrarLog('Iniciando operação "PARCELE MAIS".');
        if (dValor = 0) then
        begin
            DoRegistrarLog('Verifique o campo "Valor".');
            DoFalhaOperacao('Verifique o campo "Valor".');
            Exit;
        end;
        DoRegistrarLog('Chamou - ParceleMais('+sCNPJCliente+', '+sCNPJParceiro+', '+FloatToStr(dValor)+', '+IntToStr(iCupom)+', '+IntToStr(iLeitor)+')');
        sRetorno := ParceleMais(sCNPJCliente, sCNPJParceiro, dValor, iCupom, iLeitor);
      end;
      opRelatorio:
      begin
        DoMsg('Iniciando operação "RELATORIO".');
        DoRegistrarLog('Iniciando operação "RELATORIO".');
        DoRegistrarLog('Chamou - Relatorio('+sCNPJCliente+', '+sCNPJParceiro+', '+IntToStr(iCupom)+', '+IntToStr(iLeitor)+')');
        sRetorno := Relatorio(sCNPJCliente, sCNPJParceiro, iCupom, iLeitor);
      end;
      opAtv:
      begin
        DoMsg('Iniciando operação "ATV".');
        DoRegistrarLog('Iniciando operação "ATV".');
        DoRegistrarLog('Chamou - Atv('+sCNPJCliente+', '+sCNPJParceiro+', '+IntToStr(iCupom)+', '+IntToStr(iLeitor)+')');
        sRetorno := Atv(sCNPJCliente, sCNPJParceiro, iCupom, iLeitor);
      end;
      opAdm:
      begin
        DoMsg('Iniciando operação "ADM".');
        DoRegistrarLog('Iniciando operação "ADM".');
        if (dValor = 0) then
        begin
            DoRegistrarLog('Verifique o campo "Valor".');
            DoFalhaOperacao('Verifique o campo "Valor".');
            Exit;
        end;
        DoRegistrarLog('Chamou - Adm('+sCNPJCliente+', '+sCNPJParceiro+', '+FloatToStr(dValor)+', '+IntToStr(iCupom)+', '+IntToStr(iLeitor)+')');
        sRetorno := Adm(sCNPJCliente, sCNPJParceiro, dValor, iCupom, iLeitor);
      end;
    end;

    if Trim(sRetorno) = '' then
      Exit;

    // Processar retorno
    DoRegistrarLog('Retorno - ' + sRetorno);

    sRetorno := StringReplace(sRetorno, sLineBreak, '¬', [rfReplaceAll]);
    vLinhas := TStringList.Create;
    vTipos := TStringList.Create;

    try
      vLinhas.Delimiter := '¬';
      vLinhas.StrictDelimiter := True;
      vLinhas.DelimitedText := sRetorno;

      for sLinha in vLinhas do
      begin
        vTipos.Delimiter := ';';
        vTipos.StrictDelimiter := True;
        vTipos.DelimitedText := sLinha;

        // Obtendo status da transação
        if vTipos[0] = 'S' then
        begin
          sRetornoStatusTransacao := vTipos[1];
          sMensagemStatusTransacao := vTipos[2];
          // Ocorreu um erro.
          if sRetornoStatusTransacao = '0' then
          begin
            DoRegistrarLog(sMensagemStatusTransacao);
            DoFalhaOperacao(sMensagemStatusTransacao);
            Exit;
          end
          // Possui cupom/comprovante gerado
          else if sRetornoStatusTransacao = '1' then
          begin
            DoRegistrarLog(sMensagemStatusTransacao);
            DoMsg(sMensagemStatusTransacao);
          end
          // Não retornou cupom/comprovante.
          else if sRetornoStatusTransacao = '2' then
          begin
            DoRegistrarLog(sMensagemStatusTransacao);
            DoMsg(sMensagemStatusTransacao);
            Exit;
          end
          else
          begin
            DoRegistrarLog('Retorno fora do esperado.');
            DoFalhaOperacao('Retorno fora do esperado.');
            Exit;
          end;
        end
        // Obtendo dados do comprovante
        else if vTipos[0] = 'C' then
        begin
          // === ATRIBUIR dados ao FRetornoPgto ===
          FRetornoPgto.CUPOM := vTipos[1];
          FRetornoPgto.VALOR := vTipos[2];
          FRetornoPgto.NOME_BANDEIRA := vTipos[3];
          FRetornoPgto.NOME_REDE := vTipos[4];
          FRetornoPgto.COD_AUTORIZACAO := vTipos[5];
          FRetornoPgto.NSU := vTipos[6];
          FRetornoPgto.DESC_TIPO_TRANSACAO := vTipos[7];
          FRetornoPgto.QTDE_PARCELAS := vTipos[8];
          FRetornoPgto.CONTROLE := vTipos[9];
          FRetornoPgto.NSU_REDE := vTipos[10];
          FRetornoPgto.CNPJ_AUTORIZADORA := vTipos[11];
          FRetornoPgto.NUMERO_CARTAO := vTipos[12];
          FRetornoPgto.NOME_CLIENTE := vTipos[13];
          FRetornoPgto.VENCTO_CARTAO := vTipos[14];
          FRetornoPgto.TEXTO_ESPECIAL := vTipos[15];
          FRetornoPgto.E2E := vTipos[16];
          FRetornoPgto.Sucesso := True;
          FRetornoPgto.MensagemSucesso := sMensagemStatusTransacao;
          FRetornoPgto.ConteudoOriginalSucesso := sRetorno;

          if (Operacao = opReimpressao) then
            iCupom := StrToInt(FRetornoPgto.CUPOM);


        end
        // linhas do comprovante a serem impressas
        else if vTipos[0] = 'I' then
        begin
          comprovante := comprovante + StringReplace(vTipos[1], '"', '', [rfReplaceAll]) + sLineBreak;
        end
        else
        begin
          DoRegistrarLog('Retorno fora do esperado.');
          DoFalhaOperacao('Retorno fora do esperado.');
          Exit;
        end;
      end;
    finally
      vLinhas.Free;
      vTipos.Free;
    end;

    // Atribuir o comprovante completo ao objeto de retorno
    FRetornoPgto.COMPROVANTE := comprovante;

    // Localiza o início da segunda via
    PosInicio2Via := Pos('2A VIA - ESTABELECIMENTO', comprovante);

    if PosInicio2Via > 0 then
    begin
      // Extrai tudo da primeira via Cliente
      FRetornoPgto.COMPROVANTE_CLIENTE := Trim(Copy(comprovante, 1, PosInicio2Via - 1));

      // Extrai tudo da segunda via Estabelecimento
      FRetornoPgto.COMPROVANTE_ESTABELECIMENTO := Trim(Copy(comprovante, PosInicio2Via, Length(comprovante)));

      // Comprovante reduzido receberá a 2ª via Estabelecimento
      FRetornoPgto.COMPROVANTE_REDUZIDO := StringReplace(FRetornoPgto.COMPROVANTE_ESTABELECIMENTO, '2A VIA - ESTABELECIMENTO', '', [rfReplaceAll]);
    end
    else
    begin
      // Caso não exista a segunda via no comprovante
      FRetornoPgto.COMPROVANTE_CLIENTE := comprovante;
      FRetornoPgto.COMPROVANTE_ESTABELECIMENTO := comprovante;
      FRetornoPgto.COMPROVANTE_REDUZIDO := comprovante;
    end;

    // Retornar comprovante para a automação
    DoGerarComprovante(FRetornoPgto);

    // Confirmar a operação
    DoRegistrarLog('Chamou - Confirmar('+sCNPJCliente+', '+sCNPJParceiro+', '+IntToStr(iCupom)+')');
    sRetorno := Confirmar(sCNPJCliente, sCNPJParceiro, iCupom);

    // Processar retorno
    DoRegistrarLog('Retorno - ' + sRetorno);

    sRetorno := StringReplace(sRetorno, sLineBreak, '¬', [rfReplaceAll]);
    vLinhas := TStringList.Create;
    vTipos := TStringList.Create;

    try
      vLinhas.Delimiter := '¬';
      vLinhas.StrictDelimiter := True;
      vLinhas.DelimitedText := sRetorno;

      for sLinha in vLinhas do
      begin
        vTipos.Delimiter := ';';
        vTipos.StrictDelimiter := True;
        vTipos.DelimitedText := sLinha;

        // Obtendo status da transação
        if vTipos[0] = 'S' then
        begin
          sRetornoStatusTransacao := vTipos[1];
          sMensagemStatusTransacao := vTipos[2];
          // Ocorreu um erro.
          if sRetornoStatusTransacao = '0' then
          begin
            DoRegistrarLog(sMensagemStatusTransacao);
            DoMsg(sMensagemStatusTransacao);
            Exit;
          end
          // Não retornou cupom/comprovante.
          else if sRetornoStatusTransacao = '2' then
          begin
            DoRegistrarLog(sMensagemStatusTransacao);
            DoMsg(sMensagemStatusTransacao);
            Result := True;
            Exit;
          end
          else
          begin
            DoRegistrarLog('Retorno fora do esperado.');
            DoFalhaOperacao('Retorno fora do esperado.');
            Exit;
          end;
        end
        else
        begin
          DoRegistrarLog('Retorno fora do esperado.');
          DoFalhaOperacao('Retorno fora do esperado.');
          Exit;
        end;
      end;
    finally
      vLinhas.Free;
      vTipos.Free;
    end;

  except
    on E: Exception do
    begin
      DoRegistrarLog('Erro ao Processar Operações: ' + E.Message);
      DoMsg('Erro ao Processar Operações: ' + E.Message);
    end;
  end;

end;


end.
