create table ETPORD.ETP_TRADE_ORDER
(
    TRANS_CODE            NUMBER(10) not null,
    TRANS_DATE            DATE,
    SETTLEMENT_DATE       DATE,
    SEC_SERIAL_ID         NUMBER,
    ISIN                  VARCHAR2(12),
    BUY_FIRM_SERIAL_ID    NUMBER,
    BUY_BOOK_KEEPER       VARCHAR2(4),
    BUY_NIN_CODE          NUMBER,
    BUY_TRADER_SERIAL_ID  NUMBER,
    SELL_FIRM_SERIAL_ID   NUMBER,
    SELL_BOOK_KEEPER      VARCHAR2(4),
    SELL_NIN_CODE         NUMBER,
    SELL_TRADER_SERIAL_ID NUMBER,
    AMOUNT_TRADED         NUMBER(14, 2),
    PRICE                 NUMBER,
    GROSS_PRICE           NUMBER(14, 7),
    SETTLEMENT_VALUE      NUMBER(20, 5),
    CLEAN_PRICE           NUMBER(12, 7),
    YIELD_TO_MATURITY     NUMBER(11, 7),
    ACCRUED_INTEREST      NUMBER(11, 7),
    CURRENT_YIELD         NUMBER(11, 7),
    ACCRUAL_PERIOD        NUMBER,
    TRADE_INDICATOR       NUMBER(2),
    INSERT_USER           VARCHAR2(20),
    INSERT_DATE           DATE,
    UPDATE_USER           VARCHAR2(20),
    UPDATE_DATE           DATE,
    REJECT_RESONE         VARCHAR2(4000),
    BUY_ORDER_ID          NUMBER,
    SELL_ORDER_ID         NUMBER
)
/

create index ETPORD.BUY_ORDR_INDX
    on ETPORD.ETP_TRADE_ORDER (BUY_ORDER_ID)
/

create index ETPORD.SELL_ORDR_INDX
    on ETPORD.ETP_TRADE_ORDER (SELL_ORDER_ID)
/

| TRANS\_CODE | TRANS\_DATE | SETTLEMENT\_DATE | SEC\_SERIAL\_ID | ISIN | BUY\_FIRM\_SERIAL\_ID | BUY\_BOOK\_KEEPER | BUY\_NIN\_CODE | BUY\_TRADER\_SERIAL\_ID | SELL\_FIRM\_SERIAL\_ID | SELL\_BOOK\_KEEPER | SELL\_NIN\_CODE | SELL\_TRADER\_SERIAL\_ID | AMOUNT\_TRADED | PRICE | GROSS\_PRICE | SETTLEMENT\_VALUE | CLEAN\_PRICE | YIELD\_TO\_MATURITY | ACCRUED\_INTEREST | CURRENT\_YIELD | ACCRUAL\_PERIOD | TRADE\_INDICATOR | INSERT\_USER | INSERT\_DATE | UPDATE\_USER | UPDATE\_DATE | REJECT\_RESONE | BUY\_ORDER\_ID | SELL\_ORDER\_ID |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| 443121 | 2026-02-02 15:19:32 | 2026-02-02 | 616 | EGT9980E4Q15 | 1 | 4535 | 2321099 | 1 | 1 | 4501 | 2316019 | 1 | 34000000.00 | 24.76 | null | 32437700.00000 | 0.9540500 | null | null | null | null | null | null | null | null | null | null | 452508 | 452506 |
| 443140 | 2026-02-02 15:19:35 | 2026-02-02 | 622 | EGT998055Q10 | 1 | 4523 | 2307477 | 1 | 1 | 4523 | 2256243 | 1 | 250000000.00 | 24.15 | null | 235655000.00000 | 0.9426200 | null | null | null | null | null | null | null | null | null | null | 452514 | 452520 |
| 443146 | 2026-02-02 15:19:35 | 2026-02-02 | 549 | EGBGR05851F3 | 1 | 4504 | 2288241 | 1 | 1 | 4535 | 2249773 | 1 | 8000000.00 | 103.25332 | 1152.5335836 | 9220268.66880 | 1032.5332000 | 22.0542700 | 120.0003836 | 24.5200000 | null | null | null | null | null | null | null | 452531 | 452526 |
| 443171 | 2026-02-02 15:19:38 | 2026-02-02 | 616 | EGT9980E4Q15 | 1 | 4523 | 2917862 | 1 | 1 | 4531 | 2335898 | 1 | 10050000.00 | 24.66 | null | 9590011.50000 | 0.9542300 | null | null | null | null | null | null | null | null | null | null | 452567 | 451465 |
| 443188 | 2026-02-02 15:19:42 | 2026-02-02 | 616 | EGT9980E4Q15 | 1 | 4505 | 2856882 | 1 | 1 | 4531 | 2335898 | 1 | 125000.00 | 24.66 | null | 119278.75000 | 0.9542300 | null | null | null | null | null | null | null | null | null | null | 452597 | 451462 |
| 443200 | 2026-02-02 15:19:43 | 2026-02-02 | 609 | EGT9980H3Q19 | 1 | 4515 | 2857173 | 1 | 1 | 4515 | 644829 | 1 | 1575000.00 | 24.3 | null | 1531167.75000 | 0.9721700 | null | null | null | null | null | null | null | null | null | null | 452622 | 452621 |
| 443232 | 2026-02-02 15:19:47 | 2026-02-02 | 623 | EGBGR06271F3 | 1 | 4536 | 2249423 | 1 | 1 | 4523 | 2256243 | 1 | 100000000.00 | 99.4418386 | 1046.2776125 | 104627761.25000 | 994.4183860 | 21.5787700 | 51.8592265 | 21.4530000 | null | null | null | null | null | null | null | 452659 | 452650 |
| 443235 | 2026-02-02 15:19:48 | 2026-02-02 | 623 | EGBGR06271F3 | 1 | 4536 | 2249423 | 1 | 1 | 4523 | 2256243 | 1 | 60000000.00 | 99.2731541 | 1044.5907675 | 62675446.05000 | 992.7315410 | 21.6771300 | 51.8592265 | 21.4890000 | null | null | null | null | null | null | null | 452663 | 452662 |
| 443248 | 2026-02-02 15:19:50 | 2026-02-02 | 610 | EGT9980O3Q15 | 1 | 4508 | 1717081 | 1 | 1 | 4508 | 2960 | 1 | 202150000.00 | 24.6 | null | 195559910.00000 | 0.9674000 | null | null | null | null | null | null | null | null | null | null | 452691 | 452690 |
| 443271 | 2026-02-02 15:19:53 | 2026-02-02 | 594 | EGT998032Q18 | 1 | 4505 | 1289196 | 1 | 1 | 4515 | 644829 | 1 | 3000000.00 | 26.5 | null | 2997810.00000 | 0.9992700 | null | null | null | null | null | null | null | null | null | null | 452719 | 452499 |
| 443280 | 2026-02-02 15:19:54 | 2026-02-02 | 609 | EGT9980H3Q19 | 1 | 4508 | 1717081 | 1 | 1 | 4515 | 644829 | 1 | 27550000.00 | 24.3 | null | 26783283.50000 | 0.9721700 | null | null | null | null | null | null | null | null | null | null | 452736 | 452654 |
| 443295 | 2026-02-02 15:19:56 | 2026-02-02 | 596 | EGBGR06101F2 | 1 | 4502 | 2039328 | 1 | 1 | 4504 | 2288241 | 1 | 9691000.00 | 99.63267 | 1102.0795804 | 10680253.21366 | 996.3267000 | 21.6144600 | 105.7528804 | 21.4620000 | null | null | null | null | null | null | null | 452754 | 452755 |
| 443296 | 2026-02-02 15:19:56 | 2026-02-02 | 596 | EGBGR06101F2 | 1 | 4502 | 2039328 | 1 | 1 | 4504 | 2288241 | 1 | 1217000.00 | 99.63267 | 1102.0795804 | 1341230.84935 | 996.3267000 | 21.6144600 | 105.7528804 | 21.4620000 | null | null | null | null | null | null | null | 452756 | 452755 |
| 443301 | 2026-02-02 15:19:57 | 2026-02-02 | 608 | EGT9980A3Q14 | 1 | 4504 | 2495752 | 1 | 1 | 4526 | 2307417 | 1 | 65000000.00 | 26.39 | null | 63350950.00000 | 0.9746300 | null | null | null | null | null | null | null | null | null | null | 452767 | 448995 |
| 443323 | 2026-02-02 15:20:01 | 2026-02-02 | 561 | EGBGR05931F3 | 1 | 4504 | 2284160 | 1 | 1 | 4504 | 2288241 | 1 | 1478000.00 | 102.56818 | 1108.7719918 | 1638765.00388 | 1025.6818000 | 22.0255900 | 83.0901918 | 23.8460000 | null | null | null | null | null | null | null | 452791 | 452743 |
