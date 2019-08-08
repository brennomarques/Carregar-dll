unit Unit2;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Buttons, PngSpeedButton,
  Vcl.StdCtrls, System.IniFiles, Vcl.Imaging.pngimage, Vcl.ExtCtrls;

type
  TForm2 = class(TForm)
    PngSpeedButton1: TPngSpeedButton;
    Label1: TLabel;
    Image1: TImage;
    procedure PngSpeedButton1Click(Sender: TObject);
    Function eBuscaNome(dado: String):String;  //função para encontrar nome da seção.[INSTALL...]
    Function eEncontarSecao(ArqIni: TIniFile):String;//função para busca a seção informando o nome para buscar
    procedure eConfiguraDLL(caminho: String);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

{$R *.dfm}
Function TForm2.eBuscaNome(dado: string): String;
var
  varString, nome: string;
  SizeVet, i, x: Integer;
  status: boolean;
begin
  varString:= dado;//recebe dados para realizar o procedimento de busca.
  SizeVet := Length(varString);//saber o tamanho da StringList
  status:= False;
  for i := 0 to SizeVet do//roda até chega no tamnho da SizeVet. o SizeVet esta amarzenado o tamnho da StringList
  begin
    if (varString[i] = '[') and (varString[i+1] = 'I') then
    begin
      x:=i;
      while x <> -1 do
      begin
        //nome:=nome+varString[x];//Variavel nome recebe a possição de X
        if varString[x] = '[' then
        begin
          nome:=nome+varString[x+1];
          x:=x+2; //VAI ANDA 2 CASA NO VETOR DEVIDO A PRIMEIRA NÃO SER ATRIBUIDA.
        end
        else
        begin
          if varString[x] = ']' then
          begin
            x:=-1;
            status:=True;
          end
          else
          begin
            nome:=nome+varString[x];
            x:=x+1;
          end;
        end;
      end;
    end;
  end;
  if status then
  begin
    result:= nome;
  end
  else
  begin
    result:='False';//se não encontra o valor ele retorna nome falso para que posso realizar outro metodo
  end;
end;
Function TForm2.eEncontarSecao(ArqIni: TIniFile):String;
var
 aux, aux1: string;
 i: Integer;
begin
  i:=0;
  while i >=0 do
  begin
    aux1:='Profile'+IntToStr(i);//aux1 recebe a concatenação para String
    aux := ArqIni.ReadString(aux1, 'Default', ''); //aqui vou anda em cada Profile
    if aux = '1' then //se Default for verdadeido ou seja =1
    begin
     //ShowMessage('dentro, Profile' + IntToStr(i));
      aux := ArqIni.ReadString(aux1, 'Path', '');//pega o caminho do profile em uso
      //ShowMessage('Caminho: ' + aux);
      result:=aux;
      i:=-1;//condição de parada, se estava aqui pr achou default logo decrementa I para da stop para condição.
    end
    else//caso se aux não for =1 ele incremento a I.
    begin
      i:=i+1;
    end;
  end;
end;

procedure TForm2.eConfiguraDLL(caminho: String);
var
  Arquivo: TextFile;
  Registro: string;

begin
  if FileExists(caminho+'\PKCS11.txt') then
  begin
    ShowMessage('[PKCS11] Vai ser configurado.');
    AssignFile(Arquivo, caminho+'\PKCS11.txt');//PEGANDO O ARQUIVO PKCS11 PARA GRAVAR
    Append(Arquivo);
    Registro := 'library=etoken.dll';
    Writeln(Arquivo, Registro);
    Registro := 'name=Safenet';
    Writeln(Arquivo, Registro);
    WriteLn(Arquivo,'');//Acrescenta outra linha
    CloseFile(Arquivo);
    Label1.Caption := 'PKCS11 Configurado.';
    Label1.Font.Color := clblue;
  end
  else
  begin
    ShowMessage('[ERROR:] Não foi possível acessar PKCS11');
  end;
end;
procedure TForm2.PngSpeedButton1Click(Sender: TObject);
var//declaração das variaveis
  usuarioname, caminho, aux: String;
  ArqIni: TIniFile;
  varString, varArquivo, nomearq: string;
  StringList: TStringList;
begin
    caminho:= '\AppData\Roaming\Mozilla\Firefox\';//ESSE CAMINHO E ESTATICO DO MOZILLA.
    usuarioname:= GetEnvironmentVariable('userprofile');//LOCALIZO O CAMINHO ONDE A PASTA DO USUARIO LOCAL ESTA.

    if DirectoryExists(usuarioname+caminho) then//SE O DIRETORIO EXITIR FAZ ALTERAÇÃO DO  .INI (usuarioname+caminho E CONCATENAÇÃO DA DUA VARIAVEL)
    begin
      //ShowMessage('Tem o caminho do arquivo');
      if FileExists(usuarioname+caminho+'profiles.ini') then //AQUI VERIFICAO SE TEM O ARQUIVO .INI, PODE ACONTECE.
      begin
        //ShowMessage('Tem o aquivo .ini');
        varArquivo := usuarioname+caminho+'profiles.ini'; //CARREGO O CAMINHO DO ARQUIVO .INI
        ArqIni := TIniFile.Create(varArquivo);//AQUI CARREGO MEU ARQUIVO PARA MEMORIA PARA TER ACESSO MAIS RAPIDO.
        StringList := TStringList.Create;//
        try
          StringList.LoadFromFile(varArquivo);//ESTOU CARREGADO MEU ARQUIVO PARA StringList
          varString := StringList.Text;// Joga arquivo carregado na StringList na variável;
          nomearq:= eBuscaNome(varString);//FUNÇÃO QUE LOCALIZA SEÇÃO [INSTALL...]
          if nomearq ='False' then//AQUI DEFINI QUAL SEÇÃO SERA USADA, SE NÃO TIVER [INSTALL...] VEI SER [PROFILE]
          begin// AQUI NÃO ENCOTROU A SEÇÃO [INSTALL] ENTÃO SERA EXECULTADO A SEÇÃO [PROFILE]
            ShowMessage(' [ERROR] :');
            aux:=eEncontarSecao(ArqIni);//FUNÇÃO BUSCA SEÇÃO [PROFILE] QUE ESTA SENDO USADA.
            ShowMessage('Achou PROFILE: '+aux);
            eConfiguraDLL(usuarioname+caminho+aux);//FUNÇÃO PARA CONFIGURAR DLL
          end
          else
          begin // AQUI EXUELE ENCOTROU A SEÇÃO [INSTALL....]
            aux := ArqIni.ReadString(nomearq, 'Default', '');//AUX RECEBE O CAMINHO DO PERFIL
            eConfiguraDLL(usuarioname+caminho+aux);//FUNÇÃO PARA CONFIGURAR DLL
          end;
        finally
          FreeAndNil(StringList);
        end;
      end
      else
      begin
        ShowMessage('Não foi possível encotrar o PROFILE');
      end;
    end
    else
    begin
      ShowMessage('Não encontrado o caminho');
    end;
end;

end.
