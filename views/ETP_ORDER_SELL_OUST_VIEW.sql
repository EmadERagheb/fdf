SELECT "ORDER_ID",
           "FIRM_SERIAL_ID",
           "SEC_SERIAL_ID",
           "ORDER_STATUS",
           "INSERT_DATE",
           "MODIFIED_DATE",
           "ORDER_TYPE",
           "PRICE",
           rem_QNTY,
           "NIN",
           "TRADER_SERIAL_ID",
           "BOOK_KEEPER",
           "CLEAN_PRICE",
           "CURRENT_YIELD",
           "GROSS_PRICE",
           "YTM",
           "ACCRUED_INTEREST",
           "SETTLEMENT_VALUE",
           "DAYS_TO_MATURITY","IS_DUAL" , FIRM_ORDER_ID
      FROM ETP_order_sell
     WHERE TRUNC (SYSDATE) = TRUNC (INSERT_DATE)
           AND    ORDER_STATUS != '776'
           AND ORDER_STATUS != '778'
           AND ORDER_STATUS != '773'
           AND ORDER_STATUS != '789'
           AND ORDER_STATUS != '786'
           AND REM_QNTY <> 0