create PACKAGE BODY        ETP_API
AS
    PROCEDURE API_LOGIN (P_USER_NAME       IN     VARCHAR2,
                         P_PASS            IN     VARCHAR2,
                         P_IP_ADD          IN     VARCHAR2,
                         RETURN_STATUS        OUT NUMBER,
                         RETURN_MESSGAE       OUT VARCHAR2,
                         P_RECORDSET_OUT      OUT SYS_REFCURSOR)
    AS
        --VARIABLES DEFINITION

        V_TRD_ST              VARCHAR2 (150);
        V_IP_RES              VARCHAR2 (1);
        V_FIRM_STATUS_ID      NUMBER (2);
        V_IP_ADD              VARCHAR2 (15);
        V_PASS                VARCHAR2 (1500);
        TEMP_NUMBER           NUMBER (2);
        V_TRADER_STATUS       NUMBER (2);
        TIME_CHECK            NUMBER;
        VTRADER_SERIAL_ID     VARCHAR2 (150);
        VFIRM_SERIAL_ID       VARCHAR2 (150);
        VTRADER_CODE          VARCHAR2 (150);
        VFIRM_CODE            VARCHAR2 (150);
        VFIRM_TYPE_NAME_ENG   VARCHAR2 (150);
        --ERRORS DEFINITION
        RP                    VARCHAR2 (150) := 'WRONG PASSWORD';
        TNF                   VARCHAR2 (150) := 'TRADER NOT FOUND';
        NWD                   VARCHAR2 (150)
                                  := 'NOT A WORKING DAY - TODAY IS OFF';
        WIP                   VARCHAR2 (150) := 'WRONG IP ADDRESS';
        TRS                   VARCHAR2 (150) := 'TRADER IS SUSPENDED';
        FRMS                  VARCHAR2 (150) := 'FIRM IS SUSPENDED';
        FRMD                  VARCHAR2 (150) := 'FIRM IS DELISTED';
        TRD                   VARCHAR2 (150) := 'TRADER IS DELISTED';
    BEGIN
        RETURN_STATUS := 0;


        --CHECKING IF WORKING DAY
        SELECT CALENDAR_TIME_CHECK (2) INTO TIME_CHECK FROM DUAL;

        IF TIME_CHECK = 3                                 -- OFF DAY, VACATION
        THEN
            OPEN P_RECORDSET_OUT FOR SELECT '0' AS CODE, NWD VAL FROM DUAL;

            RETURN_MESSGAE := NWD;

            INSERT INTO ETP_LOGIN_LOG
                 VALUES (ETP_LOGIN_LOG_ID_SQ.NEXTVAL,
                         SYSDATE,
                         NULL,
                         P_IP_ADD, --,SYS_CONTEXT ('USERENV', 'IP_ADDRESS', 15),
                         NWD,
                         SYS_CONTEXT ('USERENV', 'OS_USER', 15));

            RETURN;
        END IF;

        --CHECKING IF TRADER EXISTS
        SELECT COUNT (1)
          INTO TEMP_NUMBER
          FROM ETP_TRADER
         WHERE TRIM (TRADER_USER_NAME) = TRIM (P_USER_NAME);

        IF TEMP_NUMBER = 0                             --TRADER DOES NOT EXIST
        THEN
            OPEN P_RECORDSET_OUT FOR SELECT '0' AS CODE, TNF VAL FROM DUAL;

            RETURN_MESSGAE := TNF;

            INSERT INTO ETP_LOGIN_LOG
                 VALUES (ETP_LOGIN_LOG_ID_SQ.NEXTVAL,
                         SYSDATE,
                         NULL,
                         P_IP_ADD, --SYS_CONTEXT ('USERENV', 'IP_ADDRESS', 15),
                         TNF,
                         SYS_CONTEXT ('USERENV', 'OS_USER', 15));

            RETURN;
        END IF;

        -- FETCH TRADER'S DATA - IF TRADES EXISTS --
        SELECT T1.TRADER_SERIAL_ID,
               T3.FIRM_SERIAL_ID,
               T1.TRADER_CODE,
               T3.FIRM_CODE,
               FIRM_TYPE_NAME_ENG,
               TRADER_PASSWORD,
               TRADER_STATUS,
               IP_RES,
               IP_ADD,
               FIRM_STATUS_ID
          INTO VTRADER_SERIAL_ID,
               VFIRM_SERIAL_ID,
               VTRADER_CODE,
               VFIRM_CODE,
               VFIRM_TYPE_NAME_ENG,
               V_PASS,
               V_TRADER_STATUS,
               V_IP_RES,
               V_IP_ADD,
               V_FIRM_STATUS_ID
          FROM ETP_TRADER       T1,
               ETP_TRADER_TYPE  T2,
               ETP_FIRM         T3,
               ETP_FIRM_TYPE    T4
         WHERE     T1.TRADER_TYPE_CODE = T2.TRADER_TYPE_CODE
               AND T1.FIRM_SERIAL_ID = T3.FIRM_SERIAL_ID
               AND T3.FIRM_TYPE_ID = T4.FIRM_TYPE_ID
               AND TRIM (TRADER_USER_NAME) = P_USER_NAME
               --AND T1.IP_ADD = P_IP_ADD
               AND T1.IS_API = 1
               AND T3.ISTR = 1;

        --CHECKING PASSWORD--
        IF V_PASS <> ETP_ENCRYPT (P_PASS, 'GLOBALKNOWLEDGE')  --WRONG PASSWORD
        THEN
            OPEN P_RECORDSET_OUT FOR SELECT '0' AS CODE, RP VAL FROM DUAL;

            RETURN_MESSGAE := RP;

            UPDATE ETP_TRADER
               SET FAIL_REASON = RP,
                   FTRIES = NVL (FTRIES, 0) + 1,
                   LAST_FLOGIN_DATE = SYSDATE
             WHERE TRIM (TRADER_USER_NAME) = P_USER_NAME;

            INSERT INTO ETP_LOGIN_LOG
                 VALUES (ETP_LOGIN_LOG_ID_SQ.NEXTVAL,
                         SYSDATE,
                         VTRADER_CODE,
                         V_IP_RES, --SYS_CONTEXT ('USERENV', 'IP_ADDRESS', 15),
                         RP,
                         SYS_CONTEXT ('USERENV', 'OS_USER', 15));

            COMMIT;
            RETURN;
        END IF;


        IF V_TRADER_STATUS = '1'                          --TRADER IS SUPENDED
        THEN
            V_TRD_ST := TRS;                              --TRADER IS SUPENDED
        ELSIF V_TRADER_STATUS = '2'                       --TRADER IS DELISTED
        THEN
            V_TRD_ST := TRD;                              --TRADER IS DELISTED
        END IF;

        IF V_TRADER_STATUS IN ('1', '2')        --TRADER SUSPENDED OR DELISTED
        THEN
            OPEN P_RECORDSET_OUT FOR
                SELECT '0' AS CODE, V_TRD_ST VAL FROM DUAL;

            RETURN_MESSGAE := V_TRD_ST;

            UPDATE ETP_TRADER
               SET FAIL_REASON = V_TRD_ST,
                   FTRIES = NVL (FTRIES, 0) + 1,
                   LAST_FLOGIN_DATE = SYSDATE
             WHERE TRIM (TRADER_USER_NAME) = P_USER_NAME;

            INSERT INTO ETP_LOGIN_LOG
                 VALUES (ETP_LOGIN_LOG_ID_SQ.NEXTVAL,
                         SYSDATE,
                         VTRADER_CODE,
                         V_IP_RES, --SYS_CONTEXT ('USERENV', 'IP_ADDRESS', 15),
                         V_TRD_ST,
                         SYS_CONTEXT ('USERENV', 'OS_USER', 15));

            COMMIT;
            RETURN;
        END IF;

        --CHECKING IP RESTRICTION--
        IF V_IP_RES = 'Y'                            -- IP RESTRICTION APPLIED
        THEN
            IF NVL (V_IP_ADD, 0) <> NVL (P_IP_ADD, 1) --IP ADDRESS DOES NOT MATCH
            THEN
                OPEN P_RECORDSET_OUT FOR
                    SELECT '0' AS CODE, WIP VAL FROM DUAL;

                RETURN_MESSGAE := WIP;

                UPDATE ETP_TRADER
                   SET FAIL_REASON = WIP,
                       FTRIES = NVL (FTRIES, 0) + 1,
                       LAST_FLOGIN_DATE = SYSDATE
                 WHERE TRIM (TRADER_USER_NAME) = P_USER_NAME;

                INSERT INTO ETP_LOGIN_LOG
                     VALUES (ETP_LOGIN_LOG_ID_SQ.NEXTVAL,
                             SYSDATE,
                             VTRADER_CODE,
                             P_IP_ADD, --SYS_CONTEXT ('USERENV', 'IP_ADDRESS', 15),
                             WIP,
                             SYS_CONTEXT ('USERENV', 'OS_USER', 15));

                COMMIT;
                RETURN;
            END IF;
        END IF;

        --CHECKING FIRM STATUS--
        IF V_FIRM_STATUS_ID = 1                             --FIRM IS SUPENDED
        THEN
            OPEN P_RECORDSET_OUT FOR SELECT '0' AS CODE, FRMS VAL FROM DUAL;

            RETURN_MESSGAE := FRMS;


            UPDATE ETP_TRADER
               SET FAIL_REASON = FRMS,
                   FTRIES = NVL (FTRIES, 0) + 1,
                   LAST_FLOGIN_DATE = SYSDATE
             WHERE TRIM (TRADER_USER_NAME) = P_USER_NAME;

            INSERT INTO ETP_LOGIN_LOG
                 VALUES (ETP_LOGIN_LOG_ID_SQ.NEXTVAL,
                         SYSDATE,
                         VTRADER_CODE,
                         P_IP_ADD, --SYS_CONTEXT ('USERENV', 'IP_ADDRESS', 15),
                         FRMS,
                         SYS_CONTEXT ('USERENV', 'OS_USER', 15));

            COMMIT;
            RETURN;
        END IF;

        IF V_FIRM_STATUS_ID = 2                             --FIRM IS DELISTED
        THEN
            OPEN P_RECORDSET_OUT FOR SELECT '0' AS CODE, FRMD VAL FROM DUAL;

            RETURN_MESSGAE := FRMD;

            UPDATE ETP_TRADER
               SET FAIL_REASON = FRMD,
                   FTRIES = NVL (FTRIES, 0) + 1,
                   LAST_FLOGIN_DATE = SYSDATE
             WHERE TRIM (TRADER_USER_NAME) = TRIM (P_USER_NAME);

            INSERT INTO ETP_LOGIN_LOG
                 VALUES (ETP_LOGIN_LOG_ID_SQ.NEXTVAL,
                         SYSDATE,
                         VTRADER_CODE,
                         P_IP_ADD, --SYS_CONTEXT ('USERENV', 'IP_ADDRESS', 15),
                         FRMD,
                         SYS_CONTEXT ('USERENV', 'OS_USER', 15));

            COMMIT;
            RETURN;
        END IF;

        RETURN_STATUS := 1;                                   --LOGIN IS VALID

        OPEN P_RECORDSET_OUT FOR
            --  SELECT  VFIRM_SERIAL_ID AS FIRM_SERIAL ,  VTRADER_SERIAL_ID AS TRADER_SERIAL FROM DUAL  ;
            SELECT VFIRM_TYPE_NAME_ENG     AS FIRM_TYPE_NAME_ENG,
                   VFIRM_CODE              AS FIRM_CODE,
                   VTRADER_CODE            AS TRADER_CODE,
                   VFIRM_SERIAL_ID         AS FIRM_SERIAL_ID,
                   VTRADER_SERIAL_ID       AS TRADER_SERIAL_ID
              FROM DUAL;

        /*SELECT 'FIRM_TYPE_NAME_ENG' AS CODE, VFIRM_TYPE_NAME_ENG VAL
          FROM DUAL
        UNION ALL
        SELECT 'FIRM_CODE' AS CODE, VFIRM_CODE VAL FROM DUAL
        UNION ALL
        SELECT 'TRADER_CODE' AS CODE, VTRADER_CODE VAL FROM DUAL
        UNION ALL
        SELECT 'FIRM_SERIAL_ID' AS CODE, VFIRM_SERIAL_ID VAL FROM DUAL
        UNION ALL
        SELECT 'TRADER_SERIAL_ID' AS CODE, VTRADER_SERIAL_ID VAL
          FROM DUAL;*/

        INSERT INTO ETP_LOGIN_LOG
             VALUES (ETP_LOGIN_LOG_ID_SQ.NEXTVAL,
                     SYSDATE,
                     VTRADER_CODE,
                     P_IP_ADD,    --SYS_CONTEXT ('USERENV', 'IP_ADDRESS', 15),
                     'LOGIN',
                     SYS_CONTEXT ('USERENV', 'OS_USER', 15));

        UPDATE ETP_TRADER
           SET FAIL_REASON = NULL, FTRIES = 0, LAST_SLOGIN_DATE = SYSDATE
         WHERE TRIM (TRADER_USER_NAME) = P_USER_NAME;

        COMMIT;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN_STATUS := 0;
            RETURN_MESSGAE := 'ERROR IN LOGIN';

            OPEN P_RECORDSET_OUT FOR
                SELECT '0' AS CODE, 'ERROR IN LOGIN' VAL FROM DUAL;
    END;

    FUNCTION API_SETTLEMENT_DATES (P_MARKET_CODE   NUMBER,
                                   P_ISIN_CODE     VARCHAR2)
        RETURN VARCHAR2
    IS
        -- DECLARE CURSOR VARIABLE TO HOLD THE RESULT SET
        CUR                    SYS_REFCURSOR;

        -- DECLARE ERROR CODE VARIABLE
        IERRORCODE_OUT         NUMBER;

        -- VARIABLE TO STORE THE FINAL CONCATENATED SETTLEMENT DATES
        SETTLEMENT_DATE_LIST   VARCHAR2 (4000);

        -- VARIABLE TO HOLD INDIVIDUAL SETTLEMENT DATE VALUE FETCHED FROM THE CURSOR
        TEMP_SETTLEMENT_DATE   VARCHAR2 (20);
        COL1                   VARCHAR2 (20);
        COL2                   VARCHAR2 (50);
        COL3                   VARCHAR2 (50);
        COL4                   VARCHAR2 (20);
    BEGIN
        -- INITIALIZE THE RESULT STRING TO EMPTY
        SETTLEMENT_DATE_LIST := '';

        -- CALL THE PROCEDURE TO GET THE SETTLEMENT DATES
        ETP_GET_SETTLEMENT_DATE (P_MARKET_CODE,
                                 P_ISIN_CODE,
                                 CUR,
                                 IERRORCODE_OUT);

        -- CHECK IF THERE WAS AN ERROR DURING THE PROCEDURE CALL
        IF IERRORCODE_OUT != 0
        THEN
            -- HANDLE THE ERROR (RETURNING A MESSAGE, COULD BE ADJUSTED BASED ON YOUR REQUIREMENTS)
            RETURN 'ERROR: ' || IERRORCODE_OUT;
        END IF;

        -- FETCH THE DATA FROM THE CURSOR AND BUILD THE RESULT STRING
        LOOP
            -- FETCH EACH ROW FROM THE CURSOR INTO THE TEMPORARY VARIABLE
            FETCH CUR
                INTO COL1,
                     COL2,
                     COL3,
                     COL4;

            -- EXIT THE LOOP WHEN NO MORE ROWS ARE AVAILABLE
            EXIT WHEN CUR%NOTFOUND;

            -- CONCATENATE THE FETCHED SETTLEMENT DATE TO THE RESULT STRING, ADDING A COMMA
            SETTLEMENT_DATE_LIST := SETTLEMENT_DATE_LIST || COL2 || ', ';
        END LOOP;

        -- CLOSE THE CURSOR AFTER THE LOOP
        CLOSE CUR;

        -- REMOVE THE TRAILING COMMA AND SPACE, IF PRESENT
        IF LENGTH (SETTLEMENT_DATE_LIST) > 1
        THEN
            SETTLEMENT_DATE_LIST := RTRIM (SETTLEMENT_DATE_LIST, ', ');
        END IF;

        -- RETURN THE FINAL CONCATENATED SETTLEMENT DATE LIST
        RETURN SETTLEMENT_DATE_LIST;
    EXCEPTION
        -- EXCEPTION HANDLING FOR UNEXPECTED ERRORS
        WHEN OTHERS
        THEN
            -- RETURN AN ERROR MESSAGE WITH THE SQL ERROR CODE AND MESSAGE
            RETURN 'ERROR: ' || SQLCODE || ' - ' || SQLERRM;
    END;


    PROCEDURE API_GET_ALL_ISINS (FIRM_ID               NUMBER,
                                 RETURN_STATUS     OUT NUMBER,
                                 P_RECORDSET_OUT   OUT SYS_REFCURSOR)
    AS
    BEGIN
        OPEN P_RECORDSET_OUT FOR
            SELECT ETP_TSFUND.FUND_NAME_SHORT
                       CURRENCY,
                   CASE WHEN SEC_TYPE = 1 THEN 'BOND' ELSE 'BILL' END
                       TYPE,
                   SEC_ISIN_CODE
                       ISIN_CODE,
                   RUTERS_CODE
                       REUTERS_CODE,
                   SEC_NAME_AR
                       NAME_ARB,
                   SEC_NAME_EN
                       NAME_ENG,
                   COUPON_INTER_RATE
                       COUPON_RATE,
                   MATURITY_DATE,
                   LAST_COUPON_PAYMENT
                       LAST_COUPON,
                   NEXT_COUPON_PAYMENT
                       NEXT_COUPON,
                   NUMBER_OF_COUPONS
                       COUPONS_COUNT,
                   PARVALUE
                       PAR_VALUE,
                   CASE
                       WHEN SEC_TYPE = 1
                       THEN
                           (SELECT PRICE_MAX
                              FROM ETP_MARKETS_PRICE_RANGE
                             WHERE IS_BOND = 'Y')
                       ELSE
                           (SELECT PRICE_MAX
                              FROM ETP_MARKETS_PRICE_RANGE
                             WHERE IS_BOND = 'N')
                   END
                       AS MAX_PRICE,
                   CASE
                       WHEN SEC_TYPE = 1
                       THEN
                           (SELECT PRICE_MIN
                              FROM ETP_MARKETS_PRICE_RANGE
                             WHERE IS_BOND = 'Y')
                       ELSE
                           (SELECT PRICE_MIN
                              FROM ETP_MARKETS_PRICE_RANGE
                             WHERE IS_BOND = 'N')
                   END
                       AS MIN_PRICE,
                   ETP_API.API_SETTLEMENT_DATES (
                       ETP_MARKET_SECURITIES.MARKET_CODE,
                       ETP_SECURITIES.SEC_ISIN_CODE)
                       AS SETTLEMENT_DATES,
                   CASE WHEN BOND_STATUS = 0 THEN 'A' ELSE 'S' END
                       STATUS
              FROM ETP_SECURITIES
                   JOIN ETP_MARKET_SECURITIES
                       ON ETP_MARKET_SECURITIES.SEC_SERIAL_ID =
                          ETP_SECURITIES.SEC_SERIAL_ID
                  /* JOIN ETP_FIRMS_SECURITIES
                       ON ETP_FIRMS_SECURITIES.UNQ_ID =
                          ETP_MARKET_SECURITIES.UNQ_ID*/,
                   ETP_TSFUND
             WHERE     BOND_STATUS != 2
                   AND ETP_SECURITIES.NEXT_COUPON_PAYMENT >= TRUNC (SYSDATE)
                   AND ETP_MARKET_SECURITIES.STATUS = 0
                  -- AND ETP_FIRMS_SECURITIES.STATUS = 0
                 --  AND (ETP_FIRMS_SECURITIES.FIRM_SERIAL_ID = FIRM_ID )
                   AND ETP_TSFUND.FUNDS_CODE =
                       ETP_SECURITIES.SEC_LIST_CURRENCY
                   AND ETP_MARKET_SECURITIES.MARKET_CODE = 2;

        RETURN_STATUS := 1;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN_STATUS := 0;
    END;

    PROCEDURE API_GET_ALL_BK_KEEPERS (RETURN_STATUS     OUT NUMBER,
                                      P_RECORDSET_OUT   OUT SYS_REFCURSOR)
    AS
    BEGIN
        OPEN P_RECORDSET_OUT FOR SELECT *
                                   FROM (SELECT BROKER_CODE       CODE,
                                                BROKER_NAME       NAME_ENG,
                                                BROKER_NAME_2     NAME_ARB,
                                                BROKER_STATUS     STATUS
                                           FROM ETP_BKKP
                                          WHERE RECORD_ACTIVE_IND = 'Y');

        RETURN_STATUS := 1;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN_STATUS := 0;
    END;

    PROCEDURE API_GET_ALL_FIRMS (RETURN_STATUS     OUT NUMBER,
                                 P_RECORDSET_OUT   OUT SYS_REFCURSOR)
    AS
    BEGIN
        OPEN P_RECORDSET_OUT FOR
            SELECT *
              FROM (SELECT                    --FIRM_SERIAL_ID    FIRM_SERIAL,
                           FIRM_CODE                                             CODE,
                           FIRM_ENG_NAME                                         NAME_ENG,
                           FIRM_NAME                                             NAME_ARB,
                           CASE FIRM_TYPE_ID
                               WHEN 1 THEN 'BANKS'
                               ELSE 'BROKERS'
                           END                                                   TYPE,
                           CASE WHEN FIRM_STATUS_ID = 0 THEN 'A' ELSE 'S' END    STATUS
                      --,ISTR,ISRFQ
                      FROM ETP_FIRM
                     WHERE FIRM_STATUS_ID != 2);

        RETURN_STATUS := 1;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN_STATUS := 0;
    END;

    PROCEDURE API_INSERT_TRADE (p_SELL_FIRM           NUMBER,
                                p_BUY_FIRM            NUMBER,
                                p_TRADER_CODE         NUMBER,
                                p_ISIN                VARCHAR2,
                                p_SETTLEMENT          NUMBER,
                                p_SELL_NIN            NUMBER,
                                p_BUY_NIN             NUMBER,
                                p_SELL_BOOK           NUMBER,
                                p_BUY_BOOK            NUMBER,
                                p_PRICE_YIELD         NUMBER,
                                p_VOLUME              NUMBER,
                                p_REPO_TYPE           VARCHAR2,
                                RETURN_STATUS     OUT NUMBER,
                                P_RECORDSET_OUT   OUT SYS_REFCURSOR)
    AS
        vTRADE_NUMBER        NUMBER;
        vCLEAN_PRICE_VALUE   NUMBER;
        vCURRENT_YIELD       NUMBER;
        vGROSS_PRICE         NUMBER;
        vYTM                 NUMBER;
        vACCRUED_INTEREST    NUMBER;
        vVALIDATE            VARCHAR (350);
        vSEC_TYPE            NUMBER;
        vSEC_SERIAL_ID       NUMBER;
        vSETTLEMENT_DATE     VARCHAR2 (15);
        vACCRUAL_PERIOD      NUMBER;
        vPAR_VALUE           NUMBER;
        vSETTLEMENT_VALUE    NUMBER;
        vSELL_FIRM_CODE      NUMBER;
        vBUY_FIRM_CODE       NUMBER;
        vCURRENCY            VARCHAR2 (15);
        vCONV_RATE           NUMBER;
        vMATURITY_DAYS       NUMBER;
        vSTATUS              NUMBER (1);
    BEGIN
        -- Validate All Input Data if Valide return sec_type and settlelment
        ETP_API.API_VALIDATE ('BS',
                              P_SELL_FIRM,
                              P_BUY_FIRM,
                              P_TRADER_CODE,
                              P_ISIN,
                              P_SETTLEMENT,
                              P_SELL_NIN,
                              P_BUY_NIN,
                              P_SELL_BOOK,
                              P_BUY_BOOK,
                              P_PRICE_YIELD,
                              P_VOLUME,
                              P_REPO_TYPE,
                              vSEC_TYPE,
                              vSEC_SERIAL_ID,
                              vSETTLEMENT_DATE,
                              vACCRUAL_PERIOD,
                              vPAR_VALUE,
                              vSELL_FIRM_CODE,
                              vBUY_FIRM_CODE,
                              vCURRENCY,
                              vCONV_RATE,
                              vMATURITY_DAYS,
                              vVALIDATE);

        IF SUBSTR (vValidate, 1, 5) != 'ERROR'
        THEN
            vSTATUS :=
                CASE WHEN vSELL_FIRM_CODE = vBUY_FIRM_CODE THEN 3 ELSE 1 END;

            IF vSEC_TYPE = 1
            THEN                                           -- BOND 1    BILL 2
                -- get Price details
                SELECT ETP_FUNC_CLEAN_PRICE (p_ISIN, p_PRICE_YIELD),
                       ETP_FUNC_CURRENT_YIELD (p_ISIN, p_PRICE_YIELD),
                       ROUND (
                           ETP_FUNC_GROSS_PRICE (p_ISIN,
                                                 p_PRICE_YIELD,
                                                 vSETTLEMENT_DATE),
                           7),
                       ROUND (
                           ETP_FUNC_YTM (p_ISIN,
                                         p_PRICE_YIELD,
                                         vSETTLEMENT_DATE),
                           7),
                       ROUND (
                           ETP_FUNC_ACCRUED_INTEREST (p_ISIN,
                                                      vSETTLEMENT_DATE),
                           7)
                  INTO vCLEAN_PRICE_VALUE,
                       vCURRENT_YIELD,
                       vGROSS_PRICE,
                       vYTM,
                       vACCRUED_INTEREST
                  FROM DUAL;

                vSETTLEMENT_VALUE :=
                    ROUND ((P_VOLUME * vGROSS_PRICE) / vPAR_VALUE, 2);
            ELSE                                                      -- bills
                vCLEAN_PRICE_VALUE :=
                    ETP_FUNC_BILL_PRICE (p_PRICE_YIELD, vMATURITY_DAYS);
                -- ,   CASE WHEN vCONV_RATE = 1 THEN 365 ELSE 360 END);  test
                vSETTLEMENT_VALUE :=
                    ROUND (P_VOLUME * vCLEAN_PRICE_VALUE * vCONV_RATE, 2);
            END IF;

            -- get trade number
            SELECT ETP_TRADE_REPORT_SEQ.NEXTVAL INTO vTRADE_NUMBER FROM DUAL;


            -- INSERT TRADE
            INSERT INTO ETP_TRADE_REPORT (TRANS_CODE,
                                          TRANS_DATE,
                                          SETTLEMENT_DATE,
                                          SEC_SERIAL_ID,
                                          ISIN,
                                          BUY_FIRM_SERIAL_ID,
                                          BUY_BOOK_KEEPER,
                                          BUY_NIN_CODE,
                                          SELL_FIRM_SERIAL_ID,
                                          SELL_BOOK_KEEPER,
                                          SELL_NIN_CODE,
                                          AMOUNT_TRADED,
                                          GROSS_PRICE,
                                          SETTLEMENT_VALUE,
                                          CLEAN_PRICE,
                                          YIELD_TO_MATURITY,
                                          ACCRUED_INTEREST,
                                          CURRENT_YIELD,
                                          ACCRUAL_PERIOD,
                                          STATUS_CODE,
                                          INSERT_USER,
                                          INSERT_DATE,
                                          PRICE,
                                          DAYS_TO_MATURITY,
                                          SETTLEMENT_DAYS,
                                          IS_REPO,
                                          REPO_TYPE)
                     VALUES (
                                vTRADE_NUMBER,
                                TRUNC (SYSDATE),
                                vSETTLEMENT_DATE,
                                vSEC_SERIAL_ID,
                                p_ISIN,
                                P_BUY_FIRM,
                                P_BUY_BOOK,
                                P_BUY_NIN,
                                P_SELL_FIRM,
                                P_SELL_BOOK,
                                P_SELL_NIN,
                                P_VOLUME,
                                vGROSS_PRICE,
                                vSETTLEMENT_VALUE,
                                vCLEAN_PRICE_VALUE,
                                vYTM,
                                vACCRUED_INTEREST,
                                vCURRENT_YIELD,
                                vACCRUAL_PERIOD,
                                vSTATUS,
                                P_TRADER_CODE,
                                SYSDATE,
                                P_PRICE_YIELD,
                                NULL,
                                P_SETTLEMENT,
                                CASE
                                    WHEN LENGTH (NVL (P_REPO_TYPE, '')) > 0
                                    THEN
                                        1
                                    ELSE
                                        0
                                END,
                                P_REPO_TYPE);

            COMMIT;

            IF vSTATUS = 3
            THEN
                /*/ ETP_mcsd_approve (2,
                                   vTRADE_NUMBER,
                                   P_VOLUME,
                                   'TR');*/
                ETP_INSERT_SWIFT_TICKET (vTRADE_NUMBER);
                COMMIT;
            END IF;

            IF vSEC_TYPE = 1
            THEN
                OPEN P_RECORDSET_OUT FOR
                    SELECT 'BOND'                TTYPE,
                           vTRADE_NUMBER         TRADE_NUMBER,
                           vSETTLEMENT_DATE      SETTLEMENT_DATE,
                           p_ISIN                ISIN,
                           vSELL_FIRM_CODE       SELL_FIRM_CODE,
                           P_SELL_BOOK           SELL_BOOK,
                           P_SELL_NIN            SELL_NIN,
                           vBUY_FIRM_CODE        BUY_FIRM_CODE,
                           P_BUY_BOOK            BUY_BOOK,
                           P_BUY_NIN             BUY_NIN,
                           P_PRICE_YIELD         CLEAN_PRICE_PER,
                           vCLEAN_PRICE_VALUE    CLEAN_PRICE_VALUE,
                           vYTM                  YTM,
                           vACCRUED_INTEREST     ACCRUED_INTEREST,
                           vCURRENT_YIELD        CURRENT_YIELD,
                           vACCRUAL_PERIOD       ACCRUAL_PERIOD,
                           P_VOLUME              AMOUNT,
                           vGROSS_PRICE          GROSS_PRICE,
                           vSETTLEMENT_VALUE     SETTLEMENT_VALUE,
                           CASE
                               WHEN P_REPO_TYPE = '' THEN 'NOT'
                               ELSE P_REPO_TYPE
                           END                   REPO
                      FROM DUAL;
            ELSE
                OPEN P_RECORDSET_OUT FOR
                    SELECT 'BILL'                TTYPE,
                           vTRADE_NUMBER         TRADE_NUMBER,
                           vSETTLEMENT_DATE      SETTLEMENT_DATE,
                           p_ISIN                ISIN,
                           vSELL_FIRM_CODE       SELL_FIRM_CODE,
                           P_SELL_BOOK           SELL_BOOK,
                           P_SELL_NIN            SELL_NIN,
                           vBUY_FIRM_CODE        BUY_FIRM_CODE,
                           P_BUY_BOOK            BUY_BOOK,
                           P_BUY_NIN             BUY_NIN,
                           P_PRICE_YIELD         YIELD,
                           vCLEAN_PRICE_VALUE    PRICE_VALUE,
                           P_VOLUME              AMOUNT,
                           vSETTLEMENT_VALUE     SETTLEMENT_VALUE,
                           vCURRENCY             CURRENCY,
                           vCONV_RATE            CONV_RATE,
                           -- vMATURITY_DAYS        DAYS_TO_MATURITY,
                           CASE
                               WHEN P_REPO_TYPE = '' THEN 'NOT'
                               ELSE P_REPO_TYPE
                           END                   REPO
                      FROM DUAL;
            END IF;

            RETURN_STATUS := 1;
        ELSE
            -- Return Error
            OPEN P_RECORDSET_OUT FOR SELECT vVALIDATE RESULT FROM DUAL;

            RETURN_STATUS := 0;

            INSERT INTO ETP_API_ERROR_LOG
                 VALUES ('INSERT_TRADE_VALIDATE',
                         vVALIDATE,
                         p_SELL_FIRM,
                         SYSDATE);

            COMMIT;
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK;

            OPEN P_RECORDSET_OUT FOR
                SELECT 'ERROR: No Data inserted' RESULT FROM DUAL;

            RETURN_STATUS := 0;

            INSERT INTO ETP_API_ERROR_LOG
                     VALUES (
                                'INSERT_TRADE',
                                SUBSTR (
                                       DBMS_UTILITY.format_error_backtrace
                                    || DBMS_UTILITY.format_error_stack,
                                    1,
                                    400),
                                p_SELL_FIRM,
                                SYSDATE);

            COMMIT;
    END;

    PROCEDURE API_AMEND_CANCEL_ORDER (
        p_FIRM_SERIAL             NUMBER,
        p_TRADER_SERIAL           NUMBER,
        p_ISIN_CODE               VARCHAR2,
        p_ORDER_TYPE              VARCHAR2,                   -- B Buy  S Sell
        p_VOLUME                  NUMBER,
        P_IS_PRICE                NUMBER,
        p_PRICE_YIELD             NUMBER,
        p_BOOKKEPR                NUMBER,
        p_INVESTOR_CODE           NUMBER,
        P_ACTION                  VARCHAR2,               -- A AMEND  C CANCEL
        P_ORDER_NUMBER            NUMBER,
        p_FIRM_ORDER_NUMBER       VARCHAR2,
        p_VOLUME_OLD              NUMBER,
        p_PRICE_YIELD_OLD         NUMBER,
        p_BOOKKEPR_OLD            NUMBER,
        RETURN_STATUS         OUT NUMBER,
        RETURN_MESSGAE        OUT VARCHAR2,
        P_RECORDSET_OUT       OUT SYS_REFCURSOR)
    AS
        vCLEAN_PRICE_VALUE       NUMBER;
        vCURRENT_YIELD           NUMBER;
        vGROSS_PRICE             NUMBER;
        vYTM                     NUMBER;
        vACCRUED_INTEREST        NUMBER;
        vCLEAN_PRICE_VALUE_OLD   NUMBER;
        vCURRENT_YIELD_OLD       NUMBER;
        vGROSS_PRICE_OLD         NUMBER;
        vYTM_OLD                 NUMBER;
        vACCRUED_INTEREST_OLD    NUMBER;
        vVALIDATE                VARCHAR (350);
        vSEC_TYPE                NUMBER;
        vSEC_SERIAL_ID           NUMBER;
        vSETTLEMENT_DATE         VARCHAR2 (15);
        vACCRUAL_PERIOD          NUMBER;
        vPAR_VALUE               NUMBER;
        vSETTLEMENT_VALUE        NUMBER;
        vSETTLEMENT_VALUE_OLD    NUMBER;
        vFIRM_CODE               NUMBER;
        vCURRENCY                VARCHAR2 (15);
        vCONV_RATE               NUMBER;
        vMATURITY_DAYS           NUMBER;
        vSTATUS                  NUMBER (1);
        vTRADER_SERIAL_old       NUMBER;
        vORDER_STATUS_old        NUMBER;
        vORG_QNTY_old            NUMBER;
    BEGIN
        -- Validate All Input Data if Valide return sec_type and settlelment
        API_VALIDATE (p_VALIDATE_TYPE     => 'O',
                               P_SELL_FIRM         => p_FIRM_SERIAL,
                               P_BUY_FIRM          => p_FIRM_SERIAL,
                               P_TRADER_CODE       => p_TRADER_SERIAL,
                               P_ISIN              => p_ISIN_CODE,
                               P_SETTLEMENT        => 0,
                               P_SELL_NIN          => p_INVESTOR_CODE,
                               P_BUY_NIN           => p_INVESTOR_CODE,
                               P_SELL_BOOK         => p_BOOKKEPR,
                               P_BUY_BOOK          => p_BOOKKEPR,
                               P_PRICE_YIELD       => p_PRICE_YIELD,
                               P_VOLUME            => p_VOLUME,
                               P_REPO_TYPE         => NULL,
                               p_SEC_TYPE          => vSEC_TYPE,
                               p_SEC_SERIAL_ID     => vSEC_SERIAL_ID,
                               p_SETTLEMENT_DATE   => vSETTLEMENT_DATE,
                               p_ACCRUAL_PERIOD    => vACCRUAL_PERIOD,
                               p_PAR_VALUE         => vPAR_VALUE,
                               p_SELL_FIRM_CODE    => vFIRM_CODE,
                               p_BUY_FIRM_CODE     => vFIRM_CODE,
                               p_CURRENCY          => vCURRENCY,
                               p_CONV_RATE         => vCONV_RATE,
                               p_MATURITY_DAYS     => vMATURITY_DAYS,
                               p_RESULT            => vVALIDATE);


        IF SUBSTR (vValidate, 1, 5) != 'ERROR'
        THEN
            --  get Data
            IF p_ORDER_TYPE = 'B'
            THEN
                SELECT TRADER_SERIAL_ID, ORDER_STATUS, ORG_QNTY
                  INTO vTRADER_SERIAL_old, vORDER_STATUS_old, vORG_QNTY_old
                  FROM ETP_ORDER_BUY
                 WHERE ORDER_ID = P_ORDER_NUMBER;
            ELSE
                SELECT TRADER_SERIAL_ID, ORDER_STATUS, ORG_QNTY
                  INTO vTRADER_SERIAL_old, vORDER_STATUS_old, vORG_QNTY_old
                  FROM ETP_ORDER_SELL
                 WHERE ORDER_ID = P_ORDER_NUMBER;
            END IF;

            --
            vSTATUS := 1;

            --  CASE WHEN vSELL_FIRM_CODE = vBUY_FIRM_CODE THEN 3 ELSE 1 END;

            IF vSEC_TYPE = 1
            THEN                                           -- BOND 1    BILL 2
                -- get Price details
                SELECT ETP_FUNC_CLEAN_PRICE (p_ISIN_CODE, p_PRICE_YIELD),
                       ETP_FUNC_CURRENT_YIELD (p_ISIN_CODE, p_PRICE_YIELD),
                       ROUND (
                           ETP_FUNC_GROSS_PRICE (p_ISIN_CODE,
                                                 p_PRICE_YIELD,
                                                 vSETTLEMENT_DATE),
                           7),
                       ROUND (
                           ETP_FUNC_YTM (p_ISIN_CODE,
                                         p_PRICE_YIELD,
                                         vSETTLEMENT_DATE),
                           7),
                       ROUND (
                           ETP_FUNC_ACCRUED_INTEREST (p_ISIN_CODE,
                                                      vSETTLEMENT_DATE),
                           7),
                       ETP_FUNC_CLEAN_PRICE (p_ISIN_CODE, p_PRICE_YIELD_OLD),
                       ETP_FUNC_CURRENT_YIELD (p_ISIN_CODE,
                                               p_PRICE_YIELD_OLD),
                       ROUND (
                           ETP_FUNC_GROSS_PRICE (p_ISIN_CODE,
                                                 p_PRICE_YIELD_OLD,
                                                 vSETTLEMENT_DATE),
                           7),
                       ROUND (
                           ETP_FUNC_YTM (p_ISIN_CODE,
                                         p_PRICE_YIELD_OLD,
                                         vSETTLEMENT_DATE),
                           7),
                       ROUND (
                           ETP_FUNC_ACCRUED_INTEREST (p_ISIN_CODE,
                                                      vSETTLEMENT_DATE),
                           7)
                  INTO vCLEAN_PRICE_VALUE,
                       vCURRENT_YIELD,
                       vGROSS_PRICE,
                       vYTM,
                       vACCRUED_INTEREST,
                       vCLEAN_PRICE_VALUE_OLD,
                       vCURRENT_YIELD_OLD,
                       vGROSS_PRICE_OLD,
                       vYTM_OLD,
                       vACCRUED_INTEREST_OLD
                  FROM DUAL;

                vSETTLEMENT_VALUE :=
                    ROUND ((P_VOLUME * vGROSS_PRICE) / vPAR_VALUE, 2);
                vSETTLEMENT_VALUE_OLD :=
                    ROUND ((P_VOLUME_OLD * vGROSS_PRICE_OLD) / vPAR_VALUE, 2);
            ELSE                                                      -- bills
                vCLEAN_PRICE_VALUE :=
                    ETP_FUNC_BILL_PRICE (
                        p_PRICE_YIELD,
                        vMATURITY_DAYS,
                        CASE WHEN vCONV_RATE = 1 THEN 365 ELSE 360 END);

                vSETTLEMENT_VALUE :=
                    ROUND (P_VOLUME * vCLEAN_PRICE_VALUE * vCONV_RATE, 2);
                vCLEAN_PRICE_VALUE_OLD :=
                    ETP_FUNC_BILL_PRICE (
                        p_PRICE_YIELD_OLD,
                        vMATURITY_DAYS,
                        CASE WHEN vCONV_RATE = 1 THEN 365 ELSE 360 END);

                vSETTLEMENT_VALUE_OLD :=
                    ROUND (
                        P_VOLUME_OLD * vCLEAN_PRICE_VALUE_OLD * vCONV_RATE,
                        2);
            END IF;

            etp_update_order (
                o_order_id             => P_ORDER_NUMBER,
                o_SEC_SERIAL_ID        => vSEC_SERIAL_ID,
                o_ISIN                 => p_ISIN_CODE,
                o_FIRM_SERIAL_ID       => p_FIRM_SERIAL,
                o_ORDER_STATUS         =>
                    CASE WHEN P_ACTION = 'A' THEN 775 ELSE 776 END, -- A AMEND - C CANCEL
                o_ORDER_TYPE           => p_ORDER_TYPE,
                o_PRICE                => p_PRICE_YIELD,
                o_QNTY                 => p_VOLUME,
                o_nin_code             => p_INVESTOR_CODE,
                o_TRADER_SERIAL_ID     => p_TRADER_SERIAL,
                o_BOOK_KEEPER          => p_BOOKKEPR,
                o_CLEAN_PRICE          => vCLEAN_PRICE_VALUE,
                o_CURRENT_YIELD        => vCURRENT_YIELD,
                o_GROSS_PRICE          => vGROSS_PRICE,
                o_YTM                  => vYTM,
                o_ACCRUED_INTEREST     => vACCRUED_INTEREST,
                o_SETTLEMENT_VALUE     => vSETTLEMENT_VALUE,
                o_DAYS_TO_MATURITY     => vMATURITY_DAYS,
                o_SETTLEMENT_DATE      => vSETTLEMENT_DATE,
                old_ORDER_STATUS       => vORDER_STATUS_old,
                old_PRICE              => p_PRICE_YIELD_OLD,
                old_ORG_QNTY           => vORG_QNTY_old,
                old_QNTY               => p_VOLUME_OLD,
                old_TRADER_SERIAL_ID   => vTRADER_SERIAL_old,
                old_BOOK_KEEPER        => p_BOOKKEPR_OLD,
                old_CLEAN_PRICE        => vCLEAN_PRICE_VALUE_OLD,
                old_CURRENT_YIELD      => vCURRENT_YIELD_OLD,
                old_GROSS_PRICE        => vGROSS_PRICE_OLD,
                old_YTM                => vYTM_OLD,
                old_ACCRUED_INTEREST   => vACCRUED_INTEREST_OLD,
                old_SETTLEMENT_VALUE   => vSETTLEMENT_VALUE_OLD,
                old_DAYS_TO_MATURITY   => vMATURITY_DAYS,
                old_SETTLEMENT_DATE    => vSETTLEMENT_DATE,
                o_Is_Dual              => 'N',
                o_dual_seq             => 0,
                o_par_value            => vPAR_VALUE,
                o_Is_Bill              =>
                    CASE WHEN vSEC_TYPE = 2 THEN 1 ELSE 0 END,
                O_FIRM_ORDER_ID        => p_FIRM_ORDER_NUMBER,
                o_Conv_Rate            => vCONV_RATE,
                o_done_flag            => RETURN_STATUS,
                o_done_desc            => RETURN_MESSGAE);



            COMMIT;

            IF vSEC_TYPE = 1 AND RETURN_STATUS > 0 AND P_ACTION = 'A'
            THEN
                OPEN P_RECORDSET_OUT FOR
                    SELECT 'BOND'                  TTYPE,
                           P_ORDER_NUMBER          EGX_ORDER_NUMBER,
                           p_FIRM_ORDER_NUMBER     FIRM_ORDER_NUMBER,
                           vSETTLEMENT_DATE        SETTLEMENT_DATE,
                           p_ISIN_CODE             ISIN,
                           vFIRM_CODE              FIRM_CODE,
                           p_BOOKKEPR              BOOKKEEPER,
                           p_INVESTOR_CODE         INVESTOR_CODE,
                           P_PRICE_YIELD           CLEAN_PRICE_PER,
                           vCLEAN_PRICE_VALUE      CLEAN_PRICE_VALUE,
                           vYTM                    YTM,
                           vACCRUED_INTEREST       ACCRUED_INTEREST,
                           vCURRENT_YIELD          CURRENT_YIELD,
                           vACCRUAL_PERIOD         ACCRUAL_PERIOD,
                           P_VOLUME                AMOUNT,
                           vGROSS_PRICE            GROSS_PRICE,
                           vSETTLEMENT_VALUE       SETTLEMENT_VALUE
                      FROM DUAL;
            --  RETURN_MESSGAE :=
            --    SUBSTR (RETURN_MESSGAE, 1, LENGTH (RETURN_MESSGAE) - 12);
            ELSIF vSEC_TYPE = 2 AND RETURN_STATUS > 0 AND P_ACTION = 'A'
            THEN
                OPEN P_RECORDSET_OUT FOR
                    SELECT 'BILL'                  TTYPE,
                           --TO_NUMBER (SUBSTR (RETURN_MESSGAE, -12))
                           P_ORDER_NUMBER          EGX_ORDER_NUMBER,
                           p_FIRM_ORDER_NUMBER     FIRM_ORDER_NUMBER,
                           vSETTLEMENT_DATE        SETTLEMENT_DATE,
                           p_ISIN_CODE             ISIN,
                           vFIRM_CODE              FIRM_CODE,
                           p_BOOKKEPR              BOOKKEEPER,
                           p_INVESTOR_CODE         INVESTOR_CODE,
                           P_PRICE_YIELD           YIELD,
                           vCLEAN_PRICE_VALUE      PRICE_VALUE,
                           P_VOLUME                AMOUNT,
                           vGROSS_PRICE            GROSS_PRICE,
                           vSETTLEMENT_VALUE       SETTLEMENT_VALUE,
                           vCURRENCY               CURRENCY,
                           vCONV_RATE              CONV_RATE
                      FROM DUAL;
            --RETURN_MESSGAE :=
            --  SUBSTR (RETURN_MESSGAE, 1, LENGTH (RETURN_MESSGAE) - 12);
            ELSIF RETURN_STATUS > 0 AND P_ACTION = 'C'
            THEN
                OPEN P_RECORDSET_OUT FOR
                    SELECT 'ORDER ' || P_ORDER_NUMBER || '  CANCELED . '    RESULT
                      FROM DUAL;
            ELSE
                RETURN_MESSGAE := RETURN_MESSGAE; -- vVALIDATE || RETURN_STATUS ||

                -- Error on insert
                OPEN P_RECORDSET_OUT FOR
                    SELECT RETURN_MESSGAE RESULT FROM DUAL;

                RETURN_STATUS := 0;


                INSERT INTO ETP_ORDER_REJECTED (ORDER_ID,
                                                FIRM_SERIAL_ID,
                                                TRADER_SERIAL_ID,
                                                SEC_ISIN_CODE,
                                                ORDER_TYPE,
                                                ORDER_STATUS,
                                                INSERT_DATE,
                                                PRICE,
                                                ORG_QNTY,
                                                NIN,
                                                BOOK_KEEPER,
                                                FIRM_ORDER_ID,
                                                CLEAN_PRICE,
                                                CURRENT_YIELD,
                                                YTM,
                                                ACCRUED_INTEREST,
                                                SETTLEMENT_VALUE,
                                                DAYS_TO_MATURITY,
                                                REJECT_REASON)
                     VALUES (P_ORDER_NUMBER,
                             p_FIRM_SERIAL,
                             p_TRADER_SERIAL,
                             p_ISIN_CODE,
                             p_ORDER_TYPE,
                             CASE WHEN P_ACTION = 'A' THEN 775 ELSE 776 END,
                             SYSDATE,
                             p_PRICE_YIELD,
                             p_VOLUME,
                             p_INVESTOR_CODE,
                             p_BOOKKEPR,
                             p_FIRM_ORDER_NUMBER,
                             vCLEAN_PRICE_VALUE,
                             vCURRENT_YIELD,
                             vYTM,
                             vACCRUED_INTEREST,
                             vSETTLEMENT_VALUE,
                             vMATURITY_DAYS,
                             RETURN_MESSGAE);


                INSERT INTO ETP_API_ERROR_LOG
                     VALUES ('AMEND_CANCEL_ORDER',
                             RETURN_MESSGAE,
                             vFIRM_CODE,
                             SYSDATE);

                COMMIT;
            END IF;
        ELSE
            -- -- Error on validate
            OPEN P_RECORDSET_OUT FOR SELECT vVALIDATE RESULT FROM DUAL;

            RETURN_MESSGAE := vVALIDATE;
            RETURN_STATUS := 0;

            INSERT INTO ETP_ORDER_REJECTED (FIRM_SERIAL_ID,
                                            TRADER_SERIAL_ID,
                                            SEC_ISIN_CODE,
                                            ORDER_TYPE,
                                            ORDER_STATUS,
                                            INSERT_DATE,
                                            PRICE,
                                            ORG_QNTY,
                                            NIN,
                                            BOOK_KEEPER,
                                            FIRM_ORDER_ID,
                                            CLEAN_PRICE,
                                            CURRENT_YIELD,
                                            YTM,
                                            ACCRUED_INTEREST,
                                            SETTLEMENT_VALUE,
                                            DAYS_TO_MATURITY,
                                            REJECT_REASON)
                 VALUES (p_FIRM_SERIAL,
                         p_TRADER_SERIAL,
                         p_ISIN_CODE,
                         p_ORDER_TYPE,
                         CASE WHEN P_ACTION = 'A' THEN 775 ELSE 776 END,
                         SYSDATE,
                         p_PRICE_YIELD,
                         p_VOLUME,
                         p_INVESTOR_CODE,
                         p_BOOKKEPR,
                         p_FIRM_ORDER_NUMBER,
                         vCLEAN_PRICE_VALUE,
                         vCURRENT_YIELD,
                         vYTM,
                         vACCRUED_INTEREST,
                         vSETTLEMENT_VALUE,
                         vMATURITY_DAYS,
                         RETURN_MESSGAE);


            INSERT INTO ETP_API_ERROR_LOG
                 VALUES ('ORDER VALIDATE',
                         vVALIDATE,
                         vFIRM_CODE,
                         SYSDATE);

            COMMIT;
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK;

            OPEN P_RECORDSET_OUT FOR
                SELECT 'ERROR: No Data inserted' RESULT FROM DUAL;

            RETURN_STATUS := 0;
            RETURN_MESSGAE := 'ERROR: No Data inserted';

            INSERT INTO ETP_API_ERROR_LOG
                     VALUES (
                                'AMEND_CANCEL_ORDER',
                                SUBSTR (
                                       DBMS_UTILITY.format_error_backtrace
                                    || DBMS_UTILITY.format_error_stack,
                                    1,
                                    400),
                                p_FIRM_SERIAL,
                                SYSDATE);

            COMMIT;
    END;

    PROCEDURE API_INSERT_ORDER (p_FIRM_SERIAL             NUMBER,
                                p_TRADER_SERIAL           NUMBER,
                                p_ISIN_CODE               VARCHAR2,
                                p_ORDER_TYPE              VARCHAR2,
                                p_VOLUME                  NUMBER,
                                P_IS_PRICE                NUMBER,
                                p_PRICE_YIELD             NUMBER,
                                p_BOOKKEPR                NUMBER,
                                p_INVESTOR_CODE           NUMBER,
                                p_FIRM_ORDER_NUMBER       VARCHAR2,
                                RETURN_STATUS         OUT NUMBER,
                                RETURN_MESSGAE        OUT VARCHAR2,
                                P_RECORDSET_OUT       OUT SYS_REFCURSOR)
    AS
        vCLEAN_PRICE_VALUE   NUMBER;
        vCURRENT_YIELD       NUMBER;
        vGROSS_PRICE         NUMBER;
        vYTM                 NUMBER;
        vACCRUED_INTEREST    NUMBER;
        vVALIDATE            VARCHAR (350);
        vSEC_TYPE            NUMBER;
        vSEC_SERIAL_ID       NUMBER;
        vSETTLEMENT_DATE     VARCHAR2 (15);
        vACCRUAL_PERIOD      NUMBER;
        vPAR_VALUE           NUMBER;
        vSETTLEMENT_VALUE    NUMBER;
        vFIRM_CODE           NUMBER;
        vCURRENCY            VARCHAR2 (15);
        vCONV_RATE           NUMBER;
        vMATURITY_DAYS       NUMBER;
        vSTATUS              NUMBER (1);
        
       
    BEGIN
        -- Validate All Input Data if Valide return sec_type and settlelment
        API_VALIDATE (p_VALIDATE_TYPE     => 'O',
                      P_SELL_FIRM         => p_FIRM_SERIAL,
                      P_BUY_FIRM          => p_FIRM_SERIAL,
                      P_TRADER_CODE       => p_TRADER_SERIAL,
                      P_ISIN              => p_ISIN_CODE,
                      P_SETTLEMENT        => 0,
                      P_SELL_NIN          => p_INVESTOR_CODE,
                      P_BUY_NIN           => p_INVESTOR_CODE,
                      P_SELL_BOOK         => p_BOOKKEPR,
                      P_BUY_BOOK          => p_BOOKKEPR,
                      P_PRICE_YIELD       => p_PRICE_YIELD,
                      P_VOLUME            => p_VOLUME,
                      P_REPO_TYPE         => NULL,
                      p_SEC_TYPE          => vSEC_TYPE,
                      p_SEC_SERIAL_ID     => vSEC_SERIAL_ID,
                      p_SETTLEMENT_DATE   => vSETTLEMENT_DATE,
                      p_ACCRUAL_PERIOD    => vACCRUAL_PERIOD,
                      p_PAR_VALUE         => vPAR_VALUE,
                      p_SELL_FIRM_CODE    => vFIRM_CODE,
                      p_BUY_FIRM_CODE     => vFIRM_CODE,
                      p_CURRENCY          => vCURRENCY,
                      p_CONV_RATE         => vCONV_RATE,
                      p_MATURITY_DAYS     => vMATURITY_DAYS,
                      p_RESULT            => vVALIDATE);


        IF SUBSTR (vValidate, 1, 5) != 'ERROR'
        THEN
            vSTATUS := 1;

            --  CASE WHEN vSELL_FIRM_CODE = vBUY_FIRM_CODE THEN 3 ELSE 1 END;

            IF vSEC_TYPE = 1
            THEN                                           -- BOND 1    BILL 2
                -- get Price details
                SELECT ETP_FUNC_CLEAN_PRICE (p_ISIN_CODE, p_PRICE_YIELD),
                       ETP_FUNC_CURRENT_YIELD (p_ISIN_CODE, p_PRICE_YIELD),
                       ROUND (
                           ETP_FUNC_GROSS_PRICE (p_ISIN_CODE,
                                                 p_PRICE_YIELD,
                                                 vSETTLEMENT_DATE),
                           7),
                       ROUND (
                           ETP_FUNC_YTM (p_ISIN_CODE,
                                         p_PRICE_YIELD,
                                         vSETTLEMENT_DATE),
                           7),
                       ROUND (
                           ETP_FUNC_ACCRUED_INTEREST (p_ISIN_CODE,
                                                      vSETTLEMENT_DATE),
                           7)
                  INTO vCLEAN_PRICE_VALUE,
                       vCURRENT_YIELD,
                       vGROSS_PRICE,
                       vYTM,
                       vACCRUED_INTEREST
                  FROM DUAL;

                vSETTLEMENT_VALUE :=
                    ROUND ((P_VOLUME * vGROSS_PRICE) / vPAR_VALUE, 2);
            ELSE                                                      -- bills
                vCLEAN_PRICE_VALUE :=
                    ETP_FUNC_BILL_PRICE (
                        p_PRICE_YIELD,
                        vMATURITY_DAYS,
                        CASE WHEN vCONV_RATE = 1 THEN 365 ELSE 360 END);

                vSETTLEMENT_VALUE :=
                    ROUND (P_VOLUME * vCLEAN_PRICE_VALUE * vCONV_RATE, 2);
            END IF;



            etp_match_proc (
                o_order_id           => 0,
                o_SEC_SERIAL_ID      => vSEC_SERIAL_ID,
                o_ISIN               => p_ISIN_CODE,
                o_FIRM_SERIAL_ID     => p_FIRM_SERIAL,
                o_ORDER_STATUS       => 772,
                o_MODIFIED_DATE      => NULL,
                o_ORDER_TYPE         => p_ORDER_TYPE,
                o_PRICE              => p_PRICE_YIELD,
                o_QNTY               => p_VOLUME,
                o_NIN                => p_INVESTOR_CODE,
                o_TRADER_SERIAL_ID   => p_TRADER_SERIAL,
                o_BOOK_KEEPER        => p_BOOKKEPR,
                o_CLEAN_PRICE        => vCLEAN_PRICE_VALUE,
                o_CURRENT_YIELD      => vCURRENT_YIELD,
                o_GROSS_PRICE        => vGROSS_PRICE,
                o_YTM                => vYTM,
                o_ACCRUED_INTEREST   => vACCRUED_INTEREST,
                o_SETTLEMENT_VALUE   => vSETTLEMENT_VALUE,
                o_DAYS_TO_MATURITY   => vMATURITY_DAYS,
                o_SETTLEMENT_DATE    => vSETTLEMENT_DATE,
                o_Is_Dual            => 'N',
                o_dual_seq           => 0,
                o_par_value          => vPAR_VALUE,
                o_Is_Bill            =>
                    CASE WHEN vSEC_TYPE = 2 THEN 1 ELSE 0 END,
                O_FIRM_ORDER_ID      => p_FIRM_ORDER_NUMBER,
                o_done_flag          => RETURN_STATUS,
                o_done_desc          => RETURN_MESSGAE);
-----modified 27012026
         --   COMMIT;

            IF vSEC_TYPE = 1 AND RETURN_STATUS > 0
            THEN
            RETURN_STATUS := 1;
                OPEN P_RECORDSET_OUT FOR
                    SELECT 'BOND'
                               TTYPE,
                           TO_NUMBER (SUBSTR (RETURN_MESSGAE, -12))
                               EGX_ORDER_NUMBER,
                           p_FIRM_ORDER_NUMBER
                               FIRM_ORDER_NUMBER,
                           vSETTLEMENT_DATE
                               SETTLEMENT_DATE,
                           p_ISIN_CODE
                               ISIN,
                           vFIRM_CODE
                               FIRM_CODE,
                           p_BOOKKEPR
                               BOOKKEEPER,
                           p_INVESTOR_CODE
                               INVESTOR_CODE,
                           P_PRICE_YIELD
                               CLEAN_PRICE_PER,
                           vCLEAN_PRICE_VALUE
                               CLEAN_PRICE_VALUE,
                           vYTM
                               YTM,
                           vACCRUED_INTEREST
                               ACCRUED_INTEREST,
                           vCURRENT_YIELD
                               CURRENT_YIELD,
                           vACCRUAL_PERIOD
                               ACCRUAL_PERIOD,
                           P_VOLUME
                               AMOUNT,
                           vGROSS_PRICE
                               GROSS_PRICE,
                           vSETTLEMENT_VALUE
                               SETTLEMENT_VALUE
                      FROM DUAL;

                RETURN_MESSGAE :=
                    SUBSTR (RETURN_MESSGAE, 1, LENGTH (RETURN_MESSGAE) - 12);
            ELSIF vSEC_TYPE = 2 AND RETURN_STATUS > 0
            THEN
            RETURN_STATUS := 1;
                OPEN P_RECORDSET_OUT FOR
                    SELECT 'BILL'
                               TTYPE,
                           TO_NUMBER (SUBSTR (RETURN_MESSGAE, -12))
                               EGX_ORDER_NUMBER,
                           p_FIRM_ORDER_NUMBER
                               FIRM_ORDER_NUMBER,
                           vSETTLEMENT_DATE
                               SETTLEMENT_DATE,
                           p_ISIN_CODE
                               ISIN,
                           vFIRM_CODE
                               FIRM_CODE,
                           p_BOOKKEPR
                               BOOKKEEPER,
                           p_INVESTOR_CODE
                               INVESTOR_CODE,
                           P_PRICE_YIELD
                               YIELD,
                           vCLEAN_PRICE_VALUE
                               PRICE_VALUE,
                           P_VOLUME
                               AMOUNT,
                           vGROSS_PRICE
                               GROSS_PRICE,
                           vSETTLEMENT_VALUE
                               SETTLEMENT_VALUE,
                           vCURRENCY
                               CURRENCY,
                           vCONV_RATE
                               CONV_RATE
                      FROM DUAL;

                RETURN_MESSGAE :=
                    SUBSTR (RETURN_MESSGAE, 1, LENGTH (RETURN_MESSGAE) - 12);
            ELSE
                -- Error on insert
                OPEN P_RECORDSET_OUT FOR
                    SELECT RETURN_MESSGAE RESULT FROM DUAL;

                RETURN_STATUS := 0;
                -------- modified 27012026    
            rollback ;
     -----------------------------------

                INSERT INTO ETP_ORDER_REJECTED (FIRM_SERIAL_ID,
                                                TRADER_SERIAL_ID,
                                                SEC_ISIN_CODE,
                                                ORDER_TYPE,
                                                ORDER_STATUS,
                                                INSERT_DATE,
                                                PRICE,
                                                ORG_QNTY,
                                                NIN,
                                                BOOK_KEEPER,
                                                FIRM_ORDER_ID,
                                                CLEAN_PRICE,
                                                CURRENT_YIELD,
                                                YTM,
                                                ACCRUED_INTEREST,
                                                SETTLEMENT_VALUE,
                                                DAYS_TO_MATURITY,
                                                REJECT_REASON)
                     VALUES (p_FIRM_SERIAL,
                             p_TRADER_SERIAL,
                             p_ISIN_CODE,
                             p_ORDER_TYPE,
                             772,
                             SYSDATE,
                             p_PRICE_YIELD,
                             p_VOLUME,
                             p_INVESTOR_CODE,
                             p_BOOKKEPR,
                             p_FIRM_ORDER_NUMBER,
                             vCLEAN_PRICE_VALUE,
                             vCURRENT_YIELD,
                             vYTM,
                             vACCRUED_INTEREST,
                             vSETTLEMENT_VALUE,
                             vMATURITY_DAYS,
                             RETURN_MESSGAE);

                INSERT INTO ETP_API_ERROR_LOG
                     VALUES ('INSERT_ORDER',
                             RETURN_MESSGAE,
                             vFIRM_CODE,
                             SYSDATE);

                COMMIT;
            END IF;
        ELSE
            -- -- Error on validate
            OPEN P_RECORDSET_OUT FOR SELECT vVALIDATE RESULT FROM DUAL;

            RETURN_STATUS := 0;
            RETURN_MESSGAE := vVALIDATE;
     -------- modified 27012026    
            rollback ;
     -----------------------------------
            INSERT INTO ETP_ORDER_REJECTED (FIRM_SERIAL_ID,
                                            TRADER_SERIAL_ID,
                                            SEC_ISIN_CODE,
                                            ORDER_TYPE,
                                            ORDER_STATUS,
                                            INSERT_DATE,
                                            PRICE,
                                            ORG_QNTY,
                                            NIN,
                                            BOOK_KEEPER,
                                            FIRM_ORDER_ID,
                                            REJECT_REASON)
                 VALUES (p_FIRM_SERIAL,
                         p_TRADER_SERIAL,
                         p_ISIN_CODE,
                         p_ORDER_TYPE,
                         772,
                         SYSDATE,
                         p_PRICE_YIELD,
                         p_VOLUME,
                         p_INVESTOR_CODE,
                         p_BOOKKEPR,
                         p_FIRM_ORDER_NUMBER,
                         vVALIDATE);


            INSERT INTO ETP_API_ERROR_LOG
                 VALUES ('ORDER VALIDATE',
                         vVALIDATE,
                         vFIRM_CODE,
                         SYSDATE);

            COMMIT;
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK;
            OPEN P_RECORDSET_OUT FOR
                SELECT 'ERROR: No Data inserted' RESULT FROM DUAL;

            RETURN_STATUS := 0;
            RETURN_MESSGAE := vVALIDATE;

            INSERT INTO ETP_API_ERROR_LOG
                     VALUES (
                                'INSERT_ORDER',
                                SUBSTR (
                                       DBMS_UTILITY.format_error_backtrace
                                    || DBMS_UTILITY.format_error_stack,
                                    1,
                                    400),
                                p_FIRM_SERIAL,
                                SYSDATE);

            COMMIT;
    END;

    PROCEDURE API_CONFIRM_TRADE (p_TRANS_CODE          NUMBER,
                                 p_BUY_FIRM            NUMBER,
                                 p_BUY_NIN             NUMBER DEFAULT 0,
                                 p_BUY_BOOK            NUMBER DEFAULT 0,
                                 p_TRADER_CODE         NUMBER,
                                 p_ACTION              VARCHAR2, -- A ACCEPT  ,  R REJECTED
                                 p_REJECT_RESONE       VARCHAR2 DEFAULT NULL,
                                 RETURN_STATUS     OUT NUMBER,
                                 P_RECORDSET_OUT   OUT SYS_REFCURSOR)
    AS
        vVALID_DATA      VARCHAR2 (11);
        vVALID_BOOK      VARCHAR2 (1) := 'A';
        vVALID_NIN       VARCHAR2 (1) := 'A';
        vSEC_TYPE        VARCHAR2 (1);
        vSEC_SERIAL      NUMBER;
        vResult          VARCHAR2 (400);
        IERRORCODE_OUT   NUMBER;
    BEGIN
        vResult := NULL;

        --
        -- Market Check before get datails
        IF calendar_time_check (2) > 1      -- CHECK  Trade Report market TIME
        THEN
            vResult := ' Market Closed !';
        ELSE                                            -- Validate Input data
            SELECT NVL (
                       (SELECT    CASE
                                      WHEN SELL_NIN_CODE !=
                                           NVL (p_BUY_NIN, 0)
                                      THEN
                                          'A'
                                      ELSE
                                          'X'
                                  END
                               || CASE
                                      WHEN SUBSTR (ISIN, 1, 3) = 'EGB'
                                      THEN
                                          'B'
                                      ELSE
                                          'b'
                                  END
                               || LPAD (SEC_SERIAL_ID, 9, '0') -- B BOND -- b bill
                          FROM ETP_TRADE_REPORT
                         WHERE     TRANS_CODE = p_TRANS_CODE
                               AND BUY_FIRM_SERIAL_ID = p_BUY_FIRM
                               AND TRUNC (TRANS_DATE) = TRUNC (SYSDATE)
                               AND STATUS_CODE = 1
                               AND p_ACTION IN ('A', 'R')),
                       'Z')    VALID_DATA
              INTO vVALID_DATA
              FROM DUAL;

            vSEC_TYPE := SUBSTR (vVALID_DATA, 2, 1);
            vSEC_SERIAL := TO_NUMBER (SUBSTR (vVALID_DATA, 3));
            vVALID_DATA := SUBSTR (vVALID_DATA, 1, 1);

            /* IF p_ACTION = 1 AND vVALID_DATA != 'Z'
             THEN                      -- ACCEPT NEED TO VALIDATE  NIN AND BOOK

             END IF;*/


            IF vVALID_DATA = 'Z'                        -- Error in input Data
            THEN
                vResult :=
                    ' Invalid Input data or Transaction handele by other user !';
            ELSIF vVALID_DATA = 'X'
            THEN
                vResult := ' Buyer nin equal to Seller nin !';
            ELSIF vVALID_DATA = 'A' AND p_ACTION = 'A' --- Accept and main validation true
            THEN
                -- Validate book keeper and nins
                SELECT NVL (
                           (SELECT BROKER_STATUS
                              FROM ETP_BKKP
                             WHERE     BROKER_CODE = p_BUY_BOOK
                                   AND RECORD_ACTIVE_IND = 'Y'),
                           'Z')    VALID_BOOK,
                       NVL (
                           (SELECT CASE
                                       WHEN FIELD_13 IN (0, 1) THEN 'A'
                                       ELSE 'S'
                                   END
                              FROM CLIENT
                             WHERE FIELD_1 = p_BUY_NIN),
                           'Z')    VALID_NIN
                  INTO vVALID_BOOK, vVALID_NIN
                  FROM DUAL;

                -- validate other parameters
                etp_CHECK_ALL_STATUS (p_TRADER_CODE,
                                      p_BUY_FIRM,
                                      2,
                                      vSEC_SERIAL,
                                      0,
                                      vResult,
                                      RETURN_STATUS,
                                      IERRORCODE_OUT);

                IF vVALID_BOOK = 'Z'
                THEN
                    vResult := ' Not A Valid Book Keeper !';
                ELSIF vVALID_BOOK != 'A'
                THEN
                    vResult := vResult || ' Suspended Book Keeper !';
                END IF;

                IF vVALID_NIN = 'Z'
                THEN
                    vResult := vResult || ' Not A Valid Customer !';
                ELSIF vVALID_BOOK != 'A'
                THEN
                    vResult := vResult || ' Suspended Customer !';
                END IF;
            END IF;
        END IF;

        IF vResult IS NULL                            --BASIC VALIDATION IS OK
        THEN
            IF p_ACTION = 'A'
            THEN                                                     -- ACCEPT
                UPDATE ETP_TRADE_REPORT
                   SET STATUS_CODE = 3,
                       UPDATE_USER = p_TRADER_CODE,
                       UPDATE_DATE = SYSDATE,
                       BUY_BOOK_KEEPER = p_BUY_BOOK,
                       BUY_NIN_CODE = p_BUY_NIN
                 WHERE TRANS_CODE = p_TRANS_CODE AND STATUS_CODE = 1;
            ELSE
                UPDATE ETP_TRADE_REPORT
                   SET STATUS_CODE = 6,
                       UPDATE_USER = p_TRADER_CODE,
                       UPDATE_DATE = SYSDATE
                 WHERE TRANS_CODE = p_TRANS_CODE AND STATUS_CODE = 1;
            END IF;

            IF SQL%ROWCOUNT != 0
            THEN
                COMMIT;

                IF p_ACTION = 'A' --Accept                                     -- SWIFT
                THEN
                    ETP_INSERT_SWIFT_TICKET (p_TRANS_CODE);
                    COMMIT;

                    IF vSEC_TYPE = 'B'
                    THEN
                        OPEN P_RECORDSET_OUT FOR
                            SELECT 'BOND'
                                       TTYPE,
                                   TRANS_CODE
                                       TRADE_NUMBER,
                                   SETTLEMENT_DATE,
                                   ISIN,
                                   (SELECT FIRM_CODE
                                      FROM ETP_FIRM
                                     WHERE FIRM_SERIAL_ID =
                                           SELL_FIRM_SERIAL_ID)
                                       SELL_FIRM_CODE,
                                   (SELECT FIRM_CODE
                                      FROM ETP_FIRM
                                     WHERE FIRM_SERIAL_ID =
                                           BUY_FIRM_SERIAL_ID)
                                       BUY_FIRM_CODE,
                                   BUY_BOOK_KEEPER
                                       BUY_BOOK,
                                   BUY_NIN_CODE
                                       BUY_NIN,
                                   PRICE
                                       CLEAN_PRICE_PER,
                                   CLEAN_PRICE
                                       CLEAN_PRICE_VALUE,
                                   YIELD_TO_MATURITY
                                       YTM,
                                   ACCRUED_INTEREST,
                                   CURRENT_YIELD,
                                   ACCRUAL_PERIOD
                                       ACCRUAL_PERIOD,
                                   AMOUNT_TRADED
                                       AMOUNT,
                                   GROSS_PRICE,
                                   SETTLEMENT_VALUE,
                                   NVL (REPO_TYPE, 'NOT')
                                       REPO_TYPE
                              FROM ETP_TRADE_REPORT
                             WHERE TRANS_CODE = p_TRANS_CODE;
                    ELSE
                        OPEN P_RECORDSET_OUT FOR
                            SELECT 'BILL'
                                       TTYPE,
                                   TRANS_CODE
                                       TRADE_NUMBER,
                                   SETTLEMENT_DATE,
                                   ISIN,
                                   (SELECT FIRM_CODE
                                      FROM ETP_FIRM
                                     WHERE FIRM_SERIAL_ID =
                                           SELL_FIRM_SERIAL_ID)
                                       SELL_FIRM_CODE,
                                   (SELECT FIRM_CODE
                                      FROM ETP_FIRM
                                     WHERE FIRM_SERIAL_ID =
                                           BUY_FIRM_SERIAL_ID)
                                       BUY_FIRM_CODE,
                                   BUY_BOOK_KEEPER
                                       BUY_BOOK,
                                   BUY_NIN_CODE
                                       BUY_NIN,
                                   PRICE
                                       YIELD,
                                   CLEAN_PRICE
                                       PRICE_VALUE,
                                   AMOUNT_TRADED
                                       AMOUNT,
                                   SETTLEMENT_VALUE,
                                   ETP_TSFUND.FUND_NAME_SHORT
                                       CURRENCY,
                                   FUNDS_CONV.FUNDS_CONVERSION
                                       CONV_RATE,
                                   --  DAYS_TO_MATURITY,
                                   NVL (REPO_TYPE, 'NOT')
                                       REPO_TYPE
                              FROM ETP_SECURITIES,
                                   ETP_TRADE_REPORT,
                                   FUNDS_CONV,
                                   ETP_TSFUND
                             WHERE     ETP_SECURITIES.SEC_SERIAL_ID =
                                       ETP_TRADE_REPORT.SEC_SERIAL_ID
                                   AND TO_NUMBER (FUNDS_CONV.FUNDS_CODE) =
                                       ETP_SECURITIES.SEC_LIST_CURRENCY
                                   AND ETP_TSFUND.FUNDS_CODE =
                                       ETP_SECURITIES.SEC_LIST_CURRENCY
                                   AND ETP_TRADE_REPORT.TRANS_CODE =
                                       p_TRANS_CODE;
                    END IF;
                ELSIF p_ACtion = 'R'
                THEN                                                 -- Reject
                    OPEN P_RECORDSET_OUT FOR
                        SELECT 'REJECT' TTYPE, p_TRANS_CODE TRADE_NUMBER
                          FROM DUAL;
                END IF;

                RETURN_STATUS := 1;
            ELSE
                ROLLBACK;
                RETURN_STATUS := 0;
                vResult := 'Transaction handeled by another user ! ';
            END IF;
        ELSE
            -- Return Error
            OPEN P_RECORDSET_OUT FOR SELECT vResult RESULT FROM DUAL;

            RETURN_STATUS := 0;

            INSERT INTO ETP_API_ERROR_LOG
                 VALUES ('CONFIRM_TRADE',
                         vResult,
                         p_BUY_FIRM,
                         SYSDATE);
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK;

            OPEN P_RECORDSET_OUT FOR
                SELECT 'ERROR: No Data Updated' RESULT FROM DUAL;

            RETURN_STATUS := 0;

            INSERT INTO ETP_API_ERROR_LOG
                     VALUES (
                                'CONFIRM_TRADE',
                                SUBSTR (
                                       DBMS_UTILITY.format_error_backtrace
                                    || DBMS_UTILITY.format_error_stack,
                                    1,
                                    400),
                                p_BUY_FIRM,
                                SYSDATE);

            COMMIT;
    END;

    PROCEDURE API_VALIDATE (p_VALIDATE_TYPE         VARCHAR2 DEFAULT 'SB',
                            p_SELL_FIRM             NUMBER DEFAULT 0,
                            p_BUY_FIRM              NUMBER DEFAULT 0,
                            p_TRADER_CODE           NUMBER DEFAULT 0,
                            p_ISIN                  VARCHAR2,
                            p_SETTLEMENT            NUMBER DEFAULT 0,
                            p_SELL_NIN              NUMBER DEFAULT 0,
                            p_BUY_NIN               NUMBER DEFAULT 0,
                            p_SELL_BOOK             NUMBER DEFAULT 0,
                            p_BUY_BOOK              NUMBER DEFAULT 0,
                            p_PRICE_YIELD           NUMBER DEFAULT 0,
                            p_VOLUME                NUMBER DEFAULT 0,
                            p_REPO_TYPE             VARCHAR2,
                            p_SEC_TYPE          OUT NUMBER,
                            p_SEC_SERIAL_ID     OUT NUMBER,
                            p_SETTLEMENT_DATE   OUT VARCHAR2,
                            p_ACCRUAL_PERIOD    OUT NUMBER,
                            p_PAR_VALUE         OUT NUMBER,
                            p_SELL_FIRM_CODE    OUT NUMBER,
                            p_BUY_FIRM_CODE     OUT NUMBER,
                            p_CURRENCY          OUT VARCHAR2,
                            p_CONV_RATE         OUT NUMBER,
                            p_MATURITY_DAYS     OUT NUMBER,
                            p_RESULT            OUT VARCHAR2)
    IS
        vResult                 VARCHAR2 (320);
        vSEC_ISIN_CODE          VARCHAR2 (12);
        vAMOUNT_VALIDATE        VARCHAR2 (1);
        vPRICE_RANGE            VARCHAR2 (1);
        vLAST_COUPON_DATE       DATE;
        vMATURITY_DATE          DATE;
        vBOND_STATUS            NUMBER (1);
        vSELL_FIRM_STATUS       NUMBER (1);
        vBUY_FIRM_STATUS        NUMBER (1);
        vSELL_FIRM_SEC_STATUS   NUMBER (1);
        vBUY_FIRM_SEC_STATUS    NUMBER (1);
        vSELL_KEEPER_STATUS     VARCHAR2 (1);
        vBUY_KEEPER_STATUS      VARCHAR2 (1);
        vSELL_CLIENT_STATUS     VARCHAR2 (10);
        vBUY_CLIENT_STATUS      VARCHAR2 (10);
    BEGIN
        vResult := NULL;

        -- CHECK FIRMS CODE
        IF (p_SELL_FIRM <= 0 OR p_SELL_FIRM > 9999)
        THEN
            vResult := ' Sell Firm !';
        END IF;

        IF (p_BUY_FIRM <= 0 OR p_BUY_FIRM > 9999)
        THEN
            vResult := ' Buy Firm !';
        END IF;

        -- CHECK TRADER CODE
        IF p_TRADER_CODE <= 0
        THEN
            vResult := ' Trader !';
        END IF;

        -- CHECK ISIN CODE
        IF    LENGTH (p_ISIN) != 12
           OR SUBSTR (p_ISIN, 1, 2) != 'EG'
           OR p_ISIN IS NULL
        THEN
            vResult := vResult || ' Isin !';
        END IF;

        -- CHECK SETTLEMENT DAYS
        IF p_SETTLEMENT < 0 OR p_SETTLEMENT > 5
        THEN
            vResult := ' Settlement !';
        END IF;

        -- CHECK NINS CODE
        IF p_SELL_NIN <= 0
        THEN
            vResult := ' Sell Nin !';
        END IF;

        IF p_BUY_Nin <= 0 AND (p_BUY_FIRM = p_SELL_FIRM)
        THEN
            vResult := ' Buy Nin !';
        END IF;

        IF     p_BUY_Nin = p_SELL_Nin
           AND (p_BUY_FIRM = p_SELL_FIRM)
           AND (p_VALIDATE_TYPE != 'O')
        THEN
            vResult := ' Buy and Sell Nins Is Equal !';
        END IF;

        -- CHECK FIRMS CODE
        IF p_SELL_BOOK <= 0 OR p_SELL_BOOK > 9999
        THEN
            vResult := ' Sell Book !';
        END IF;

        IF     (p_BUY_BOOK <= 0 OR p_BUY_BOOK > 9999)
           AND p_BUY_FIRM = p_SELL_FIRM
        THEN
            vResult := ' Buy Book !' || p_BUY_FIRM || ' -' || p_SELL_FIRM;
        END IF;

        -- CHECK VOLUME
        IF    p_VOLUME <= 0
           OR LENGTH (p_VOLUME) > 12
           OR (p_VOLUME - TRUNC (p_VOLUME)) > 0                  -- no decimal
        THEN
            vResult := ' Volume !';
        END IF;

        -- CHECK Price Yield
        IF    p_PRICE_YIELD <= 0
           OR LENGTH (p_PRICE_YIELD - TRUNC (p_PRICE_YIELD)) >
              CASE WHEN SUBSTR (p_ISIN, 1, 3) = 'EGB' THEN 8 ELSE 6 END -- decimal max is 7 digit FOR BOND 5 FOR BILL
        THEN
            vResult := ' Price Yield !';
        END IF;

        -- CHECK Repo
        IF p_REPO_TYPE IS NOT NULL
        THEN
            IF p_REPO_TYPE NOT IN ('DVP',
                                   'DVP-TAX',
                                   'FOP',
                                   'FOP-TAX')
            THEN
                vResult := vResult || ' Repo !';
            END IF;
        END IF;

        -- Market Check before get datails
        IF calendar_time_check (2) > 1      -- CHECK  Trade Report market TIME
        THEN
            vResult := ' Market Closed !';
        END IF;


        /* Database check if basic validate true*/

        IF vResult IS NULL                            --BASIC VALIDATION IS OK
        THEN
            SELECT ETP_SECURITIES.SEC_SERIAL_ID,
                   SEC_TYPE,
                   SEC_ISIN_CODE,
                   CASE
                       WHEN MOD (p_VOLUME, PARVALUE) = 0 THEN 'A'
                       ELSE 'Z'
                   END                            AMOUNT_VALIDATE,
                   CASE
                       WHEN p_PRICE_YIELD BETWEEN ETP_MARKETS_PRICE_RANGE.PRICE_MIN
                                              AND ETP_MARKETS_PRICE_RANGE.PRICE_MAX
                       THEN
                           'A'
                       ELSE
                           'Z'
                   END                            PRICE_RANGE,
                   NVL (
                       REGEXP_SUBSTR (
                           ETP_API.API_SETTLEMENT_DATES (
                               ETP_MARKET_SECURITIES.MARKET_CODE,
                               ETP_SECURITIES.SEC_ISIN_CODE),
                           '[^,]+',
                           1,
                           p_SETTLEMENT + 1),
                       'Z')                       SETTLEMENT_DATE,
                   BOND_STATUS,
                   ETP_FIRMS_SECURITIES.STATUS    SELL_FIRM_STATUS,
                   NVL (
                       (SELECT ND_FIRM.STATUS
                          FROM ETP_MARKET_SECURITIES  ND_MARK,
                               ETP_FIRMS_SECURITIES   ND_FIRM
                         WHERE     ND_MARK.SEC_SERIAL_ID =
                                   ETP_SECURITIES.SEC_SERIAL_ID
                               AND ND_FIRM.UNQ_ID = ND_MARK.UNQ_ID
                               AND ND_FIRM.FIRM_SERIAL_ID = p_BUY_FIRM
                               AND ND_MARK.MARKET_CODE = 2),
                       -1)                        BUY_FIRM_STATUS,
                   NVL (
                       (SELECT BROKER_STATUS
                          FROM ETP_BKKP
                         WHERE     BROKER_CODE = p_SELL_BOOK
                               AND RECORD_ACTIVE_IND = 'Y'),
                       'Z')                       SELL_KEEPER_STATUS,
                   CASE
                       WHEN p_BUY_FIRM = p_SELL_FIRM
                       THEN
                           NVL (
                               (SELECT BROKER_STATUS
                                  FROM ETP_BKKP
                                 WHERE     BROKER_CODE = p_BUY_BOOK
                                       AND RECORD_ACTIVE_IND = 'Y'),
                               'Z')
                       ELSE
                           'A'
                   END                            BUY_KEEPER_STATUS,
                   NVL (
                       (SELECT CASE
                                   WHEN FIELD_13 IN (0, 2) THEN 'A'
                                   ELSE 'S'
                               END
                          FROM CLIENT
                         WHERE FIELD_1 = p_SELL_NIN),
                       'Z')                       SELL_CLIENT_STATUS,
                   CASE
                       WHEN p_BUY_FIRM = p_SELL_FIRM
                       THEN
                           NVL (
                               (SELECT CASE
                                           WHEN FIELD_13 IN (0, 1) THEN 'A'
                                           ELSE 'S'
                                       END
                                  FROM CLIENT
                                 WHERE FIELD_1 = p_BUY_NIN),
                               'Z')
                       ELSE
                           'A'
                   END                            BUY_CLIENT_STATUS,
                   ETP_FIRM.FIRM_STATUS_ID        SELL_FIRM_STATUS,
                   NVL ( (SELECT FIRM_STATUS_ID
                            FROM ETP_FIRM
                           WHERE ETP_FIRM.FIRM_SERIAL_ID = p_BUY_FIRM),
                        -1)                       BUY_FIRM_STATUS,
                   ETP_SECURITIES.LAST_COUPON_PAYMENT,
                   ETP_SECURITIES.PARVALUE,
                   ETP_FIRM.FIRM_CODE             SELL_FIRM_CODE,
                   NVL ( (SELECT FIRM_CODE
                            FROM ETP_FIRM
                           WHERE ETP_FIRM.FIRM_SERIAL_ID = p_BUY_FIRM),
                        -1)                       BUY_FIRM_CODE,
                   FUNDS_CONV.FUNDS_CONVERSION    CONV_RATE,
                   ETP_TSFUND.FUND_NAME_SHORT,
                   ETP_SECURITIES.MATURITY_DATE
              INTO p_SEC_SERIAL_ID,
                   p_SEC_TYPE,
                   vSEC_ISIN_CODE,
                   vAMOUNT_VALIDATE,
                   vPRICE_RANGE,
                   p_SETTLEMENT_DATE,
                   vBOND_STATUS,
                   vSELL_FIRM_SEC_STATUS,
                   vBUY_FIRM_SEC_STATUS,
                   vSELL_KEEPER_STATUS,
                   vBUY_KEEPER_STATUS,
                   vSELL_CLIENT_STATUS,
                   vBUY_CLIENT_STATUS,
                   vSELL_FIRM_STATUS,
                   vBUY_FIRM_STATUS,
                   vLAST_COUPON_DATE,
                   p_PAR_VALUE,
                   p_SELL_FIRM_CODE,
                   p_BUY_FIRM_CODE,
                   p_CONV_RATE,
                   p_CURRENCY,
                   vMATURITY_DATE
              FROM ETP_SECURITIES,
                   FUNDS_CONV,
                   ETP_TSFUND,
                   ETP_MARKET_SECURITIES,
                   ETP_FIRMS_SECURITIES,
                   ETP_MARKETS_PRICE_RANGE,
                   ETP_FIRM
             WHERE     ETP_MARKET_SECURITIES.SEC_SERIAL_ID =
                       ETP_SECURITIES.SEC_SERIAL_ID
                   AND ETP_FIRM.FIRM_SERIAL_ID =
                       ETP_FIRMS_SECURITIES.FIRM_SERIAL_ID
                   AND ETP_FIRMS_SECURITIES.UNQ_ID =
                       ETP_MARKET_SECURITIES.UNQ_ID
                   AND TO_NUMBER (FUNDS_CONV.FUNDS_CODE) =
                       ETP_SECURITIES.SEC_LIST_CURRENCY
                   AND ETP_TSFUND.FUNDS_CODE =
                       ETP_SECURITIES.SEC_LIST_CURRENCY
                   AND BOND_STATUS != 2
                   AND (ETP_FIRM.ISTR = 1 OR ETP_FIRM.ISORDER = 1)
                   AND ETP_MARKET_SECURITIES.STATUS = 0
                   AND ETP_FIRMS_SECURITIES.STATUS = 0
                   AND ETP_FIRM.FIRM_SERIAL_ID = p_SELL_FIRM
                   AND ETP_MARKET_SECURITIES.MARKET_CODE = 2
                   AND ETP_SECURITIES.SEC_ISIN_CODE = p_ISIN
                   AND ETP_MARKETS_PRICE_RANGE.IS_BOND =
                       CASE WHEN SEC_TYPE = 1 THEN 'Y' ELSE 'N' END;
        END IF;

        -- CHECKS  RESULT
        IF vAMOUNT_VALIDATE = 'Z'
        THEN
            vResult := vResult || ' AMOUNT !';
        END IF;

        IF vPRICE_RANGE = 'Z'
        THEN
            vResult := vResult || ' PRICE RANGE !';
        END IF;

        IF vBOND_STATUS > 0
        THEN
            vResult := vResult || ' ISIN SUSPENDED !';
        END IF;

        IF p_SETTLEMENT_DATE = 'Z'
        THEN
            vResult := vResult || ' SETTLEMENT !';
        END IF;


        IF vSELL_FIRM_SEC_STATUS > 0
        THEN
            vResult := vResult || ' SELL FIRM ISIN !';
        END IF;

        IF vSELL_FIRM_STATUS > 0
        THEN
            vResult := vResult || ' SELL FIRM SUSPENDED !';
        END IF;

        IF vBUY_FIRM_STATUS = -1
        THEN
            vResult := vResult || ' BUY FIRM NOT EXIST !';
        END IF;

        IF vBUY_FIRM_STATUS > 0
        THEN
            vResult := vResult || ' BUY FIRM SUSPENDED !';
        END IF;

        IF vBUY_FIRM_SEC_STATUS = -1
        THEN
            vResult := vResult || ' BUY FIRM SEC NOT EXIST !';
        END IF;

        IF vBUY_FIRM_SEC_STATUS > 0
        THEN
            vResult := vResult || ' BUY FIRM ISIN !';
        END IF;

        IF vSELL_KEEPER_STATUS = 'S'
        THEN
            vResult := vResult || ' SELL BOOK SUSPEND !';
        END IF;

        IF vSELL_KEEPER_STATUS = 'Z'
        THEN
            vResult := vResult || ' SELL BOOK NOT EXIST !';
        END IF;

        IF vBUY_KEEPER_STATUS = 'S'
        THEN
            vResult := vResult || ' BUY BOOK SUSPEND !';
        END IF;

        IF vBUY_KEEPER_STATUS = 'Z'
        THEN
            vResult := vResult || ' BUY BOOK NOT EXIST !';
        END IF;

        IF vSELL_CLIENT_STATUS = 'S'
        THEN
            vResult := vResult || ' SELL NIN SUSPEND !';
        END IF;

        IF vSELL_CLIENT_STATUS = 'Z'
        THEN
            vResult := vResult || ' SELL NIN NOT EXIST !';
        END IF;

        IF vBUY_CLIENT_STATUS = 'S'
        THEN
            vResult := vResult || ' BUY NIN SUSPEND !';
        END IF;

        IF vBUY_CLIENT_STATUS = 'Z'
        THEN
            vResult := vResult || ' BUY NIN NOT EXIST !';
        END IF;

        IF vResult IS NOT NULL
        THEN
            vResult := 'ERROR Check ' || SUBSTR (vResult, 1, 300); -- found error
        ELSE
            p_ACCRUAL_PERIOD :=
                  TO_DATE (p_SETTLEMENT_DATE, 'DD/MM/YYYY')
                - TO_DATE (vLAST_COUPON_DATE, 'DD/MM/YYYY');
            --p_BUY_FIRM_CODE := p_SELL_FIRM_CODE;
            p_SETTLEMENT_DATE := TRIM (p_SETTLEMENT_DATE);
            p_MATURITY_DAYS :=
                  TO_DATE (vMATURITY_DATE, 'DD/MM/YYYY')
                - TO_DATE (p_SETTLEMENT_DATE, 'DD/MM/YYYY');
            vResult := 'VALID';
        END IF;

        p_Result := vResult;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            p_Result := 'ERROR Check ISIN , Sell Firm !';
        WHEN OTHERS
        THEN
            RAISE;
            p_Result := 'ERROR Abnormal Action!';
    -- log i
    END;
END;
/

