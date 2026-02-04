create view ETPORD.ETP_BKKP as
SELECT   "BROKER_CODE",
            "BROKER_NAME",
            "BROKER_NAME_2",
            "BROKER_SHORTNAME",
            "BROKER_SHORTNAME_ENG",
            "RECORD_ACTIVE_IND",
            "TRADING_MEMBER_IND",
            "FINANCIAL_INT_IND",
            "BROKER_STATUS",
            "BROKER_CHAIRMAN",
            "BROKER_CHAIRMAN_ENG",
            "BROKER_ADDRESS",
            "BROKER_ADDRESS_ENG",
            "BROKER_PHONE",
            "BROKER_FAX",
            "BROKER_EMAIL",
            "LAST_UPDATE_DATE",
            "LAST_UPDATE_USER_ID",
            "IP_START_FROM",
            "IP_END_AT"
     FROM   TSHMBR
    WHERE   FINANCIAL_INT_IND = 'Y'
            AND broker_code IN (SELECT   BKKP_CODE
                                  FROM   ETP_BANK_BKKP
                                 WHERE   CBE_MEMBER = 'Y')
   UNION ALL
  SELECT   "BROKER_CODE",
            "BROKER_NAME",
            "BROKER_NAME_2",
            "BROKER_SHORTNAME",
            "BROKER_SHORTNAME_ENG",
            "RECORD_ACTIVE_IND",
            "TRADING_MEMBER_IND",
            "FINANCIAL_INT_IND",
            "BROKER_STATUS",
            "BROKER_CHAIRMAN",
            "BROKER_CHAIRMAN_ENG",
            "BROKER_ADDRESS",
            "BROKER_ADDRESS_ENG",
            "BROKER_PHONE",
            "BROKER_FAX",
            "BROKER_EMAIL",
            "LAST_UPDATE_DATE",
            "LAST_UPDATE_USER_ID",
            "IP_START_FROM",
            "IP_END_AT"
     FROM   etp_bkkp_local
    WHERE   FINANCIAL_INT_IND = 'Y'
            AND broker_code IN (SELECT   BKKP_CODE
                                  FROM   ETP_BANK_BKKP
                                 WHERE   CBE_MEMBER = 'Y')
/

| BROKER\_CODE | BROKER\_NAME | BROKER\_NAME\_2 | BROKER\_SHORTNAME | BROKER\_SHORTNAME\_ENG | RECORD\_ACTIVE\_IND | TRADING\_MEMBER\_IND | FINANCIAL\_INT\_IND | BROKER\_STATUS | BROKER\_CHAIRMAN | BROKER\_CHAIRMAN\_ENG | BROKER\_ADDRESS | BROKER\_ADDRESS\_ENG | BROKER\_PHONE | BROKER\_FAX | BROKER\_EMAIL | LAST\_UPDATE\_DATE | LAST\_UPDATE\_USER\_ID | IP\_START\_FROM | IP\_END\_AT |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| 4516 | Al-Watany for Bookkeeping | الوطنى لادارة السجلات | الوطنى | null | Y | N | Y | A | null | null | null | null | null | null | null | 2010-04-20 09:08:45 | watny      | 10.10.0.0 | 10.10.0.0 |
| 4515 | Commercial International Bank for Bookkeeping | البنك التجاري الدولي / مصر | التجاري | null | Y | N | Y | A | null | null | null | null | null | null | null | 2010-04-20 09:08:45 | whaggagy   | 10.10.0.0 | 10.10.0.0 |
| 4601 | المجموعة المالية هيرمس القابضة | المجموعة المالية هيرمس القابضة | المجموعة المالية هيرمس القابضه | null | Y | N | Y | A | null | null | null | null | null | null | null | 2010-04-20 09:08:46 | mfayez     | 10.10.0.0 | 10.10.0.0 |
| 4524 | بنك كريدى اجريكول  / الاسكندرية | بنك كريدى اجريكول  / الاسكندرية | بنك كريدي اجريكول مصر/الاسكندريه | null | Y | N | Y | A | null | null | null | null | null | null | null | 2010-04-20 09:08:46 | nmaksoud   | 10.10.0.0 | 10.10.0.0 |
| 4532 | البنك الاهلي سوسيتيه جنرال/جلوبال | البنك الاهلي سوسيتيه جنرال/جلوبال | سوسيتيه جنرال | سوسيتيه جنرال | Y | N | Y | A | null | null | null | null | null | null | null | 2010-04-20 07:45:15 | Mkhairy   | 10.10.0.0 | 10.10.0.0 |
| 4533 | بنك المصرف المتحد | بنك المصرف المتحد | بنك المصرف المتحد | بنك المصرف المتحد | Y | N | Y | A | null | null | null | null | null | null | null | 2012-05-14 | mtanany | 10.10.0.0 | 10.10.0.0 |
| 4536 | Abu Dhabi Islamic Bank - Egypt \(ADIB - Egypt\) | مصرف أبو ظبي الإسلامي - مصر | أبو ظبي الإسلامي - مصر | ADIB - Egypt | Y | N | Y | A | null | null | null | null | null | null | null | 2022-09-28 18:06:46 | mbehairy | 10.10.0.0 | 10.10.0.0 |
| 4537 | Abu Dhabi Commercial Bank-Egypt\(ADCB-Egypt\) | بنك أبو ظبي التجاري - مصر ش.م.م | أبو ظبي التجاري - مصر | ADCB - Egypt | Y | N | Y | A | null | null | null | null | null | null | null | 2023-08-30 15:38:46 | mbehairy | 10.10.0.0 | 10.10.0.0 |
| 4620 | Ostoul Capital | مجموعة أسطول للاستثمارات المالية | اسطول | Ostoul  | Y | N | Y | A | null | null | null | null | null | null | null | 2017-12-04 | null | 10.10.0.0 | 10.10.0.0 |
| 4534 | Arab Investment Bank | بنك الإستثمار العربى | بنك الإستثمار العربى | Arab Investment Bank | Y | N | Y | A | null | null | null | null | null | null | null | 2018-02-25 14:59:54 | mtanany | 10.10.0.0 | 10.10.0.0 |
| 4623 | Mubasher Capital  Holding | مباشر كابيتال هولدنج للإستثمارات المالية | مباشر كابيتال | Mubasher Capital | Y | N | Y | A | null | null | null | null | null | null | null | 2021-02-28 | MTANANY | 10.10.0.0 | 10.10.0.0 |
| 4535 | First Abu Dhabi Bank \(FAB\) | بنك أبو ظبي الأول | بنك أبو ظبي الأول | First Abu Dhabi Bank | Y | N | Y | A | null | null | null | null | null | null | null | 2022-03-08 16:50:04 | mtanany | 10.10.0.0 | 10.10.0.0 |
| 4530 | بنك عودة لادارة السجلات | بنك عودة لادارة السجلات | بنك عوده لاداره السجلا ت | null | Y | N | Y | A | null | null | null | null | null | null | null | 2010-04-20 09:08:46 | nmaksoud   | 10.10.0.0 | 10.10.0.0 |
| 4503 | Ahli United Bank\_Egypt | \(البنك الاهلى المتحد \(مصر | بنك الدلتا الدولى | null | Y | N | Y | A | null | null | null | null | null | null | null | 2010-04-20 09:08:45 | mtanany    | 10.10.0.0 | 10.10.0.0 |
| 4523 | National Sosite General for Bookkeeping | البنك الاهلي سوسيتيه جنرال | بنك مصر الدولى | null | Y | N | Y | A | null | null | null | null | null | null | null | 2010-04-20 09:08:46 | mfayez     | 10.10.0.0 | 10.10.0.0 |
| 4505 | Bank Misr For Bookkeeping | بنك مصر لادارة السجلات | بنك مصر | null | Y | N | Y | A | null | null | null | null | null | null | null | 2010-04-20 09:08:45 | mfayez     | 10.10.0.0 | 10.10.0.0 |
| 4526 | Piraeus Bank - Egypt for Bookkeeping | بنك بيريوس - مصر | بنك بيريوس | null | Y | N | Y | A | null | null | null | null | null | null | null | 2010-04-20 09:08:46 | mfayez     | 10.10.0.0 | 10.10.0.0 |
| 4501 | National Bank of Egypt for Bookkeeping | البنك الاهلي المصري | البنك الا هلى | null | Y | N | Y | A | null | null | null | null | null | null | null | 2013-03-21 09:57:28 | 0          | 10.10.0.0 | 10.10.0.0 |
| 4511 | بنك كريدى اجريكول لادارة السجلات | بنك كريدى اجريكول لادارة السجلات | امريكان اكسبريس | null | Y | N | Y | A | null | null | null | null | null | null | null | 2010-04-20 09:08:45 | nmaksoud   | 10.10.0.0 | 10.10.0.0 |
| 4508 | Arab African Bank For Bookkeeping | البنك العربى الافريقى لادارة السجلات | العربى الا فريقى | null | Y | N | Y | A | null | null | null | null | null | null | null | 2010-04-20 09:08:45 | mfayez     | 10.10.0.0 | 10.10.0.0 |
| 4522 | بنك فيصل الاسلامي المصري | بنك فيصل الاسلامي المصري | بنك فيصل | null | Y | N | Y | A | null | null | null | null | null | null | null | 2010-04-20 09:08:46 | whaggagy   | 10.10.0.0 | 10.10.0.0 |
| 4998 | مصر للمقاصة / أرصدة السجلات | مصر للمقاصة / أرصدة السجلات | مصر للمقاصة/أرصدة سجلا ت | null | Y | N | Y | A | null | null | null | null | null | null | null | 2010-04-20 09:08:46 | mfayez     | 10.10.0.0 | 10.10.0.0 |
| 4608 | برايم القابضة للاستثمارات المالية | برايم القابضة للاستثمارات المالية | برايم القابضة | null | Y | N | Y | A | null | null | null | null | null | null | null | 2010-04-20 09:08:46 | mtanany    | 10.10.0.0 | 10.10.0.0 |
| 4517 | Arab Bank LTD. for Bookkeeping | البنك العربى المحدود | البنك العربى المحدود | null | Y | N | Y | A | null | null | null | null | null | null | null | 2022-11-24 14:37:35 | amr        | 10.10.0.0 | 10.10.0.0 |
| 4528 | BNP Paribas Bank for Bookkeeping | بنك بي ان بي باريبا | بنك بى ان بى باريبا | null | Y | N | Y | A | null | null | null | null | null | null | null | 2010-04-20 09:08:46 | mfayez     | 10.10.0.0 | 10.10.0.0 |
| 4527 | BLOM Bank Egypt - for Bookkeeping | بنك بلوم مصر | بنك بلوم مصر | null | Y | N | Y | A | null | null | null | null | null | null | null | 2010-04-20 09:08:46 | mfayez     | 10.10.0.0 | 10.10.0.0 |
| 4520 | بنك قناة السويس لادارة السجلات | بنك قناة السويس لادارة السجلات | بنك قناة السويس | null | Y | N | Y | A | null | null | null | null | null | null | null | 2010-04-20 09:08:46 | mfayez     | 10.10.0.0 | 10.10.0.0 |
| 4529 | بنك التمويل المصرى السعودى | بنك التمويل المصرى السعودى | بنك التمويل المصرى السعودى | null | Y | N | Y | A | null | null | null | null | null | null | null | 2010-04-20 09:08:46 | nmaksoud   | 10.10.0.0 | 10.10.0.0 |
| 4531 | بنك باركليز مصر | بنك باركليز مصر | بنك باركليز مصر | null | Y | N | Y | A | null | null | null | null | null | null | null | 2010-04-20 09:08:46 | mtanany    | 10.10.0.0 | 10.10.0.0 |
| 4506 | Cairo Bank For Bookkeeping | بنك القاهرة لادارة السجلات | بنك القاهرة | null | Y | N | Y | A | null | null | null | null | null | null | null | 2010-04-20 09:08:45 | mfayez     | 10.10.0.0 | 10.10.0.0 |
| 4611 | اتش سى للأوراق المالية | اتش سى للأوراق المالية | اتش سى | null | Y | N | Y | A | null | null | null | null | null | null | null | 2010-04-20 09:08:46 | heba       | 10.10.0.0 | 10.10.0.0 |
| 4518 | بنك الشركة المصرفية | بنك الشركة المصرفية | بنك الشركة المصرفية | null | Y | N | Y | A | null | null | null | null | null | null | null | 2022-11-24 10:42:58 | BANK       | 10.10.0.0 | 10.10.0.0 |
| 4603 | Beltone Securities Holding | بلتون سيكيورتيز هولدنج | بلتون سيكيورتيز | null | Y | N | Y | A | null | null | null | null | null | null | null | 2010-04-20 09:08:46 | mfayez     | 10.10.0.0 | 10.10.0.0 |
| 4512 | HSBC For Bookkeeping | بنك اتش اس بى سى لادارة السجلات | المصري البريطاني | null | Y | N | Y | A | null | null | null | null | null | null | null | 2010-04-20 09:08:45 | mtanany    | 10.10.0.0 | 10.10.0.0 |
| 4605 | سى أى كابيتال القابضة | سى أى كابيتال القابضة | سى اى كابيتال القابضة | null | Y | N | Y | A | null | null | null | null | null | null | null | 2011-05-29 09:59:27 | nmaksoud   | 10.10.0.0 | 10.10.0.0 |
| 4509 | Misr Iran Bank For Bookkeeping | بنك مصر ايران للتنمية لادارة السجلات | بنك مصر ايران للتنمية لا دارة السجلا ت | null | Y | N | Y | A | null | null | null | null | null | null | null | 2010-04-20 09:08:45 | mfayez     | 10.10.0.0 | 10.10.0.0 |
| 4507 | Bank of Alexandria for Bookkeeping | بنك الاسكندرية لادارة السجلات | بنك الا سكندرية | null | Y | N | Y | A | null | null | null | null | null | null | null | 2010-04-20 09:08:45 | 0          | 10.10.0.0 | 10.10.0.0 |
| 4510 | بنك كريدى أجريكول مصر لادارة السجلات | بنك كريدى أجريكول مصر لادارة السجلات | المصري الا مريكي | null | Y | N | Y | A | null | null | null | null | null | null | null | 2010-04-20 09:08:45 | nmaksoud   | 10.10.0.0 | 10.10.0.0 |
| 4502 | HSBC Egypt for Bookkeeping | بنك اتش اس بي سي مصر | HSBC | null | Y | N | Y | A | null | null | null | null | null | null | null | 2010-04-20 09:08:45 | whaggagy   | 10.10.0.0 | 10.10.0.0 |
| 4602 | سيجما كابيتال القابضة للاستثمارات المالية | سيجما كابيتال القابضة للاستثمارات المالية | سيجما كابيتال القابضة | null | Y | N | Y | A | null | null | null | null | null | null | null | 2010-04-20 09:08:46 | mtaher     | 10.10.0.0 | 10.10.0.0 |
| 4525 | البنك المصري الخليجي | البنك المصري الخليجي | البنك المصرى الخليجى | null | Y | N | Y | A | null | null | null | null | null | null | null | 2010-04-20 09:08:46 | mfayez     | 10.10.0.0 | 10.10.0.0 |
| 4504 | CitiBank For Bookkeeping | سيتى بنك لادارة السجلات | سيتى بنك | null | Y | N | Y | A | null | null | null | null | null | null | null | 2010-04-20 09:08:45 | mfayez     | 10.10.0.0 | 10.10.0.0 |
| 4521 | بنك مصر/طلعت حرب -الاسكندرية | بنك مصر/طلعت حرب -الاسكندرية | بنك مصرطلعت حرب | null | Y | N | Y | A | null | null | null | null | null | null | null | 2010-04-20 09:08:46 | mfayez     | 10.10.0.0 | 10.10.0.0 |
| 4999 | MCDR for Bookkeeping | مصر المقاصه لاداره السجلات | مصر المقاصه | null | Y | N | Y | A | null | null | null | null | null | null | null | 2010-04-20 09:08:46 | 0          | 10.10.0.0 | 10.10.0.0 |
| 4519 | البنك المصري لتنمية الصادرات | البنك المصري لتنمية الصادرات | البنك المصرى لتنمية الصادرات | null | Y | N | Y | A | null | null | null | null | null | null | null | 2010-04-20 09:08:46 | mfayez     | 10.10.0.0 | 10.10.0.0 |
| 5005 | Standard Chartered Bank | بنك ستاندرد تشارتر | بنك ستاندرد تشارتر | Standard Chartered Bank | Y | N | Y | A | null | null | null | null | null | null | null | 2024-12-19 | Khairy | 10.10.0.0 | 10.10.0.0 |
| 5001 | Mashreq Bank | بنك المشرق - مصر | بنك المشرق | Mashreq Bank - Egypt | Y | N | Y | A | null | null | null | null | null | null | null | 2023-06-14 | Khairy | 10.10.0.0 | 10.10.0.0 |
| 5002 | Housing & Development bank | بنك التعمير والإسكان | بنك التعمير والإسكان | Housing & Development bank | Y | N | Y | A | null | null | null | null | null | null | null | 2023-09-21 | Khairy | 10.10.0.0 | 10.10.0.0 |
| 5999 | Egyptian Central Securities Depository | الشركة المصرية للإيداع والقيد المركزي | المصرية للإيداع والقيد المركزي | Egyptian Central Securities Depository | Y | N | Y | A | null | null | null | null | null | null | null | 2023-09-21 | Khairy | 10.10.0.0 | 10.10.0.0 |
