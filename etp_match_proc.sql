create PROCEDURE        etp_match_proc (
    o_order_id               NUMBER,
    o_SEC_SERIAL_ID          NUMBER,
    o_ISIN                   VARCHAR2,
    o_FIRM_SERIAL_ID         NUMBER,
    o_ORDER_STATUS           VARCHAR2,
    o_MODIFIED_DATE          DATE,
    o_ORDER_TYPE             VARCHAR2,
    o_PRICE                  NUMBER,
    o_QNTY                   NUMBER,
    o_NIN                    NUMBER,
    o_TRADER_SERIAL_ID       NUMBER,
    o_BOOK_KEEPER            VARCHAR2,
    o_CLEAN_PRICE            NUMBER,
    o_CURRENT_YIELD          NUMBER,
    o_GROSS_PRICE            NUMBER,
    o_YTM                    NUMBER,
    o_ACCRUED_INTEREST       NUMBER,
    o_SETTLEMENT_VALUE       NUMBER,
    o_DAYS_TO_MATURITY       NUMBER,
    o_SETTLEMENT_DATE        DATE,
    o_Is_Dual                VARCHAR2,
    o_dual_seq               NUMBER,
    o_par_value              NUMBER,
    o_Is_Bill                NUMBER,
    o_firm_order_id          VARCHAR2 DEFAULT NULL,
    o_Conv_Rate              NUMBER DEFAULT 1,
    o_done_flag          OUT NUMBER,
    o_done_desc          OUT VARCHAR2)
AS
    CURSOR ORBUY IS
          SELECT ORDER_ID,
                 FIRM_SERIAL_ID,
                 SEC_SERIAL_ID,
                 ORDER_STATUS,
                 INSERT_DATE,
                 MODIFIED_DATE,
                 ORDER_TYPE,
                 CASE WHEN o_Is_Bill = 1 THEN clean_price ELSE PRICE END
                     PRICE,
                 -- PRICE,
                 rem_QNTY,
                 NIN,
                 TRADER_SERIAL_ID,
                 BOOK_KEEPER,
                 CASE WHEN o_Is_Bill = 1 THEN PRICE ELSE clean_price END
                     CLEAN_PRICE,
                 --CLEAN_PRICE, 21012026
                 CURRENT_YIELD,
                 GROSS_PRICE,
                 YTM,
                 ACCRUED_INTEREST,
                 SETTLEMENT_VALUE,
                 DAYS_TO_MATURITY,
                 IS_DUAL,
                 FIRM_ORDER_ID
            FROM ETP_order_buy_oust_view
           WHERE SEC_SERIAL_ID = o_SEC_SERIAL_ID
        ORDER BY PRICE DESC, NVL (MODIFIED_DATE, INSERT_DATE) ASC;


    CURSOR ORsell IS
          SELECT ORDER_ID,
                 FIRM_SERIAL_ID,
                 SEC_SERIAL_ID,
                 ORDER_STATUS,
                 INSERT_DATE,
                 MODIFIED_DATE,
                 ORDER_TYPE,
                 CASE WHEN o_Is_Bill = 1 THEN clean_price ELSE PRICE END
                     PRICE,
                 --PRICE ,
                 rem_QNTY,
                 NIN,
                 TRADER_SERIAL_ID,
                 BOOK_KEEPER,
                 CASE WHEN o_Is_Bill = 1 THEN PRICE ELSE clean_price END
                     CLEAN_PRICE,
                 --CLEAN_PRICE, 21012026
                 CURRENT_YIELD,
                 GROSS_PRICE,
                 YTM,
                 ACCRUED_INTEREST,
                 SETTLEMENT_VALUE,
                 DAYS_TO_MATURITY,
                 IS_DUAL,
                 FIRM_ORDER_ID
            FROM ETP_order_sell_oust_view
           WHERE SEC_SERIAL_ID = o_SEC_SERIAL_ID
        ORDER BY PRICE ASC, NVL (MODIFIED_DATE, INSERT_DATE) ASC;


    v_sell_order        ETP_order_sell_oust_view%ROWTYPE;
    v_buy_order         ETP_order_buy_oust_view%ROWTYPE;

    o_count_sell_nin    NUMBER;
    o_count_buy_nin     NUMBER;
    o_sell_order_id     NUMBER;
    o_buy_order_id      NUMBER;

    p_volume            NUMBER := 0;
    t_volume            NUMBER := 0;
    t_count_buy         NUMBER := 0;
    t_count_sell        NUMBER := 0;
    Get_buy_order_ID    NUMBER;
    Get_sell_order_ID   NUMBER;
    o_exec_flag         NUMBER;
    TEMP_TR             NUMBER;
--o_done_desc       varchar2(4000);
-- o_done_flag       number;
v_msg varchar2(1000);
BEGIN
    o_done_flag := 0;
    o_done_desc := 'Match Error';

     SELECT  exec_flag
      INTO o_exec_flag
      FROM etp_control_order
      where  SEC_SERIAL_ID = o_SEC_SERIAL_ID
      FOR UPDATE ;

    IF o_exec_flag = 0
    THEN
        UPDATE etp_control_order
           SET exec_flag = 1
         WHERE  SEC_SERIAL_ID = o_SEC_SERIAL_ID ; --and exec_flag = 0;


        o_done_flag := 0;
        o_done_desc := NULL;

        IF o_ORDER_TYPE = 'B'
        THEN
            SELECT COUNT (*)
              INTO o_count_sell_nin
              FROM ETP_order_sell_oust_view
             WHERE     SEC_SERIAL_ID = o_SEC_SERIAL_ID
                   AND CASE
                           WHEN o_Is_Bill = 1 THEN clean_price
                           ELSE PRICE
                       END < =
                       CASE
                           WHEN o_Is_Bill = 1 THEN o_CLEAN_PRICE
                           ELSE o_price
                       END
                   --  PRICE <= o_price
                   AND nin = o_nin;

            IF o_count_sell_nin <> 0
            THEN /* not accept buy order in case there is sell order with the same nin*/
                o_done_flag := -1;
                o_done_desc :=
                    'not accept buy order in case there is sell order with the same nin';

                ROLLBACK;

                UPDATE etp_control_order
                   SET  exec_flag = 0 where SEC_SERIAL_ID = o_SEC_SERIAL_ID ;

                --WHERE   exec_flag = 1;

                COMMIT;


                RETURN;
            END IF;


            IF o_ORDER_STATUS = '772'
            THEN
                INSERT INTO ETP_order_buy (FIRM_SERIAL_ID,
                                           SEC_SERIAL_ID,
                                           ORDER_STATUS,
                                           INSERT_DATE,
                                           MODIFIED_DATE,
                                           ORDER_TYPE,
                                           PRICE,
                                           org_QNTY,
                                           rem_qnty,
                                           NIN,
                                           TRADER_SERIAL_ID,
                                           BOOK_KEEPER,
                                           CLEAN_PRICE,
                                           CURRENT_YIELD,
                                           GROSS_PRICE,
                                           YTM,
                                           ACCRUED_INTEREST,
                                           SETTLEMENT_VALUE,
                                           DAYS_TO_MATURITY,
                                           rec_seq,
                                           Is_Dual,
                                           dual_seq,
                                           FIRM_ORDER_ID)
                     VALUES (o_FIRM_SERIAL_ID,
                             o_SEC_SERIAL_ID,
                             o_ORDER_STATUS,
                             SYSDATE,
                             NULL,
                             'B',
                             o_PRICE,
                             o_QNTY,
                             o_QNTY,
                             o_NIN,
                             o_TRADER_SERIAL_ID,
                             o_BOOK_KEEPER,
                             o_CLEAN_PRICE,
                             o_CURRENT_YIELD,
                             o_GROSS_PRICE,
                             o_YTM,
                             o_ACCRUED_INTEREST,
                             o_SETTLEMENT_VALUE,
                             o_DAYS_TO_MATURITY,
                             ETP_ORDER_ins_up_SEQ.NEXTVAL,
                             o_Is_Dual,
                             o_dual_seq,
                             o_firm_order_id)
                  RETURNING ETP_order_buy.order_ID
                       INTO Get_buy_order_ID;

               o_done_desc :=
                    'order buy added' || LPAD (Get_buy_order_ID, 12, 0);
            ELSE
                Get_buy_order_ID := o_order_id;
            END IF;

            p_volume := o_QNTY;
            o_done_flag := 1;


            OPEN ORsell;


            LOOP
                FETCH ORsell INTO v_sell_order;

                EXIT WHEN ORsell%NOTFOUND;

                SELECT order_id
                  INTO o_sell_order_id
                  FROM ETP_order_sell
                 WHERE order_id = v_sell_order.order_id
                FOR UPDATE;

                IF CASE
                       WHEN o_Is_Bill = 1 THEN o_CLEAN_PRICE
                       ELSE o_price
                   END <
                   v_sell_order.price
                --o_PRICE < v_sell_order.price
                THEN
                    EXIT;
                ELSE
                    o_done_flag := 2;
                    t_count_buy := t_count_buy + 1;

                    IF p_volume <= v_sell_order.rem_QNTY
                    THEN
                        t_volume := p_volume;
                        p_volume := 0;
                    ELSE
                        t_volume := v_sell_order.rem_QNTY;
                        p_volume := p_volume - t_volume;
                    END IF;

                    SELECT ETP_TRADE_REPORT_SEQ.NEXTVAL
                      INTO TEMP_TR
                      FROM DUAL;

                    INSERT INTO ETP_TRADE_order
                             VALUES (
                                        TEMP_TR,
                                        SYSDATE,
                                        o_SETTLEMENT_DATE,
                                        o_SEC_SERIAL_ID,
                                        o_ISIN,
                                        o_FIRM_SERIAL_ID,
                                        o_BOOK_KEEPER,
                                        o_NIN,
                                        o_TRADER_SERIAL_ID,
                                        v_sell_order.FIRM_SERIAL_ID,
                                        v_sell_order.BOOK_KEEPER,
                                        v_sell_order.nin,
                                        v_sell_order.TRADER_SERIAL_ID,
                                        t_volume,
                                        -- _sell_order.price 21012026
                                        CASE
                                            WHEN o_Is_Bill = 1
                                            THEN
                                               v_sell_order.CLEAN_PRICE
                                            ELSE
                                                v_sell_order.price
                                        END,
                                        v_sell_order.GROSS_PRICE,
                                        CASE
                                            WHEN o_Is_Bill = 1
                                            THEN
                                                  --  v_sell_order.CLEAN_PRICE 21012026
                                                  v_sell_order.PRICE
                                                * t_volume
                                                * o_Conv_Rate
                                            ELSE
                                                  v_sell_order.GROSS_PRICE
                                                * (t_volume / o_par_value)
                                                * o_Conv_Rate
                                        END,
                                        --v_sell_order.CLEAN_PRICE,21/01/2026
                                        CASE
                                            WHEN o_Is_Bill = 1
                                            THEN
                                                v_sell_order.price
                                            ELSE
                                                v_sell_order.CLEAN_PRICE
                                        END,
                                        v_sell_order.YTM,
                                        v_sell_order.ACCRUED_INTEREST,
                                        v_sell_order.CURRENT_YIELD,
                                        NULL,
                                        NULL,
                                        NULL,
                                        NULL,
                                        NULL,
                                        NULL,
                                        NULL,
                                        Get_buy_order_ID,
                                        v_sell_order.ORDER_ID);


                    UPDATE ETP_order_sell
                       SET REM_QNTY = REM_QNTY - t_volume,
                           ORDER_STATUS =
                               DECODE (REM_QNTY, t_volume, '786', '779'),
                           SETTLEMENT_VALUE =
                               CASE
                                   WHEN o_Is_Bill = 1
                                   THEN
                                         CLEAN_PRICE
                                       * (REM_QNTY - t_volume)
                                       * o_Conv_Rate
                                   ELSE
                                         GROSS_PRICE
                                       * ((REM_QNTY - t_volume) / o_par_value)
                                       * o_Conv_Rate
                               END
                     WHERE ORDER_ID = v_sell_order.ORDER_ID;

                    UPDATE ETP_order_buy
                       SET REM_QNTY = REM_QNTY - t_volume,
                           ORDER_STATUS =
                               DECODE (REM_QNTY, t_volume, '786', '779'),
                           SETTLEMENT_VALUE =
                               CASE
                                   WHEN o_Is_Bill = 1
                                   THEN
                                         CLEAN_PRICE
                                       * (REM_QNTY - t_volume)
                                       * o_Conv_Rate
                                   ELSE
                                         GROSS_PRICE
                                       * ((REM_QNTY - t_volume) / o_par_value)
                                       * o_Conv_Rate
                               END
                     WHERE ORDER_ID = Get_buy_order_ID;


                    ETP_INSERT_SWIFT_TICKET (TEMP_TR);

                    IF p_volume = 0
                    THEN
                        EXIT;
                    END IF;
                END IF;
            END LOOP;

            CLOSE ORsell;                                              /*new*/

            IF o_done_flag = 2
            THEN
                o_done_desc :=
                       'order buy added and matched no. trades '
                    || t_count_buy
                    || ' '
                    || LPAD (Get_buy_order_ID, 12, 0);
            END IF;
        ELSE
            SELECT COUNT (*)
              INTO o_count_buy_nin
              FROM ETP_order_buy_oust_view
             WHERE     SEC_SERIAL_ID = o_SEC_SERIAL_ID
                   AND CASE
                           WHEN o_Is_Bill = 1 THEN clean_price
                           ELSE PRICE
                       END >=
                       CASE
                           WHEN o_Is_Bill = 1 THEN o_CLEAN_PRICE
                           ELSE o_price
                       END
                   --PRICE >= o_price
                   AND nin = o_nin;

            IF o_count_buy_nin <> 0
            THEN /* not accept buy order in case there is buy order with the same nin*/
                /* not accept buy order in case there is sell order with the same nin*/
                o_done_flag := -1;
                o_done_desc :=
                    'not accept sell order in case there is buy order with the same nin';

                UPDATE etp_control_order
                   SET exec_flag = 0
                 WHERE     SEC_SERIAL_ID = o_SEC_SERIAL_ID ; --exec_flag = 1 

                COMMIT;

                RETURN;
            END IF;


            IF o_ORDER_STATUS = '772'
            THEN
                INSERT INTO ETP_order_sell (FIRM_SERIAL_ID,
                                            SEC_SERIAL_ID,
                                            ORDER_STATUS,
                                            INSERT_DATE,
                                            MODIFIED_DATE,
                                            ORDER_TYPE,
                                            PRICE,
                                            org_QNTY,
                                            rem_qnty,
                                            NIN,
                                            TRADER_SERIAL_ID,
                                            BOOK_KEEPER,
                                            CLEAN_PRICE,
                                            CURRENT_YIELD,
                                            GROSS_PRICE,
                                            YTM,
                                            ACCRUED_INTEREST,
                                            SETTLEMENT_VALUE,
                                            DAYS_TO_MATURITY,
                                            rec_seq,
                                            Is_Dual,
                                            dual_seq,
                                            FIRM_ORDER_ID)
                     VALUES (o_FIRM_SERIAL_ID,
                             o_SEC_SERIAL_ID,
                             o_ORDER_STATUS,
                             SYSDATE,
                             NULL,
                             'S',
                             o_PRICE,
                             o_QNTY,
                             o_QNTY,
                             o_NIN,
                             o_TRADER_SERIAL_ID,
                             o_BOOK_KEEPER,
                             o_CLEAN_PRICE,
                             o_CURRENT_YIELD,
                             o_GROSS_PRICE,
                             o_YTM,
                             o_ACCRUED_INTEREST,
                             o_SETTLEMENT_VALUE,
                             o_DAYS_TO_MATURITY,
                             ETP_ORDER_ins_up_SEQ.NEXTVAL,
                             o_Is_Dual,
                             o_dual_seq,
                             o_firm_order_id)
                  RETURNING ETP_order_sell.order_ID
                       INTO Get_sell_order_ID;

                o_done_desc :=
                    'order sell added ' || LPAD (Get_sell_order_ID, 12, 0);
            ELSE
                Get_sell_order_ID := o_order_id;
            END IF;


            p_volume := o_QNTY;
            o_done_flag := 1;



            OPEN ORbuy;


            LOOP
                FETCH ORbuy INTO v_buy_order;

                EXIT WHEN ORbuy%NOTFOUND;

                SELECT order_id
                  INTO o_buy_order_id
                  FROM ETP_order_buy
                 WHERE order_id = v_buy_order.order_id
                FOR UPDATE;

                IF CASE
                       WHEN o_Is_Bill = 1 THEN o_CLEAN_PRICE
                       ELSE o_price
                   END >
                   v_buy_order.price
                -- o_PRICE > v_buy_order.price
                THEN
                    EXIT;
                ELSE
                    o_done_flag := 2;
                    t_count_sell := t_count_sell + 1;

                    IF p_volume <= v_buy_order.rem_QNTY
                    THEN
                        t_volume := p_volume;
                        p_volume := 0;
                    ELSE
                        t_volume := v_buy_order.rem_QNTY;
                        p_volume := p_volume - t_volume;
                    END IF;

                    SELECT ETP_TRADE_REPORT_SEQ.NEXTVAL
                      INTO TEMP_TR
                      FROM DUAL;

                    INSERT INTO ETP_TRADE_order
                             VALUES (
                                        TEMP_TR,
                                        SYSDATE,
                                        o_SETTLEMENT_DATE,
                                        o_SEC_SERIAL_ID,
                                        o_ISIN,
                                        v_buy_order.FIRM_SERIAL_ID,
                                        v_buy_order.BOOK_KEEPER,
                                        v_buy_order.nin,
                                        v_buy_order.TRADER_SERIAL_ID,
                                        o_FIRM_SERIAL_ID,
                                        o_BOOK_KEEPER,
                                        o_NIN,
                                        o_TRADER_SERIAL_ID,
                                        t_volume,
                                        --v_buy_order.price,21012026
                                        CASE
                                            WHEN o_Is_Bill = 1
                                            THEN
                                                v_buy_order.CLEAN_PRICE
                                            ELSE
                                                v_buy_order.price
                                        END,
                                        v_buy_order.GROSS_PRICE,
                                        CASE
                                            WHEN o_Is_Bill = 1
                                            THEN
                                                  --   v_buy_order.CLEAN_PRICE 21012026
                                                  v_buy_order.PRICE
                                                * t_volume
                                                * o_Conv_Rate
                                            ELSE
                                                  v_buy_order.GROSS_PRICE
                                                * (t_volume / o_par_value)
                                                * o_Conv_Rate
                                        END,
                                        --  v_buy_order.CLEAN_PRICE,21012026
                                        CASE
                                            WHEN o_Is_Bill = 1
                                           THEN
                                                v_buy_order.price
                                            ELSE
                                                v_buy_order.CLEAN_PRICE
                                        END,
                                        v_buy_order.YTM,
                                        v_buy_order.ACCRUED_INTEREST,
                                        v_buy_order.CURRENT_YIELD,
                                        NULL,
                                        NULL,
                                        NULL,
                                        NULL,
                                        NULL,
                                        NULL,
                                        NULL,
                                        v_buy_order.ORDER_ID,
                                        Get_sell_order_ID);


                    UPDATE ETP_order_buy
                       SET REM_QNTY = REM_QNTY - t_volume,
                           ORDER_STATUS =
                               DECODE (REM_QNTY, t_volume, '786', '779'),
                           SETTLEMENT_VALUE =
                               CASE
                                   WHEN o_Is_Bill = 1
                                   THEN
                                         CLEAN_PRICE
                                       * (REM_QNTY - t_volume)
                                       * o_Conv_Rate
                                   ELSE
                                         GROSS_PRICE
                                       * ((REM_QNTY - t_volume) / o_par_value)
                                       * o_Conv_Rate
                               END
                     WHERE ORDER_ID = v_buy_order.ORDER_ID;

                    UPDATE ETP_order_sell
                       SET REM_QNTY = REM_QNTY - t_volume,
                           ORDER_STATUS =
                               DECODE (REM_QNTY, t_volume, '786', '779'),
                           SETTLEMENT_VALUE =
                               CASE
                                   WHEN o_Is_Bill = 1
                                   THEN
                                         CLEAN_PRICE
                                       * (REM_QNTY - t_volume)
                                       * o_Conv_Rate
                                   ELSE
                                         GROSS_PRICE
                                       * ((REM_QNTY - t_volume) / o_par_value)
                                       * o_Conv_Rate
                               END
                     WHERE ORDER_ID = Get_sell_order_ID;

                    ETP_INSERT_SWIFT_TICKET (TEMP_TR);

                    IF p_volume = 0
                    THEN
                        EXIT;
                    END IF;
                END IF;
            END LOOP;

            CLOSE ORbuy;                                               /*new*/

            IF o_done_flag = 2
            THEN
                o_done_desc :=
                       'order sell added and matched no. trades '
                    || t_count_sell
                    || ' '
                    || LPAD (Get_sell_order_ID, 12, 0);
            END IF;
        END IF;


        UPDATE etp_control_order
           SET exec_flag = 0
         WHERE   SEC_SERIAL_ID = o_SEC_SERIAL_ID; --exec_flag = 1;
    END IF;


    COMMIT;
  EXCEPTION
    WHEN OTHERS
    THEN
     v_msg:= SUBSTR (
                                       DBMS_UTILITY.format_error_backtrace
                                    || DBMS_UTILITY.format_error_stack,
                                    1,
                                    400) ;
                                    
   
  

             rollback;
  
          add_error_log('match_proc', v_msg, o_FIRM_SERIAL_ID);
   
    
         o_done_flag := 0;
         o_done_desc := 'Internal Error';
      
END;
/

