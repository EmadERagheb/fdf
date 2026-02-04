create table ETPORD.ETP_MARKETS_PRICE_RANGE
(
    ID        NUMBER not null
        constraint ETP_MARKETS_PRICE_RANGE_PK
            primary key,
    IS_BOND   CHAR   not null,
    PRICE_MAX NUMBER not null,
    PRICE_MIN NUMBER not null,
    YTM_MAX   NUMBER not null,
    YTM_MIN   NUMBER not null
)
/

| ID | IS\_BOND | PRICE\_MAX | PRICE\_MIN | YTM\_MAX | YTM\_MIN |
| :--- | :--- | :--- | :--- | :--- | :--- |
| 0 | Y | 130 | 50 | 50 | 1 |
| 1 | N | 50 | 1 | 50 | 1 |
