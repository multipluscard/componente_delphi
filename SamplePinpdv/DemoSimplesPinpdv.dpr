program DemoSimplesPinpdv;

uses
  Vcl.Forms,
  pinpdv in 'pinpdv.pas' {FormPrincipal};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormPrincipal, FormPrincipal);
  Application.Run;
end.
