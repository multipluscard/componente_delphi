unit MultiplusCardCommons;

//==============================================================================
// UNIT DE CÓDIGO COMUM PARA TODOS OS COMPONENTES
// Contém tipos, classes e funções utilitárias compartilhadas
//==============================================================================

interface

uses
  System.Classes,
  System.SysUtils,
  System.StrUtils,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.Controls,
  vcl.ExtCtrls,
  Vcl.Buttons,
  Vcl.Graphics,
  Vcl.ComCtrls,
  MultiplusCardUtils,
  System.RegularExpressions,
  System.Generics.Collections;

//==============================================================================
// TIPOS E ENUMERAÇÕES
//==============================================================================

type
  /// Tipos de solicitação na interface para usuário
  TTipoSolicitacao = (tsMenu, tsPergunta, tsMensagem, tsSimNao);

  /// Solicitação feita para usuário
  TSolicitacaoUsuario = record
    Tipo: TTipoSolicitacao;
    Titulo: string;
    Mensagem: string;
    Opcoes: string;  // Apenas para tsMenu
  end;

  /// Resposta do usuário em formato padrão
  TRespostaUsuario = record
    RespTexto: string;
    Confirmou: Boolean;
    RespondeuSolicitacao: Boolean;
  end;

  type
  TItemData = record
    Caption: string;
    Value: Integer;
    Data: Pointer;
  end;

//==============================================================================
// ESTRUTURAS DE DADOS PARA INTERAÇÃO COM USUÁRIO
//==============================================================================

  /// Dados de interação quando pergunta
  TDadosPerguntaDll = record
    TextoPergunta: string;
    TipoDado: string;      // INT, DATE, DECIMAL
    TamanhoMinimo: Integer;
    TamanhoMaximo: Integer;
    ValorMinimo: string;
    ValorMaximo: string;
    CasasDecimais: Integer;
    Valida: Boolean;
  end;

  /// Dados de interação quando mensagem
  TDadosMensagemDll = record
    TextoMensagem: string;
    Valida: Boolean;
  end;

  /// Dados de cada item do menu
  TItemMenuDll = record
    Codigo: string;
    Valor: string;
    Texto: string;
  end;

  /// Dados de interação quando menu
  TDadosMenuDll = record
    TituloMenu: string;
    Itens: array of TItemMenuDll;
    Valida: Boolean;
  end;

  /// Dados de interação quando sim/não
  TDadosSimNao = record
    TituloMenu: string;
    BotaoSim: string;
    BotaoNao: string;
    Valida: Boolean;
  end;

//==============================================================================
// DEFINIÇÃO DE EVENTOS
//==============================================================================

  TOnMsgEvent = procedure(Sender: TObject; const Conteudo: string) of object;
  TOnSolicitarInteracao = procedure(Sender: TObject; const Solicitacao: TSolicitacaoUsuario;
                                   var Resposta: TRespostaUsuario) of object;

//==============================================================================
// CLASSES AUXILIARES
//==============================================================================

  /// Classe de retorno de transação
  TMultiplusCardRetorno = class(TPersistent)
  private

  public    
    // Campos internos que armazenam os dados retornados pela DLL
    NOME_BANDEIRA : string;
    CNPJ_AUTORIZADORA : string;
    VALOR : string;
    NUM_VIAS_COMPROVANTE : string;
    CUPOM : string;
    CARTAO_PRE_PAGO : string;
    NSU_REDE : string;
    COD_REDE : string;
    NOME_REDE : string;
    BIN_CARTAO : string;
    COD_TIPO_TRANSACAO : string;
    ULTIMOS_DIGITOS_CARTAO : string;
    DESC_TIPO_TRANSACAO : string;
    COMPROVANTE : string;
    COMPROVANTE_REDUZIDO : string;
    COMPROVANTE_CLIENTE : string;
    COMPROVANTE_ESTABELECIMENTO : string;
    NSU : string;
    NOME_CLIENTE : string;
    TAXA_SERVICO : string;
    VENCTO_CARTAO : string;
    QTDE_PARCELAS : string;
    COD_AUTORIZACAO : string;
    COD_BANDEIRA : string;
    E2E : string;
    SUCESSO    : Boolean;
    MENSAGEMERRO : string;
    MENSAGEMSUCESSO : string;
    CONTEUDOORIGINALSUCESSO : string;
    DATA_HORA_ESTABELECIMENTO : string;
    DATA_HORA_ADMINISTRADORA : string;
    NUMERO_CARTAO : string;
    STATUS : string;
    TERMINAL : string;
    CONTROLE : string;
    TEXTO_ESPECIAL : string;
    // Método para carregar os campos a partir do texto retornado pela DLL
    procedure DllParaRetorno(const ATexto: string);
    procedure LimparDados;

  end;

  /// Classe de retorno do relatório de vendas
  TMultiplusCardRetornoList = TObjectList<TMultiplusCardRetorno>;

  /// Classe de interação com usuário
  TMultiplusCardUi = class(TComponent)
  private
    // Pergunta para UI
    FOnSolicitarInteracao: TOnSolicitarInteracao;
    FRespostaInteracao   : TRespostaUsuario;

    // Variáveis de controle
    Retorno              : Integer;
    mydata               : TDateTime;

    // Variáveis para formulários dinâmicos
    fMensagem            : TForm;
    lMensagem            : TLabel ;
    lvListMenu           : TListview;
    lblTitulo            : TLabel;
    pnContainer          : TPanel;
    pnTitulo             : TPanel;
    pnMensagem           : TPanel;
    pnBotoes             : TPanel;
    eResposta            : TEdit;
    bOk                  : TButton;
    bCancelar            : TButton;
    pnBotoesInner        : TPanel;

    // Eventos
    FOnMsgCm             : TOnMsgEvent;

    // Objetos auxiliares
    FRetornoPgto         : TMultiplusCardRetorno;
    FMensagemReduzida    : Boolean;

    // Métodos privados - eventos
    procedure DoMsg(const Conteudo: string);

  public
    // Construtores e destrutores
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;

    // Métodos de teste
    procedure TestarFormularioPadrao;
    procedure TestarFormularioPersonalizado;

    // Métodos de interação
    function SolicitarInteracao(Tipo: TTipoSolicitacao; const  Mensagem: string): TRespostaUsuario;
    function ResponderInteracao(Resposta: TRespostaUsuario): Boolean;

    // Métodos de interface dinâmica
    function CriarFormInterfaceDinamica(Tipo: TTipoSolicitacao; const Mensagem: string; UsaFormPadrao: Boolean): TRespostaUsuario;
    procedure CriarFormMensagem;
    procedure ConfigurarFormPorTipo(Tipo: TTipoSolicitacao; const Mensagem: string);
    procedure DestruirMensagem;
    procedure BotaoOkClick(Sender: TObject);
    procedure BotaoCancelarClick(Sender: TObject);
    procedure ListView1SelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);

  published
    // Eventos
    property OnMsgCm           : TOnMsgEvent    read FOnMsgCm            write FOnMsgCm;
    property OnSolicitarInteracaoCm: TOnSolicitarInteracao read FOnSolicitarInteracao write FOnSolicitarInteracao;
  end;

//==============================================================================
// FUNÇÕES UTILITÁRIAS PARA EXTRAÇÃO DE DADOS
//==============================================================================

/// Extrai valor com base em regex
function ExtrairValor(const ATexto, APattern: string): string;

/// Extrai de item de menu para texto
function ArrayMenuParaTextoCustomizado(const Itens: array of TItemMenuDll;
  const FormatoItem: string = '[%s] %s'): string;

  /// Extrai de item de menu para listview
procedure ArrayMenuParaListView(AListView: TListView; const Itens: array of TItemMenuDll);

/// Adicona item para uma TListView
procedure AdicionarItem(AListView: TListView; const ACaption: string; AValue: Integer);

/// Extrai dados de pergunta para texto
function ExtrairDadosPergunta(const TextoCompleto: string): TDadosPerguntaDll;

/// Extrai dados de pergunta para mensagem
function ExtrairDadosMensagem(const TextoCompleto: string): TDadosMensagemDll;

/// Extrai dados de pergunta para menu
function ExtrairDadosMenu(const TextoCompleto: string): TDadosMenuDll;

/// Extrai dados para sim/não
function ExtrairDadosSimNao(const TextoCompleto: string): TDadosSimNao;

implementation

//==============================================================================
// IMPLEMENTAÇÃO DAS FUNÇÕES UTILITÁRIAS
//==============================================================================
procedure TMultiplusCardRetorno.LimparDados;
begin
  CUPOM := '';
  VALOR := '';
  NOME_BANDEIRA := '';
  NOME_REDE := '';
  COD_AUTORIZACAO := '';
  NSU := '';
  DESC_TIPO_TRANSACAO := '';
  QTDE_PARCELAS := '';
  CONTROLE := '';
  NSU_REDE := '';
  CNPJ_AUTORIZADORA := '';
  NUMERO_CARTAO := '';
  NOME_CLIENTE := '';
  VENCTO_CARTAO := '';
  TEXTO_ESPECIAL := '';
  E2E := '';
  SUCESSO := False;
  MENSAGEMERRO := '';
  MENSAGEMSUCESSO := '';
  CONTEUDOORIGINALSUCESSO := '';
  COD_BANDEIRA := '';
  COD_REDE := '';
  TAXA_SERVICO := '';
  BIN_CARTAO := '';
  ULTIMOS_DIGITOS_CARTAO := '';
  CARTAO_PRE_PAGO := '';
  COD_TIPO_TRANSACAO := '';
  COMPROVANTE := '';
  COMPROVANTE_REDUZIDO := '';
  COMPROVANTE_CLIENTE := '';
  COMPROVANTE_ESTABELECIMENTO := '';
  NUM_VIAS_COMPROVANTE := '';
  DATA_HORA_ESTABELECIMENTO := '';
  DATA_HORA_ADMINISTRADORA := '';
  STATUS := '';
  TERMINAL := '';
end;

function ExtrairValor(const ATexto, APattern: string): string;
var
  Regex : TRegEx;
  Match : TMatch;
begin
  Regex := TRegEx.Create(APattern);
  Match := Regex.Match(ATexto);
  if Match.Success then
    Result := Match.Groups[1].Value
  else
    Result := '';
end;

function ExtrairDadosPergunta(const TextoCompleto: string): TDadosPerguntaDll;
var
  partes: TStringList;
  texto: string;
begin
  // Inicializar resultado
  Result.Valida := False;
  Result.TextoPergunta := '';
  Result.TipoDado := '';
  Result.TamanhoMinimo := 0;
  Result.TamanhoMaximo := 0;
  Result.ValorMinimo := '';
  Result.ValorMaximo := '';
  Result.CasasDecimais := 0;

  // Verificar se começa com [PERGUNTA]
  if not TextoCompleto.StartsWith('[PERGUNTA]#') then
    begin
      Result.TextoPergunta := TextoCompleto;
      Exit;
    end;
  // Remover o prefixo [PERGUNTA]#
  texto := Copy(TextoCompleto, 12, Length(TextoCompleto)); // 12 = Length('[PERGUNTA]#') + 1

  partes := TStringList.Create;
  try

    // Usar StrictDelimiter para split correto
    partes.StrictDelimiter := True;
    partes.Delimiter := '#';
    partes.DelimitedText := texto;

    // Verificar se tem todas as 7 partes esperadas
    if partes.Count <> 7 then
      Exit;

    // Extrair cada parte
    Result.TextoPergunta := Trim(partes[0]);
    Result.TipoDado := UpperCase(Trim(partes[1]));
    Result.TamanhoMinimo := StrToIntDef(Trim(partes[2]), 0);
    Result.TamanhoMaximo := StrToIntDef(Trim(partes[3]), 0);
    Result.ValorMinimo := Trim(partes[4]);
    Result.ValorMaximo := Trim(partes[5]);
    Result.CasasDecimais := StrToIntDef(Trim(partes[6]), 0);

    Result.Valida := True;

  finally
    partes.Free;
  end;
end;

function ExtrairDadosMensagem(const TextoCompleto: string): TDadosMensagemDll;
var
  texto: string;
begin
  // Inicializar
  Result.Valida := False;
  Result.TextoMensagem := '';

  // Verificar se começa com [MSG]#
  if Copy(TextoCompleto, 1, 6) <> '[MSG]#' then
    begin
      Result.TextoMensagem := TextoCompleto;
      Exit;
    end;

  // Extrair texto após [MSG]#
  texto := Copy(TextoCompleto, 7, Length(TextoCompleto));

  Result.TextoMensagem := Trim(texto);
  Result.Valida := True;
end;

function ExtrairDadosMenu(const TextoCompleto: string): TDadosMenuDll;
var
  TextoTrabalhado: string;
  PosicaoTitulo, PosicaoItens: Integer;
  TituloCompleto, ItensCompleto: string;
  ListaItens: TArray<string>;
  Item: string;
  PartesItem: TArray<string>;
  ParteCodigoValor, ParteTexto: string;
  PartesCodigoValor: TArray<string>;
  I: Integer;
begin
  // Inicializar resultado
  Result.TituloMenu := '';
  Result.Valida := False;
  SetLength(Result.Itens, 0);

  // Verificar se o texto começa com [MENU]
  if not TextoCompleto.StartsWith('[MENU]#') then
    begin
      Result.TituloMenu := TextoCompleto;
      Exit;
    end;

  try
    // Remover [MENU]# do início
    TextoTrabalhado := TextoCompleto.Substring(7); // Remove '[MENU]#'

    // Encontrar a posição do próximo # (fim do título)
    PosicaoTitulo := TextoTrabalhado.IndexOf('#');
    if PosicaoTitulo = -1 then
      Exit;

    // Extrair título
    Result.TituloMenu := TextoTrabalhado.Substring(0, PosicaoTitulo);

    // Extrair itens (após o segundo #)
    ItensCompleto := TextoTrabalhado.Substring(PosicaoTitulo + 1);

    // Separar itens por |
    ListaItens := ItensCompleto.Split(['|']);

    // Configurar array de itens
    SetLength(Result.Itens, Length(ListaItens));

    // Processar cada item
    for I := 0 to High(ListaItens) do
    begin
      Item := ListaItens[I].Trim;

      // Separar por - (Codigo,Valor-Texto)
      PartesItem := Item.Split(['-'], TStringSplitOptions.None); // Limita a 2 partes
      if Length(PartesItem) < 2 then
        Continue;

      ParteCodigoValor := PartesItem[0].Trim;
      ParteTexto := string.Join('-', Copy(PartesItem, 1, Length(PartesItem) - 1));
      ParteTexto := ParteTexto.Trim;

      // Separar Codigo,Valor
      PartesCodigoValor := ParteCodigoValor.Split([','], 2); // Limita a 2 partes
      if Length(PartesCodigoValor) <> 2 then
        Continue;

      // Preencher o item
      Result.Itens[I].Codigo := PartesCodigoValor[0].Trim;
      Result.Itens[I].Valor := PartesCodigoValor[1].Trim;
      Result.Itens[I].Texto := ParteTexto;
    end;

    // Marcar como válido se chegou até aqui
    Result.Valida := True;

  except
    // Em caso de erro, retornar estrutura inválida
    Result.TituloMenu := '';
    Result.Valida := False;
    SetLength(Result.Itens, 0);
  end;
end;

function ExtrairDadosSimNao(const TextoCompleto: string): TDadosSimNao;
begin
  Result.TituloMenu := TextoCompleto;
  Result.BotaoSim := 'Sim';
  Result.BotaoNao := 'Não';
end;

function ArrayMenuParaTextoCustomizado(const Itens: array of TItemMenuDll;
  const FormatoItem: string = '[%s] %s'): string;
var
  lista: TStringList;
  i: Integer;
begin
  Result := '';

  if Length(Itens) = 0 then
    Exit;

  lista := TStringList.Create;
  try
    for i := 0 to High(Itens) do
    begin
      lista.Add(Format(FormatoItem, [Itens[i].Valor, Itens[i].Texto]));
    end;

    Result := lista.Text;
  finally
    lista.Free;
  end;
end;

procedure ArrayMenuParaListView(AListView: TListView; const Itens: array of TItemMenuDll);
var
  i: Integer;
begin
  if not Assigned(AListView) then
    Exit;

  if Length(Itens) = 0 then
    Exit;

  AListView.Items.BeginUpdate;
  try
    AListView.Items.Clear; // Limpar itens existentes

    for i := 0 to High(Itens) do
    begin
      AdicionarItem(AListView, Itens[i].Texto, StrToInt(Itens[i].Valor));
    end;
  finally
    AListView.Items.EndUpdate;
  end;
end;

procedure AdicionarItem(AListView: TListView; const ACaption: string; AValue: Integer);
var
  Item: TListItem;
  ItemData: ^TItemData;
begin
  New(ItemData);
  ItemData^.Caption := ACaption;
  ItemData^.Value := AValue;

  Item := AListView.Items.Add;
  Item.Caption := ACaption;      // O que o usuário vê
  Item.Data := ItemData;         // Estrutura com dados completos
end;

//=========================================================================
// IMPLEMENTAÇÃO DA CLASSE TMultiplusCardRetorno
//==============================================================================

procedure TMultiplusCardRetorno.DllParaRetorno(const ATexto: string);
var
  P: Integer;
begin
  CUPOM := ExtrairValor(ATexto, 'CAMPO0160=([\d,]+)');             // Número do cupom
  VALOR := ExtrairValor(ATexto, 'CAMPO0002=([\d,]+)');          // Valor da transação
  COD_BANDEIRA := ExtrairValor(ATexto, 'CAMPO0132=(\d+)');             // Código da bandeira
  COD_REDE := ExtrairValor(ATexto, 'CAMPO0131=(\d+)');                 // Código da rede
  COD_AUTORIZACAO := ExtrairValor(ATexto, 'CAMPO0135=(\d+)');          // Código de autorização
  NSU := ExtrairValor(ATexto, 'CAMPO0133=([^#]+)');                      // NSU (Número Sequencial Único)
  E2E := ExtrairValor(ATexto, 'CAMPO2620=([^#]+)');                      // E2E (End to End - para PIX)
  QTDE_PARCELAS := ExtrairValor(ATexto, 'CAMPO0505=(\d+)');         // Quantidade de parcelas
  TAXA_SERVICO := ExtrairValor(ATexto, 'CAMPO0504=([\d,]+)');             // Taxa de serviço
  BIN_CARTAO := ExtrairValor(ATexto, 'CAMPO0136=(\d+)');                  // BIN do cartão
  ULTIMOS_DIGITOS_CARTAO := ExtrairValor(ATexto, 'CAMPO1190=(\d+)');        // Últimos dígitos do cartão
  CNPJ_AUTORIZADORA := ExtrairValor(ATexto, 'CAMPO0950=(\d+)');    // CNPJ da autorizadora
  NOME_CLIENTE := ExtrairValor(ATexto, 'CAMPO1003=([^#]+)');              // Nome do cliente
  NSU_REDE := ExtrairValor(ATexto, 'CAMPO0134=(\d+)');                    // NSU da rede
  VENCTO_CARTAO := ExtrairValor(ATexto, 'CAMPO0513=(\d+)');           // Vencimento do cartão
  NUM_VIAS_COMPROVANTE := ExtrairValor(ATexto, 'CAMPO0003=(\d+)');      // Número de vias do comprovante
  NOME_BANDEIRA := ExtrairValor(ATexto, 'CAMPO9999=([^#]+)');             // Nome da bandeira
  NOME_REDE := ExtrairValor(ATexto, 'CAMPO9998=([^#]+)');                 // Nome da rede
  CARTAO_PRE_PAGO := ExtrairValor(ATexto, 'CAMPO4221=([^#]+)');                  // Indicador se é cartão pré-pago
  COD_TIPO_TRANSACAO := ExtrairValor(ATexto, 'CAMPO0100=(\d+)');        // Código do tipo de transação
  DESC_TIPO_TRANSACAO := ExtrairValor(ATexto, 'CAMPO0101=([^#]+)');   // Descrição do tipo de transação
  COMPROVANTE := ExtrairValor(ATexto, 'CAMPO122=([^#]+)');          // Dados do comprovante
  COMPROVANTE_REDUZIDO := ExtrairValor(ATexto, 'CAMPO0121=([^#]+)'); // Dados do comprovante Reduzido

  // Localiza a posição da palavra "CORTAR"
  P := Pos('CORTAR', COMPROVANTE);
  if P > 0 then
  begin
    // Via Cliente: tudo antes de "CORTAR"
    COMPROVANTE_CLIENTE := Trim(Copy(COMPROVANTE, 1, P - 1));

    // Via Estabelecimento: tudo depois de "CORTAR"
    COMPROVANTE_ESTABELECIMENTO := Trim(Copy(COMPROVANTE, P + Length('CORTAR'), Length(COMPROVANTE)));   
  end
  else
  begin
    // Dados do comprovante Cliente                                           
    COMPROVANTE_CLIENTE := COMPROVANTE;  
    // Dados do comprovante Estabelecimento
    COMPROVANTE_ESTABELECIMENTO := COMPROVANTE;
  end;

  // Removendo caractere | e substituindo por quebra de linha 
  COMPROVANTE := COMPROVANTE.Replace('|', sLineBreak);
  COMPROVANTE_REDUZIDO := COMPROVANTE_REDUZIDO.Replace('|', sLineBreak);   
  COMPROVANTE_CLIENTE := COMPROVANTE_CLIENTE.Replace('|', sLineBreak);
  COMPROVANTE_ESTABELECIMENTO := COMPROVANTE_ESTABELECIMENTO.Replace('|', sLineBreak);

  SUCESSO := true;
  MENSAGEMSUCESSO := '';
  MENSAGEMERRO :='';
  CONTEUDOORIGINALSUCESSO := Atexto;
end;

//==============================================================================
// IMPLEMENTAÇÃO DA CLASSE TMultiplusCardUi
//==============================================================================

constructor TMultiplusCardUi.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FRetornoPgto := TMultiplusCardRetorno.Create;
  FMensagemReduzida := False;

end;

destructor TMultiplusCardUi.Destroy;
begin
  FRetornoPgto.Free;

  inherited Destroy;
end;

// =============================================================================
// MÉTODOS DE INTERFACE DINÂMICA
// =============================================================================

function TMultiplusCardUi.CriarFormInterfaceDinamica(Tipo: TTipoSolicitacao; const Mensagem: string; UsaFormPadrao: Boolean): TRespostaUsuario;
begin
  Result.RespTexto := '';
  Result.Confirmou := False;
  Result.RespondeuSolicitacao := false;

  if not UsaFormPadrao then
  begin
    SolicitarInteracao(Tipo, Mensagem);
    while FRespostaInteracao.RespondeuSolicitacao = false   do
    begin
      Application.ProcessMessages; // ESSENCIAL - permite processar eventos
      Sleep(100);
    end;
    Result := FRespostaInteracao;
    Exit;
  end;

  // Form padrão - mesmo padrão para todos os tipos
  CriarFormMensagem;
  try
    ConfigurarFormPorTipo(Tipo, Mensagem);

    // DEFINIR FOCO APÓS CONFIGURAÇÃO
    if bOk.Enabled and bOk.Visible then
      fMensagem.ActiveControl := bOk;

    Result.Confirmou := (fMensagem.ShowModal = mrOk);
    if Result.Confirmou and eResposta.Enabled then
      Result.RespTexto := eResposta.Text;
  finally
    DestruirMensagem;
  end;
end;

procedure TMultiplusCardUi.CriarFormMensagem;
begin
  fMensagem := TForm.Create(nil);

   // === FORM PRINCIPAL ===
  fMensagem.BorderIcons  := [];
  fMensagem.BorderStyle  := bsSingle;
  fMensagem.ClientWidth  := 400;
  fMensagem.ClientHeight := 300;

  fMensagem.Position    := poScreenCenter;

  // === CONTAINER ===
  pnContainer := TPanel.Create(fMensagem);
  pnContainer.Parent := fMensagem;
  pnContainer.Left := 15;
  pnContainer.Top := 15;
  pnContainer.Width := fMensagem.ClientWidth - 30;
  pnContainer.Height := fMensagem.ClientHeight - 30;
  pnContainer.BevelOuter := bvNone;
  pnContainer.Anchors := [akLeft, akTop, akRight, akBottom];

  // === TÍTULO ===
  pnTitulo := TPanel.Create(pnContainer);
  pnTitulo.Parent := pnContainer;
  pnTitulo.Align := alTop;
  pnTitulo.Height := 100;
  pnTitulo.BevelOuter := bvNone;

  lblTitulo := TLabel.Create(pnTitulo);
  lblTitulo.Parent := pnTitulo;
  lblTitulo.Align := alClient;
  lblTitulo.Alignment := taCenter;
  lblTitulo.Layout := tlCenter;
  lblTitulo.Caption := 'TÍTULO';
  lblTitulo.WordWrap := True;
  lblTitulo.Font.Size := 14;
  lblTitulo.Font.Style := [fsBold];

  // === RODAPÉ PRIMEIRO (para não sobrepor) ===
  pnBotoes := TPanel.Create(pnContainer);
  pnBotoes.Parent := pnContainer;
  pnBotoes.Align := alBottom;
  pnBotoes.Height := 60;
  pnBotoes.BevelOuter := bvNone;

  // === CONTEÚDO (agora no meio) ===
  pnMensagem := TPanel.Create(pnContainer);
  pnMensagem.Parent := pnContainer;
  pnMensagem.Align := alClient;  // Agora ocupará o espaço entre título e rodapé
  pnMensagem.BevelOuter := bvNone;


  // === LST PARA MENU ===

  // === LST PARA MENU ===
  lvListMenu := TListView.Create(pnMensagem);
  lvListMenu.Parent := pnMensagem;
  lvListMenu.Left := 20;
  lvListMenu.Top := 5;
  lvListMenu.Width := 330;
  lvListMenu.Height := 90;

  lvListMenu.ViewStyle := vsReport;
  lvListMenu.RowSelect := True;
  lvListMenu.ShowColumnHeaders := False;  // REMOVE O CABEÇALHO
  lvListMenu.Columns.Add.Caption := '';   // Caption vazio
  lvListMenu.Columns[0].Width := lvListMenu.ClientWidth - 4;
  lvListMenu.Anchors := [akLeft, akTop, akRight];
  lvListMenu.OnSelectItem := ListView1SelectItem;


  // === MENSAGEM (SEM alClient para dar espaço ao eResposta) ===
  lMensagem := TLabel.Create(pnMensagem);
  lMensagem.Parent := pnMensagem;
  lMensagem.Left := 20;
  lMensagem.Top := 20;
  lMensagem.Width := pnMensagem.Width - 40;
  lMensagem.Height := pnMensagem.Height - 80;  // deixa espaço para eResposta validando


  lMensagem.Align := alTop;
  lMensagem.Alignment := taCenter;
  lMensagem.Layout := tlCenter;
  lMensagem.WordWrap := True;

  lMensagem.Caption := 'Mensagem teste';
  lMensagem.Anchors := [akLeft, akTop, akRight];

  // === CAMPO RESPOSTA (agora com espaço adequado) ===
  eResposta := TEdit.Create(pnMensagem);
  eResposta.Parent := pnMensagem;
  eResposta.Height := 28;
  eResposta.Left := 20;
  eResposta.Width := pnMensagem.Width - 40;
  eResposta.Top := pnMensagem.Height - eResposta.Height - 10;
  eResposta.Anchors := [akLeft, akRight, akBottom];

  // === BOTÕES ===
  pnBotoesInner := TPanel.Create(pnBotoes);
  pnBotoesInner.Parent := pnBotoes;
  pnBotoesInner.Left := 20;
  pnBotoesInner.Top := 0;
  pnBotoesInner.Width := pnBotoes.Width - 40;
  pnBotoesInner.Height := pnBotoes.Height;
  pnBotoesInner.BevelOuter := bvNone;
  pnBotoesInner.Anchors := [akLeft, akTop, akRight, akBottom];

  // Botões...
  bCancelar := TButton.Create(pnBotoesInner);
  bCancelar.Parent := pnBotoesInner;
  bCancelar.Caption := 'Cancelar';
  bCancelar.Width := 100;
  bCancelar.Height := 32;
  bCancelar.Left := 0;  // ESQUERDA (sem margem) ou use 10 para uma pequena margem
  bCancelar.Top := (pnBotoesInner.Height - bCancelar.Height) div 2;
  bCancelar.Anchors := [akLeft, akTop];  // ANCHOR à ESQUERDA
  bCancelar.OnClick := BotaoCancelarClick;

  bOK := TButton.Create(pnBotoesInner);
  bOK.Parent := pnBotoesInner;
  bOK.Caption := 'OK';
  bOK.Width := 100;
  bOK.Height := 32;
  bOK.Left := pnBotoesInner.Width - bOK.Width;
  bOK.Top := (pnBotoesInner.Height - bOK.Height) div 2;
  bOK.Anchors := [akRight, akTop];
  bOK.OnClick := BotaoOkClick;
end;

procedure TMultiplusCardUi.ConfigurarFormPorTipo(Tipo: TTipoSolicitacao; const Mensagem: string);
var
  perguntaDll: TDadosPerguntaDll;
  mensagemDll: TDadosMensagemDll;
  menuDll: TDadosMenuDll;
  simNao: TDadosSimNao;
begin
  // Resetar controles para estado padrão
  bCancelar.Enabled := True;
  bCancelar.Visible := True;
  eResposta.Enabled := True;
  eResposta.Visible := True;
  lMensagem.Visible := True;
  lvListMenu.Visible := False; // Só mostra quando é Menu.
  lMensagem.Caption := '';

  case Tipo of
    tsPergunta:
    begin
      perguntaDll := ExtrairDadosPergunta(Mensagem);
      lblTitulo.Caption := perguntaDll.TextoPergunta;
      lMensagem.Caption := perguntaDll.TipoDado;
      bOk.Caption := 'Reponder';
    end;

    tsMensagem:
    begin
      mensagemDll := ExtrairDadosMensagem(Mensagem);
      lblTitulo.Caption := mensagemDll.TextoMensagem;

      pnMensagem.Height := 0;
      pnTitulo.Height := 200;

      // Para mensagem, desabilita entrada de dados
      bCancelar.Enabled  := False;
      bCancelar.Visible  := False;
      eResposta.Enabled  := False;
      eResposta.Visible  := False;
      eResposta.ReadOnly := False;
    end;

    tsMenu:
    begin
      menuDll := ExtrairDadosMenu(Mensagem);
      lblTitulo.Caption := menuDll.TituloMenu;
      lMensagem.Caption := ArrayMenuParaTextoCustomizado(menuDll.Itens);
      lMensagem.Visible := False;
      lvListMenu.Visible := True; // Só mostra quando é Menu.
      eResposta.ReadOnly := True;
      eResposta.Visible := false;
      ArrayMenuParaListView(lvListMenu,menuDll.Itens);

      // SELECIONAR PRIMEIRA OPÇÃO AUTOMATICAMENTE
      if lvListMenu.Items.Count > 0 then
      begin
        lvListMenu.Items[0].Selected := True;
        lvListMenu.Items[0].Focused := True;
        lvListMenu.ItemIndex := 0;
      end;

      bCancelar.Caption := 'Cancelar';
      bOk.Caption := 'Confirmar';
    end;

    tsSimNao:
    begin
      simNao := ExtrairDadosSimNao(Mensagem);
      lblTitulo.Caption := simNao.TituloMenu;
      pnMensagem.Height := 0;
      pnTitulo.Height := 200;
      eResposta.Visible := False;
      bCancelar.Caption := 'Não';
      bOk.Caption := 'Sim';
    end;
  end;
end;

procedure TMultiplusCardUi.DestruirMensagem;
begin
  if Assigned(fMensagem) then
    FreeAndNil(fMensagem);
end;

procedure TMultiplusCardUi.BotaoOkClick(Sender: TObject);
var
  Form: TCustomForm;
begin
  if Sender is TControl then
  begin
    Form := GetParentForm(TControl(Sender));
    if Assigned(Form) then
      Form.ModalResult := mrOk;
  end;
end;

procedure TMultiplusCardUi.BotaoCancelarClick(Sender: TObject);
var
  Form: TCustomForm;
begin
  if Sender is TControl then
  begin
    Form := GetParentForm(TControl(Sender));
    if Assigned(Form) then
      Form.ModalResult := mrCancel;
  end;
end;



procedure TMultiplusCardUi.ListView1SelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
var
 ItemData: ^TItemData;
begin
 try
   if Selected and Assigned(Item) then
   begin
     // Obter dados do item
     ItemData := Item.Data;
     if Assigned(ItemData) then
     begin
//        ShowMessage('Selecionado: ' + ItemData^.Caption +
//                    ' - Valor: ' + IntToStr(ItemData^.Value));
       eResposta.Text := IntToStr(ItemData^.Value);
     end;
   end;
 except
   eResposta.Text := '';
 end;
end;

// =============================================================================
// MÉTODOS DE INTERAÇÃO
// =============================================================================

function TMultiplusCardUi.SolicitarInteracao(Tipo: TTipoSolicitacao; const Mensagem: string): TRespostaUsuario;
var
  Solicitacao: TSolicitacaoUsuario;
begin
   // Zera todos os campos do record
  FRespostaInteracao.Confirmou := false;
  FRespostaInteracao.RespondeuSolicitacao := false;
  FRespostaInteracao.RespTexto := '';
  Solicitacao.Tipo := Tipo;
  Solicitacao.Mensagem := Mensagem;

  Result.RespTexto := '';
  Result.Confirmou := False;

  if Assigned(FOnSolicitarInteracao) then
    FOnSolicitarInteracao(Self, Solicitacao, Result);
end;

function TMultiplusCardUi.ResponderInteracao(Resposta: TRespostaUsuario) : Boolean;
begin
  resposta.RespondeuSolicitacao := true;
  resposta.Confirmou := Resposta.Confirmou;
  FRespostaInteracao := Resposta;
  Result := true;
end;

// =============================================================================
// MÉTODOS DE TESTE
// =============================================================================

procedure TMultiplusCardUi.TestarFormularioPadrao;
var
  resposta: TRespostaUsuario;
begin
  try
    try
      resposta := CriarFormInterfaceDinamica(tsPergunta, '[PERGUNTA]#INFORME O NSU#INT#0#0#0,00#0,00#0',True);
      DoMsg(IfThen(resposta.Confirmou, '[OK] ', '[CANCEL] ') + resposta.RespTexto);

      resposta := CriarFormInterfaceDinamica(tsMensagem, '[MSG]#CONECTANDO COM O SERVIDOR',True);
      DoMsg(IfThen(resposta.Confirmou, '[OK] ', '[CANCEL] ') + resposta.RespTexto);

      resposta := CriarFormInterfaceDinamica(tsMenu, '[MENU]#TÍTULO DO MENU#1,1-OPÇÃO A|2,2-OPÇÃO B',True);
      DoMsg(IfThen(resposta.Confirmou, '[OK] ', '[CANCEL] ') + resposta.RespTexto);

      resposta := CriarFormInterfaceDinamica(tsSimNao, 'Esse é um form de pergunta. Qual é a resposta: Sim ou não?',True);
      DoMsg(IfThen(resposta.Confirmou, '[OK] ', '[CANCEL] ') + resposta.RespTexto);
    except
      on E: Exception do
        ShowMessage('ERRO: ' + E.Message + ' - Linha: ' + IntToStr(E.HelpContext));
    end;
  finally
  end;
end;

procedure TMultiplusCardUi.TestarFormularioPersonalizado;
var
  resposta: TRespostaUsuario;
begin
  try
    try
      resposta := CriarFormInterfaceDinamica(tsPergunta, '[PERGUNTA]#INFORME O NSU#INT#0#0#0,00#0,00#0',False);
      DoMsg(IfThen(resposta.Confirmou, '[OK] ', '[CANCEL] ') + resposta.RespTexto);

      resposta := CriarFormInterfaceDinamica(tsMensagem, '[MSG]#CONECTANDO COM O SERVIDOR',False);
      DoMsg(IfThen(resposta.Confirmou, '[OK] ', '[CANCEL] ') + resposta.RespTexto);

      resposta := CriarFormInterfaceDinamica(tsMenu, '[MENU]#TÍTULO DO MENU#1,1-OPÇÃO A|2,2-OPÇÃO B',False);
      DoMsg(IfThen(resposta.Confirmou, '[OK] ', '[CANCEL] ') + resposta.RespTexto);

      resposta := CriarFormInterfaceDinamica(tsSimNao, 'Pergunta: Sim ou não?',False);
      DoMsg(IfThen(resposta.Confirmou, '[OK] ', '[CANCEL] ') + resposta.RespTexto);
    except
      on E: Exception do
        ShowMessage('ERRO: ' + E.Message + ' - Linha: ' + IntToStr(E.HelpContext));
    end;
  finally
  end;
end;

// =============================================================================
// MÉTODOS AUXILIARES
// =============================================================================

procedure TMultiplusCardUi.DoMsg(const Conteudo: string);
var
  Posicao: integer;
  var NovoConteudo: string;
begin
  NovoConteudo := Conteudo;
  if Assigned(FOnMsgCm) then
    FOnMsgCm(Self, NovoConteudo);
end;

end.
