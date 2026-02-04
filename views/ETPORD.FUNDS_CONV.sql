create view ETPORD.FUNDS_CONV as
SELECT   funds_code, FUNDS_CONVERSION
     FROM   temp_tsconv a
    WHERE   FUNDS_DATE_CCD =
               (SELECT   MAX (FUNDS_DATE_CCD)
                  FROM   temp_tsconv b
                 WHERE   a.funds_code = b.funds_code
                         AND FUNDS_DATE_CCD <= TRUNC (SYSDATE))
/

