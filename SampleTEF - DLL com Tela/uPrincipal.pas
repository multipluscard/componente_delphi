unit uPrincipal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, System.Threading,
  MultiplusCardTefGP, MultiplusCardCommons, Vcl.ExtCtrls;

type
  TFormPrincipal = class(TForm)
    tabOperacoes: TPageControl;
    tabCartoes: TTabSheet;
    tabModalidadesCartoes: TPageControl;
    tabCredito: TTabSheet;
    btnCreditoParcLoja: TButton;
    btnCredito: TButton;
    btnCreditoAVista: TButton;
    btnCreditoParcAdm: TButton;
    tabDebito: TTabSheet;
    btnDebitoAVista: TButton;
    btnDebito: TButton;
    tabGenerica: TTabSheet;
    btnVendaGenerica: TButton;
    tabPrivateLabel: TTabSheet;
    btnPrivateLabel: TButton;
    tabFrotaCompleto: TTabSheet;
    lbSKm: TLabel;
    lbSPlaca: TLabel;
    lbSMatricula: TLabel;
    lbQtdeItens: TLabel;
    lbSItens: TLabel;
    btnFrotaCompleto: TButton;
    txtSKm: TEdit;
    txtSPlaca: TEdit;
    txtSMatricula: TEdit;
    txtQtdeItens: TEdit;
    txtSItens: TEdit;
    tabLinkDePagamento: TTabSheet;
    tabModalidadesLinkPagamento: TPageControl;
    tabGerarLinkPagamento: TTabSheet;
    lbSItensLink: TLabel;
    lbSTelefone: TLabel;
    lbSTexto: TLabel;
    lbQtdeItensLink: TLabel;
    btnGerarLink: TButton;
    txtSItensLink: TEdit;
    txtSTexto: TEdit;
    txtSTelefone: TEdit;
    txtQtdeItensLink: TEdit;
    tabAdmLinkDePagamento: TTabSheet;
    btnManutencaoLink: TButton;
    btnListarLink: TButton;
    tabPIX: TTabSheet;
    btnPIX: TButton;
    tabRecargaCelular: TTabSheet;
    btnRecargaCelular: TButton;
    tabParceleMais: TTabSheet;
    btnParceleMais: TButton;
    tabAdministracao: TTabSheet;
    btnReimpressaoDireto: TButton;
    btnAtv: TButton;
    btnReimpressao: TButton;
    btnRelatorio: TButton;
    btnAdm: TButton;
    btnCancelamento: TButton;
    memoLog: TMemo;
    memoComprovante: TMemo;
    lbStatus: TLabel;
    pDadosOperacao: TPanel;
    lbIParcela: TLabel;
    lbDValor: TLabel;
    lbICupom: TLabel;
    lbSControle: TLabel;
    lbSNsu: TLabel;
    lbData: TLabel;
    txtIParcela: TEdit;
    txtDValor: TEdit;
    txtICupom: TEdit;
    txtSControle: TEdit;
    txtSNsu: TEdit;
    txtData: TEdit;
    MultiplusCardTefGP1: TMultiplusCardTefGP;
    procedure MultiplusCardTefGP1FalhaOperacao(Sender: TObject;
      const Conteudo: string);
    procedure MultiplusCardTefGP1Msg(Sender: TObject; const Conteudo: string);
    procedure MultiplusCardTefGP1RegistrarLog(Sender: TObject;
      const Conteudo: string);
    procedure btnCreditoClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnCreditoAVistaClick(Sender: TObject);
    procedure btnCreditoParcLojaClick(Sender: TObject);
    procedure btnCreditoParcAdmClick(Sender: TObject);
    procedure btnDebitoClick(Sender: TObject);
    procedure btnDebitoAVistaClick(Sender: TObject);
    procedure btnVendaGenericaClick(Sender: TObject);
    procedure btnPrivateLabelClick(Sender: TObject);
    procedure btnFrotaCompletoClick(Sender: TObject);
    procedure btnGerarLinkClick(Sender: TObject);
    procedure btnListarLinkClick(Sender: TObject);
    procedure btnManutencaoLinkClick(Sender: TObject);
    procedure btnPIXClick(Sender: TObject);
    procedure btnRecargaCelularClick(Sender: TObject);
    procedure btnParceleMaisClick(Sender: TObject);
    procedure RecuperarDadosTEdit;
    procedure btnReimpressaoClick(Sender: TObject);
    procedure btnReimpressaoDiretoClick(Sender: TObject);
    procedure btnCancelamentoClick(Sender: TObject);
    procedure btnAtvClick(Sender: TObject);
    procedure btnAdmClick(Sender: TObject);
    procedure btnRelatorioClick(Sender: TObject);
    procedure MultiplusCardTefGP1GerarComprovante(Sender: TObject;
      const Retorno: TMultiplusCardRetorno);
  private
    { Private declarations }
    // Variaveis para armazenar os dados dos TEdit
    iCupom, iParcelas : integer;
    dValor : double;
    sControle, sNSU, Data : string;
  public
    { Public declarations }
  end;

var
  FormPrincipal: TFormPrincipal;

implementation

{$R *.dfm}

procedure TFormPrincipal.RecuperarDadosTEdit;
begin
  if not TryStrToInt(txtICupom.Text, iCupom) then iCupom := 0;
  if not TryStrToFloat(txtDValor.Text, dValor) then dValor := 0;
  if not TryStrToInt(txtIParcela.Text, iParcelas) then iParcelas := 0;
  sNSU := txtSNsu.Text;
  sControle := txtSControle.Text;
  Data := txtData.Text;
end;

procedure TFormPrincipal.btnAdmClick(Sender: TObject);
var
  sucesso: boolean;
begin
  RecuperarDadosTEdit;
  TTask.Run(
    procedure
    begin
      sucesso := MultiplusCardTefGP1.AdmGP(dValor, iCupom);
      if sucesso then
        lbStatus.Caption := 'Operação concluída com sucesso';
    end);
end;

procedure TFormPrincipal.btnAtvClick(Sender: TObject);
var
  sucesso: boolean;
begin
  RecuperarDadosTEdit;
  TTask.Run(
    procedure
    begin
      sucesso := MultiplusCardTefGP1.AtvGP(iCupom);
      if sucesso then
        lbStatus.Caption := 'Operação concluída com sucesso';
    end);
end;

procedure TFormPrincipal.btnCancelamentoClick(Sender: TObject);
var
  sucesso: boolean;
begin
  RecuperarDadosTEdit;
  TTask.Run(
    procedure
    begin
      sucesso := MultiplusCardTefGP1.CancelarGP(dValor, iCupom, sControle);
      if sucesso then
        lbStatus.Caption := 'Operação concluída com sucesso';
    end);
end;

procedure TFormPrincipal.btnCreditoAVistaClick(Sender: TObject);
var
  sucesso: boolean;
begin
  RecuperarDadosTEdit;
  TTask.Run(
    procedure
    begin
      sucesso := MultiplusCardTefGP1.VendeCreditoVistaGP(dValor, iCupom);
      if sucesso then
        lbStatus.Caption := 'Operação concluída com sucesso';
    end);
end;

procedure TFormPrincipal.btnCreditoClick(Sender: TObject);
var
  sucesso: boolean;
begin
  RecuperarDadosTEdit;
  TTask.Run(
    procedure
    begin
      sucesso := MultiplusCardTefGP1.VendeCreditoGP(dValor, iCupom);
      if sucesso then
        lbStatus.Caption := 'Operação concluída com sucesso';
    end);
end;

procedure TFormPrincipal.btnCreditoParcAdmClick(Sender: TObject);
var
  sucesso: boolean;
begin
  RecuperarDadosTEdit;
  TTask.Run(
    procedure
    begin
      sucesso := MultiplusCardTefGP1.VendeCreditoParcAdmGP(dValor, iCupom, iParcelas);
      if sucesso then
        lbStatus.Caption := 'Operação concluída com sucesso';
    end);
end;

procedure TFormPrincipal.btnCreditoParcLojaClick(Sender: TObject);
var
  sucesso: boolean;
begin
  RecuperarDadosTEdit;
  TTask.Run(
    procedure
    begin
      sucesso := MultiplusCardTefGP1.VendeCreditoParcLojaGP(dValor, iCupom, iParcelas);
      if sucesso then
        lbStatus.Caption := 'Operação concluída com sucesso';
    end);
end;

procedure TFormPrincipal.btnDebitoAVistaClick(Sender: TObject);
var
  sucesso: boolean;
begin
  RecuperarDadosTEdit;
  TTask.Run(
    procedure
    begin
      sucesso := MultiplusCardTefGP1.VendeDebitoAVistaGP(dValor, iCupom);
      if sucesso then
        lbStatus.Caption := 'Operação concluída com sucesso';
    end);
end;

procedure TFormPrincipal.btnDebitoClick(Sender: TObject);
var
  sucesso: boolean;
begin
  RecuperarDadosTEdit;
  TTask.Run(
    procedure
    begin
      sucesso := MultiplusCardTefGP1.VendeDebitoGP(dValor, iCupom);
      if sucesso then
        lbStatus.Caption := 'Operação concluída com sucesso';
    end);
end;

procedure TFormPrincipal.btnFrotaCompletoClick(Sender: TObject);
var
  qtdeItens: integer;
  sucesso: boolean;
begin
  RecuperarDadosTEdit;
  if not TryStrToInt(txtQtdeItens.Text, qtdeItens) then qtdeItens := 0;
  TTask.Run(
    procedure
    begin
      sucesso := MultiplusCardTefGP1.VendeFrotaCompletoGP(dValor, iCupom, qtdeItens, txtSKm.Text, txtSPlaca.Text, txtSMatricula.Text, txtSItens.Text);
      if sucesso then
        lbStatus.Caption := 'Operação concluída com sucesso';
    end);
end;

procedure TFormPrincipal.btnGerarLinkClick(Sender: TObject);
var
  qtdeItens: integer;
  sucesso: boolean;
begin
  RecuperarDadosTEdit;
  if not TryStrToInt(txtQtdeItens.Text, qtdeItens) then qtdeItens := 0;
  TTask.Run(
    procedure
    begin
      sucesso := MultiplusCardTefGP1.LinkPagamentoGP(dValor, iCupom, iParcelas, qtdeItens, txtSItensLink.Text, txtSTelefone.Text, txtSTexto.Text);
      if sucesso then
        lbStatus.Caption := 'Operação concluída com sucesso';
    end);
end;

procedure TFormPrincipal.btnListarLinkClick(Sender: TObject);
var
  sucesso: boolean;
begin
  RecuperarDadosTEdit;
  TTask.Run(
    procedure
    begin
      sucesso := MultiplusCardTefGP1.ListarLinkPagamentoPagoGP(dValor, iCupom);
      if sucesso then
        lbStatus.Caption := 'Operação concluída com sucesso';
    end);
end;

procedure TFormPrincipal.btnManutencaoLinkClick(Sender: TObject);
var
  sucesso: boolean;
begin
  RecuperarDadosTEdit;
  TTask.Run(
    procedure
    begin
      sucesso := MultiplusCardTefGP1.ManutencaoLinkPagamentoGP;
      if sucesso then
        lbStatus.Caption := 'Operação concluída com sucesso';
    end);
end;

procedure TFormPrincipal.btnParceleMaisClick(Sender: TObject);
var
  sucesso: boolean;
begin
  RecuperarDadosTEdit;
  TTask.Run(
    procedure
    begin
      sucesso := MultiplusCardTefGP1.ParceleMaisGP(dValor, iCupom);
      if sucesso then
        lbStatus.Caption := 'Operação concluída com sucesso';
    end);
end;

procedure TFormPrincipal.btnPIXClick(Sender: TObject);
var
  sucesso: boolean;
begin
  RecuperarDadosTEdit;
  TTask.Run(
    procedure
    begin
      sucesso := MultiplusCardTefGP1.VendeCarteiraDigitalPixGP(dValor, iCupom);
      if sucesso then
        lbStatus.Caption := 'Operação concluída com sucesso';
    end);
end;

procedure TFormPrincipal.btnPrivateLabelClick(Sender: TObject);
var
  sucesso: boolean;
begin
  RecuperarDadosTEdit;
  TTask.Run(
    procedure
    begin
      sucesso := MultiplusCardTefGP1.MenuPrivateGP(dValor, iCupom);
      if sucesso then
        lbStatus.Caption := 'Operação concluída com sucesso';
    end);
end;

procedure TFormPrincipal.btnRecargaCelularClick(Sender: TObject);
var
  sucesso: boolean;
begin
  RecuperarDadosTEdit;
  TTask.Run(
    procedure
    begin
      sucesso := MultiplusCardTefGP1.RecargaCelularGP(iCupom);
      if sucesso then
        lbStatus.Caption := 'Operação concluída com sucesso';
    end);
end;

procedure TFormPrincipal.btnReimpressaoClick(Sender: TObject);
var
  sucesso: boolean;
begin
  RecuperarDadosTEdit;
  TTask.Run(
    procedure
    begin
      sucesso := MultiplusCardTefGP1.ReimpressaoGP;
      if sucesso then
        lbStatus.Caption := 'Operação concluída com sucesso';
    end);
end;

procedure TFormPrincipal.btnReimpressaoDiretoClick(Sender: TObject);
var
  sucesso: boolean;
begin
  RecuperarDadosTEdit;
  TTask.Run(
    procedure
    begin
      sucesso := MultiplusCardTefGP1.ReimpressaoDiretoGP(sNSU, Data, iCupom);
      if sucesso then
        lbStatus.Caption := 'Operação concluída com sucesso';
    end);
end;

procedure TFormPrincipal.btnRelatorioClick(Sender: TObject);
var
  sucesso: boolean;
begin
  RecuperarDadosTEdit;
  TTask.Run(
    procedure
    begin
      sucesso := MultiplusCardTefGP1.RelatorioGP(iCupom);
      if sucesso then
        lbStatus.Caption := 'Operação concluída com sucesso';
    end);
end;

procedure TFormPrincipal.btnVendaGenericaClick(Sender: TObject);
var
  sucesso: boolean;
begin
  RecuperarDadosTEdit;
  TTask.Run(
    procedure
    begin
      sucesso := MultiplusCardTefGP1.VendaGenericaGP(dValor, iCupom);
      if sucesso then
        lbStatus.Caption := 'Operação concluída com sucesso';
    end);
end;

// =============================================================================
// CONFIGURAÇÃO E INICIALIZAÇÃO
// =============================================================================

procedure TFormPrincipal.FormCreate(Sender: TObject);
begin
  MultiplusCardTefGP1.Configuracoes.CnpjCliente := 'CnpjCliente';
  MultiplusCardTefGP1.Configuracoes.CnpjParceiro := 'CnpjParceiro';
  MultiplusCardTefGP1.Configuracoes.ILeitor := 0;

  // Preencher com a data de hoje (Usado na Reimpressão Direto)
  txtData.Text := FormatDateTime('dd/mm/yyyy', Date);
end;

// =============================================================================
// EVENTOS TEF DLL com Gerenciador Padrão
// =============================================================================


procedure TFormPrincipal.MultiplusCardTefGP1FalhaOperacao(Sender: TObject;
  const Conteudo: string);
begin
  lbStatus.Font.Color := clRed;
  lbStatus.Caption := Conteudo;
end;

procedure TFormPrincipal.MultiplusCardTefGP1GerarComprovante(Sender: TObject;
  const Retorno: TMultiplusCardRetorno);
begin
  memoComprovante.Lines.Clear;
  memoComprovante.Lines.Add('=== COMPROVANTE GP ===');
  memoComprovante.Lines.Add(Retorno.Comprovante);
  memoComprovante.Lines.Add('================================');
  memoComprovante.Lines.Add(' ');
  memoComprovante.Lines.Add(' ');
  memoComprovante.Lines.Add(' ');
  memoComprovante.Lines.Add('=== COMPROVANTE REDUZIDO GP ===');
  memoComprovante.Lines.Add(Retorno.COMPROVANTE_REDUZIDO);
  memoComprovante.Lines.Add('=========================');
  memoComprovante.Lines.Add(' ');
  memoComprovante.Lines.Add(' ');
  memoComprovante.Lines.Add(' ');
  memoComprovante.Lines.Add('=== COMPROVANTE CLIENTE GP ===');
  memoComprovante.Lines.Add(Retorno.COMPROVANTE_CLIENTE);
  memoComprovante.Lines.Add('=========================');
  memoComprovante.Lines.Add(' ');
  memoComprovante.Lines.Add(' ');
  memoComprovante.Lines.Add(' ');
  memoComprovante.Lines.Add('=== COMPROVANTE ESTABELECIMENTO GP ===');
  memoComprovante.Lines.Add(Retorno.COMPROVANTE_ESTABELECIMENTO);
  memoComprovante.Lines.Add('=========================');
  memoComprovante.Lines.Add(' ');
  memoComprovante.Lines.Add(' ');
  memoComprovante.Lines.Add(' ');
  memoComprovante.Lines.Add('CUPOM: '                  + Retorno.CUPOM);
  memoComprovante.Lines.Add('VALOR: '                  + Retorno.VALOR);
  memoComprovante.Lines.Add('NOME_BANDEIRA: '          + Retorno.NOME_BANDEIRA);
  memoComprovante.Lines.Add('NOME_REDE: '              + Retorno.NOME_REDE);
  memoComprovante.Lines.Add('COD_AUTORIZACAO: '        + Retorno.COD_AUTORIZACAO);
  memoComprovante.Lines.Add('NSU: '                    + Retorno.NSU);
  memoComprovante.Lines.Add('DESC_TIPO_TRANSACAO: '    + Retorno.DESC_TIPO_TRANSACAO);
  memoComprovante.Lines.Add('QTDE_PARCELAS: '          + Retorno.QTDE_PARCELAS);
  memoComprovante.Lines.Add('CONTROLE: '               + Retorno.CONTROLE);
  memoComprovante.Lines.Add('NSU_REDE: '               + Retorno.NSU_REDE);
  memoComprovante.Lines.Add('CNPJ_AUTORIZADORA: '      + Retorno.CNPJ_AUTORIZADORA);
  memoComprovante.Lines.Add('NUMERO_CARTAO: '          + Retorno.NUMERO_CARTAO);
  memoComprovante.Lines.Add('NOME_CLIENTE: '           + Retorno.NOME_CLIENTE);
  memoComprovante.Lines.Add('VENCTO_CARTAO: '          + Retorno.VENCTO_CARTAO);
  memoComprovante.Lines.Add('TEXTO_ESPECIAL: '         + Retorno.TEXTO_ESPECIAL);
  memoComprovante.Lines.Add('FINALIZAÇÃO/ID PGTO: '    + Retorno.E2E);

  memoComprovante.Lines.Add('MensagemSucesso: '        + Retorno.MensagemSucesso);
  memoComprovante.Lines.Add('================================');
  memoComprovante.Lines.Add('ConteudoOriginalSucesso: '+ Retorno.ConteudoOriginalSucesso);
end;

procedure TFormPrincipal.MultiplusCardTefGP1Msg(Sender: TObject;
  const Conteudo: string);
begin
  lbStatus.Font.Color := clBlack;
  lbStatus.Caption := Conteudo;
end;

procedure TFormPrincipal.MultiplusCardTefGP1RegistrarLog(Sender: TObject;
  const Conteudo: string);
begin
  MemoLog.Lines.Add(FormatDateTime('hh:nn:ss', Now) + ' - ' + Conteudo);
end;

end.
