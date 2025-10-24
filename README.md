# MultiplusCard - Documentação Componente Delphi

## Visão Geral

O **Componente da MultiplusCard** é uma suíte completa para integração TEF em aplicações Delphi, oferecendo três modalidades distintas de pagamento:

- **TMultiplusCardTef**: TEF via DLL (Modo Interativo)
- **TMultiplusCardTefGP**: TEF via DLL (Gerenciador de Pagamentos)
- **TMultiplusCardPinPDV**: Pagamentos diretos via API REST (POS-TEF e Pré-venda)  

Todas as modalidades compartilham uma interface unificada e sistema de eventos consistente.
  
---

## 🚀 Instalação Rápida

1. **Baixe o código fonte** do projeto MultiplusCard
2. **Compile o package** `MultiplusCard.bpl` no Delphi
3. **Instale o package** no IDE (Component → Install Packages)
4. **Adicione os componentes** ao seu formulário conforme a modalidade desejada

---

# 🪙 TMultiplusCardTef - TEF via DLL (Modo Interativo)

Componente para integração com TEF através de DLL, oferecendo todas as operações TEF clássicas com controle total do fluxo via eventos.

> **Importante:** para o correto funcionamento do componente **TMultiplusCardTef**, certifique-se de que o parâmetro `ConfirmacaoAutomatica=SIM` esteja definido no arquivo de configuração `ClientD\CliMC.ini`.

## ⚙️ Configuração Inicial

```pascal
uses
  MultiplusCardTef, MultiplusCardCommons, MultiplusCardUtils;

procedure TForm1.FormCreate(Sender: TObject);
begin
  // Configuração obrigatória
  MultiplusCardTef1.Configuracoes.CnpjEmpresa   := '12.345.678/0001-90';
  MultiplusCardTef1.Configuracoes.CodigoLoja    := '001';
  MultiplusCardTef1.Configuracoes.PontoDeVenda  := '001';
  MultiplusCardTef1.Configuracoes.Data          := FormatDateTime('yyyyMMdd', Now);
  
  // Opção de interface
  MultiplusCardTef1.Configuracoes.UsaFormPadrao := False; // True = UI automática
end;
```

**Observação**: Caso queira utilizar a UI exclusiva do seu sistema, nessa parte de configurações defina "MultiplusCardTef1.Configuracoes.UsaFormPadrao := False" e implemente o evento "OnSolicitarInteracao". Deixando "MultiplusCardTef1.Configuracoes.UsaFormPadrao := True" será utilizado a UI automática do próprio componente.

---

## 💳 Executando Transações TEF

### Uma chamada faz tudo

```pascal
procedure TForm1.ExecutarTEF;
var
  Sucesso: Boolean;
begin
  Sucesso := MultiplusCardTef1.EfetuaTransacao(
    tpiComando_CREDITO_A_VISTA,  // Tipo da operação
    '123456',                    // Número do cupom
    '123456',                    // NSU
    '25,90',                     // Valor
    1,                           // Parcelas
    ''                           // Parâmetros extras
  );
  
  // O resultado real vem nos EVENTOS, não no retorno booleano
end;
```

### Operações TEF Disponíveis

- `tpiComando_CREDITO` - Crédito
- `tpiComando_CREDITO_A_VISTA` - Crédito à vista
- `tpiComando_CREDITO_PARC_LOJA` - Crédito parc. loja
- `tpiComando_CREDITO_PARC_ADM` - Crédito parc. administradora
- `tpiComando_DEBITO` - Débito
- `tpiComando_DEBITO_A_VISTA` - Débito à vista
- `tpiComando_FROTA` - Frota
- `tpiComando_VOUCHER` - Voucher
- `tpiComando_PRE_AUTORIZACAO` - Pré-Autorização
- `tpiComando_CONF_PRE_AUTORIZACAO` - Confirmar Pré-Autorização
- `tpiComando_CANC_PRE_AUTORIZACAO` - Cancelar Pré-Autorização
- `tpiComando_CONSULTA_SALDO_CREDITO` - Consulta Saldo Crédito
- `tpiComando_CONSULTA_SALDO_DEBITO` - Consulta Saldo Débito
- `tpiComando_EXCLUIR_BINS` - Excluir Bins
- `tpiComando_REIMPRESSAO` - Reimpressão
- `tpiComando_COLETA_DE_CPF` - Coleta de CPF
- `tpiComando_OPCOES_PSP` - PIX (Retorna menu com os PSP)
- `tpiComando_PSP_CLIENTE` - PIX (PSP padrão do cliente)
- `tpiComando_MERCADO_PAGO` - PIX (Mercado Pago)
- `tpiComando_PICPAY` - PIX (PicPay)
- `tpiComando_ESTORNO` - Cancelamento/Estorno
- `tpiComando_ESTORNO_PIX` - Cancelamento/Estorno PIX
- `tpiComando_STATUS_TRANSACAO_PIX` - Status Transação PIX
- `tpiComando_LIMPEZA_TABELA` - Limpeza de Tabelas
- `tpiComando_REALATORIO_TRANSACOES` - Relatório de vendas
- `tpiComando_POS_TEF` - POS Tef
- `tpiComando_REMOVE_PIX` - Remove PIX
- `tpiComando_REIMPRESSAO_PIX` - Reimpressão PIX
- `tpiComando_COMPROVANTE_POS` - Comprovante POS
- `tpiComando_STATUS_POS_TEF` - Reimpressão
- `tpiComando_CANCELAR_POS_TEF` - Status POS Tef
- `tpiComando_PRE_VENDA` - Pré venda
- `tpiComando_STATUS_PRE_VENDA` - Status Pré venda
- `tpiComando_CANCELAR_PRE_VENDA` - Cancelar Pré venda
- `tpiComando_CONFIRMA_TRANSACAO` - Confirmar transação
- `tpiComando_DESFAZ_TRANSACAO` - Desfazer transação
- `tpiComando_STATUS_PINPAD` - Status pinpad
- `tpiComando_INFORMACAO_PINPAD` - Informações pinpad

## 🎯 Eventos Essenciais TEF

### 📄 OnGerarComprovante - Retorno das Transações

```pascal
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

  memoComprovante.Lines.Add('CUPOM: '                  + Retorno.CUPOM);
  memoComprovante.Lines.Add('VALOR: '                  + Retorno.VALOR);
  memoComprovante.Lines.Add('COD_BANDEIRA: '           + Retorno.COD_BANDEIRA);
  memoComprovante.Lines.Add('COD_REDE: '               + Retorno.COD_REDE);
  memoComprovante.Lines.Add('COD_AUTORIZACAO: '        + Retorno.COD_AUTORIZACAO);
  memoComprovante.Lines.Add('NSU: '                    + Retorno.NSU);
  memoComprovante.Lines.Add('QTDE_PARCELAS: '          + Retorno.QTDE_PARCELAS);
  memoComprovante.Lines.Add('TAXA_SERVICO: '           + Retorno.TAXA_SERVICO);
  memoComprovante.Lines.Add('BIN_CARTAO: '             + Retorno.BIN_CARTAO);
  memoComprovante.Lines.Add('ULTIMOS_DIGITOS_CARTAO: ' + Retorno.ULTIMOS_DIGITOS_CARTAO);
  memoComprovante.Lines.Add('CNPJ_AUTORIZADORA: '      + Retorno.CNPJ_AUTORIZADORA);
  memoComprovante.Lines.Add('NOME_CLIENTE: '           + Retorno.NOME_CLIENTE);
  memoComprovante.Lines.Add('NSU_REDE: '               + Retorno.NSU_REDE);
  memoComprovante.Lines.Add('NUM_VIAS_COMPROVANTE: '   + Retorno.NUM_VIAS_COMPROVANTE);
  memoComprovante.Lines.Add('VENCTO_CARTAO: '          + Retorno.VENCTO_CARTAO);
  memoComprovante.Lines.Add('NOME_BANDEIRA: '          + Retorno.NOME_BANDEIRA);
  memoComprovante.Lines.Add('NOME_REDE: '              + Retorno.NOME_REDE);
  memoComprovante.Lines.Add('CARTAO_PRE_PAGO: '        + Retorno.CARTAO_PRE_PAGO);
  memoComprovante.Lines.Add('COD_TIPO_TRANSACAO: '     + Retorno.COD_TIPO_TRANSACAO);
  memoComprovante.Lines.Add('DESC_TIPO_TRANSACAO: '    + Retorno.DESC_TIPO_TRANSACAO);
  memoComprovante.Lines.Add('E2E (PIX): '              + Retorno.E2E);
end;
```

### 📢 OnMsg - Interface do Usuário (CRÍTICO)

```pascal
procedure TForm1.MultiplusCardTef1Msg(Sender: TObject; const Conteudo: string);
begin
  // Mensagens para guiar o usuário durante a transação
  if StartsText('[MSG]', Conteudo) then
  begin
    lblStatus.Caption := Copy(Conteudo, 7, Length(Conteudo));
    lblStatus.Font.Color := clBlue;
  end
  else if StartsText('[ERRODISPLAY]', Conteudo) then
  begin
    lblStatus.Caption := Copy(Conteudo, 15, Length(Conteudo));
    lblStatus.Font.Color := clRed;
  end
  else if StartsText('[RETORNO]', Conteudo) then
  begin
    lblStatus.Caption := 'Transação realizada com sucesso!';
    lblStatus.Font.Color := clGreen;
  end;  
end;
```

### ❌ OnFalhaOperacao - Tratamento de Erros

```pascal
procedure TForm1.MultiplusCardTef1FalhaOperacao(Sender: TObject; 
  const Conteudo: string);
begin
  ShowMessage('Erro na transação: ' + Conteudo);
  // Resetar interface do usuário
  lblStatus.Caption := 'Pronto para nova transação';
end;
```

## 📊 Relatórios de Transações TEF

### Executando Relatório

```pascal
procedure TForm1.BuscarRelatorio;
var
  Parametros: string;
begin
  // Para JSON
  Parametros := 'DATAINICIO=24/09/2025;DATAFIM=24/09/2025;HORAINICIO=00:00:00;HORAFIM=23:59:59;PDV=1;JSON=SIM;PAGINA=1';
  
  // Para CSV
  // Parametros := 'DATAINICIO=24/09/2025;DATAFIM=24/09/2025;HORAINICIO=00:00:00;HORAFIM=23:59:59;PDV=1;JSON=NAO;PAGINA=1';
  
  MultiplusCardTef1.EfetuaTransacao(
    tpiComando_REALATORIO_TRANSACOES,
    '123456',      // Cupom
    '123456',      // NSU  
    '1,00',        // Valor
    1,             // Parcelas
    Parametros
  );
end;
```

### Processando Retorno do Relatório

```pascal
procedure TForm1.MultiplusCardTef1RelatorioTransacoes(Sender: TObject;
  const Retorno: TMultiplusCardRetornoList);
var
  I: Integer;
  Transacao: TMultiplusCardRetorno;
begin
  memoComprovante.Lines.Clear;
  memoComprovante.Lines.Add('=== RELATÓRIO DE TRANSAÇÕES ===');
  memoComprovante.Lines.Add('Total de transações: ' + IntToStr(Retorno.Count));
  memoComprovante.Lines.Add('=========================');

  // Loop pela lista de transações
  for I := 0 to Retorno.Count - 1 do
  begin
    Transacao := Retorno[I];
    memoComprovante.Lines.Add('--- TRANSAÇÃO '              + IntToStr(I + 1) + ' ---');
    memoComprovante.Lines.Add('NOME_REDE: '                 + Transacao.NOME_REDE);
    memoComprovante.Lines.Add('NOME_BANDEIRA: '             + Transacao.NOME_BANDEIRA);
    memoComprovante.Lines.Add('DESC_TIPO_TRANSACAO: '       + Transacao.DESC_TIPO_TRANSACAO);
    memoComprovante.Lines.Add('NSU: '                       + Transacao.NSU);
    memoComprovante.Lines.Add('DATA_HORA_ESTABELECIMENTO: ' + Transacao.DATA_HORA_ESTABELECIMENTO);
    memoComprovante.Lines.Add('DATA_HORA_ADMINISTRADORA: '  + Transacao.DATA_HORA_ADMINISTRADORA);
    memoComprovante.Lines.Add('VALOR: '                     + Transacao.VALOR);
    memoComprovante.Lines.Add('TAXA_SERVICO: '              + Transacao.TAXA_SERVICO);
    memoComprovante.Lines.Add('NUMERO_CARTAO: '             + Transacao.NUMERO_CARTAO);
    memoComprovante.Lines.Add('COD_AUTORIZACAO: '           + Transacao.COD_AUTORIZACAO);
    memoComprovante.Lines.Add('NSU_REDE: '                  + Transacao.NSU_REDE);
    memoComprovante.Lines.Add('STATUS: '                    + Transacao.STATUS);
    memoComprovante.Lines.Add('QTDE_PARCELAS: '             + Transacao.QTDE_PARCELAS);
    memoComprovante.Lines.Add('TERMINAL: '                  + Transacao.TERMINAL);
    memoComprovante.Lines.Add('');
  end;
end;
```

## 🔧 Recursos Específicos TEF

### OnSolicitarInteracao
```pascal
procedure TForm1.MultiplusCardTef1SolicitarInteracao(Sender: TObject;
  const Solicitacao: TSolicitacaoUsuario; var Resposta: TRespostaUsuario);
begin
  var resp : TRespostaUsuario;
  case Solicitacao.Tipo of
    tsPergunta:
      begin
        var perguntaDll := ExtrairDadosPergunta(Solicitacao.Mensagem);
        var respostaTxt : String;
        var respondeu := InputQuery(perguntaDll.TextoPergunta, perguntaDll.TipoDado, respostaTxt);
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
        var respondeu := InputQuery(menuDll.TituloMenu, menuItensTxt, respostaTxt);
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
```

### Cancelar Fluxo

```pascal
procedure TForm1.BtnCancelarTEF;
begin
  MultiplusCardTef1.CancelarFluxo;
end;
```

### Outros Eventos Úteis TEF

```pascal
// Coleta de CPF
procedure TForm1.MultiplusCardTef1CpfInformado(Sender: TObject;
  const Conteudo: string);
begin
  memoLog.Lines.Add('CPF coletado: ' + Conteudo);
end;

// Retorno com QR Code para PIX
//ExibirQrCode no arquivo CliMC.ini
{
0 Retorno por string para a automação realizar a exibição em uma janela personalizada.
1 Exibe no Pinpad e em uma janela padrão.  (JANELA CRIADA PELA DLL, SEM RELAÇÃO COM COMPONENTE)
2 Exibe apenas na janela padrão.           (JANELA CRIADA PELA DLL, SEM RELAÇÃO COM COMPONENTE)
3 Exibe apenas no Pinpad
}
procedure TForm1.MultiplusCardTef1QrCodeGerado(Sender: TObject;
  const Conteudo: string);
begin
  memoLog.Lines.Add('Retorno com QRCode: ' + Conteudo);
end;

// Informações do Pinpad
procedure TForm1.MultiplusCardTef1Pinpad(Sender: TObject;
  const Conteudo: string);
begin
  memoLog.Lines.Add('Pinpad: ' + Conteudo);
end;

// Logs detalhados
procedure TForm1.MultiplusCardTef1RegistrarLog(Sender: TObject;
  const Conteudo: string);
begin
  memoDebug.Lines.Add(FormatDateTime('hh:nn:ss', Now) + ' - ' + Conteudo);
end;
```

---

# 💼 TMultiplusCardTefGP - TEF via DLL (Gerenciador de Pagamentos)

Componente para integração com TEF através do Gerenciador de Pagamentos, oferecendo operações TEF simplificadas.

## ⚙️ Configuração Inicial GP

```pascal
uses
  MultiplusCardTefGP, MultiplusCardCommons;

procedure TForm1.FormCreate(Sender: TObject);
begin
  // Configuração obrigatória
  MultiplusCardTefGP1.Configuracoes.CnpjCliente  := '12.345.678/0001-90';
  MultiplusCardTefGP1.Configuracoes.CnpjParceiro := '98.765.432/0001-10';
  MultiplusCardTefGP1.Configuracoes.ILeitor      := 0;
end;
```

---

## 💳 Executando Transações TEF GP

### Exemplos de Operações

```pascal
// Crédito à vista
procedure TForm1.ExecutarCreditoVista;
begin
  if MultiplusCardTefGP1.VendeCreditoVistaGP(25.90, 123456) then
    ShowMessage('Transação realizada com sucesso!');
end;

// Crédito parcelado loja
procedure TForm1.ExecutarCreditoParceladoLoja;
begin
  if MultiplusCardTefGP1.VendeCreditoParcLojaGP(150.00, 123456, 3) then
    ShowMessage('Transação realizada com sucesso!');
end;

// Débito
procedure TForm1.ExecutarDebito;
begin
  if MultiplusCardTefGP1.VendeDebitoGP(50.00, 123456) then
    ShowMessage('Transação realizada com sucesso!');
end;

// PIX
procedure TForm1.ExecutarPix;
begin
  if MultiplusCardTefGP1.VendeCarteiraDigitalPixGP(75.50, 123456) then
    ShowMessage('Transação realizada com sucesso!');
end;

// Cancelamento
procedure TForm1.ExecutarCancelamento;
var
  Controle: string;
begin
  Controle := '12345'; // Código de controle da transação original
  if MultiplusCardTefGP1.CancelarGP(25.90, 123456, Controle) then
    ShowMessage('Cancelamento realizado com sucesso!');
end;
```

### Operações GP Disponíveis

- `VendeCreditoGP` - Crédito
- `VendeCreditoVistaGP` - Crédito à vista
- `VendeCreditoParcLojaGP` - Crédito parcelado loja
- `VendeCreditoParcAdmGP` - Crédito parcelado administradora
- `VendeDebitoGP` - Débito
- `VendeDebitoAVistaGP` - Débito à vista
- `VendaGenericaGP` - Venda genérica
- `MenuPrivateGP` - Menu private
- `VendeFrotaCompletoGP` - Venda frota completo
- `LinkPagamentoGP` - Link de pagamento
- `ListarLinkPagamentoPagoGP` - Listar links de pagamento
- `ManutencaoLinkPagamentoGP` - Manutenção de links de pagamento
- `CancelarGP` - Cancelamento
- `ReimpressaoGP` - Reimpressão
- `ReimpressaoDiretoGP` - Reimpressão direta
- `VendeCarteiraDigitalPixGP` - PIX
- `RecargaCelularGP` - Recarga de celular
- `ParceleMaisGP` - Parcele Mais
- `RelatorioGP` - Relatório
- `AtvGP` - ATV
- `AdmGP` - ADM

## 🎯 Eventos GP

### 📄 OnGerarComprovante - Retorno GP

```pascal
procedure TForm1.MultiplusCardTefGP1GerarComprovante(Sender: TObject;
  const Retorno: TMultiplusCardRetorno);
begin
  memoComprovante.Lines.Clear;
  memoComprovante.Lines.Add('=== COMPROVANTE GP ===');
  memoComprovante.Lines.Add(Retorno.COMPROVANTE);
  memoComprovante.Lines.Add('=====================');  
  memoComprovante.Lines.Add(' ');
  memoComprovante.Lines.Add('=== COMPROVANTE REDUZIDO GP ===');
  memoComprovante.Lines.Add(Retorno.COMPROVANTE_REDUZIDO);
  memoComprovante.Lines.Add('=========================');
  memoComprovante.Lines.Add(' ');
  memoComprovante.Lines.Add('=== COMPROVANTE CLIENTE GP ===');
  memoComprovante.Lines.Add(Retorno.COMPROVANTE_CLIENTE);
  memoComprovante.Lines.Add('=========================');
  memoComprovante.Lines.Add(' ');
  memoComprovante.Lines.Add('=== COMPROVANTE ESTABELECIMENTO GP ===');
  memoComprovante.Lines.Add(Retorno.COMPROVANTE_ESTABELECIMENTO);
  memoComprovante.Lines.Add('=========================');

  memoComprovante.Lines.Add('CUPOM: '             + Retorno.CUPOM);
  memoComprovante.Lines.Add('VALOR: '             + Retorno.VALOR);
  memoComprovante.Lines.Add('NOME_BANDEIRA: '     + Retorno.NOME_BANDEIRA);
  memoComprovante.Lines.Add('NOME_REDE: '         + Retorno.NOME_REDE);
  memoComprovante.Lines.Add('COD_AUTORIZACAO: '   + Retorno.COD_AUTORIZACAO);
  memoComprovante.Lines.Add('NSU: '               + Retorno.NSU);
  memoComprovante.Lines.Add('DESC_TIPO_TRANSACAO: ' + Retorno.DESC_TIPO_TRANSACAO);
  memoComprovante.Lines.Add('QTDE_PARCELAS: '     + Retorno.QTDE_PARCELAS);
  memoComprovante.Lines.Add('CONTROLE: '          + Retorno.CONTROLE);
  memoComprovante.Lines.Add('NSU_REDE: '          + Retorno.NSU_REDE);
  memoComprovante.Lines.Add('CNPJ_AUTORIZADORA: ' + Retorno.CNPJ_AUTORIZADORA);
  memoComprovante.Lines.Add('NUMERO_CARTAO: '     + Retorno.NUMERO_CARTAO);
  memoComprovante.Lines.Add('NOME_CLIENTE: '      + Retorno.NOME_CLIENTE);
  memoComprovante.Lines.Add('VENCTO_CARTAO: '     + Retorno.VENCTO_CARTAO);
  memoComprovante.Lines.Add('TEXTO_ESPECIAL: '    + Retorno.TEXTO_ESPECIAL);
  memoComprovante.Lines.Add('E2E (PIX): '         + Retorno.E2E);
end;
```

### Outros Eventos GP

```pascal
// Mensagens
procedure TForm1.MultiplusCardTefGP1Msg(Sender: TObject;
  const Conteudo: string);
begin
  lblStatus.Caption := Conteudo;
end;

// Erros
procedure TForm1.MultiplusCardTefGP1FalhaOperacao(Sender: TObject;
  const Conteudo: string);
begin
  ShowMessage('Erro GP: ' + Conteudo);
end;

// Logs
procedure TForm1.MultiplusCardTefGP1RegistrarLog(Sender: TObject;
  const Conteudo: string);
begin
  memoLog.Lines.Add(FormatDateTime('hh:nn:ss', Now) + ' [GP] - ' + Conteudo);
end;
```

---

# 🏪 TMultiplusCardPinPDV - Pagamentos POS-TEF via API REST

Componente para pagamentos diretos no dispositivo PinPDV através de API REST, com monitoramento automático de transações.

## ⚙️ Configuração PinPDV

```pascal
procedure TForm1.ConfigurarPinPDV;
begin
  MultiplusCardPinPDV1.Configuracoes.BaseURL := 'https://api.pinpdv.com.br';
  MultiplusCardPinPDV1.Configuracoes.Token := 'seu_token_aqui';
  MultiplusCardPinPDV1.Configuracoes.UsaFormPadrao := False; // True = UI automática
  MultiplusCardPinPDV1.Configuracoes.IntervaloVerificacaoAutomatica := 5000; // 5 segundos
end;
```

**Observação**: Caso queira utilizar a UI exclusiva do seu sistema, nessa parte de configurações defina "MultiplusCardPinPDV1.Configuracoes.UsaFormPadrao := False" e implemente o evento "OnSolicitarInteracao". Deixando "MultiplusCardPinPDV1.Configuracoes.UsaFormPadrao := True" será utilizado a UI automática do próprio componente.

---

## 🔧 Gerenciamento de Dispositivos PinPDV

### Listar Dispositivos

```pascal
procedure TForm1.btnListarDispositivosPinPDVClick(Sender: TObject);
var
  Lista: TListaPinPDV;
  I: Integer;
begin
  Lista := MultiplusCardPinPDV1.ListarDispositivosPinPDV;
  try
    cbDispositivos.Clear;
    
    for I := 0 to Lista.Data.Count - 1 do
    begin
      if Lista.Data[I].IsAtivo then
      begin
        cbDispositivos.Items.AddObject(
          Format('%s - %s', [Lista.Data[I].Codigo, Lista.Data[I].Nome]),
          TObject(Lista.Data[I].Id)
        );
      end;
    end;
  finally
    Lista.Free;
  end;
end;
```

### Listar Dispositivos JSON

```pascal
procedure TForm1.btnListarDispositivosPinPDVJSONClick(Sender: TObject);
var
  JSON: TJSONObject;
begin
  JSON := MultiplusCardPinPDV1.ListarDispositivosPinPDVJSON;
  try
    memoJSON.Lines.Text := JSON.Format;
  finally
    JSON.Free;
  end;
end;
```

---

## 💳 Executando Transações POS-TEF

### Com monitoramento automático

```pascal
procedure TForm1.ExecutarPinPDVPosTef;
var
  TransacaoId: Integer;
begin
  // Buscar dispositivos ativos
  var ListaDispositivos := MultiplusCardPinPDV1.ListarDispositivosPinPDV;

  try
    // Usar o primeiro dispositivo ativo
    if ListaDispositivos.Data.Count > 0 then
    begin
      TransacaoId := MultiplusCardPinPDV1.CadastrarPosVendaComMonitoramento(
        ListaDispositivos.Data[0].Id,                   // ID do dispositivo
        'VENDA' + FormatDateTime('ddmmyyhhnnss', Now),  // Identificador único
        'Venda Exemplo',                                // Descrição
        25.90,                                          // Valor
        tpCredito,                                      // Tipo de pagamento
        1                                               // Parcelas
      );

      if TransacaoId > 0 then
        memoLog.Lines.Add('POS TEF cadastrado com ID: ' + IntToStr(TransacaoId))
      else
        memoLog.Lines.Add('Falha ao cadastrar POS TEF');

      // Monitoramento automático via eventos
    end;
  finally
    ListaDispositivos.Free;
  end;
end;
```

### Operações Manuais POS-TEF

```pascal
// Cadastrar sem monitoramento
procedure TForm1.btnCadastrarPosVendaClick(Sender: TObject);
var
  TransacaoId: Integer;
  DispositivoId: Integer;
begin
  DispositivoId := Integer(cbDispositivos.Items.Objects[cbDispositivos.ItemIndex]);
  
  TransacaoId := MultiplusCardPinPDV1.CadastrarPosVenda(
    DispositivoId,
    'VENDA' + FormatDateTime('ddmmyyhhnnss', Now),
    'Venda Manual',
    50.00,
    tpCredito,
    1
  );
  
  if TransacaoId > 0 then
    ShowMessage('POS-TEF cadastrado: ' + IntToStr(TransacaoId))
  else
    ShowMessage('Falha ao cadastrar POS-TEF');
end;

// Consultar POS-TEF
procedure TForm1.btnConsultarPosVendaClick(Sender: TObject);
var
  PosVenda: TPosVenda;
  Identificador: string;
begin
  Identificador := edIdentificador.Text;
  
  PosVenda := MultiplusCardPinPDV1.ConsultarPosVenda(Identificador);
  try
    if Assigned(PosVenda) then
    begin
      memoResultado.Lines.Clear;
      memoResultado.Lines.Add('ID: ' + IntToStr(PosVenda.Id));
      memoResultado.Lines.Add('Identificador: ' + PosVenda.Identificador);
      memoResultado.Lines.Add('Descrição: ' + PosVenda.Descricao);
      memoResultado.Lines.Add('Valor: ' + CurrToStr(PosVenda.Valor));
      memoResultado.Lines.Add('Parcelas: ' + IntToStr(PosVenda.Parcelas));
      memoResultado.Lines.Add('Status: ' + IntToStr(Ord(PosVenda.Status)));
      
      if PosVenda.Vendas.Count > 0 then
      begin
        memoResultado.Lines.Add('');
        memoResultado.Lines.Add('=== VENDAS ===');
        for var I := 0 to PosVenda.Vendas.Count - 1 do
        begin
          memoResultado.Lines.Add('Venda ' + IntToStr(I + 1));
          memoResultado.Lines.Add('  Status: ' + IntToStr(Ord(PosVenda.Vendas[I].Status)));
          
          if PosVenda.Vendas[I].Transacoes.Count > 0 then
          begin
            memoResultado.Lines.Add('  NSU: ' + PosVenda.Vendas[I].Transacoes[0].Dados.NSU);
            memoResultado.Lines.Add('  Autorização: ' + PosVenda.Vendas[I].Transacoes[0].Dados.Autorizacao);
          end;
        end;
      end;
    end;
  finally
    PosVenda.Free;
  end;
end;

// Consultar POS-TEF JSON
procedure TForm1.btnConsultarPosVendaJSONClick(Sender: TObject);
var
  JSON: TJSONObject;
  Identificador: string;
begin
  Identificador := edIdentificador.Text;
  
  JSON := MultiplusCardPinPDV1.ConsultarPosVendaJSON(Identificador);
  try
    memoJSON.Lines.Text := JSON.Format;
  finally
    JSON.Free;
  end;
end;

// Abortar POS-TEF
procedure TForm1.btnAbortarPosVendaClick(Sender: TObject);
var
  Identificador: string;
begin
  Identificador := edIdentificador.Text;
  
  if MultiplusCardPinPDV1.AbortarPosVenda(Identificador) then
    ShowMessage('POS-TEF abortado com sucesso')
  else
    ShowMessage('Falha ao abortar POS-TEF');
end;

// Abortar POS-TEF com Retry
procedure TForm1.btnAbortarPosVendaRetentativaClick(Sender: TObject);
var
  Identificador: string;
begin
  Identificador := edIdentificador.Text;
  
  if MultiplusCardPinPDV1.AbortarRetry(Identificador) then
    ShowMessage('POS-TEF abortado com sucesso')
  else
    ShowMessage('Falha ao abortar POS-TEF');
end;
```

### Operações POS TEF Disponíveis

- `tpNone` - Nenhum tipo específico definido
- `tpDinheiro` - Pagamento em dinheiro
- `tpCredito` - Cartão de crédito
- `tpDebito` - Cartão de débito
- `tpPix` - Pagamento via PIX
- `tpValeRefeicao` - Vale refeição
- `tpValeAlimentacao` - Vale alimentação

---

## 💳 Executando Pré-vendas

### Com monitoramento automático

```pascal
procedure TForm1.ExecutarPreVenda;
var
  PreVendaId: Integer;
begin
  // Buscar dispositivos ativos
  var ListaDispositivos := MultiplusCardPinPDV1.ListarDispositivosPinPDV;
  try
    // Usar o primeiro dispositivo ativo
    if ListaDispositivos.Data.Count > 0 then
    begin
      PreVendaId := MultiplusCardPinPDV1.CadastrarPreVendaComMonitoramento(
        'VENDA' + FormatDateTime('ddmmyyhhnnss', Now),  // Identificador único
        'Pré-venda Exemplo',                            // Descrição
        15.50,                                          // Valor
        1,                                              // Parcelas
        tpCredito,                                      // Tipo de pagamento
        ListaDispositivos.Data[0].Id                    // ID do dispositivo
      );

      if PreVendaId > 0 then
        memoLog.Lines.Add('Pré-venda cadastrada com ID: ' + IntToStr(PreVendaId))
      else
        memoLog.Lines.Add('Falha ao cadastrar pré-venda');

      // Monitoramento automático via eventos
    end;
  finally
    ListaDispositivos.Free;
  end;
end;
```

### Operações Manuais Pré-venda

```pascal
// Cadastrar sem monitoramento
procedure TForm1.btnCadastrarPreVendaClick(Sender: TObject);
var
  PreVendaId: Integer;
  DispositivoId: Integer;
begin
  DispositivoId := Integer(cbDispositivos.Items.Objects[cbDispositivos.ItemIndex]);
  
  PreVendaId := MultiplusCardPinPDV1.CadastrarPreVenda(
    'PREVENDA' + FormatDateTime('ddmmyyhhnnss', Now),
    'Pré-venda Manual',
    100.00,
    1,
    tpCredito,
    DispositivoId
  );
  
  if PreVendaId > 0 then
    ShowMessage('Pré-venda cadastrada: ' + IntToStr(PreVendaId))
  else
    ShowMessage('Falha ao cadastrar pré-venda');
end;

// Consultar Pré-venda
procedure TForm1.btnConsultarPreVendaClick(Sender: TObject);
var
  PreVenda: TPreVenda;
  Identificador: string;
begin
  Identificador := edIdentificador.Text;
  
  PreVenda := MultiplusCardPinPDV1.ConsultarPreVenda(Identificador);
  try
    if Assigned(PreVenda) then
    begin
      memoResultado.Lines.Clear;
      memoResultado.Lines.Add('ID: ' + IntToStr(PreVenda.Id));
      memoResultado.Lines.Add('Identificador: ' + PreVenda.Identificador);
      memoResultado.Lines.Add('Descrição: ' + PreVenda.Descricao);
      memoResultado.Lines.Add('Valor: ' + CurrToStr(PreVenda.Valor));
      memoResultado.Lines.Add('Parcelas: ' + IntToStr(PreVenda.Parcelas));
      memoResultado.Lines.Add('Status: ' + IntToStr(Ord(PreVenda.Status)));
      
      if PreVenda.Vendas.Count > 0 then
      begin
        memoResultado.Lines.Add('');
        memoResultado.Lines.Add('=== VENDAS ===');
        for var I := 0 to PreVenda.Vendas.Count - 1 do
        begin
          memoResultado.Lines.Add('Venda ' + IntToStr(I + 1));
          memoResultado.Lines.Add('  Status: ' + IntToStr(Ord(PreVenda.Vendas[I].Status)));
          
          if PreVenda.Vendas[I].Transacoes.Count > 0 then
          begin
            memoResultado.Lines.Add('  NSU: ' + PreVenda.Vendas[I].Transacoes[0].Dados.NSU);
            memoResultado.Lines.Add('  Autorização: ' + PreVenda.Vendas[I].Transacoes[0].Dados.Autorizacao);
          end;
        end;
      end;
    end;
  finally
    PreVenda.Free;
  end;
end;

// Consultar Pré-venda JSON
procedure TForm1.btnConsultarPreVendaJSONClick(Sender: TObject);
var
  JSON: TJSONObject;
  Identificador: string;
begin
  Identificador := edIdentificador.Text;
  
  JSON := MultiplusCardPinPDV1.ConsultarPreVendaJSON(Identificador);
  try
    memoJSON.Lines.Text := JSON.Format;
  finally
    JSON.Free;
  end;
end;

// Abortar Pré-venda
procedure TForm1.btnAbortarPreVendaClick(Sender: TObject);
var
  Identificador: string;
begin
  Identificador := edIdentificador.Text;
  
  if MultiplusCardPinPDV1.AbortarPreVenda(Identificador) then
    ShowMessage('Pré-venda abortada com sucesso')
  else
    ShowMessage('Falha ao abortar pré-venda');
end;

// Abortar Pré-venda com Retry
procedure TForm1.btnAbortarPreVendaRetentativaClick(Sender: TObject);
var
  Identificador: string;
begin
  Identificador := edIdentificador.Text;
  
  if MultiplusCardPinPDV1.AbortarPreVendaRetry(Identificador) then
    ShowMessage('Pré-venda abortada com sucesso')
  else
    ShowMessage('Falha ao abortar pré-venda');
end;
```

---

## 🎯 Eventos PinPDV

### 📢 OnMsg - Interface do Usuário (CRÍTICO)

```pascal
procedure TForm1.MultiplusCardPinPDV1Msg(Sender: TObject;
  const Conteudo: string);
begin
  lblStatus.Caption := Conteudo;
end;
```

### ❌ OnFalhaOperacao - Erros PinPDV

```pascal
procedure TForm1.MultiplusCardPinPDV1FalhaOperacao(Sender: TObject;
  const Conteudo: string);
begin
  ShowMessage('Erro PinPDV: ' + Conteudo);
  lblStatus.Caption := 'Erro na transação PinPDV';
end;
```

### 📝 OnRegistrarLog - Logs PinPDV

```pascal
procedure TForm1.MultiplusCardPinPDV1RegistrarLog(Sender: TObject;
  const Conteudo: string);
begin
  memoLog.Lines.Add(FormatDateTime('hh:nn:ss', Now) + ' [PINPDV] - ' + Conteudo);
end;
```

### 🖨️ OnSolicitarImpressao - Geração do Cupom

```pascal
procedure TForm1.MultiplusCardPinPDV1SolicitarImpressao(Sender: TObject;
  const PreVenda: TPreVenda);
var
  Comprovante: string;
begin
  // Montar comprovante
  Comprovante := GerarComprovanteFiscal(PreVenda);

  // Enviar para o componente
  MultiplusCardPinPDV1.EnviaDocumentoImpressao(Comprovante);
end;

// Função utilitária para gerar o texto do comprovante
function TForm1.GerarComprovanteFiscal(const PreVenda: TPreVenda): string;
var
  Valor: Currency;
  NSU, Autorizacao, Bandeira, Adquirente, TipoPgto: string;
  Parcelas: Integer;
begin
  Valor := PreVenda.Valor;

  // Identifica a forma de pagamento
  if (PreVenda.Vendas.Count > 0) and (PreVenda.Vendas[0].Transacoes.Count > 0) then
  begin
    with PreVenda.Vendas[0].Transacoes[0] do
    begin
      Valor       := Valor;
      Parcelas    := Parcelas;
      NSU         := Dados.NSU;
      Autorizacao := Dados.Autorizacao;
      Bandeira    := Dados.Bandeira;
      Adquirente  := Dados.Adquirente;

      case TipoPagamento of
        tpCredito: TipoPgto := 'CARTAO CREDITO';
        tpDebito: TipoPgto := 'CARTAO DEBITO';
        tpPix: TipoPgto := 'PIX';
        tpValeRefeicao: TipoPgto := 'VALE REFEICAO';
        tpValeAlimentacao: TipoPgto := 'VALE ALIMENTACAO';
        tpDinheiro: TipoPgto := 'DINHEIRO';
        else       TipoPgto := 'OUTROS';
      end;
    end;
  end;

  // Cabeçalho
  Result := '========= SEM VALOR FISCAL   =========' + #13#10;
  Result := Result + '========= SEM VALOR FISCAL   =========' + #13#10;
  Result := Result + '========= SEM VALOR FISCAL   =========' + #13#10;
  Result := Result + '        EMPRESA EXEMPLO LTDA          ' + #13#10;
  Result := Result + '     CNPJ: 12.345.678/0001-90         ' + #13#10;
  Result := Result + '======================================' + #13#10;

  // Dados gerais
  Result := Result + 'Data/Hora: ' + FormatDateTime('dd/mm/yyyy hh:nn:ss', Now) + #13#10;
  Result := Result + 'Identificador: ' + PreVenda.Identificador + #13#10;
  Result := Result + '--------------------------------------' + #13#10;

  // Totais
  Result := Result + Format('TOTAL R$: %.2f', [Valor]) + #13#10;
  Result := Result + '======================================' + #13#10;

  // Forma de pagamento
  Result := Result + 'Pagamento: ' + TipoPgto + #13#10;
  Result := Result + 'Parcelas: ' + IntToStr(Parcelas) + #13#10;

  // Dados da transação
  if NSU <> '' then
  begin
    Result := Result + '--------------------------------------' + #13#10;
    Result := Result + 'NSU: ' + NSU + #13#10;
    Result := Result + 'Autorização: ' + Autorizacao + #13#10;
    Result := Result + 'Bandeira: ' + Bandeira + #13#10;
    Result := Result + 'Adquirente: ' + Adquirente + #13#10;
  end;

  // Rodapé
  Result := Result + '======================================' + #13#10;
  Result := Result + '      OBRIGADO PELA PREFERÊNCIA!      ' + #13#10;
  Result := Result + '======================================' + #13#10;
  Result := Result + '========= SEM VALOR FISCAL   =========' + #13#10;
  Result := Result + '========= SEM VALOR FISCAL   =========' + #13#10;
  Result := Result + '========= SEM VALOR FISCAL   =========' + #13#10;

  // Pula algumas linhas para corte
  Result := Result + #13#10 + #13#10 + #13#10;
end;
```

### 📄 OnGerarComprovante - Finalização da Transação

```pascal
procedure TForm1.MultiplusCardPinPDV1GerarComprovante(Sender: TObject;
  const Retorno: TMultiplusCardRetorno);
begin
  memoComprovante.Lines.Clear;
  memoComprovante.Lines.Add('=== COMPROVANTE PINPDV ===');
  memoComprovante.Lines.Add(Retorno.COMPROVANTE);
  memoComprovante.Lines.Add('=========================');

  memoComprovante.Lines.Add('VALOR: '             + Retorno.VALOR);
  memoComprovante.Lines.Add('COD_AUTORIZACAO: '   + Retorno.COD_AUTORIZACAO);
  memoComprovante.Lines.Add('NSU: '               + Retorno.NSU);
  memoComprovante.Lines.Add('QTDE_PARCELAS: '     + Retorno.QTDE_PARCELAS);
  memoComprovante.Lines.Add('NSU_REDE: '          + Retorno.NSU_REDE);
  memoComprovante.Lines.Add('NOME_BANDEIRA: '     + Retorno.NOME_BANDEIRA);
  memoComprovante.Lines.Add('NOME_REDE: '         + Retorno.NOME_REDE);
  memoComprovante.Lines.Add('E2E: '               + Retorno.E2E);
  memoComprovante.Lines.Add('SUCESSO: '           + BoolToStr(Retorno.SUCESSO, True));
end;
```

### OnSolicitarInteracao

```pascal
procedure TForm1.MultiplusCardPinPDV1SolicitarInteracao(Sender: TObject;
  const Solicitacao: TSolicitacaoUsuario; var Resposta: TRespostaUsuario);
begin
  var resp : TRespostaUsuario;
  case Solicitacao.Tipo of
    tsPergunta:
      begin
        var perguntaDll := ExtrairDadosPergunta(Solicitacao.Mensagem);
        var respostaTxt : String;
        var respondeu := InputQuery(perguntaDll.TextoPergunta, perguntaDll.TipoDado, respostaTxt);
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
        var respondeu := InputQuery(menuDll.TituloMenu, menuItensTxt, respostaTxt);
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
  MultiplusCardPinPDV1.objUi.ResponderInteracao(resp);
end;
```

### Interromper fluxos PinPDV

```pascal
procedure TForm1.BtnCancelarPosTef;
begin
  MultiplusCardPinPDV1.CancelarFluxoPosTefMonitorado;
end;

procedure TForm1.BtnCancelarPreVenda;
begin
  MultiplusCardPinPDV1.CancelarFluxoPreVendaMonitorado;
end;
```

---

# 🎮 Controles de Interface Compartilhados

## Modo Padrão vs Personalizado

```pascal
// MODO PADRÃO (UsaFormPadrao = True)
// + Implementação mais rápida
// - Menos controle sobre UX
MultiplusCardTef1.Configuracoes.UsaFormPadrao := True;
MultiplusCardPinPDV1.Configuracoes.UsaFormPadrao := True;

// MODO PERSONALIZADO (UsaFormPadrao = False) 
// + Controle total da interface
// + Melhor experiência do usuário
// - Requer implementação do evento OnSolicitarInteracao
MultiplusCardTef1.Configuracoes.UsaFormPadrao := False;
MultiplusCardPinPDV1.Configuracoes.UsaFormPadrao := False;
```

## Interface Personalizada Avançada (OnSolicitarInteracao)

```pascal
procedure TForm1.MultiplusCardTef1SolicitarInteracao(Sender: TObject;
  const Solicitacao: TSolicitacaoUsuario; var Resposta: TRespostaUsuario);
begin
  var resp : TRespostaUsuario;
  case Solicitacao.Tipo of
    tsPergunta:
      begin
        var perguntaDll := ExtrairDadosPergunta(Solicitacao.Mensagem);
        var respostaTxt : String;
        var respondeu := InputQuery(perguntaDll.TextoPergunta, perguntaDll.TipoDado, respostaTxt);
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
        var respondeu := InputQuery(menuDll.TituloMenu, menuItensTxt, respostaTxt);
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
```

---

# ⚡ Resumo de Implementação

## Passos Mínimos por Modalidade

### TEF via DLL (Modo Interativo)
1. **Configurar** CNPJ, Loja, PDV, Data
2. **Implementar** OnGerarComprovante, OnFalhaOperacao, OnRegistrarLog, OnMsg
3. **Chamar** EfetuaTransacao()

### TEF via DLL (Gerenciador de Pagamentos)
1. **Configurar** CnpjCliente, CnpjParceiro, ILeitor
2. **Implementar** OnGerarComprovante, OnFalhaOperacao, OnRegistrarLog, OnMsg
3. **Chamar** métodos GP (VendeCreditoVistaGP, VendeDebitoGP, etc)

### PinPDV POS-TEF
1. **Configurar** BaseURL e Token
2. **Implementar** OnFalhaOperacao, OnRegistrarLog, OnMsg
3. **Listar dispositivos** e **chamar** CadastrarPosVendaComMonitoramento()

### PinPDV Pré-vendas
1. **Configurar** BaseURL e Token
2. **Implementar** OnSolicitarImpressao, OnGerarComprovante, OnFalhaOperacao, OnRegistrarLog, OnMsg
3. **Chamar** CadastrarPreVendaComMonitoramento()

Com estes eventos básicos, você terá uma integração TEF/PINPDV funcional e profissional em sua aplicação Delphi.