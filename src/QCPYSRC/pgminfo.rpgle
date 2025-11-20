**free

//-----------------------------------------------------------------------
// Program Information Data Structure
//-----------------------------------------------------------------------
dcl-ds d_PgmInfo           psds qualified;
  ProcName                 *proc;
  PgmStatus                *status;
  PrvStatus                zoned(5);
  LineNbr                  char(8);
  Routine                  *routine;
  Parms                    *parms;
  ExcptId                  char(7);
  ExcptPrfx                char(3) overlay(ExcptId);
  ExcptNbr                 char(4) overlay(ExcptId: *next);
  Instruction              char(4);
  WrkMsg                   char(30);
  PgmLib                   char(10);
  ExcptText                char(80);
  ExcptIdent               char(4);
  File                     char(10);
  *N                       char(6);
  JobDate                  char(8);
  JobYear                  zoned(2);
  FileUsed                 char(8);
  FileInfo                 char(35);
  FileSts                  char(5) overlay(FileInfo);
  FileOpCode               char(6) overlay(FileInfo: *next);
  FileRoutine              char(8) overlay(FileInfo: *next);
  FileLine                 char(8) overlay(FileInfo: *next);
  FileFormat               char(8) overlay(FileInfo: *next);
  Job                      char(26);
  JobName                  char(10) overlay(Job);
  UserId                   char(10) overlay(Job: *next);
  JobNbr                   char(6) overlay(Job: *next);
  JobUDate                 zoned(6);
  PgmRunUDate              zoned(6);
  PgmRunTime               zoned(6);
  PgmCrtUDate              char(6);
  PgmCrtTime               char(6);
  CplLevel                 char(4);
  SrcFile                  char(10);
  SrcLib                   char(10);
  SrcMbr                   char(10);
  PgmName                  char(10);
  MdlName                  char(10);
  LineNbr2                 bindec(4);
  LineNbr3                 bindec(4);
  UserPrf                  char(10);
  ExtError                 int(10);
  XMLElm                   int(20);
  *N                       char(50);
end-ds;
