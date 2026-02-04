
create table ETPORD.ETP_FIRMS_SECURITIES
(
    FIRM_SERIAL_ID   NUMBER not null
        constraint "etp_firms_securities_fk_firm"
            references ETPORD.ETP_FIRM,
    STATUS           NUMBER,
    UNQ_ID           NUMBER not null
        constraint "etp_firms_securities_fk_sec"
            references ETPORD.ETP_MARKET_SECURITIES,
    START_DATE       DATE,
    END_DATE         DATE,
    FIRM_PRIV        NUMBER not null
        constraint "etp_firms_securities_fk_prv"
            references ETPORD.ETP_FIRM_PRIV,
    LAST_UPDATE_DATE DATE,
    LAST_UPDATE_USER VARCHAR2(100),
    MARKET_DISP      VARCHAR2(1),
    constraint ETP_FIRMS_SECURITIES_PK
        primary key (FIRM_SERIAL_ID, UNQ_ID, FIRM_PRIV)
)
/

comment on column ETPORD.ETP_FIRMS_SECURITIES.MARKET_DISP is 'for MM for RFQ relation'
/

| FIRM\_SERIAL\_ID | STATUS | UNQ\_ID | START\_DATE | END\_DATE | FIRM\_PRIV | LAST\_UPDATE\_DATE | LAST\_UPDATE\_USER | MARKET\_DISP |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| 1 | 0 | 1 | 2020-12-24 | 2025-02-20 | 1 | null | null | 1 |
| 1 | 0 | 2 | 2020-12-24 | 2021-03-20 | 1 | null | null | 1 |
| 1 | 0 | 3 | 2020-12-24 | 2023-04-10 | 1 | null | null | 1 |
| 1 | 0 | 4 | 2020-12-24 | 2028-05-08 | 1 | null | null | 1 |
| 1 | 0 | 5 | 2020-12-24 | 2021-06-12 | 1 | null | null | 1 |
| 1 | 0 | 6 | 2020-12-24 | 2023-07-03 | 1 | null | null | 1 |
| 1 | 0 | 7 | 2020-12-24 | 2025-08-07 | 1 | null | null | 1 |
| 1 | 0 | 8 | 2020-12-24 | 2023-10-09 | 1 | null | null | 1 |
| 1 | 0 | 9 | 2020-12-24 | 2028-11-06 | 1 | null | null | 1 |
| 1 | 0 | 10 | 2020-12-24 | 2021-12-11 | 1 | null | null | 1 |
| 1 | 0 | 11 | 2020-12-24 | 2026-04-02 | 1 | null | null | 1 |
| 1 | 0 | 12 | 2020-12-24 | 2024-04-09 | 1 | null | null | 1 |
| 1 | 0 | 13 | 2020-12-24 | 2029-05-07 | 1 | null | null | 1 |
| 1 | 0 | 14 | 2020-12-24 | 2022-06-11 | 1 | null | null | 1 |
| 1 | 0 | 15 | 2020-12-24 | 2024-07-02 | 1 | null | null | 1 |
| 1 | 0 | 16 | 2020-12-24 | 2026-08-06 | 1 | null | null | 1 |
