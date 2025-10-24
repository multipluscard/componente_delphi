unit MultiplusCardUtils;

//==============================================================================
// UNIT DE FUNÇÕES UTILITÁRIAS
// Contém funções auxiliares para manipulação de arquivos, texto, JSON e logs
//==============================================================================

interface

uses
  System.SysUtils,
  System.Classes,
  System.RegularExpressions,
  System.JSON,
  Winapi.Windows,
  Vcl.Forms;

//==============================================================================
// DECLARAÇÃO DAS FUNÇÕES UTILITÁRIAS
//==============================================================================

// Funções de Texto e Regex
function ExtrairValor(const ATexto, APattern: string): string;
function URLEncode(const S: string): string;
function DecodeUnicodeEscapes(const AText: string): string;

// Funções Auxiliares para JSON
function GetJSONStringValue(AJSON: TJSONObject; const AName: string): string;
function GetJSONIntValue(AJSON: TJSONObject; const AName: string): Integer;
function GetJSONBoolValue(AJSON: TJSONObject; const AName: string): Boolean;
function GetJSONFloatValue(AJSON: TJSONObject; const AName: string): Currency;

implementation

//==============================================================================
// IMPLEMENTAÇÃO - FUNÇÕES DE TEXTO E REGEX
//==============================================================================

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

function URLEncode(const S: string): string;
var
  I: Integer;
  Ch: Char;
begin
  Result := '';
  for I := 1 to Length(S) do
  begin
    Ch := S[I];
    if Ch in [' ', '!', '*', '''', '(', ')', ';', ':', '@', '&', '=', '+', '$',
          ',', '/', '?', '%', '#', '[', ']'] then
      Result := Result + '%' + IntToHex(Ord(Ch), 2)
    else
      Result := Result + Ch;
  end;
end;

function DecodeUnicodeEscapes(const AText: string): string;
var
  I: Integer;
  UnicodeCode: string;
  CharCode: Integer;
begin
  Result := AText;
  I := 1;

  while I <= Length(Result) do
  begin
    if (I <= Length(Result) - 5) and (Copy(Result, I, 2) = '\u') then
    begin
      // Extrai o código Unicode (4 dígitos hex)
      UnicodeCode := Copy(Result, I + 2, 4);
      if TryStrToInt('$' + UnicodeCode, CharCode) then
      begin
        // Substitui o escape pelo caractere
        Delete(Result, I, 6);
        Insert(Chr(CharCode), Result, I);
      end;
    end;
    Inc(I);
  end;
end;

//==============================================================================
// IMPLEMENTAÇÃO - FUNÇÕES AUXILIARES PARA JSON
//==============================================================================

function GetJSONStringValue(AJSON: TJSONObject; const AName: string): string;
var
  JSONValue: TJSONValue;
begin
  Result := '';
  if Assigned(AJSON) then
  begin
    JSONValue := AJSON.GetValue(AName);
    if Assigned(JSONValue) and not (JSONValue is TJSONNull) then
      Result := JSONValue.Value;
  end;
end;

function GetJSONIntValue(AJSON: TJSONObject; const AName: string): Integer;
var
  JSONValue: TJSONValue;
begin
  Result := 0;
  if Assigned(AJSON) then
  begin
    JSONValue := AJSON.GetValue(AName);
    if Assigned(JSONValue) and not (JSONValue is TJSONNull) then
      Result := StrToIntDef(JSONValue.Value, 0);
  end;
end;

function GetJSONBoolValue(AJSON: TJSONObject; const AName: string): Boolean;
var
  JSONValue: TJSONValue;
begin
  Result := False;
  if Assigned(AJSON) then
  begin
    JSONValue := AJSON.GetValue(AName);
    if Assigned(JSONValue) and not (JSONValue is TJSONNull) then
      Result := (JSONValue is TJSONTrue) or (UpperCase(JSONValue.Value) = 'TRUE');
  end;
end;

function GetJSONFloatValue(AJSON: TJSONObject; const AName: string): Currency;
var
  JSONValue: TJSONValue;
begin
  Result := 0;
  if Assigned(AJSON) then
  begin
    JSONValue := AJSON.GetValue(AName);
    if Assigned(JSONValue) and not (JSONValue is TJSONNull) then
      Result := StrToCurrDef(JSONValue.Value, 0, TFormatSettings.Invariant);
  end;
end;


end.
