unit Unit4;

interface
    //This Version got edited by Menaxerius to switch to Burstnation Wallets
 // Feel free to Support me BURST-Y77Y-HWGC-XSMF-2BPZM
uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, System.UITypes, Vcl.ComCtrls, Types, IOUtils, ShellApi,idHTTP, Vcl.ExtCtrls, Vcl.Clipbrd, StrUtils,  IdBaseComponent,IdComponent;

type
  TForm4 = class(TForm)
    Button1: TButton;
    ListBox1: TListBox;
    Label2: TLabel;
    ComboBox1: TComboBox;
    Label3: TLabel;
    Label4: TLabel;
    Button2: TButton;
    Label7: TLabel;
    Button3: TButton;
    Label5: TLabel;
    Label6: TLabel;
    Button5: TButton;
    Label11: TLabel;
    Label1: TLabel;
    Edit1: TEdit;
    Label8: TLabel;
    procedure Button2Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Label11Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);

  private
    { Private-Deklarationen }
    p: Textfile;
    pool : String;
    port : String;


  public
    { Public-Deklarationen }
     deviceID : String;
  end;

var
  Form4: TForm4;


implementation

{$R *.dfm}
uses BurstWallet2, Unit14;


function isAvxSupported: Boolean;
asm
{$IFDEF CPUX86}
    push ebx
{$ENDIF}
{$IFDEF CPUX64}
    mov r10, rbx
{$ENDIF}
    xor eax, eax
    cpuid
    cmp eax, 1
    jb @not_supported
    mov eax, 1
    cpuid
    and ecx, 018000000h
    cmp ecx, 018000000h
    jne @not_supported
    xor ecx, ecx
    db 0Fh, 01h, 0D0h //XGETBV
    and eax, 110b
    cmp eax, 110b
    jne @not_supported
    mov eax, 1
    jmp @done
@not_supported:
    xor eax, eax
@done:
{$IFDEF CPUX86}
    pop ebx
{$ENDIF}
{$IFDEF CPUX64}
    mov rbx, r10
{$ENDIF}
end;
function IsDirectoryEmpty(const directory : string) : boolean;
 var
   searchRec :TSearchRec;
   oem: cardinal;
 begin

  oem := SetErrorMode(SEM_FAILCRITICALERRORS);
   SetErrorMode(Oem) ;
   try
    result := (FindFirst(directory+'\*.*', faAnyFile, searchRec) = 0) AND
              (FindNext(searchRec) = 0) AND
              (FindNext(searchRec) <> 0) ;
   finally
     FindClose(searchRec) ;
   end;
 end;

 function MyMessageDlg(CONST Msg: string; DlgTypt: TmsgDlgType; button: TMsgDlgButtons;
  Caption: ARRAY OF string; dlgcaption: string): Integer;
var
  aMsgdlg: TForm;
  i: Integer;
  Dlgbutton: Tbutton;
  Captionindex: Integer;
begin
  aMsgdlg := createMessageDialog(Msg, DlgTypt, button);
  aMsgdlg.Caption := dlgcaption;
  aMsgdlg.BiDiMode := bdRightToLeft;
  Captionindex := 0;
  for i := 0 to aMsgdlg.componentcount - 1 Do
  begin
    if (aMsgdlg.components[i] is Tbutton) then
    Begin
      Dlgbutton := Tbutton(aMsgdlg.components[i]);
      if Captionindex <= High(Caption) then
        Dlgbutton.Caption := Caption[Captionindex];
      inc(Captionindex);
    end;
  end;
  Result := aMsgdlg.Showmodal;
end;

procedure GetFilenames(Path: string; Dest: TStrings);
var
  SR: TSearchRec;
begin
try
   if FindFirst(Path+'*.*', faAnyFile, SR) = 0 then
  repeat
    Dest.Add(SR.Name);
  until FindNext(SR) <> 0;
  FindClose(SR);
finally

end;

end;

procedure TForm4.Button1Click(Sender: TObject);
 var
   t : TextFile;
   t3 : TextFile;
   directories: String;
begin
if ListBox1.Items.Count < 1 then
 Showmessage('No plots found. You have to generate plots before mining! Or you have to put your Plots to: X:\Burst\plots or X:\plots\')
else
 begin
  if Label6.Caption = 'none - choose!' then
  Showmessage('You have to choose a pool first')
  else
 begin
   begin
   AssignFile(t3,'miner-burst-1.160705/chosen_port.txt');
    Rewrite(T3);
    Writeln(T3,Edit1.Text);
    CloseFile(t3);
  end;

   begin
    directories:= ListBox1.Items.GetText;
    directories:= StringReplace(directories, '\', '\\', [rfReplaceAll, rfIgnoreCase]);

    directories:= StringReplace(directories, #13#10, '","', [rfReplaceAll, rfIgnoreCase]);
      delete(directories, length(directories), 1);
      delete(directories, length(directories), 1);
      delete(directories, length(directories), 1);

  begin
    AssignFile(t,'miner-burst-1.160705/miner.conf');
    Rewrite(T);
    Writeln(T,'{');
    Writeln(T,'"Mode" : "pool",');
    Writeln(T,'"Server" : "'+Label6.Caption+'",');
    Writeln(T,'"Port" : '+Edit1.Text+',');
    Writeln(T,'');
    Writeln(T,'"UpdaterAddr" : "'+Label6.Caption+'",');
    Writeln(T,'"UpdaterPort" : '+Edit1.Text+',');
    Writeln(T,'');
    Writeln(T,'"InfoAddr" : "'+Label6.Caption+'",');
    Writeln(T,'"InfoPort" : '+Edit1.Text+',');
    Writeln(T,'');
    Writeln(T,'"EnableProxy" : false,');
    Writeln(T,'"ProxyPort" : 8126,');
    Writeln(T,'');
    Writeln(T,'"Paths":');
    Writeln(T,'[');
    Writeln(T,'        "'+directories+'"');
    Writeln(T,'],');
    Writeln(T,'"CacheSize" : 100000,');
    Writeln(T,'"ShowMsg" : false,');
    Writeln(T,'"ShowUpdates" : false,');
    Writeln(T,'');
    Writeln(T,'"Debug" : true,');
    //Writeln(T,'"UseHDDWakeUp" : true,');
    Writeln(T,'');
    Writeln(T,'"SendBestOnly" : true,');
    Writeln(T,'"TargetDeadline": 6048000,');
    Writeln(T,'');
    Writeln(T,'"UseFastRcv" : false,');
    Writeln(T,'"SendInterval" : 100,');
    Writeln(T,'"UpdateInterval" : 950,');
    Writeln(T,'');
    Writeln(T,'"UseLog" : true,');
    Writeln(T,'"ShowWinner" : false,');
    Writeln(T,'"UseBoost" : false,');
    Writeln(T,'');
    Writeln(T,'"WinSizeX" : 80,');
    Writeln(T,'"WinSizeY" : 60');
      Writeln(T,'}');
    CloseFile(T);

    if isAvxSupported = true then
    ShellExecute(0, 'open', PChar('miner-v1.160705_AVX.exe'),PChar('/K'), PChar('miner-burst-1.160705'), SW_SHOW)
     else
     ShellExecute(0, 'open', PChar('miner-v1.160705.exe'),PChar('/K'), PChar('miner-burst-1.160705'), SW_SHOW);

     close;
     end;
     end;
   end;

  end;
end;
procedure TForm4.Button2Click(Sender: TObject);
var
clipboard2: Tclipboard;
idHTTP: TIdHTTP;
dummy: String;

begin
//IdHTTP := TIdHTTP.Create;
 BurstWallet2.Form1.N7.Enabled := True;
 BurstWallet2.Form1.N6.Enabled := True;
if ComboBox1.Text = '' then
Showmessage('Please choose a Pool')

  else
  begin
    begin
     try
     if BurstWallet2.Form1.percentage < 99 then
     Form1.Webbrowser1.Navigate('https://wallet1.burstnation.com:8125/rewardassignmentshort.html')
     else

     Form1.Webbrowser1.Navigate('http://127.0.0.1:8125/rewardassignmentshort.html');
     except
     // Form1.Webbrowser1.Navigate('https://wallet1.burstnation.com:8125/rewardassignmentshort.html')
     end;


Form1.N7.Enabled := True;


clipboard2 := TClipBoard.create;

if Label6.Caption = 'pool.burstcoin.biz' then
    clipboard2.AsText:='BURST-6WVW-2WVD-YXE5-EZBHU';
if Label6.Caption = 'pool.burstcoin.eu' then
    clipboard2.AsText:='BURST-7Z2V-J9CF-NCW9-HWFRY';
if Label6.Caption = 'burst.ninja' then
    clipboard2.AsText:='BURST-7CPJ-BW8N-U4XF-CWW3U';
if  Label6.Caption = 'pool.burstcoin.it' then
     clipboard2.AsText:='BURST-LGKU-3UUM-M6Q5-86SLK';
if  Label6.Caption = 'burst.poolto.be' then
     clipboard2.AsText:='BURST-5AXK-EABZ-7FTB-4NBT9';
if  Label6.Caption = 'mininghere.com' then
     clipboard2.AsText:='BURST-7S5L-6UHX-SVS5-BU6HA';
if  Label6.Caption = 'us-burstpool.broke-it.net' then
     clipboard2.AsText:='BURST-NM25-LV2Y-KXVC-HUZ67';
if  Label6.Caption = 'pool.burst-team.us' then
     clipboard2.AsText:='BURST-32TT-TSAC-HTKW-CC26C';
if  Label6.Caption = 'pool.burstcoin.fr' then
     clipboard2.AsText:='BURST-YNJ6-8XEJ-WKKR-2AHTY';
if  Label6.Caption = 'burstneon.ddns.net' then
     clipboard2.AsText:='BURST-YXZW-JH7M-QKR9-9PKBN';
if  Label6.Caption = 'pool.burstcoin.sk' then
     clipboard2.AsText:='BURST-NACG-ZZDB-BHX7-9ELAF';

  if  Label6.Caption = 'pool.news-asset.com' then
     begin
     clipboard2.AsText:='BURST-GQSC-8NHH-NL2J-7BH4C';
     port := '7080';
     end;
 if  Label6.Caption = '216.165.179.42' then
     begin
     clipboard2.AsText:='BURST-896D-RERK-UXXN-G97ED';
     port := '5080';
     end;
 if  Label6.Caption = 'burst.lexitoshi.uk' then
     begin
     clipboard2.AsText:='BURST-F3XD-Y4M5-SN8C-G9FFJ';
     port := '8124';
     end;
 if  Label6.Caption = 'pool.burstcoinmining.com' then
     begin
     clipboard2.AsText:='BURST-8HDN-MKTJ-GGYV-FY664';
     port := '6080';
     end;
if  Label6.Caption = 'pool.burstcoin.de' then
     begin
     clipboard2.AsText:='BURST-GHTV-7ZP3-DY4B-FPBFA';
     port := '8080';
     end;
if  Label6.Caption = 'burstpool.ddns.net' then
     clipboard2.AsText:='BURST-JGBV-U7YK-SWHM-4P4QS';
if  Label6.Caption = '69.43.42.57' then
     begin
     clipboard2.AsText:='BURST-YEFS-QJ32-K9Z5-HPW7K';
     port := '8080';
     end;
 if  Label6.Caption = 'pool.burstmining.club' then
     clipboard2.AsText:='BURST-RNMB-9FJW-3BJW-F3Z3M';
if  Label6.Caption = 'pool.burstcoinmining.com' then
     begin
     clipboard2.AsText:='BURST-8HDN-MKTJ-GGYV-FY664';
     port := '6080';
     end;
if  Label6.Caption = 'pool.burstcoin.party' then
     begin
     clipboard2.AsText:='BURST-PHJ5-JMZP-3EQQ-EAA2B';
     port := '8081';
     end;
if  Label6.Caption = 'pool.burstcoinmining.com' then
     begin
     clipboard2.AsText:='BURST-8HDN-MKTJ-GGYV-FY664';
     port := '6080';
     end;
if  Label6.Caption = 'pool.burstcoin.ml' then
     begin
     clipboard2.AsText:='BURST-67XA-W9AU-MFGE-DAPPG';
     port := '8020';
     end;
if  Label6.Caption = 'burst.btfg.space' then
     begin
     clipboard2.AsText:='BURST-6YBP-TDPA-27KD-9MQVX';
     port := '8124';
     end;
if  Label6.Caption = 'pool.rapidcoin.club' then
     begin
     clipboard2.AsText:='BURST-X2WJ-RQMQ-SXET-FVAV3';
     port := '6080';
     end;
ShowMessage('The pool address '+clipboard.AsText+' of '+Combobox1.Text+' got copied into your clipboard.'+#13#10+ 'Paste it into the second textbox: "Recipient - Burst address of pool" and paste your wallet passphrase in the first textbox.');

  end;
end;
end;

procedure TForm4.Button5Click(Sender: TObject);
 var
   t2 : TextFile;
   t4 : TextFile;
   directoriesGPU: String;
   address: String;
   addressstring: String;
   idHTTP: TIdHTTP;
   filename : TSearchRec;
   plotDirectory: String;
   platformID : String;
   trigger : boolean;

   buttonSelected: Integer;
begin
  if ListBox1.Items.Count < 1 then
 Showmessage('No plots found. You have to generate plots before mining! Or you have to put your Plots to: X:\Burst\plots or X:\plots\')
else
begin
 begin
   AssignFile(t4,'miner-burst-1.160705/chosen_port.txt');
    Rewrite(T4);
    Writeln(T4,Edit1.Text);
    CloseFile(t4);

 end;


    begin
      if Label6.Caption = 'none - choose!' then
      Showmessage('You have to choose a pool first')
       else

  begin
    directoriesGPU:= ListBox1.Items.GetText;
    directoriesGPU:= StringReplace(directoriesGPU, '\', '/', [rfReplaceAll, rfIgnoreCase]);
    directoriesGPU:= StringReplace(directoriesGPU, #13#10, ',', [rfReplaceAll, rfIgnoreCase]);

    plotDirectory:=(ListBox1.Items[0]);
    //plotDirectory:=StringReplace(plotDirectory, '\', '/', [rfReplaceAll, rfIgnoreCase]);
    plotDirectory:= plotDirectory+'\';
    FindFirst(plotDirectory+'*', faAnyFile-faDirectory, filename);
    FindClose(filename);
    addressstring := Copy(filename.Name, 1, Pos('_', filename.Name) - 1);

   // Show a custom dialog
   platformID:='0';
   deviceID:='0';

   begin
     buttonSelected := MessageDlg('Use your second openCL device to mine?', mtCustom,[mbNo, mbYes], 0);
       if buttonSelected = mrCancel then
     begin

     end;
     if buttonSelected = mrNo then
     begin
       deviceID:='0';
     end;
     if buttonSelected = mrYes then
     begin
       deviceID:='1';
     end;


   end;


    begin
    AssignFile(t2,'burstcoin-jminer-0.4.8-RELEASE/jminer.properties');
    Rewrite(T2);
       Writeln(T2,'plotPaths='+directoriesGPU);
       Writeln(T2,'poolMining=true') ;
       Writeln(T2,'numericAccountId='+addressstring);
       Writeln(T2,'poolServer=http://'+Label6.Caption+':'+Edit1.Text);
       Writeln(T2,'walletServer=http://localhost:8125');
       Writeln(T2,'winnerRetriesOnAsync=');
       Writeln(T2,'winnerRetryIntervalInMs=');
       Writeln(T2,'devPool=false');
       Writeln(T2,'devPoolCommitsPerRound=');
       Writeln(T2,'soloServer=http://localhost:8125');
       Writeln(T2,'passPhrase=xxxxxxxxxxxxxx');
       Writeln(T2,'targetDeadline=');
       Writeln(T2,'platformId='+platformID);
       Writeln(T2,'deviceId='+deviceID);
       Writeln(T2,'chunkPartNonces=320000');
       Writeln(T2,'refreshInterval=2000');
       Writeln(T2,'connectionTimeout=30000');

    CloseFile(T2);
    end;

  ShellExecute(0, 'open', PChar('run.bat'),PChar('/K'), PChar('burstcoin-jminer-0.4.8-RELEASE'), SW_SHOW);
  close;

   end;

  end;
  end;
  end;


procedure TForm4.ComboBox1Change(Sender: TObject);
begin
 AssignFile(p,'miner-burst-1.160705/chosen_pool.txt');
   Rewrite(P);
   Writeln(P,Combobox1.Text);
   CloseFile(P);
//Showmessage('Changes saved');

    pool:=TFile.ReadAllText('miner-burst-1.160705/chosen_pool.txt');
    pool:= StringReplace(pool, #13#10, '', [rfReplaceAll, rfIgnoreCase]);
    Label6.Caption:=(pool);
    Edit1.Text := '8124';

 if  Label6.Caption = 'pool.news-asset.com' then
     begin
     Edit1.Text := '7080';
     end;
 if  Label6.Caption = '216.165.179.42' then
     begin
      Edit1.Text:= '5080';
     end;
 if  Label6.Caption = 'burst.lexitoshi.uk' then
     begin
      Edit1.Text := '8124';
     end;
 if  Label6.Caption = 'pool.burstcoinmining.com' then
     begin
      Edit1.Text := '6080';
     end;
if  Label6.Caption = 'pool.burstcoin.de' then
     begin
      Edit1.Text := '8080';
     end;
if  Label6.Caption = 'pool.devip.xyz' then
     begin
      Edit1.Text := '8080';
     end;
if  Label6.Caption = 'pool.burstcoin.party' then
     begin
      Edit1.Text := '8081';
     end;
if  Label6.Caption = 'pool.burstcoinmining.com' then
     begin
      Edit1.Text := '6080';
     end;
if  Label6.Caption = 'pool.burstcoin.ml' then
     begin
      Edit1.Text := '8020';
     end;
if  Label6.Caption = 'burst.btfg.space' then
     begin
      Edit1.Text := '8124';
     end;
if  Label6.Caption = 'pool.rapidcoin.club' then
     begin
      Edit1.Text := '6080';
     end;



end;

procedure TForm4.FormActivate(Sender: TObject);
var

character: Char;
begin
 try
  try
 ListBox1.Items.Clear;
   For character:= 'Z' downto 'C' do
  if TDirectory.Exists(character+':\Burst\plots') then
  if not IsDirectoryEmpty(character+':\Burst\plots')
  then ListBox1.Items.Add(character+':\Burst\plots');
    if TDirectory.Exists(character+':\plots')   then
   if not IsDirectoryEmpty(character+':\plots')

  then ListBox1.Items.Add(character+':\plots');
  finally
  end;
 except

 end;

   port:=TFile.ReadAllText('miner-burst-1.160705/chosen_port.txt');
   Edit1.Text:= StringReplace(port, #13#10, '', [rfReplaceAll, rfIgnoreCase]);

   pool:=TFile.ReadAllText('miner-burst-1.160705/chosen_pool.txt');
   pool:= StringReplace(pool, #13#10, '', [rfReplaceAll, rfIgnoreCase]);

  if pool = '' then
    else
    Label6.Caption:=(pool);

end;

procedure TForm4.FormHide(Sender: TObject);
begin
ListBox1.Items.Clear;
end;

procedure TForm4.Label11Click(Sender: TObject);
begin
ShellExecute(0, 'open', 'http://burstcoin.biz/faucet', nil, nil, SW_SHOWNORMAL);
end;


end.
