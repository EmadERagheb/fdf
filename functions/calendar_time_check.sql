create FUNCTION calendar_time_check (p_market_code NUMBER)
    RETURN NUMBER
IS
    v_result         NUMBER;      /* 1= session on, 2=session off, 3=day off*/
    v_trading_flag   VARCHAR2 (1);
    v_time_check number;
BEGIN
    SELECT trading_flag
      INTO v_trading_flag
      FROM CALENDER
     WHERE DAY_DATE = TRUNC (SYSDATE);


    IF v_trading_flag = 'Y'
    THEN
        SELECT COUNT (*)
          INTO v_time_check
          FROM ETP_MARKET
         WHERE     MARKET_CODE = p_market_code
               AND TO_CHAR (SYSDATE, 'hh24miss') BETWEEN TO_CHAR (
                                                             TRADE_STRAT_TIME,
                                                             'hh24miss')
                                                     AND TO_CHAR (
                                                             TRADE_END_TIME,
                                                             'hh24miss');

        IF v_time_check > 0
        THEN
            v_result := 1;                                        --session on
        ELSE
            v_result := 2;                                       --session off
        END IF;
    ELSE
        v_result := 3;                                               --day off
    END IF;

    RETURN v_result;
END;
/

