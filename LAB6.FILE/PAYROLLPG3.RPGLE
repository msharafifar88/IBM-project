000102191101       //pay roll programing
000103191101
000106191101
000107191101          DCL-F SHIFTWEEK USAGE(*INPUT) KEYED RENAME(SHIFTWEEK: SHIFTWEEKR);
000109191102          DCL-F CONFIRMPY3 WORKSTN;
000111191031          DCL-F SHIFTRATES DISK USAGE(*INPUT) RENAME(SHIFTRATES:SHIFTRATER);
000112191102          DCL-F PAYRPT3 PRINTER OFLIND(*IN01);
000113191031          DCL-S HOURSOVER PACKED(3);
000114191102
000115191102          DCL-PI MAIN ExtPgm('PAYROLLPG3');
000116191102            ShiftType char (30);
000117191102          END-PI;
000118191102
000119191102        // END-PI;
000120191029
000121191101                             // read and overwrite from on printfile
000122191101
000123191031           READ  SHIFTRATES;
000124191031           WRITE TITLE;
000125191031           WRITE COLHDG;
000126191031           READ SHIFTWEEK;
000127191029
000128191101                    // starting do while and desplay the pay info
000129191101
000130191029                DOW NOT %EOF;
000131191031                    EXSR PAYSR;
000132191029                  IF *IN01;
000133191029                    WRITE TITLE;
000134191031                    WRITE COLHDG;
000135191029                    *IN01 = *OFF;
000136191029                  ENDIF;
000137191029                    WRITE EMPDETAIL;
000138191029                    READ SHIFTWEEK;
000139191031
000140191029                ENDDO;
000141191031
000142191029
000143191029
000144191031                     TOTWKPAY = TOTOVTPAY + TOTREGPAY;
000145191031
000146191029                     WRITE TOTALS;
000147191029                     EXFMT RECORD1;
000148191029                     *INLR = *ON;
000149191029                     RETURN;
000150191101
000151191101                     //pay subrotin for morning evening or overnight
000152191101
000153191101
000154191031
000155191031         BEGSR PAYSR;
000156191029                SELECT;
000157191029                     WHEN workshift='1';
000158191031                         HOURLYRATE = DAYRATE;
000159191031                         SELECT;
000160191031                           WHEN PAYGRADE = 'A';
000161191031                             EVAL(H) HOURLYRATE *= 1.096;
000162191031                           WHEN PAYGRADE = 'B';
000163191031                             EVAL(H) HOURLYRATE *= 1.072;
000164191031                           WHEN PAYGRADE = 'C';
000165191031                             EVAL(H) HOURLYRATE *= 0.956;
000166191031                         ENDSL;
000167191101
000170191101                     WHEN workshift='2';
000171191031                         HOURLYRATE = AFTNRATE;
000172191031                         SELECT;
000173191031                           WHEN PAYGRADE = 'A';
000174191031                             EVAL(H) HOURLYRATE *= 1.096;
000175191031                           WHEN PAYGRADE = 'B';
000176191031                             EVAL(H) HOURLYRATE *= 1.072;
000177191031                           WHEN PAYGRADE = 'C';
000178191031                             EVAL(H) HOURLYRATE *= 0.956;
000179191031                         ENDSL;
000180191101                           WHEN workshift='3';
000181191101                         HOURLYRATE = NIGHTRATE;
000182191101                         SELECT;
000183191101                           WHEN PAYGRADE = 'A';
000184191101                             EVAL(H) HOURLYRATE *= 1.096;
000185191101                           WHEN PAYGRADE = 'B';
000186191101                             EVAL(H) HOURLYRATE *= 1.072;
000187191101                           WHEN              PAYGRADE = 'C';
000188191101                             EVAL(H) HOURLYRATE *= 0.956;
000189191101                         ENDSL;
000190191031                    ENDSL;
000191191031         IF HRSWORKED > 40;
000192191031           HOURSOVER = HRSWORKED - 40;
000193191031         ELSE;
000194191031           HOURSOVER = 0;
000195191031         ENDIF;
000196191031           REGULARPAY = HOURLYRATE * (HRSWORKED - HOURSOVER);
000197191031           EVAL(H) OVERPAY = HOURSOVER *  1.5 * HOURLYRATE;
000198191031           WEEKLYPAY = REGULARPAY + OVERPAY;
000199191031           TOTREGPAY += REGULARPAY;
000200191031           TOTOVTPAY += OVERPAY;
000201191031
000202191031         ENDSR;
000203191031
