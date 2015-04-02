(*$A+,B-,D+,E+,F-,G-,I+,L+,N-,O-,P-,Q-,R-,S+,T-,V+,X+*)
(*$M 16384,70000,70000*)
(*&Use32+*)
program addcode; (* nach umgebung_freigeben; *)

uses
  Dos,
  (*$IFDEF VirtualPascal*)
  VpUtils,
  (*$ELSE*)
  TpUtils,
  (*$ENDIF*)
  ac_spra;

(* V.K. 01.07.1997 *) (* auch im Programmtext Ñndern *)
(*      01.11.1997 Neugestaltung fÅr UnterstÅtzung von .BIN (IBMBIO.COM) *)
(*      06.12.1997 korrektes FÅllen mit ^z                              *)
(*      16.12.1997 Sprache                                              *)
(*      11.03.1998 neue unit spra_aus                                   *)
(*      2000.11.09 OS/2-Version                                         *)
(*      2000.12.26 auch wieder TP7-Version                              *)
(*                 Verîffentlichung mit OS2CS                           *)
(*                 Quelltextverschînerung                               *)

(*$IFNDEF VirtualPascal*)
type
  smallword             =word;
(*$ENDIF*)


const
  datum                 ='2000.12.26';
  fuell                 :char=^z;
  pos_0                 :longint=0;

type
  puffer_typ            =array[0..65534] of byte;
  sword_ptr             =^smallword;

var
  datei                 :file;
  ende                  :longint;
  puffer                :array[0..100] of byte;
  puffer_z              :array[0..100] of char absolute puffer;

  exe_kopf:
    record
      sig               :array[1..2] of char;
      mod512,page512,
      relo_anzahl,
      kopfgroesse,
      halde_min,
      halde_max,
      ss,sp,pruef,ip,cs,
      relo_off,overlay  :smallword;
    end;

  cs_100                :array[0..3] of byte;

  sprungdiff            :smallword;
  exelaenge,
  org_exe_laenge,
  halde_diff            :longint;

  org_cs,org_ip         :smallword;

  byte_angehaengt       :word;

  zusatzcode            :^puffer_typ;
  zusatzcode_laenge     :longint;

  gelesen               :word;

(*&OrgName+*)
procedure comfix_bin;external;
(*$IFDEF VirtualPascal*)
(*$L COMFIX32.OBJ*)
(*$ELSE*)
(*$L COMFIX16.OBJ*)
(*$ENDIF*)
const
  comfix_bin_laenge=48;
  comfix_bin_w100_position=$15;
  comfix_bin_w102_position=$1a;

procedure exefix_bin;external;
(*$IFDEF VirtualPascal*)
(*$L EXEFIX32.OBJ*)
(*$ELSE*)
(*$L EXEFIX16.OBJ*)
(*$ENDIF*)
const
  exefix_bin_laenge=32;
  exefix_bin_cs_org=$0d;
  exefix_bin_ip_org=$02;
(*&OrgName-*)

procedure Abbruch(t:string);
  begin
    WriteLn(#7,t);
    Halt(1);
  end;

function zusatz_beschreibung:string;
  var
    beschreibung        :string;
    zaehler             :word;
  begin
    if (zusatzcode^[0]=$86) and (zusatzcode^[1]=$c0) then
      begin
         zaehler:=5;
         beschreibung:=' "';
         while zusatzcode^[zaehler]<>ord(^z) do
           begin
             beschreibung:=beschreibung+chr(zusatzcode^[zaehler]);
             inc(zaehler);
           end;

         zusatz_beschreibung:=beschreibung+'"';
       end
     else
       zusatz_beschreibung:='';
  end;

procedure halde(const w:word);
  begin
    Write(longint(w)*16:8,' [$',Int2Hex(w,SizeOf(w)*2),'0]');
  end;


begin

  WriteLn('AddCode * Veit Kannegieser * 1997.07.01..',datum);
  WriteLn(textz_titel2^);

  New(zusatzcode);
  (**********************************************************************)
  if ParamCount<>2 then
    Abbruch(textz_syntax1^+ParamStr(0)+textz_syntax2^);

  (**********************************************************************)
  Assign(datei,ParamStr(2));
  FileMode:=$40;
  Reset(datei,1);
  zusatzcode_laenge:=FileSize(datei);

  if zusatzcode_laenge>60000 then
    Abbruch(textz_zusatz_zu_gross^);

  BlockRead(datei,zusatzcode^,zusatzcode_laenge);
  Close(datei);
  if (zusatzcode^[0]=ord('M')) and (zusatzcode^[1]=ord('Z'))
  or (zusatzcode^[0]=ord('Z')) and (zusatzcode^[1]=ord('M')) then
    Abbruch(textz_zusatz_ist_exe^);

  (**********************************************************************)
  Assign(datei,ParamStr(1));
  FileMode:=$12;
  SetFAttr(datei,0);
  Reset(datei,1);
  ende:=FileSize(datei);
  if ende=0 then
    Abbruch(textz_null_datei^);

  (**********************************************************************)
  BlockRead(datei,puffer,2,gelesen);
  if
    (gelesen=2)
  and
    ( ((puffer_z[0]='M') and (puffer_z[1]='Z'))
    or
      ((puffer_z[0]='Z') and (puffer_z[1]='M')) )
   then
    begin
      Seek(datei,0);
      Blockread(datei,exe_kopf,$1c); (* KOPF *)
      exelaenge:=longint(exe_kopf.page512)*512;
      if exe_kopf.mod512<>0 then
        dec(exelaenge,512-exe_kopf.mod512);

      if exelaenge<>ende then
        Abbruch(textz_exe_overlays^);

      org_exe_laenge:=exelaenge;

      org_cs:=exe_kopf.cs;
      org_ip:=exe_kopf.ip;

      Seek(datei,ende);

      while (ende and $f)<>0 do
        begin
          BlockWrite(datei,fuell,1);
          Inc(ende);
          Inc(exelaenge);
          Inc(byte_angehaengt);
        end;

      if byte_angehaengt>0 then
        writeln('+ ',byte_angehaengt:7,textz_Byte_aufgefuellt^);


      Inc(ende,exefix_bin_laenge+zusatzcode_laenge);
      Inc(byte_angehaengt,exefix_bin_laenge+zusatzcode_laenge);

      exelaenge:=ende;
      exe_kopf.page512:=(exelaenge) div 512;
      exe_kopf.mod512 :=(exelaenge) mod 512;
      if exe_kopf.mod512<>0 then
        Inc(exe_kopf.page512);


      Move(Addr(exefix_bin)^,puffer,exefix_bin_laenge);

      sword_ptr(@puffer[exefix_bin_ip_org])^:=exe_kopf.ip;
      sword_ptr(@puffer[exefix_bin_cs_org])^:=(exelaenge-(exefix_bin_laenge+zusatzcode_laenge))
        div 16-exe_kopf.kopfgroesse-(($0100-exefix_bin_laenge) div $10)
                                            -exe_kopf.cs;

      Seek(datei,ende-(exefix_bin_laenge+zusatzcode_laenge));
      BlockWrite(datei,puffer,exefix_bin_laenge);
      WriteLn('+ ',exefix_bin_laenge:7,textz_Byte_EXE_Anpasser^);
      BlockWrite(datei,zusatzcode^,zusatzcode_laenge);
      WriteLn('+ ',zusatzcode_laenge:7,textz_Byte_Zusatz^,zusatz_beschreibung);

      exe_kopf.cs:=(exelaenge-(exefix_bin_laenge+zusatzcode_laenge))
        div 16-exe_kopf.kopfgroesse-(($0100-exefix_bin_laenge) div $10);
      exe_kopf.ip:=$0100-exefix_bin_laenge;

      halde_diff:=exelaenge div 16;
      if (exelaenge and $f)<>0 then
        Inc(halde_diff);

      Dec(halde_diff,org_exe_laenge div 16);
      if (org_exe_laenge and $f)<>0 then
        Dec(halde_diff);

      Write(textz_min_heap^);
      halde(exe_kopf.halde_min);
      if (exe_kopf.halde_min>halde_diff) and (exe_kopf.halde_min<>$ffff) then
        Dec(exe_kopf.halde_min,halde_diff);
      Write(' ->');
      halde(exe_kopf.halde_min);
      WriteLn;

      Write(textz_max_heap^);
      halde(exe_kopf.halde_max);
      if (exe_kopf.halde_max>halde_diff) and (exe_kopf.halde_max<>$ffff) then
        Dec(exe_kopf.halde_max,halde_diff);
      Write(' ->');
      halde(exe_kopf.halde_max);
      WriteLn;

      Seek(datei,0);
      BlockWrite(datei,exe_kopf,$1c);

    end


  (**********************************************************************)
  else
    begin
      if ende+zusatzcode_laenge>65000 then
        Abbruch(textz_Beide_Dateien_zusammen_sind_zu_gross^);

      Seek(datei,ende);

      while (ende and $0f)<>0 do
        begin
          BlockWrite(datei,fuell,1);
          Inc(ende);
          Inc(byte_angehaengt);
        end;

      Inc(ende,comfix_bin_laenge+zusatzcode_laenge);
      Inc(byte_angehaengt,comfix_bin_laenge+zusatzcode_laenge);

      Seek(datei,pos_0);
      BlockRead(datei,cs_100,sizeof(cs_100));
      if (cs_100[0]=$eb) and (cs_100[2]=$90) then (* OS2BOOT *)
        begin
          Inc(pos_0,2+cs_100[1]);
          Seek(datei,pos_0);
          BlockRead(datei,cs_100,sizeof(cs_100));
        end;

      Seek(datei,ende-(comfix_bin_laenge+zusatzcode_laenge));

      Move(Addr(comfix_bin)^,puffer,comfix_bin_laenge);
      sword_ptr(@puffer[comfix_bin_w100_position])^:=sword_ptr(@cs_100[0])^;
      sword_ptr(@puffer[comfix_bin_w102_position])^:=sword_ptr(@cs_100[2])^;

      BlockWrite(datei,puffer,comfix_bin_laenge);
      WriteLn('+ ',comfix_bin_laenge:7,textz_Byte_COM_Anpasser^);

      BlockWrite(datei,zusatzcode^,zusatzcode_laenge);
      WriteLn('+ ',zusatzcode_laenge:7,textz_Byte_Zusatz^,zusatz_beschreibung);

      Seek(datei,pos_0);
      sprungdiff:=ende-(comfix_bin_laenge+zusatzcode_laenge)-($0104-$0100)-pos_0;

      puffer[$00]:=$0e;              (* push cs  *)
      puffer[$01]:=$e8;              (* call ... *)
      puffer[$02]:=Lo(sprungdiff);
      puffer[$03]:=Hi(sprungdiff);
      BlockWrite(datei,puffer,4);
    end;

  Close(datei);
end.

