000100191117         // **************************************************************************
000200190313        //  CUSTOMER19 READ BY NATIVE LANGUAGE (ILE RPG)
000300190313        //  CONTACTW19 ROW RETRIEVED WITH EMBEDDED SQL
000400190313        //  DETAIL REPORT LINE INCLUDES INFORMATION FROM CUSTOMER19 AND CONTACTW19
000500190313        //  SUMMARRY REPORT INFORMATION RETRIEVED WITH EMBEDDED SQL STATEMENTS
000600190314
000700190313           DCL-F PHNREPORT PRINTER OFLIND(*IN01) ;
000800190313           DCL-F CUSTOMER19 DISK(*EXT) KEYED USAGE(*INPUT)
000900190314                 RENAME(CUSTOMER19:CUSTR);
001000190314                      // data structure for host variables from CONTACTW19
001100191117           DCL-DS CONTACTW19 EXT END-DS;
001200190314                     // Standalone fields for indicator variables
001300191117           DCL-S INDLASTCDATE BINDEC(4:0);
001301191117           DCL-S INDNEXTCDATE BINDEC(4:0);
001400191117
001500190314
001600190314           DCL-S Dummy  Zoned(1);
001700190314
001800190314        //**************************************************************************
001900190314        //*                        ***   M A I N   R O U T I N E   ***
002000190314        //**************************************************************************
002100190314
002200070119                EXSR SummaryInfo;
002300190313                WRITE HEADINGS;
002400190313                READ CUSTOMER19;
002500070119                DOW NOT %EOF;
002600070119                    EXSR SQLSelect;
002601191118                    if phnldc = oldestdate;
002602191118                      flag = '<--------';
002603191118
002604191118                      else;
002605191118                        flag = ' ' ;
002606191118                    ENDIF;
002700190313                    IF *IN01 = *ON;
002800190313                       Write HEADINGS;
002900190313                       *IN01 = *OFF;
003000070119                    ENDIF;
003100190313                    Write DETAIL;
003200190313                   READ CUSTOMER19;
003300070119                ENDDO;
003400190313                Write SUMMARY;
003500070119                *INLR = *ON;
003600070119                RETURN;
003700080923        //**********************************************************************
003800080923        //   S Q L S E L E C T   S U B R O U T I N E
003900080923   //   //********************************************************************
004000080923   //                  BEGSR    SQLSelect ;
004100080923   //    // A row from the contacts table that has the same customer number as t
004200190313   //    // read from the CUSTOMER19 file is retrieved to find out the last date
004300080923   //    // phone number, comments and the salesperson number.
004400080923   //
004500080923   //    //  The call back interval is added to the last date called to determin
004600080923   //    //  next date to call.  Since null values may be stored in the last dat
004700080923   //    // indicator variables are used.
004800190314
004900190314
005000190314
005100191117            EXEC SQL
005101191117              SELECT CSTLASTCALLDATE + CSTCALLBACKINT DAYS,CSTLASTCALLDATE,
005102191117                     CSTPHONE,CoMMENTS,CSTSLN
005103191117              INTO   :NEXTCDATE :INDNEXTCDATE, :PHNLDC :INDLASTCDATE,
005104191117                     :CSTPHN, :PHNCOM, :CSTSLN
005105191117              FROM   BCI433LIB/CONTACTW19
005106191117              WHERE CSTNUM =:CSTNUM;
005107191117              select;
005109191117                WHEN SQLSTATE = '00000';
005110191117                 DUMMY=0;
005112191117                WHEN SQLSTATE = '02000';
005113191117                 CSTPHN ='NOT FOUND';
005114191117                 NEXTCDATE=D'9999-09-09';
005115191117                 PHNLDC=D'9999-09-09';
005116191117                 PHNCOM=*ALL'*';
005117191117                 CSTSLN=*ALL'*';
005118191117                WHEN  %Subst(SQLSTATE :1 :2) = '01';
005119191117                 NEXTCDATE = D'9999-09-09';
005120191117                 PhnLDC = D'9999-09-09';
005121191117                 PhnCom = *ALL'*';
005122191117                 CstSln = *ALL'*';
005123191117                 CstPhn = *ALL'*';
005124191117                OTHER;
005125191117                 CstPhn = *ALL'*';
005126191117                 NEXTCDATE = D'9999-09-09';
005127191117                 PhnLDC = D'9999-09-09';
005128191117                 PhnCom = *ALL'*';
005129191117                 CstSln = *ALL'*';
005131191117              ENDSL;
005132191117
005133191117              IF INDLASTCDATE = -1;
005134191117               CSTPHN = 'UNKNOWN DATE';
005137191117               NEXTCDATE = D'9999-09-09';
005138191117               PHNLDC = D'9999-09-09';
005139191117              ELSE;
005140191117               IF IndLastCDate <> 0;
005141191117                CSTPHN = 'DATE PROBLEM';
005142191117                NEXTCDATE = D'9999-09-09';
005143191117                PHNLDC = D'9999-09-09';
005145191117               ENDIF;
005146191117              ENDIF;
005147191117
005148191117
005149191117
005150191117
005151191117
005152191117
005153191117
005154191117
006900080923                         ENDSR ;
007000080923        //**********************************************************************
007100080923        // S U M M A R Y I N F O   S U B R O U T I N E
007200080923        //**********************************************************************
007300080923                         BEGSR  SummaryInfo;
007400190313        //  D E T E R M I N E   T O T A L S   F O R   CONTACTW19 & CUSTOMER19
007500190314
007600191117            EXEC SQL
007601191117            SELECT COUNT(*)
007602191117            INTO :CONTACTT
007603191117            FROM BCI433LIB/CONTACTW19;
007605191117            IF (SQLCODE<>0) OR (SQLwn0='W');
007606191117            CONTACTT=-99999;
007607191117            ENDIF;
007608191118
007609191118             EXEC SQL
007610191118            SELECT COUNT(*)
007611191118            INTO :CUSTOMERT
007612191118            FROM BCI433LIB/customer19;
007613191118            IF (SQLCODE<>0) OR (SQLwn0='W');
007614191118            CUSTOMERT=-99999;
007615191118            ENDIF;
007700191117
009000190314        // D E T E R M I N E   N U M B E R   O F   U N K N O W N   LAST   DATE CALLED
009100191117         EXEC SQL
009101191117           SELECT COUNT(*) INTO:UNKNOWNT
009200191117           FROM BCI433LIB/CONTACTW19
009300191117           WHERE CSTLASTCALLDATE IS NULL;
009301191117         IF (SQLCODE<>0) OR (SQLWN0='W') AND (SQLWN2<>'W');
009302191117           OLDESTDATE=D'9999-09-09';
009303191117         ENDIF;
009400190314
009500190314
009600190314
009700190314
009800190314
009900190314
010000190314
010100080923        //  D E T E R M I N E   O L D E S T   &  M O S T   R E C E N T  L A S T
010200191117         EXEC SQL
010201191118           SELECT MAX(CSTLASTCALLDATE) INTO :RECENTDATE
010202191117           FROM BCI433LIB/CONTACTW19;
010203191117           IF (SQLCODE<>0) OR (SQLWN0='W') AND (SQLWN2<>'W');
010204191118           RECENTDATE=D'9999-09-09';
010205191117           ENDIF;
010206191117
010207191117                           EXEC SQL
010208191118           SELECT Min(CSTLASTCALLDATE) INTO :OLDESTDATE
010209191117           FROM BCI433LIB/CONTACTW19;
010210191117           IF (SQLCODE<>0) OR (SQLWN0='W') AND (SQLWN2<>'W');
010211191118           OLDESTDATE=D'9999-09-09';
010212191117           ENDIF;
010213191117
010214191117
011900190314
012000190314
012100080923       // D E T E R M I N E   T H E   U S E R   S E R V E R   &   T I M E S T A
012200191117         EXEC SQL
012201191117           SELECT USER,CURRENT TIMESTAMP, CURRENT SERVER
012202191117             INTO :USER, :TIMESTAMP, :SERVER
012203191117             FROM SYSIBM/SYSDUMMY1;
012204191117
012300190314
012400190314
012500190314
012600190314
012700190314
012800080923                         ENDSR;
