program ac_def;

uses spr2_ein;

begin
  sprachtabellenkopf_erweitert(
                     +'EN'
                     +'DE'
                     +''
                     +'',
                     false);


  sprach_eintrag04('titel2',
                   'Add small pre-programms to EXE and COM/BIN files',
                   'AnhÑngen von Vorprogrammen an EXE und COM/BIN Dateien',
                   '',
                   '');

  sprach_eintrag04('syntax1',
                   'usage ',
                   'Benutzung ',
                   '',
                   '');

  sprach_eintrag04('syntax2',
                   ' Targetfilename Addfilename',
                   ' Zieldateiname Zusatzdatei',
                   '',
                   '');

  sprach_eintrag04('zusatz_zu_gross',
                   'the addfile is to big ! ( >60K )',
                   'Die Zusatzdatei ist zu gro· ! ( >60K )',
                   '',
                   '');

  sprach_eintrag04('zusatz_ist_exe',
                   'addfile is EXE ( use EXE2COM,EXETOCOM, E2C, UNP .. )',
                   'Zusatz ist EXE ! ( EXE2COM, EXETOCOM, E2C, UNP .. benutzen )',
                   '',
                   '');

  sprach_eintrag04('null_datei',
                   'the file contains no data (0 bytes)',
                   'Die Datei enhÑlt keine Daten (0 Byte)',
                   '',
                   '');

  sprach_eintrag04('exe_overlays',
                   'EXE-file has Overlays',
                   'EXE-Datei hat öberlÑnge (Overlays)',
                   '',
                   '');

  sprach_eintrag04('Byte_aufgefuellt',
                   ' bytes filled',
                   ' Byte aufgefÅllt',
                   '',
                   '');

  sprach_eintrag04('Byte_EXE_Anpasser',
                   ' bytes .EXE adaptor',
                   ' Byte .EXE Anpasser',
                   '',
                   '');

  sprach_eintrag04('Byte_COM_Anpasser',
                   ' bytes .COM adaptor',
                   ' Byte .COM Anpasser',
                   '',
                   '');

  sprach_eintrag04('Byte_Zusatz',
                   ' bytes Addfile',
                   ' Byte Zusatz',
                   '',
                   '');

  sprach_eintrag04('Beide_Dateien_zusammen_sind_zu_gross',
                   'both files together are to big for .COM',
                   'Beide Dateien zusammen sind zu gro· fÅr .COM Datei',
                   '',
                   '');

  sprach_eintrag04('min_heap',
                   'min heap',
                   'min Halde',
                   '',
                   '');

  sprach_eintrag04('max_heap',
                   'max heap',
                   'max Halde',
                   '',
                   '');
  {
  sprach_eintrag04('',
                   '',
                   '',
                   '',
                   '');
  }

  schreibe_sprach_datei('AC__$$$.001','AC__$$$.002','sprach_modul','sprach_start','^string');
end.
