unit tef;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Threading, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  MultiplusCardTef, MultiplusCardCommons, System.Generics.Collections;

type
  TFormPrincipal = class(TForm)
    Button1: TButton;
    Panel1: TPanel;
    Memo1: TMemo;
    Memo2: TMemo;
    MultiplusCardTef1: TMultiplusCardTef;
    procedure Button1Click(Sender: TObject);
    procedure MultiplusCardTef1Msg(Sender: TObject; const Conteudo: string);
    procedure MultiplusCardTef1RegistrarLog(Sender: TObject;
      const Conteudo: string);
    procedure MultiplusCardTef1GerarComprovante(Sender: TObject;
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

//VENDA TEF
procedure TFormPrincipal.Button1Click(Sender: TObject);
  var
    Resultado: Boolean;
begin

  MultiplusCardTef1.Configuracoes.CnpjEmpresa   := 'seu_cnpj';
  MultiplusCardTef1.Configuracoes.CodigoLoja    := 'codigo_loja';
  MultiplusCardTef1.Configuracoes.Data          := FormatDateTime('yyyyMMdd', Now);
  MultiplusCardTef1.Configuracoes.PontoDeVenda  := 'numero_pdv';
  MultiplusCardTef1.Configuracoes.UsaFormPadrao := True;

  TTask.Run(
    procedure
    begin
      Resultado := MultiplusCardTef1.EfetuaTransacao(
        tpiComando_DEBITO_A_VISTA,
        '1234',
        '456',
        '0,10',
        1,
        ''
      );

      // Atualiza interface dentro de Synchronize
      TThread.Synchronize(nil,
        procedure
        begin
          if Resultado then
            Panel1.Caption := 'Transação concluída com sucesso'
          else
            Panel1.Caption := 'Transação cancelada ou falhou';
        end
      );

    end
  );
end;

//COMPROVANTE
procedure TFormPrincipal.MultiplusCardTef1GerarComprovante(Sender: TObject;
  const Retorno: TMultiplusCardRetorno);
begin
  Memo2.Lines.Clear;
  Memo2.Lines.Add('=== COMPROVANTE DLL TEF ===');
  Memo2.Lines.Add(Retorno.COMPROVANTE);
  Memo2.Lines.Add('=========================');
  Memo2.Lines.Add(' ');
  Memo2.Lines.Add('=== COMPROVANTE REDUZIDO DLL TEF ===');
  Memo2.Lines.Add(Retorno.COMPROVANTE_REDUZIDO);
  Memo2.Lines.Add('=========================');
  Memo2.Lines.Add(' ');
  Memo2.Lines.Add('=== COMPROVANTE CLIENTE DLL TEF ===');
  Memo2.Lines.Add(Retorno.COMPROVANTE_CLIENTE);
  Memo2.Lines.Add('=========================');
  Memo2.Lines.Add(' ');
  Memo2.Lines.Add('=== COMPROVANTE ESTABELECIMENTO DLL TEF ===');
  Memo2.Lines.Add(Retorno.COMPROVANTE_ESTABELECIMENTO);
  Memo2.Lines.Add('=========================');
  Memo2.Lines.Add(' ');

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
  Memo2.Lines.Add('E2E (PIX): '              + Retorno.E2E);
end;

//LOG
procedure TFormPrincipal.MultiplusCardTef1RegistrarLog(Sender: TObject;
  const Conteudo: string);
begin
  Memo1.Lines.Add(Conteudo);
end;

//MSG USUARIO

procedure TFormPrincipal.MultiplusCardTef1Msg(Sender: TObject; const Conteudo: string);
begin
  Panel1.Caption := Conteudo;
end;



end.
