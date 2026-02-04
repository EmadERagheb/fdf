create table ETPORD.ETP_ORDER_REJECTED
(
    ORDER_ID         NUMBER,
    FIRM_SERIAL_ID   NUMBER,
    SEC_SERIAL_ID    NUMBER,
    SEC_ISIN_CODE    VARCHAR2(12),
    ORDER_STATUS     VARCHAR2(3),
    INSERT_DATE      DATE,
    MODIFIED_DATE    DATE,
    ORDER_TYPE       VARCHAR2(1),
    PRICE            NUMBER,
    ORG_QNTY         NUMBER,
    REM_QNTY         NUMBER,
    NIN              NUMBER(10),
    TRADER_SERIAL_ID NUMBER,
    BOOK_KEEPER      VARCHAR2(4),
    CLEAN_PRICE      NUMBER,
    CURRENT_YIELD    NUMBER,
    GROSS_PRICE      NUMBER,
    YTM              NUMBER,
    ACCRUED_INTEREST NUMBER,
    SETTLEMENT_VALUE NUMBER,
    DAYS_TO_MATURITY NUMBER,
    REC_SEQ          NUMBER,
    IS_DUAL          VARCHAR2(1),
    DUAL_SEQ         NUMBER,
    FIRM_ORDER_ID    VARCHAR2(50),
    REJECT_REASON    VARCHAR2(2000)
)
/

| ORDER\_ID | FIRM\_SERIAL\_ID | SEC\_SERIAL\_ID | SEC\_ISIN\_CODE | ORDER\_STATUS | INSERT\_DATE | MODIFIED\_DATE | ORDER\_TYPE | PRICE | ORG\_QNTY | REM\_QNTY | NIN | TRADER\_SERIAL\_ID | BOOK\_KEEPER | CLEAN\_PRICE | CURRENT\_YIELD | GROSS\_PRICE | YTM | ACCRUED\_INTEREST | SETTLEMENT\_VALUE | DAYS\_TO\_MATURITY | REC\_SEQ | IS\_DUAL | DUAL\_SEQ | FIRM\_ORDER\_ID | REJECT\_REASON |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| null | 1 | null | EGT9980H3Q19 | 772 | 2026-02-02 15:08:16 | null | S | 24.2 | 50350000 | null | 644829 | 1 | 4515 | 0.97228 | null | null | null | null | 48954298 | 43 | null | null | null | 135998 | Match Error |
| null | 1 | null | EGT9980E4Q15 | 772 | 2026-02-02 15:08:22 | null | S | 24.78 | 200000000 | null | 637200 | 1 | 4517 | 0.95401 | null | null | null | null | 190802000 | 71 | null | null | null | 136174 | Match Error |
| null | 1 | null | EGT998033Q17 | 772 | 2026-02-02 15:08:40 | null | S | 23.52 | 22300000 | null | 2258166 | 1 | 4528 | 0.98166 | null | null | null | null | 21891018 | 29 | null | null | null | 136843 | Match Error |
| null | 1 | null | EGT9980S4Q15 | 772 | 2026-02-02 15:08:52 | null | B | 24.239 | 1850000000 | null | 2259100 | 1 | 4520 | 0.94657 | null | null | null | null | 1751154500 | 85 | null | null | null | 137357 | not accept buy order in case there is sell order with the same nin |
| null | 1 | null | EGT9980E4Q15 | 772 | 2026-02-02 15:09:17 | null | B | 24 | 10900000 | null | 2279361 | 1 | 4517 | 0.9554 | null | null | null | null | 10413860 | 71 | null | null | null | 138233 | Match Error |
| null | 1 | null | EGT998055Q10 | 772 | 2026-02-02 15:09:24 | null | B | 24.498 | 1000000000 | null | 2323651 | 1 | 4501 | 0.94184 | null | null | null | null | 941840000 | 92 | null | null | null | 138489 | Match Error |
| null | 1 | null | EGT9980S4Q15 | 772 | 2026-02-02 15:10:07 | null | S | 23.55 | 350000 | null | 2947 | 1 | 4501 | 0.94801 | null | null | null | null | 331803.5 | 85 | null | null | null | 139991 | Match Error |
| null | 1 | null | EGT9980H2Q10 | 772 | 2026-02-02 15:10:20 | null | S | 26.569 | 374700000 | null | 5175 | 1 | 4505 | 0.9892 | null | null | null | null | 370653240 | 15 | null | null | null | 140437 | Match Error |
| null | 1 | null | EGT9980H3Q19 | 772 | 2026-02-02 15:10:24 | null | S | 25.5 | 48000000 | null | 637200 | 1 | 4517 | 0.97084 | null | null | null | null | 46600320 | 43 | null | null | null | 140505 | Match Error |
| null | 1 | null | EGT9980H2Q10 | 772 | 2026-02-02 15:10:31 | null | B | 26.72 | 12000000 | null | 2275694 | 1 | 4509 | 0.98914 | null | null | null | null | 11869680 | 15 | null | null | null | 140680 | Match Error |
| null | 1 | null | EGT9980H2Q10 | 772 | 2026-02-02 15:10:48 | null | B | 26.65 | 14125000 | null | 1292495 | 1 | 4535 | 0.98917 | null | null | null | null | 13972026.25 | 15 | null | null | null | 141062 | Match Error |
| null | 1 | null | EGT9980H2Q10 | 772 | 2026-02-02 15:10:49 | null | B | 26 | 2150000 | null | 2428942 | 1 | 4536 | 0.98943 | null | null | null | null | 2127274.5 | 15 | null | null | null | 141077 | Match Error |
| null | 1 | null | EGT9980S4Q15 | 772 | 2026-02-02 15:10:54 | null | S | 23.75 | 1550000 | null | 2947 | 1 | 4501 | 0.94759 | null | null | null | null | 1468764.5 | 85 | null | null | null | 141309 | Match Error |
| null | 1 | null | EGT9980E4Q15 | 772 | 2026-02-02 15:11:02 | null | B | 23.35 | 600000 | null | 3061026 | 1 | 4505 | 0.95655 | null | null | null | null | 573930 | 71 | null | null | null | 141629 | Match Error |
| null | 1 | null | EGT998032Q18 | 772 | 2026-02-02 15:11:04 | null | B | 26.3 | 328000000 | null | 2356787 | 1 | 4501 | 0.99928 | null | null | null | null | 327763840 | 1 | null | null | null | 141698 | not accept buy order in case there is sell order with the same nin |
