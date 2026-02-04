create table ETPORD.ETP_MARKET_SECURITIES
(
    MARKET_CODE   NUMBER not null
        constraint "etp_market_securities_fk_mar"
            references ETPORD.ETP_MARKET,
    SEC_SERIAL_ID NUMBER not null
        constraint "etp_market_securities_fk_sec"
            references ETPORD.ETP_SECURITIES,
    UNQ_ID        NUMBER not null
        constraint "etp_market_securities_pk"
            primary key,
    START_DATE    DATE,
    END_DATE      DATE,
    UPDATE_DATE   DATE,
    UPDATE_USER   VARCHAR2(50 char),
    STATUS        NUMBER default 0
)
/

| MARKET\_CODE | SEC\_SERIAL\_ID | UNQ\_ID | START\_DATE | END\_DATE | UPDATE\_DATE | UPDATE\_USER | STATUS |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| 2 | 175 | 1 | 2020-12-24 | 2025-02-20 | null | null | 0 |
| 2 | 176 | 2 | 2020-12-24 | 2021-03-20 | null | null | 0 |
| 2 | 177 | 3 | 2020-12-24 | 2023-04-10 | null | null | 0 |
| 2 | 178 | 4 | 2020-12-24 | 2028-05-08 | null | null | 0 |
| 2 | 179 | 5 | 2020-12-24 | 2021-06-12 | null | null | 0 |
| 2 | 180 | 6 | 2020-12-24 | 2023-07-03 | null | null | 0 |
| 2 | 181 | 7 | 2020-12-24 | 2025-08-07 | null | null | 0 |
| 2 | 182 | 8 | 2020-12-24 | 2023-10-09 | null | null | 0 |
| 2 | 183 | 9 | 2020-12-24 | 2028-11-06 | null | null | 0 |
| 2 | 184 | 10 | 2020-12-24 | 2021-12-11 | null | null | 0 |
| 2 | 185 | 11 | 2020-12-24 | 2026-04-02 | null | null | 0 |
| 2 | 186 | 12 | 2020-12-24 | 2024-04-09 | null | null | 0 |
| 2 | 187 | 13 | 2020-12-24 | 2029-05-07 | null | null | 0 |
| 2 | 188 | 14 | 2020-12-24 | 2022-06-11 | null | null | 0 |
| 2 | 189 | 15 | 2020-12-24 | 2024-07-02 | null | null | 0 |
| 2 | 190 | 16 | 2020-12-24 | 2026-08-06 | null | null | 0 |
