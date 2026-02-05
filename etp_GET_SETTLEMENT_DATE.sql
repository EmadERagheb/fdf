create PROCEDURE etp_GET_SETTLEMENT_DATE ( /*coupon date > settelment date*/
                                                          /*changed fot T+0   /* in go live  VALLOW_ZERO     =1*/
    P_MARKET_CODE         NUMBER,
    P_ISIN_CODE           VARCHAR2,
    P_RECORDSET_OUT   OUT SYS_REFCURSOR,
    IERRORCODE_OUT    OUT NUMBER)
AS
    VSETTLEMENT_TIME           VARCHAR2 (6);
    VSETTLEMENT_DAYS           NUMBER := 0;
    o_TRANS_DATE               DATE := TRUNC (SYSDATE);
    VNEXT_COUPON_DATE          DATE;
    --VALLOW_ZERO        NUMBER := 1;
    VSETTLEMENT_DAYS_DEFAULT   NUMBER := 1;
BEGIN
    IERRORCODE_OUT := 0;

    SELECT TO_CHAR (TRADE_STRAT_TIME, 'HH24MISS'),
           SETTLEMENT_DAYS,
           SETTLEMENT_DAYS_DEFAULT --1 ALLOW_ZERO -- 1 user can select T+0 else prevent it ( when SETTLEMENT_DAYS =1 only )
      INTO VSETTLEMENT_TIME, VSETTLEMENT_DAYS, VSETTLEMENT_DAYS_DEFAULT
      FROM ETP_MARKET
     WHERE ETP_MARKET.MARKET_CODE = P_MARKET_CODE;

    SELECT NEXT_COUPON_PAYMENT --,  CASE WHEN SEC_TYPE =2  THEN 1 ELSE VSETTLEMENT_DAYS_DEFAULT END -- IF BILLS AND TR THEN FORCE TO BE T+0
      INTO VNEXT_COUPON_DATE                     --,  VSETTLEMENT_DAYS_DEFAULT
      FROM ETP_SECURITIES
     WHERE SEC_ISIN_CODE = P_ISIN_CODE;

    IF TO_CHAR (SYSDATE, 'HH24MISS') < VSETTLEMENT_TIME
    THEN                                                             -- why ??
        OPEN P_RECORDSET_OUT FOR
            SELECT 0
                       DAY_COUNT,
                   o_TRANS_DATE
                       SETTLEMENT_DATE,
                   TO_CHAR (o_TRANS_DATE, 'DD/MM/YYYY') || ' T+0'
                       SETTLEMENT_Display,
                   VSETTLEMENT_DAYS_DEFAULT
                       SETTLEMENT_DAYS_DEFAULT
              FROM DUAL;
    ELSE
        OPEN P_RECORDSET_OUT FOR
            SELECT ROWNUM - 1                  DAY_COUNT,
                   DAY_DATE                    SETTLEMENT_DATE,
                      TO_CHAR (DAY_DATE, 'DD/MM/YYYY')
                   || ' T+'
                   || TO_CHAR (ROWNUM - 1)     SETTLEMENT_Display,
                   VSETTLEMENT_DAYS_DEFAULT    SETTLEMENT_DAYS_DEFAULT
              FROM (  SELECT DAY_DATE
                        FROM etp_CALENDER
                       WHERE     TO_CHAR (DAY_DATE, 'YYYYMMDD') >=
                                 TO_CHAR (o_TRANS_DATE, 'YYYYMMDD')
                             AND SETTLEMENT_FLAG = 'Y'
                             AND DAY_DATE < VNEXT_COUPON_DATE
                    ORDER BY DAY_DATE)
             WHERE ROWNUM <= VSETTLEMENT_DAYS + 1;
    END IF;
EXCEPTION
    WHEN OTHERS
    THEN
        IERRORCODE_OUT := SQLCODE;
END;
/

