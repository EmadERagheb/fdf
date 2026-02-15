create FUNCTION     etp_func_ACCRUED_INTEREST ( /*odd calc*/
    o_ISIN               CHAR,
    o_SETTLEMENT_DATE    DATE)
    RETURN NUMBER
AS
    VCOUPON_RATE           NUMBER;
    VPARVALUE              NUMBER;
    FREQUENCY              NUMBER;
    VLAST_COUPON_PAYMENT   DATE;
    VNEXT_COUPON_PAYMENT   DATE;
    VCouponInDays          NUMBER;
    VIsSpecialIsin         NUMBER;
    VMATURITY_DATE         DATE;
    VYearInDays            NUMBER;
    VPERIOD                NUMBER;
    VACCRUED_INTEREST      NUMBER;
    vODD                   VARCHAR (3);
BEGIN
    SELECT PARVALUE,
           COUPON_INTER_RATE / 100,
           NUMBER_OF_COUPONS,
           LAST_COUPON_PAYMENT,
           NEXT_COUPON_PAYMENT,
           MATURITY_DATE,
           TO_NUMBER (
               DECODE (
                   TO_CHAR (
                       TO_DATE (
                           '31/12' || TO_CHAR (o_SETTLEMENT_DATE, 'YYYY'),
                           'DD/MM/YYYY'),
                       'DDD'),
                   '366', '366',
                   '365')),
           NVL (bond_type, 0),
           ETP_FUNC_ODD_TYPE (SEC_SERIAL_ID, o_SETTLEMENT_DATE)
      INTO VPARVALUE,
           VCOUPON_RATE,
           FREQUENCY,
           VLAST_COUPON_PAYMENT,
           VNEXT_COUPON_PAYMENT,
           VMATURITY_DATE,create FUNCTION     etp_func_ACCRUED_INTEREST ( /*odd calc*/
    o_ISIN               CHAR,
    o_SETTLEMENT_DATE    DATE)
    RETURN NUMBER
AS
    VCOUPON_RATE           NUMBER;
    VPARVALUE              NUMBER;
    FREQUENCY              NUMBER;
    VLAST_COUPON_PAYMENT   DATE;
    VNEXT_COUPON_PAYMENT   DATE;
    VCouponInDays          NUMBER;
    VIsSpecialIsin         NUMBER;
    VMATURITY_DATE         DATE;
    VYearInDays            NUMBER;
    VPERIOD                NUMBER;
    VACCRUED_INTEREST      NUMBER;
    vODD                   VARCHAR (3);
BEGIN
    SELECT PARVALUE,
           COUPON_INTER_RATE / 100,
           NUMBER_OF_COUPONS,
           LAST_COUPON_PAYMENT,
           NEXT_COUPON_PAYMENT,
           MATURITY_DATE,
           TO_NUMBER (
               DECODE (
                   TO_CHAR (
                       TO_DATE (
                           '31/12' || TO_CHAR (o_SETTLEMENT_DATE, 'YYYY'),
                           'DD/MM/YYYY'),
                       'DDD'),
                   '366', '366',
                   '365')),
           NVL (bond_type, 0),
           ETP_FUNC_ODD_TYPE (SEC_SERIAL_ID, o_SETTLEMENT_DATE)
      INTO VPARVALUE,
           VCOUPON_RATE,
           FREQUENCY,
           VLAST_COUPON_PAYMENT,
           VNEXT_COUPON_PAYMENT,
           VMATURITY_DATE,
           VYearInDays,
           VIsSpecialIsin,
           vODD
      FROM ETP_SECURITIES
     WHERE SEC_ISIN_CODE = o_ISIN;

    IF SUBSTR (VODD, 1, 1) = 'N'
    THEN                                                             -- NORMAL
        /*   if  o_ISIN='EGBGR03221F1' and to_char(VLAST_coupon_payment,'yyyymmdd') ='20210629'  then 
              VCouponInDays := (VNEXT_coupon_payment - ((VLAST_coupon_payment)+2)); 
          else    
              VCouponInDays := (VNEXT_coupon_payment - VLAST_coupon_payment);
              
          end if; 
          */
           VCouponInDays := (VNEXT_coupon_payment - VLAST_coupon_payment);
          
    ELSE                                                                -- ODD
        VCouponInDays :=
            (  VNEXT_coupon_payment
             - ((VLAST_coupon_payment) + TO_NUMBER (SUBSTR (VODD, 2))));
    END IF;

    IF VIsSpecialIsin = 1 AND VCOUPON_RATE > 0
    THEN                                                       --- MOF Request
        FREQUENCY := ROUND (VYearInDays / VCouponInDays, 5);
    END IF;

    VPERIOD := TRUNC (o_SETTLEMENT_DATE - VLAST_coupon_payment);

    VACCRUED_INTEREST :=
        NVL (
              (VCOUPON_RATE * VPARVALUE / FREQUENCY)
            * (VPERIOD)
            / (VCouponInDays),
            0);

    RETURN VACCRUED_INTEREST;
END;
/


           VYearInDays,
           VIsSpecialIsin,
           vODD
      FROM ETP_SECURITIES
     WHERE SEC_ISIN_CODE = o_ISIN;

    IF SUBSTR (VODD, 1, 1) = 'N'
    THEN                                                             -- NORMAL
        /*   if  o_ISIN='EGBGR03221F1' and to_char(VLAST_coupon_payment,'yyyymmdd') ='20210629'  then 
              VCouponInDays := (VNEXT_coupon_payment - ((VLAST_coupon_payment)+2)); 
          else    
              VCouponInDays := (VNEXT_coupon_payment - VLAST_coupon_payment);
              
          end if; 
          */
           VCouponInDays := (VNEXT_coupon_payment - VLAST_coupon_payment);
          
    ELSE                                                                -- ODD
        VCouponInDays :=
            (  VNEXT_coupon_payment
             - ((VLAST_coupon_payment) + TO_NUMBER (SUBSTR (VODD, 2))));
    END IF;

    IF VIsSpecialIsin = 1 AND VCOUPON_RATE > 0
    THEN                                                       --- MOF Request
        FREQUENCY := ROUND (VYearInDays / VCouponInDays, 5);
    END IF;

    VPERIOD := TRUNC (o_SETTLEMENT_DATE - VLAST_coupon_payment);

    VACCRUED_INTEREST :=
        NVL (
              (VCOUPON_RATE * VPARVALUE / FREQUENCY)
            * (VPERIOD)
            / (VCouponInDays),
            0);

    RETURN VACCRUED_INTEREST;
END;
/

