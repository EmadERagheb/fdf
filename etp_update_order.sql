create PROCEDURE etp_update_order (
    o_order_id                 NUMBER,
    o_SEC_SERIAL_ID            NUMBER,
    o_ISIN                     VARCHAR2,
    o_FIRM_SERIAL_ID           NUMBER,
    o_ORDER_STATUS             VARCHAR2,
    o_ORDER_TYPE               VARCHAR2,
    o_PRICE                    NUMBER,
    o_QNTY                     NUMBER,
    o_nin_code                 NUMBER,
    o_TRADER_SERIAL_ID         NUMBER,
    o_BOOK_KEEPER              VARCHAR2,
    o_CLEAN_PRICE              NUMBER,
    o_CURRENT_YIELD            NUMBER,
    o_GROSS_PRICE              NUMBER,
    o_YTM                      NUMBER,
    o_ACCRUED_INTEREST         NUMBER,
    o_SETTLEMENT_VALUE         NUMBER,
    o_DAYS_TO_MATURITY         NUMBER,
    o_SETTLEMENT_DATE          DATE,
    old_ORDER_STATUS           VARCHAR2,
    old_PRICE                  NUMBER,
    old_ORG_QNTY               NUMBER,
    old_QNTY                   NUMBER,
    old_TRADER_SERIAL_ID       NUMBER,
    old_BOOK_KEEPER            VARCHAR2,
    old_CLEAN_PRICE            NUMBER,
    old_CURRENT_YIELD          NUMBER,
    old_GROSS_PRICE            NUMBER,
    old_YTM                    NUMBER,
    old_ACCRUED_INTEREST       NUMBER,
    old_SETTLEMENT_VALUE       NUMBER,
    old_DAYS_TO_MATURITY       NUMBER,
    old_SETTLEMENT_DATE        DATE,
    o_Is_Dual                  VARCHAR2,
    o_dual_seq                 NUMBER,
    o_par_value                NUMBER,
    o_Is_Bill                  NUMBER,
    o_firm_order_id            VARCHAR2 DEFAULT NULL,
    o_Conv_Rate                NUMBER DEFAULT 1,
    o_done_flag            OUT NUMBER,
    o_done_desc            OUT VARCHAR2)
AS
    v_num   NUMBER;
BEGIN
    IF o_ORDER_STATUS = '775'
    THEN
        IF o_ORDER_TYPE = 'B'
        THEN
               UPDATE ETP_order_buy
                  SET MODIFIED_DATE = SYSDATE,
                      ORDER_STATUS = o_ORDER_STATUS,
                      PRICE = o_PRICE,
                      ORG_QNTY = ORG_QNTY - (REM_QNTY - o_QNTY),
                      REM_QNTY = o_QNTY,
                      TRADER_SERIAL_ID = o_TRADER_SERIAL_ID,
                      BOOK_KEEPER = o_BOOK_KEEPER,
                      CLEAN_PRICE = o_CLEAN_PRICE,
                      CURRENT_YIELD = o_CURRENT_YIELD,
                      GROSS_PRICE = o_GROSS_PRICE,
                      YTM = o_YTM,
                      ACCRUED_INTEREST = o_ACCRUED_INTEREST,
                      SETTLEMENT_VALUE = o_SETTLEMENT_VALUE,
                      DAYS_TO_MATURITY = o_DAYS_TO_MATURITY,
                      rec_seq = ETP_ORDER_ins_up_SEQ.NEXTVAL,
                      firm_order_id = o_firm_order_id
                WHERE     ORDER_ID = o_order_id
                      AND ORDER_STATUS = old_ORDER_STATUS
                      AND PRICE = old_PRICE
                      AND ORG_QNTY = old_ORG_QNTY
                      AND REM_QNTY = old_QNTY
                      AND TRADER_SERIAL_ID = old_TRADER_SERIAL_ID
                      AND BOOK_KEEPER = old_BOOK_KEEPER
                      AND CLEAN_PRICE = old_CLEAN_PRICE
                      AND /*CURRENT_YIELD = old_CURRENT_YIELD  and
                          GROSS_PRICE = old_GROSS_PRICE and
                          YTM = old_YTM and
                          ACCRUED_INTEREST= old_ACCRUED_INTEREST and */
                          NVL (CURRENT_YIELD, 0) = NVL (old_CURRENT_YIELD, 0)
                      AND NVL (GROSS_PRICE, 0) = NVL (old_GROSS_PRICE, 0)
                      AND NVL (YTM, 0) = NVL (old_YTM, 0)
                      AND NVL (ACCRUED_INTEREST, 0) =
                          NVL (old_ACCRUED_INTEREST, 0)
                      AND SETTLEMENT_VALUE = old_SETTLEMENT_VALUE
            --  DAYS_TO_MATURITY =  old_DAYS_TO_MATURITY
            RETURNING ORDER_ID
                 INTO v_num;

            --DBMS_OUTPUT.PUT_LINE (' o_num ' || v_num);

            IF v_num IS NOT NULL
            THEN
                etp_match_proc (v_num,
                                o_SEC_SERIAL_ID,
                                o_ISIN,
                                o_FIRM_SERIAL_ID,
                                '775',
                                SYSDATE,
                                o_ORDER_TYPE,
                                o_PRICE,
                                o_QNTY,
                                o_nin_code,
                                o_TRADER_SERIAL_ID,
                                o_BOOK_KEEPER,
                                o_CLEAN_PRICE,
                                o_CURRENT_YIELD,
                                o_GROSS_PRICE,
                                o_YTM,
                                o_ACCRUED_INTEREST,
                                o_SETTLEMENT_VALUE,
                                o_DAYS_TO_MATURITY,
                                SYSDATE,
                                o_Is_Dual,
                                o_dual_seq,
                                o_par_value,
                                o_Is_Bill,
                                o_firm_order_id,
                                o_Conv_Rate,
                                o_done_flag,
                                o_done_desc);



                IF o_done_flag <> -1
                THEN
                    o_done_desc :=
                           o_done_desc
                        || ' and  the buy order status has been changed';
                END IF;
            ELSE
                o_done_flag := -1;
                o_done_desc := 'the buy order status can not changed';
            END IF;
        ELSE
               UPDATE ETP_order_sell
                  SET MODIFIED_DATE = SYSDATE,
                      ORDER_STATUS = o_ORDER_STATUS,
                      PRICE = o_PRICE,
                      ORG_QNTY = ORG_QNTY - (REM_QNTY - o_QNTY),
                      REM_QNTY = o_QNTY,
                      TRADER_SERIAL_ID = o_TRADER_SERIAL_ID,
                      BOOK_KEEPER = o_BOOK_KEEPER,
                      CLEAN_PRICE = o_CLEAN_PRICE,
                      CURRENT_YIELD = o_CURRENT_YIELD,
                      GROSS_PRICE = o_GROSS_PRICE,
                      YTM = o_YTM,
                      ACCRUED_INTEREST = o_ACCRUED_INTEREST,
                      SETTLEMENT_VALUE = o_SETTLEMENT_VALUE,
                      DAYS_TO_MATURITY = o_DAYS_TO_MATURITY,
                      rec_seq = ETP_ORDER_ins_up_SEQ.NEXTVAL,
                      firm_order_id = o_firm_order_id
                WHERE     ORDER_ID = o_order_id
                      AND ORDER_STATUS = old_ORDER_STATUS
                      AND PRICE = old_PRICE
                      AND ORG_QNTY = old_ORG_QNTY
                      AND REM_QNTY = old_QNTY
                      AND TRADER_SERIAL_ID = old_TRADER_SERIAL_ID
                      AND BOOK_KEEPER = old_BOOK_KEEPER
                      AND CLEAN_PRICE = old_CLEAN_PRICE
                      AND NVL (CURRENT_YIELD, 0) = NVL (old_CURRENT_YIELD, 0)
                      AND NVL (GROSS_PRICE, 0) = NVL (old_GROSS_PRICE, 0)
                      AND NVL (YTM, 0) = NVL (old_YTM, 0)
                      AND NVL (ACCRUED_INTEREST, 0) =
                          NVL (old_ACCRUED_INTEREST, 0)
                      AND SETTLEMENT_VALUE = old_SETTLEMENT_VALUE        --and
            -- DAYS_TO_MATURITY =  old_DAYS_TO_MATURITY
            RETURNING ORDER_ID
                 INTO v_num;

            --DBMS_OUTPUT.PUT_LINE (' o_num ' || v_num);

            IF v_num IS NOT NULL
            THEN
                etp_match_proc (v_num,
                                o_SEC_SERIAL_ID,
                                o_ISIN,
                                o_FIRM_SERIAL_ID,
                                '775',
                                SYSDATE,
                                o_ORDER_TYPE,
                                o_PRICE,
                                o_QNTY,
                                o_nin_code,
                                o_TRADER_SERIAL_ID,
                                o_BOOK_KEEPER,
                                o_CLEAN_PRICE,
                                o_CURRENT_YIELD,
                                o_GROSS_PRICE,
                                o_YTM,
                                o_ACCRUED_INTEREST,
                                o_SETTLEMENT_VALUE,
                                o_DAYS_TO_MATURITY,
                                SYSDATE,
                                o_Is_Dual,
                                o_dual_seq,
                                o_par_value,
                                o_Is_Bill,
                                o_firm_order_id,
                                o_Conv_Rate,
                                o_done_flag,
                                o_done_desc);

                IF o_done_flag <> -1
                THEN
                    o_done_desc :=
                           o_done_desc
                        || ' and  the sell order status has been changed';
                END IF;
            ELSE
                o_done_flag := -1;
                o_done_desc := 'the sell order status can not changed';
            END IF;
        END IF;
    ELSIF o_ORDER_STATUS = '776'
    THEN
        IF o_ORDER_TYPE = 'B'
        THEN
               UPDATE ETP_order_buy
                  SET MODIFIED_DATE = SYSDATE,
                      ORDER_STATUS = o_ORDER_STATUS,
                      REM_QNTY = 0,
                      TRADER_SERIAL_ID = o_TRADER_SERIAL_ID,
                      rec_seq = ETP_ORDER_ins_up_SEQ.NEXTVAL,
                      firm_order_id = o_firm_order_id
                WHERE     ORDER_ID = o_order_id
                      AND ORDER_STATUS = old_ORDER_STATUS
                      AND PRICE = old_PRICE
                      AND ORG_QNTY = old_ORG_QNTY
                      AND REM_QNTY = old_QNTY
                      AND TRADER_SERIAL_ID = old_TRADER_SERIAL_ID
                      AND BOOK_KEEPER = old_BOOK_KEEPER
                      AND CLEAN_PRICE = old_CLEAN_PRICE
                      AND /*CURRENT_YIELD = old_CURRENT_YIELD  and
                          GROSS_PRICE = old_GROSS_PRICE and
                          YTM = old_YTM and
                          ACCRUED_INTEREST= old_ACCRUED_INTEREST and */
                          NVL (CURRENT_YIELD, 0) = NVL (old_CURRENT_YIELD, 0)
                      AND NVL (GROSS_PRICE, 0) = NVL (old_GROSS_PRICE, 0)
                      AND NVL (YTM, 0) = NVL (old_YTM, 0)
                      AND NVL (ACCRUED_INTEREST, 0) =
                          NVL (old_ACCRUED_INTEREST, 0)
                      AND SETTLEMENT_VALUE = old_SETTLEMENT_VALUE /*and
                         DAYS_TO_MATURITY =  old_DAYS_TO_MATURITY*/
            RETURNING ORDER_ID
                 INTO v_num;

            --DBMS_OUTPUT.PUT_LINE (' o_num ' || v_num);

            IF v_num IS NOT NULL
            THEN
                o_done_flag := 1;
                o_done_desc := 'Buy order canceled';

                COMMIT;
            ELSE
                o_done_flag := -1;
                o_done_desc := 'the Buy order can not cancel';
            END IF;
        ELSE
               UPDATE ETP_order_sell
                  SET MODIFIED_DATE = SYSDATE,
                      ORDER_STATUS = o_ORDER_STATUS,
                      REM_QNTY = 0,
                      TRADER_SERIAL_ID = o_TRADER_SERIAL_ID,
                      rec_seq = ETP_ORDER_ins_up_SEQ.NEXTVAL,
                      firm_order_id = o_firm_order_id
                WHERE     ORDER_ID = o_order_id
                      AND ORDER_STATUS = old_ORDER_STATUS
                      AND PRICE = old_PRICE
                      AND ORG_QNTY = old_ORG_QNTY
                      AND REM_QNTY = old_QNTY
                      AND TRADER_SERIAL_ID = old_TRADER_SERIAL_ID
                      AND BOOK_KEEPER = old_BOOK_KEEPER
                      AND CLEAN_PRICE = old_CLEAN_PRICE
                      AND NVL (CURRENT_YIELD, 0) = NVL (old_CURRENT_YIELD, 0)
                      AND NVL (GROSS_PRICE, 0) = NVL (old_GROSS_PRICE, 0)
                      AND NVL (YTM, 0) = NVL (old_YTM, 0)
                      AND NVL (ACCRUED_INTEREST, 0) =
                          NVL (old_ACCRUED_INTEREST, 0)
                      AND SETTLEMENT_VALUE = old_SETTLEMENT_VALUE /*d
                          DAYS_TO_MATURITY =  old_DAYS_TO_MATURITY */
            RETURNING ORDER_ID
                 INTO v_num;

            --DBMS_OUTPUT.PUT_LINE (' o_num ' || v_num);

            IF v_num IS NOT NULL
            THEN
                o_done_flag := 1;
                o_done_desc := 'Sell order canceled';

                COMMIT;
            ELSE
                o_done_flag := -1;
                o_done_desc := 'the Sell order can not cancel';
            END IF;
        END IF;
    ELSIF o_ORDER_STATUS = '789'
    THEN
        IF o_ORDER_TYPE = 'B'
        THEN
               UPDATE ETP_order_buy
                  SET MODIFIED_DATE = SYSDATE,
                      ORDER_STATUS = o_ORDER_STATUS,
                      TRADER_SERIAL_ID = o_TRADER_SERIAL_ID,
                      rec_seq = ETP_ORDER_ins_up_SEQ.NEXTVAL,
                      firm_order_id = o_firm_order_id
                WHERE     ORDER_ID = o_order_id
                      AND ORDER_STATUS = old_ORDER_STATUS
                      AND PRICE = old_PRICE
                      AND ORG_QNTY = old_ORG_QNTY
                      AND REM_QNTY = old_QNTY
                      AND TRADER_SERIAL_ID = old_TRADER_SERIAL_ID
                      AND BOOK_KEEPER = old_BOOK_KEEPER
                      AND CLEAN_PRICE = old_CLEAN_PRICE
                      AND /*CURRENT_YIELD = old_CURRENT_YIELD  and
                          GROSS_PRICE = old_GROSS_PRICE and
                          YTM = old_YTM and
                          ACCRUED_INTEREST= old_ACCRUED_INTEREST and */
                          NVL (CURRENT_YIELD, 0) = NVL (old_CURRENT_YIELD, 0)
                      AND NVL (GROSS_PRICE, 0) = NVL (old_GROSS_PRICE, 0)
                      AND NVL (YTM, 0) = NVL (old_YTM, 0)
                      AND NVL (ACCRUED_INTEREST, 0) =
                          NVL (old_ACCRUED_INTEREST, 0)
                      AND SETTLEMENT_VALUE = old_SETTLEMENT_VALUE
                      AND DAYS_TO_MATURITY = old_DAYS_TO_MATURITY
            RETURNING ORDER_ID
                 INTO v_num;

            --DBMS_OUTPUT.PUT_LINE (' o_num ' || v_num);

            IF v_num IS NOT NULL
            THEN
                o_done_flag := 1;
                o_done_desc := 'Buy order Suspended';

                COMMIT;
            ELSE
                o_done_flag := -1;
                o_done_desc := 'the Buy order can not suspend';
            END IF;
        ELSE
               UPDATE ETP_order_sell
                  SET MODIFIED_DATE = SYSDATE,
                      ORDER_STATUS = o_ORDER_STATUS,
                      TRADER_SERIAL_ID = o_TRADER_SERIAL_ID,
                      rec_seq = ETP_ORDER_ins_up_SEQ.NEXTVAL,
                      firm_order_id = o_firm_order_id
                WHERE     ORDER_ID = o_order_id
                      AND ORDER_STATUS = old_ORDER_STATUS
                      AND PRICE = old_PRICE
                      AND ORG_QNTY = old_ORG_QNTY
                      AND REM_QNTY = old_QNTY
                      AND TRADER_SERIAL_ID = old_TRADER_SERIAL_ID
                      AND BOOK_KEEPER = old_BOOK_KEEPER
                      AND CLEAN_PRICE = old_CLEAN_PRICE
                      AND /*CURRENT_YIELD = old_CURRENT_YIELD  and
                          GROSS_PRICE = old_GROSS_PRICE and
                          YTM = old_YTM and
                          ACCRUED_INTEREST= old_ACCRUED_INTEREST and*/
                          NVL (CURRENT_YIELD, 0) = NVL (old_CURRENT_YIELD, 0)
                      AND NVL (GROSS_PRICE, 0) = NVL (old_GROSS_PRICE, 0)
                      AND NVL (YTM, 0) = NVL (old_YTM, 0)
                      AND NVL (ACCRUED_INTEREST, 0) =
                          NVL (old_ACCRUED_INTEREST, 0)
                      AND SETTLEMENT_VALUE = old_SETTLEMENT_VALUE
                      AND DAYS_TO_MATURITY = old_DAYS_TO_MATURITY
            RETURNING ORDER_ID
                 INTO v_num;

            --DBMS_OUTPUT.PUT_LINE (' o_num ' || v_num);

            IF v_num IS NOT NULL
            THEN
                o_done_flag := 1;
                o_done_desc := 'Sell order Suspended';

                COMMIT;
            ELSE
                o_done_flag := -1;
                o_done_desc := 'the Sell order can not suspend';
            END IF;
        END IF;
    ELSIF o_ORDER_STATUS = '790'
    THEN
        IF o_ORDER_TYPE = 'B'
        THEN
               UPDATE ETP_order_buy
                  SET MODIFIED_DATE = SYSDATE,
                      ORDER_STATUS = o_ORDER_STATUS,
                      TRADER_SERIAL_ID = o_TRADER_SERIAL_ID,
                      rec_seq = ETP_ORDER_ins_up_SEQ.NEXTVAL,
                      firm_order_id = o_firm_order_id
                WHERE     ORDER_ID = o_order_id
                      AND ORDER_STATUS = old_ORDER_STATUS
                      AND PRICE = old_PRICE
                      AND ORG_QNTY = old_ORG_QNTY
                      AND REM_QNTY = old_QNTY
                      AND TRADER_SERIAL_ID = old_TRADER_SERIAL_ID
                      AND BOOK_KEEPER = old_BOOK_KEEPER
                      AND CLEAN_PRICE = old_CLEAN_PRICE
                      AND /*CURRENT_YIELD = old_CURRENT_YIELD  and
                          GROSS_PRICE = old_GROSS_PRICE and
                          YTM = old_YTM and
                          ACCRUED_INTEREST= old_ACCRUED_INTEREST and  */
                          NVL (CURRENT_YIELD, 0) = NVL (old_CURRENT_YIELD, 0)
                      AND NVL (GROSS_PRICE, 0) = NVL (old_GROSS_PRICE, 0)
                      AND NVL (YTM, 0) = NVL (old_YTM, 0)
                      AND NVL (ACCRUED_INTEREST, 0) =
                          NVL (old_ACCRUED_INTEREST, 0)
                      AND SETTLEMENT_VALUE = old_SETTLEMENT_VALUE
                      AND DAYS_TO_MATURITY = old_DAYS_TO_MATURITY
            RETURNING ORDER_ID
                 INTO v_num;

            --DBMS_OUTPUT.PUT_LINE (' o_num ' || v_num);

            IF v_num IS NOT NULL
            THEN
                etp_match_proc (v_num,
                                o_SEC_SERIAL_ID,
                                o_ISIN,
                                o_FIRM_SERIAL_ID,
                                '790',
                                SYSDATE,
                                o_ORDER_TYPE,
                                o_PRICE,
                                o_QNTY,
                                o_nin_code,
                                o_TRADER_SERIAL_ID,
                                o_BOOK_KEEPER,
                                o_CLEAN_PRICE,
                                o_CURRENT_YIELD,
                                o_GROSS_PRICE,
                                o_YTM,
                                o_ACCRUED_INTEREST,
                                o_SETTLEMENT_VALUE,
                                o_DAYS_TO_MATURITY,
                                SYSDATE,
                                o_Is_Dual,
                                o_dual_seq,
                                o_par_value,
                                o_Is_Bill,
                                o_firm_order_id,
                                o_Conv_Rate,
                                o_done_flag,
                                o_done_desc);

                IF o_done_flag <> -1
                THEN
                    o_done_desc :=
                           o_done_desc
                        || ' and  the buy order status has been Resumed';
                END IF;
            ELSE
                o_done_flag := -1;
                o_done_desc := 'the buy order status can not Resume';
            END IF;
        ELSE
               UPDATE ETP_order_sell
                  SET MODIFIED_DATE = SYSDATE,
                      ORDER_STATUS = o_ORDER_STATUS,
                      TRADER_SERIAL_ID = o_TRADER_SERIAL_ID,
                      rec_seq = ETP_ORDER_ins_up_SEQ.NEXTVAL,
                      firm_order_id = o_firm_order_id
                WHERE     ORDER_ID = o_order_id
                      AND ORDER_STATUS = old_ORDER_STATUS
                      AND PRICE = old_PRICE
                      AND ORG_QNTY = old_ORG_QNTY
                      AND REM_QNTY = old_QNTY
                      AND TRADER_SERIAL_ID = old_TRADER_SERIAL_ID
                      AND BOOK_KEEPER = old_BOOK_KEEPER
                      AND CLEAN_PRICE = old_CLEAN_PRICE
                      AND /* CURRENT_YIELD = old_CURRENT_YIELD  and
                           GROSS_PRICE = old_GROSS_PRICE and
                           YTM = old_YTM and
                           ACCRUED_INTEREST= old_ACCRUED_INTEREST and */
                          NVL (CURRENT_YIELD, 0) = NVL (old_CURRENT_YIELD, 0)
                      AND NVL (GROSS_PRICE, 0) = NVL (old_GROSS_PRICE, 0)
                      AND NVL (YTM, 0) = NVL (old_YTM, 0)
                      AND NVL (ACCRUED_INTEREST, 0) =
                          NVL (old_ACCRUED_INTEREST, 0)
                      AND SETTLEMENT_VALUE = old_SETTLEMENT_VALUE
                      AND DAYS_TO_MATURITY = old_DAYS_TO_MATURITY
            RETURNING ORDER_ID
                 INTO v_num;

            --DBMS_OUTPUT.PUT_LINE (' o_num ' || v_num);

            IF v_num IS NOT NULL
            THEN
                etp_match_proc (v_num,
                                o_SEC_SERIAL_ID,
                                o_ISIN,
                                o_FIRM_SERIAL_ID,
                                '790',
                                SYSDATE,
                                o_ORDER_TYPE,
                                o_PRICE,
                                o_QNTY,
                                o_nin_code,
                                o_TRADER_SERIAL_ID,
                                o_BOOK_KEEPER,
                                o_CLEAN_PRICE,
                                o_CURRENT_YIELD,
                                o_GROSS_PRICE,
                                o_YTM,
                                o_ACCRUED_INTEREST,
                                o_SETTLEMENT_VALUE,
                                o_DAYS_TO_MATURITY,
                                SYSDATE,
                                o_Is_Dual,
                                o_dual_seq,
                                o_par_value,
                                o_Is_Bill,
                                o_firm_order_id,
                                o_Conv_Rate,
                                o_done_flag,
                                o_done_desc);



                IF o_done_flag <> -1
                THEN
                    o_done_desc :=
                           o_done_desc
                        || ' and  the sell order status has been Resumed';
                END IF;
            ELSE
                o_done_flag := -1;
                o_done_desc := 'the sell order status can not Resume';
            END IF;
        END IF;
    END IF;
--DBMS_OUTPUT.PUT_LINE (' o_done_flag ' || o_done_flag);
--DBMS_OUTPUT.PUT_LINE (' o_done_desc ' || o_done_desc);
END;
/

