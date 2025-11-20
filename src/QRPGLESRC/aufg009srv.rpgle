**free
ctl-opt dftactgrp(*no) bnddir('MAIN_BD');

/COPY QCPYSRC,PGMINFO

dcl-f PERSONAD workstn;

dcl-f PERSONC disk usage(*input: *output) keyed;
dcl-ds o_person  likerec(PERSONF: *output);

dcl-s SaveReady ind inz;
dcl-s ErrMsg    varchar(80);
dcl-s ErrFields varchar(1024) inz(' ');

Init();

//============================ MAIN PGM LOOP ===============================
dow *on;

  write F0MSGCTL;
  exfmt F0RECORD;

  ClearMSGQ();
  ErrMsg = '';
  ErrFields = ' ';

  if *in25; // Funktionstasten
    *in25 = *off;

    if *inKE; // F5 -> Felder leeren
      ClearFields();
      SaveReady = *off;
      iter;
    endif;

    if *inKC or *inKL; // F3/F12 -> Exit
      leave;
    endif;

    SendMsg('Ungültige Funktionstaste.');
    SaveReady = *off;
    iter;
  endif;

  if isEnter();

    if *in29;
      SaveReady = *off;
      //SendMsg('Werte wurden geaendert.');
    endif;

    if SaveReady;
      SavePersonRecord(o_person);
      SaveReady = *off;
      ClearFields();
      iter;
    endif;

    ResetErrIndicators();

    clear o_person;

    MapScreenToBuffer(o_person);
    NormalizeBuffer(o_person);
    UpdateScreenFromBuffer(o_person);

    if ValidateBuffer(o_person : ErrFields : ErrMsg);
      SendMsg('Eingaben OK. Enter zum Speichern.');
      SaveReady = *on;
    else;

      SaveReady = *off;
    endif;

    HandleErrors(ErrFields : ErrMsg);

  endif;
enddo;

*inlr = *on;

//============================ Prozeduren ===============================

dcl-proc Init;
  // Header
  F0USERID   = d_PgmInfo.UserId;
  F0PGMNAME  = d_PgmInfo.PgmName;

  // PGM Msg Queue
  Q_PGMQUEUE = d_PgmInfo.PgmName;
end-proc;

dcl-proc ClearFields;
  clear F0VNAME;
  clear F0NNAME;
  clear F0TITEL;
  clear F0GEBORT;
  clear F0NATION;
  clear F0AUGFRB;
  clear F0GROESSE;
  clear F0GEBTT;
  clear F0GEBMM;
  clear F0GEBJJ;
  clear ErrMsg;
  clear ErrFields;
end-proc;

dcl-proc isEnter;

  dcl-pi *n ind end-pi;

  return not ( *inKA or *inKB or *inKC or *inKD or
           *inKE or *inKF or *inKG or *inKH or
           *inKI or *inKJ or *inKK or *inKL or
           *inKM or *inKN or *inKP or *inKQ or
           *inKR or *inKS or *inKT or *inKU or
           *inKV or *inKW or *inKX);
end-proc;

dcl-proc HandleErrors;
  dcl-pi *n ;
    ErrFields varchar(100) const;
    ErrMsg    varchar(80) const;
  end-pi;

  ApplyErrorIndicators(ErrFields);

  if ErrMsg <> '';
    SendMsg('Fehler: ' + %trim(ErrMsg));
  endif;

end-proc;

dcl-proc ApplyErrorIndicators;

  dcl-pi *n;
    ErrFields varchar(100) const;
  end-pi;

  // ErrFields hat das Format: ' VORNAME NACHNAME GEBDATUM ... '

  if %scan(' VORNAME '  : ErrFields) > 0;
    *in30 = *on;
  endif;

  if %scan(' NACHNAME ' : ErrFields) > 0;
    *in31 = *on;
  endif;

  if %scan(' TITEL '    : ErrFields) > 0;
    *in32 = *on;
  endif;

  if %scan(' GEBDATUM ' : ErrFields) > 0;
    *in33 = *on;
  endif;

  if %scan(' GEBORT '   : ErrFields) > 0;
    *in34 = *on;
  endif;

  if %scan(' NATION '   : ErrFields) > 0;
    *in35 = *on;
  endif;

  if %scan(' GROESSE '  : ErrFields) > 0;
    *in36 = *on;
  endif;

  if %scan(' AUGENFARBE ' : ErrFields) > 0;
    *in37 = *on;
  endif;

  if %scan(' *RECORD ' : ErrFields) > 0;
    *in30 = *on;
    *in31 = *on;
    *in33 = *on;
    *in35 = *on;
  endif;

end-proc;

dcl-proc ResetErrIndicators;
  //clear %subarr(*in: 30: 20);
  *in30 = *off; // Vorname
  *in31 = *off; // Nachname
  *in32 = *off; // Titel
  *in33 = *off; // Geburtsdatum
  *in34 = *off; // Geburtsort
  *in35 = *off; // Nationalität
  *in36 = *off; // Größe
  *in37 = *off; // Augenfarbe
end-proc;

dcl-proc UpdateScreenFromBuffer;

  dcl-pi *n;
    person likeds(o_person) const;
  end-pi;

  F0VNAME   = person.VORNAME;
  F0NNAME   = person.NACHNAME;
  F0TITEL   = person.TITEL;
  F0GEBORT  = person.GEBORT;
  F0NATION  = person.NATION;
  F0AUGFRB  = person.AUGENFARBE;

  if person.GROESSE <> 0;
    F0GROESSE = %char(person.GROESSE);
  endif;

end-proc;

dcl-proc MapScreenToBuffer;

  dcl-pi *n;
    person likeds(o_person);
  end-pi;

  dcl-s GroesseStr varchar(10);

  dcl-s GebJJ_z zoned(4);
  dcl-s GebMM_z zoned(2);
  dcl-s GebTT_z zoned(2);

  dcl-s GebJJ_str varchar(4);
  dcl-s GebMM_str varchar(2);
  dcl-s GebTT_str varchar(2);

  dcl-s GebStr char(10);

  person.VORNAME     = F0VNAME;
  person.NACHNAME    = F0NNAME;
  person.TITEL       = F0TITEL;
  person.AUGENFARBE  = F0AUGFRB;
  person.GEBORT      = F0GEBORT;
  person.NATION      = F0NATION;
  person.RCDSTS      = '1';

  // Größe nur prüfen, wenn etwas eingegeben wurde
  GroesseStr = %trim(F0GROESSE);

  if GroesseStr <> '';
    monitor;
      person.GROESSE = %dec(GroesseStr : 3 : 0);
    on-error;
      *in36 = *on;
      SendMsg('Fehler: Groesse ungültig');
      // person.GROESSE bleibt INZ
    endmon;
  endif;

  // Mindestens ein Feld nicht leer
  GebJJ_str = %trim(F0GEBJJ);
  GebMM_str = %trim(F0GEBMM);
  GebTT_str = %trim(F0GEBTT);

  if GebJJ_str <> '' or GebMM_str <> '' or GebTT_str <> '';

    // Nur teilweise gefüllt
    if GebJJ_str = '' or GebMM_str = '' or GebTT_str = '';
      *in33 = *on;
      SendMsg('Fehler: Datum unvollständig');
      return;
    endif;

    // Dezimal
    monitor;
      GebJJ_z = %dec(GebJJ_str : 4 : 0);
      GebMM_z = %dec(GebMM_str : 2 : 0);
      GebTT_z = %dec(GebTT_str : 2 : 0);

      GebStr =
        %editc(GebJJ_z : 'X') + '-' +
        %editc(GebMM_z : 'X') + '-' +
        %editc(GebTT_z : 'X');

      person.GEBDATUM = %date(GebStr : *iso);
    on-error;
      *in33 = *on;
      SendMsg('Fehler: Datum ungültig');
      return;
    endmon;
  endif;
end-proc;

dcl-proc NormalizeBuffer;

  dcl-pi *n;
    person likeds(o_person);
  end-pi;

  // Namen / Textfelder normalisieren
  person.VORNAME     = ToProperCase(person.VORNAME);
  person.NACHNAME    = ToProperCase(person.NACHNAME);
  person.TITEL       = ToProperCase(person.TITEL);
  person.GEBORT      = ToProperCase(person.GEBORT);
  person.AUGENFARBE  = ToProperCase(person.AUGENFARBE);

  // Nationalität 2-stellig Upper
  person.NATION      = %upper(%trim(person.NATION));

end-proc;

dcl-proc ValidateBuffer;

  dcl-pi *n ind;
    person    likeds(o_person) const;
    ErrFields varchar(1024);
    ErrMsg    varchar(80);
  end-pi;

  dcl-c CtryList ' AT DE FR IT ES SK PL CZ HU CH NL BE DK SE NO FI GB IE PT RO BG GR SI HR RS UA ';
  dcl-s MinDate date inz(*loval);
  dcl-s MaxDate date inz(*hival);
  dcl-s IsValid ind inz(*on);

  // -------- Pflichtfelder --------
  if %len(%trim(person.VORNAME)) = 0;
    ErrFields += 'VORNAME ';
    if IsValid;
      ErrMsg = 'Vorname ist ein Pflichtfeld.';
    endif;
    IsValid = *off;
  endif;

  if %len(%trim(person.NACHNAME)) = 0;
    ErrFields += 'NACHNAME ';
    if IsValid;
      ErrMsg = 'Nachname ist ein Pflichtfeld.';
    endif;
    IsValid = *off;
  endif;

  if person.GEBDATUM = *loval;
    ErrFields += 'GEBDATUM ';
    if IsValid;
      ErrMsg = 'Geburtsdatum ist ungültig und ein Pflichtfeld.';
    endif;
    IsValid = *off;
  endif;

  if %len(%trim(person.NATION)) = 0;
    ErrFields += 'NATION ';
    if IsValid;
      ErrMsg = 'Nationalität ist ein Pflichtfeld.';
    endif;
    IsValid = *off;
  endif;

  // -------- Größe prüfen --------
  if person.GROESSE < 0;
    ErrFields += 'GROESSE ';
    if IsValid;
      ErrMsg = 'Größe darf nur Ziffern enthalten.';
    endif;
    IsValid = *off;
  endif;

  // -------- Datumsrange --------
  MaxDate = %date();
  MinDate = MaxDate - %years(100);

  if ((person.GEBDATUM < MinDate) or (person.GEBDATUM > MaxDate));

    ErrFields += 'GEBDATUM ';
    if IsValid;
      ErrMsg = 'Geburtsdatum außerhalb des erlaubten Bereichs.';
    endif;
    IsValid = *off;
  endif;

  // -------- Nationalität in Liste? --------
  if %len(%trim(person.NATION)) > 0 and
     %scan(' ' + %trim(person.NATION) + ' ' : CtryList) = 0;

    ErrFields += 'NATION ';
    if IsValid;
      ErrMsg = 'Nationalität nicht anerkannt.';
    endif;
    IsValid = *off;
  endif;

  // -------- Duplikatcheck --------
  if isDuplicate(person);
    ErrFields += '*RECORD ';
    if IsValid;
      ErrMsg = 'Datensatz existiert bereits.';
    endif;
    IsValid = *off;
  endif;

  return IsValid;

end-proc;

dcl-proc SavePersonRecord;

  dcl-pi *n;
    person likeds(o_person);
  end-pi;

  dcl-ds i_person likerec(PERSONF: *input);

  setgt *hival PERSONC;
  readp PERSONC i_person;

  if %eof(PERSONC);
    person.NUMMER = 1;
  else;
    person.NUMMER = i_person.NUMMER + 1;
  endif;

  write PERSONF person;

  SendMsg('Neuer Datensatz wurde gespeichert.');

end-proc;

dcl-proc isDuplicate;

  dcl-pi *n ind;
    record likeds(o_person) const;
  end-pi;

  dcl-f PERSONL disk usage(*input: *output: *update) keyed;

  dcl-ds i_person  likerec(PERSONF: *input);

  // Prüfen, ob Datensatz mit gleichen Schlüsseln bereits existiert
  setll (record.VORNAME : record.NACHNAME : record.GEBDATUM : record.NATION) PERSONL;
  reade (record.VORNAME : record.NACHNAME : record.GEBDATUM : record.NATION) PERSONL i_person;

  return not %eof(PERSONL);

end-proc;

dcl-proc SendMsg;
  dcl-pi *n;
    MsgText varchar(256) const;
  end-pi;

  dcl-s MsgKey  char(4) inz;
  dcl-s ErrCode char(8) inz;

  dcl-pr QMHSNDPM extpgm('QMHSNDPM');
    MsgId           char(7)   const;
    QualMsgF        char(20)  const;
    MsgData         char(512) const;
    MsgDtaLen       int(10)   const;
    MsgType         char(10)  const;
    CallStackEntry  char(10)  const;
    CallStackCtr    int(10)   const;
    MsgKey          char(4);
    ErrorCode       char(8);
  end-pr;

  // Neue Nachricht senden
  QMHSNDPM(
    'CPF9897'
  : 'QCPFMSG   QSYS'
  : %trim(MsgText)
  : %len(%trim(MsgText))
  : '*INFO'
  : Q_PGMQueue
  : 0
  : MsgKey
  : ErrCode);

end-proc;

dcl-proc ClearMSGQ;

  dcl-s ErrCode char(8) inz;

  dcl-pr QMHRMVPM extpgm('QMHRMVPM');
    CallStackEntry   char(10) const;
    CallStackCounter int(10)  const;
    MsgKey           char(4)  const;
    MessagesToRemove char(10) const;
    ErrCode          char(8);
  end-pr;

  // Alte Messages löschen
  QMHRMVPM(
    Q_PGMQueue
  : 0
  : *BLANKS
  : '*ALL'
  : ErrCode
  );

end-proc;


