create table ETPORD.ETP_TRADER
(
    TRADER_SERIAL_ID  NUMBER not null
        constraint "ETP_TRADER_pk"
            primary key,
    FIRM_SERIAL_ID    NUMBER
        constraint "ETP_TRADER_fk_firm"
            references ETPORD.ETP_FIRM,
    TRADER_CODE       VARCHAR2(50),
    TRADER_TYPE_CODE  NUMBER
        constraint "ETP_TRADER_fk_type"
            references ETPORD.ETP_TRADER_TYPE,
    TRADER_USER_NAME  VARCHAR2(50),
    TRADER_NAME       VARCHAR2(100),
    TRADER_ENG_NAME   VARCHAR2(100),
    TRADER_START_DATE DATE,
    TRADER_END_DATE   DATE,
    TRADER_STATUS     NUMBER,
    TRADER_PASSWORD   VARCHAR2(1500),
    LAST_SLOGIN_DATE  DATE,
    LAST_FLOGIN_DATE  DATE,
    FTRIES            NUMBER(5),
    FAIL_REASON       VARCHAR2(1500),
    IP_ADD            VARCHAR2(15),
    IP_RES            VARCHAR2(1),
    LAST_UPDATE_DATE  DATE,
    LAST_UPDATE_USER  VARCHAR2(100),
    PROCESSOR_ID      VARCHAR2(100),
    MOTHERBOARD_ID    VARCHAR2(100),
    IS_FIRST_LOGIN    CHAR      default 0,
    IS_API            NUMBER(1) default 0
)
/
| TRADER\_SERIAL\_ID | FIRM\_SERIAL\_ID | TRADER\_CODE | TRADER\_TYPE\_CODE | TRADER\_USER\_NAME | TRADER\_NAME | TRADER\_ENG\_NAME | TRADER\_START\_DATE | TRADER\_END\_DATE | TRADER\_STATUS | TRADER\_PASSWORD | LAST\_SLOGIN\_DATE | LAST\_FLOGIN\_DATE | FTRIES | FAIL\_REASON | IP\_ADD | IP\_RES | LAST\_UPDATE\_DATE | LAST\_UPDATE\_USER | PROCESSOR\_ID | MOTHERBOARD\_ID | IS\_FIRST\_LOGIN | IS\_API |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| 1 | 1 | 3501 | 2 | NBEUSER1 | البنك الاهلي المصري | National Bank of Egypt | 2020-07-01 | null | 0 | }}q | 2026-02-04 11:38:56 | 2026-01-27 11:13:34 | 0 | null | 10.35.1.5 | N | null | null | BFEBFBFF000906EA |                      | 1 | 1 |
| 2 | 2 | 3502 | 2 | HSBCUSER1 | بنك اتش اس بي سي مصر | HSBC Bank-Egypt 1 | 2020-07-01 | null | 0 | }}q | 2026-01-26 10:21:27 | 2026-01-21 15:11:22 | 0 | null | 10.35.2.5 | N | 2022-09-11 15:02:51 | mbehairy | BFEBFBFF000B0671 | /5GZVYY3/CNFCW0035400J5/ | 1 | 1 |
| 3 | 2 | 3502 | 2 | HSBCUSER2 |  بنك اتش اس بي سي مصر | HSBC Bank-Egypt 2 | 2020-07-01 | null | 0 | }}q | 2025-11-06 09:05:51 | 2025-10-06 09:11:47 | 0 | null | 10.35.2.6 | N | 2022-09-11 15:02:51 | mbehairy | null | null | 0 | 1 |
| 4 | 2 | 3502 | 2 | HSBCUSER3 |  بنك اتش اس بي سي مصر | HSBC Bank-Egypt 3 | 2020-07-01 | null | 0 | }}q | 2025-11-18 15:13:52 | 2025-11-04 14:31:51 | 0 | null | 10.35.2.7 | N | 2022-09-11 15:02:51 | mbehairy | null | null | 0 | 1 |
| 5 | 2 | 3502 | 2 | HSBCUSER4 |  بنك اتش اس بي سي مصر | HSBC Bank-Egypt 4 | 2020-07-01 | null | 0 | }}q | 2025-11-18 12:50:21 | 2025-09-16 11:32:33 | 0 | null | 10.35.2.8 | N | 2022-09-11 15:02:51 | mbehairy | null | null | 0 | 1 |
| 6 | 3 | 3504 | 2 | BONDS | Bonds System Owner | Bonds System Owner | 2020-07-01 | null | 2 | }}q | null | null | 0 | null | 172.0.0.41 | N | null | null | null | null | 0 | 1 |
| 7 | 3 | 3504 | 2 | CITIUSER1 | سيتي بنك 1 | Citi Bank 1 | 2020-07-01 | null | 0 | }}q | 2026-01-26 09:56:52 | 2025-10-22 09:51:00 | 0 | null | 10.35.4.5 | N | null | null | BFEBFBFF000906EA |                      | 1 | 1 |
| 8 | 4 | 3505 | 2 | MISRUSER1 | بنك مصر | Banque Misr | 2020-07-01 | null | 0 | }}q | 2026-01-26 09:57:15 | 2025-10-21 10:18:07 | 0 | null | 10.35.5.5 | N | null | null | BFEBFBFF000B0671 | PTQUE0FCYL4916 | 1 | 1 |
| 9 | 5 | 3506 | 2 | BCUSER1 | بنك القاهرة | Banque du Caire | 2020-07-01 | null | 0 | }}q | 2026-02-02 11:01:11 | 2025-10-20 11:15:49 | 0 | null | 10.35.6.5 | N | 2021-02-18 14:46:13 | mbehairy | BFEBFBFF000B0671 | /5GZVYY3/CNFCW0035400J5/ | 1 | 1 |
| 10 | 6 | 3507 | 2 | BAUSER1 | بنك الاسكندرية | Bank of Alexandria | 2020-07-01 | null | 0 | }}q | 2026-01-26 09:57:56 | 2025-11-09 13:45:38 | 0 | null | 10.35.7.5 | N | null | null | BFEBFBFF000A0653 | /HRDVVD3/CNFCW0011O00QC/ | 1 | 1 |
| 11 | 7 | 3508 | 2 | AABUSER1 | البنك العربى الافريقى | Arab African Bank | 2020-07-01 | null | 0 | }}q | 2026-01-26 09:58:28 | 2025-11-06 09:58:26 | 0 | null | 10.35.8.5 | N | null | null | BFEBFBFF000A0655 | /779FWD3/CNFCW0011O035H/ | 1 | 1 |
| 12 | 8 | 3509 | 2 | MIDUSER1 | ميد بنك | MIDBANK S.A.E | 2020-07-01 | null | 0 | }}q | 2026-01-26 09:58:49 | 2025-10-23 09:30:05 | 0 | null | 10.35.9.5 | N | null | null | BFEBFBFF000A0653 | /G89FWD3/CNFCW00231000S/ | 1 | 1 |
| 13 | 9 | 3510 | 2 | EABUSER1 | بنك كريدى أجريكول-مصر 1 | Credit Agricole Egypt 1 | 2020-07-01 | null | 0 | }}q | 2026-01-26 09:59:28 | 2025-11-13 09:50:16 | 0 | null | 10.35.10.6 | N | null | null | BFEBFBFF000006FB | HUB81002NK | 1 | 1 |
| 14 | 10 | 3515 | 2 | CIBUSER1 | البنك التجارى الدولى | Commercial International Bank- Egypt | 2020-07-01 | null | 0 | }}q | 2026-02-04 12:07:43 | 2025-11-17 10:00:21 | 0 | null | 10.35.15.5 | N | null | null | BFEBFBFF0001067A | CZC0166V49 | 1 | 1 |
| 15 | 11 | 3517 | 2 | ALBUSER1 | البنك العربى 1 | Arab Bank Ltd 1 | 2020-07-01 | null | 0 | }}q | 2026-01-26 10:00:39 | 2025-11-13 12:31:03 | 0 | null | 10.35.17.5 | N | null | null | BFEBFBFF0001067A | CZC90957D5 | 1 | 1 |

