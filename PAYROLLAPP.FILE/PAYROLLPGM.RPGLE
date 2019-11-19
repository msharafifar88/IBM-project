000102191101       //pay roll programing
000103191101
000106191101
000107191101          DCL-F SHIFTWEEK USAGE(*INPUT) KEYED RENAME(SHIFTWEEK: SHIFTWEEKR);
000109191101          DCL-F CONFIRMPYE WORKSTN;
000110191031          DCL-F SHIFTRATES DISK USAGE(*INPUT) RENAME(SHIFTRATES:SHIFTRATER);
000111191031          DCL-F PAYRPT PRINTER OFLIND(*IN01);
000112191031          DCL-S HOURSOVER PACKED(3);
000113191029
000114191101                             // read and overwrite from on printfile
000115191101
000116191031           READ  SHIFTRATES;
000117191031           WRITE TITLE;
000118191031           WRITE COLHDG;
000119191031           READ SHIFTWEEK;
000120191029
000121191101                    // starting do while and desplay the pay info
000122191101
000123191029                DOW NOT %EOF;
000124191031                    EXSR PAYSR;
000125191029                  IF *IN01;
000126191029                    WRITE TITLE;
000127191031                    WRITE COLHDG;
000128191029                    *IN01 = *OFF;
000129191029                  ENDIF;
000130191029                    WRITE EMPDETAIL;
000131191029                    READ SHIFTWEEK;
000132191031
000133191029                ENDDO;
000134191031
000135191029
000136191029
000137191031                     TOTWKPAY = TOTOVTPAY + TOTREGPAY;
000138191031
000139191029                     WRITE TOTALS;
000140191029                     EXFMT RECORD1;
000141191029                     *INLR = *ON;
000142191029                     RETURN;
000143191101
000144191101                     //pay subrotin for morning evening or overnight
000145191101
000146191101
000147191031
000148191031         BEGSR PAYSR;
000149191029                SELECT;
000150191029                     WHEN workshift='1';
000151191031                         HOURLYRATE = DAYRATE;
000152191031                         SELECT;
000153191031                           WHEN PAYGRADE = 'A';
000154191031                             EVAL(H) HOURLYRATE *= 1.096;
000155191031                           WHEN PAYGRADE = 'B';
000156191031                             EVAL(H) HOURLYRATE *= 1.072;
000157191031                           WHEN PAYGRADE = 'C';
000158191031                             EVAL(H) HOURLYRATE *= 0.956;
000159191031                         ENDSL;
000160191101
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
