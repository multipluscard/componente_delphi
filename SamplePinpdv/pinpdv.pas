unit pinpdv;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls,
  MultiplusCardTef, MultiplusCardCommons, MultiplusCardPinPDV;

type
  TFormPrincipal = class(TForm)
    Button1: TButton;
    Memo1: TMemo;
    Memo2: TMemo;
    Panel1: TPanel;
    MultiplusCardPinPDV1: TMultiplusCardPinPDV;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure MultiplusCardPinPDV1Msg(Sender: TObject; const Conteudo: string);
    procedure MultiplusCardPinPDV1SolicitarImpressao(Sender: TObject;
      const PreVenda: TPreVenda);
    procedure MultiplusCardPinPDV1RegistrarLog(Sender: TObject;
      const Conteudo: string);
    procedure MultiplusCardPinPDV1GerarComprovante(Sender: TObject;
      const Retorno: TMultiplusCardRetorno);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormPrincipal: TFormPrincipal;

implementation

{$R *.dfm}


//VENDA POS TEF
procedure TFormPrincipal.Button1Click(Sender: TObject);
var
  ListaDispositivos: TListaPinPDV;
  Dispositivo : Integer;
begin

  MultiplusCardPinPDV1.Configuracoes.BaseUrl := 'BaseUrl';
  MultiplusCardPinPDV1.Configuracoes.Token := 'Token';
  MultiplusCardPinPDV1.Configuracoes.UsaFormPadrao := True;
  ListaDispositivos := MultiplusCardPinPDV1.ListarDispositivosPinPDV;

  if (ListaDispositivos.Data.Count > 0) and Assigned(ListaDispositivos.Data[0]) then
    Dispositivo := ListaDispositivos.Data[0].Id;
  Panel1.Caption := 'Dispositivo usado:' + IntToStr(Dispositivo);

  MultiplusCardPinPDV1.CadastrarPosVendaComMonitoramento(Dispositivo,FormatDateTime('hhnnsszzz', Now),'DESCRICAO',0.10,TTipoPagamento.tpDebito,1)
end;


//VENDA PRE VENDA
procedure TFormPrincipal.Button2Click(Sender: TObject);
var
  ListaDispositivos: TListaPinPDV;
  Dispositivo : Integer;
begin

  MultiplusCardPinPDV1.Configuracoes.BaseURL := 'BaseUrl';
  MultiplusCardPinPDV1.Configuracoes.Token := 'Token';
  MultiplusCardPinPDV1.Configuracoes.UsaFormPadrao := True;
  ListaDispositivos := MultiplusCardPinPDV1.ListarDispositivosPinPDV;

  if (ListaDispositivos.Data.Count > 0) and Assigned(ListaDispositivos.Data[0]) then
    Dispositivo := ListaDispositivos.Data[0].Id;
  Panel1.Caption := 'Dispositivo usado:' + IntToStr(Dispositivo);

  MultiplusCardPinPDV1.CadastrarPreVendaComMonitoramento(FormatDateTime('hhnnsszzz', Now), 'DESCRICAO', 0.10, 1, TTipoPagamento.tpDebito, Dispositivo)


end;


// RECEBE COMPROVANTE
procedure TFormPrincipal.MultiplusCardPinPDV1GerarComprovante(Sender: TObject;
  const Retorno: TMultiplusCardRetorno);
begin
  Memo2.Lines.Clear;
  Memo2.Lines.Add('=== COMPROVANTE PINPDV ===');
  Memo2.Lines.Add(Retorno.COMPROVANTE);
  Memo2.Lines.Add('=========================');

  Memo2.Lines.Add('CUPOM: '                  + Retorno.CUPOM);
  Memo2.Lines.Add('VALOR: '                  + Retorno.VALOR);
  Memo2.Lines.Add('COD_BANDEIRA: '           + Retorno.COD_BANDEIRA);
  Memo2.Lines.Add('COD_REDE: '               + Retorno.COD_REDE);
  Memo2.Lines.Add('COD_AUTORIZACAO: '        + Retorno.COD_AUTORIZACAO);
  Memo2.Lines.Add('NSU: '                    + Retorno.NSU);
  Memo2.Lines.Add('QTDE_PARCELAS: '          + Retorno.QTDE_PARCELAS);
  Memo2.Lines.Add('TAXA_SERVICO: '           + Retorno.TAXA_SERVICO);
  Memo2.Lines.Add('BIN_CARTAO: '             + Retorno.BIN_CARTAO);
  Memo2.Lines.Add('ULTIMOS_DIGITOS_CARTAO: ' + Retorno.ULTIMOS_DIGITOS_CARTAO);
  Memo2.Lines.Add('CNPJ_AUTORIZADORA: '      + Retorno.CNPJ_AUTORIZADORA);
  Memo2.Lines.Add('NOME_CLIENTE: '           + Retorno.NOME_CLIENTE);
  Memo2.Lines.Add('NSU_REDE: '               + Retorno.NSU_REDE);
  Memo2.Lines.Add('NUM_VIAS_COMPROVANTE: '   + Retorno.NUM_VIAS_COMPROVANTE);
  Memo2.Lines.Add('VENCTO_CARTAO: '          + Retorno.VENCTO_CARTAO);
  Memo2.Lines.Add('NOME_BANDEIRA: '          + Retorno.NOME_BANDEIRA);
  Memo2.Lines.Add('NOME_REDE: '              + Retorno.NOME_REDE);
  Memo2.Lines.Add('CARTAO_PRE_PAGO: '        + Retorno.CARTAO_PRE_PAGO);
  Memo2.Lines.Add('COD_TIPO_TRANSACAO: '     + Retorno.COD_TIPO_TRANSACAO);
  Memo2.Lines.Add('DESC_TIPO_TRANSACAO: '    + Retorno.DESC_TIPO_TRANSACAO);
end;

//LOG
procedure TFormPrincipal.MultiplusCardPinPDV1RegistrarLog(Sender: TObject;
  const Conteudo: string);
begin
  Memo1.Lines.Add(Conteudo);
end;

//MSG INTERFACE

procedure TFormPrincipal.MultiplusCardPinPDV1Msg(Sender: TObject;
  const Conteudo: string);
begin
  Panel1.Caption := Conteudo;
end;

//RECEBE SOLICITACAO DE IMPRESSAO
procedure TFormPrincipal.MultiplusCardPinPDV1SolicitarImpressao(Sender: TObject;
  const PreVenda: TPreVenda);
begin
   MultiplusCardPinPDV1.EnviaDocumentoImpressao('Finalizou!'+ sLineBreak + 'Segunda Linha!');
end;

end.
