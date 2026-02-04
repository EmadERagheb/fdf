create FUNCTION     etp_func_YTM (o_ISIN               CHAR,
                                             o_TRANS_RATE         NUMBER,
                                             o_SETTLEMENT_DATE    DATE)
    RETURN NUMBER
AS
    VPARVALUE               NUMBER;
    VCOUPON_RATE            NUMBER;
    VYearInDays             NUMBER;
    VCouponInDays           NUMBER;                                        --E
    VSettlemnt_LastCoupon   NUMBER;                                        --A
    VNextCoupon_Settlemnt   NUMBER;                                     -- DSC
    VIsSpecialIsin          NUMBER;
    VFREQUENCE              NUMBER;
    VMATURITY_DATE          DATE;
    YEARS                   NUMBER;
    VYIELD_TO_MATURITY      NUMBER;
    YTM                     NUMBER;
    E                       NUMBER := 1;
    VCOUPON_LEFT            NUMBER;
    VRATE_PER_PERIOD        NUMBER;
    PARTA                   NUMBER;
    PARTB                   NUMBER;
    PARTC                   NUMBER;
    PARTD                   NUMBER;
    VLAST_COUPON_PAYMENT    DATE;
    VNEXT_COUPON_PAYMENT    DATE;
    vACCRUED_INTEREST       NUMBER;
    vYTM                    NUMBER;
    vRedemption             NUMBER := 100;
BEGIN
    SELECT PARVALUE,
           COUPON_INTER_RATE / 100,
           TO_NUMBER (
               DECODE (
                   TO_CHAR (
                       TO_DATE (
                           '31/12' || TO_CHAR (o_SETTLEMENT_DATE, 'YYYY'),
                           'DD/MM/YYYY'),
                       'DDD'),
                   '366', '366',
                   '365')),
           (NEXT_COUPON_PAYMENT - LAST_COUPON_PAYMENT),
           NUMBER_OF_COUPONS,
           NVL (bond_type, 0),
           MATURITY_DATE,
           NEXT_COUPON_PAYMENT,
           LAST_COUPON_PAYMENT,
           (o_SETTLEMENT_DATE - LAST_COUPON_PAYMENT),
           (NEXT_COUPON_PAYMENT - o_SETTLEMENT_DATE)
      INTO VPARVALUE,
           VCOUPON_RATE,
           VYearInDays,
           VCouponInDays,
           VFREQUENCE,
           VIsSpecialIsin,
           VMATURITY_DATE,
           VNEXT_COUPON_PAYMENT,
           VLAST_COUPON_PAYMENT,
           VSettlemnt_LastCoupon,
           VNextCoupon_Settlemnt
      FROM ETP_SECURITIES
     WHERE SEC_ISIN_CODE = o_ISIN;
     
     
    /* if o_isin ='EGBGR03221F1' and to_char(VLAST_COUPON_PAYMENT,'yyyymmdd') ='20210629' then
    
    vACCRUED_INTEREST :=
        etp_func_ACCRUED_INTEREST_odd (o_isin, o_SETTLEMENT_DATE);
    else
     
    vACCRUED_INTEREST :=
        etp_func_ACCRUED_INTEREST (o_isin, o_SETTLEMENT_DATE);
        
    end if;*/
    

    vACCRUED_INTEREST :=
        etp_func_ACCRUED_INTEREST (o_isin, o_SETTLEMENT_DATE);

    -- Check if isin is special (0 normal 1 special)
    IF VIsSpecialIsin = 1 AND VCOUPON_RATE > 0
    THEN                        --- MOF Request      to eliminate zero coupons
        VFREQUENCE := ROUND ((VYearInDays / VCouponInDays), 5);
    END IF;


    IF o_TRANS_RATE IS NOT NULL
    THEN
        SELECT etp_func_YEARS_CALC (VMATURITY_DATE, o_SETTLEMENT_DATE)
          INTO YEARS
          FROM DUAL;

        -- Check if isin is special (0 normal 1 special)
        IF VIsSpecialIsin = 1
        THEN
            YEARS := (VMATURITY_DATE - o_SETTLEMENT_DATE) / VYearInDays; -- MOF Request
        END IF;

        --
        IF     (YEARS * VFREQUENCE) = FLOOR (YEARS * VFREQUENCE)
           AND (YEARS * VFREQUENCE) = CEIL (YEARS * VFREQUENCE) -- SETTLEMENT_DATE at coupon date
        THEN
            VYIELD_TO_MATURITY :=
                etp_func_DOCALC (o_TRANS_RATE,
                                 VCOUPON_RATE,
                                 100,
                                 YEARS,
                                 VFREQUENCE);
        ELSIF FLOOR (YEARS * VFREQUENCE) = 0
        THEN      --  before  last coupon  as excel yield function  10/12/2019
            -- E   (NEXT_COUPON_PAYMENT - LAST_COUPON_PAYMENT) VCouponInDays
            -- A       (o_SETTLEMENT_DATE - LAST_COUPON_PAYMENT)
            --DSR = VCouponInDays -  VSettlemnt_LastCoupon    = E-A

            PARTA := ((vRedemption / 100) + (VCOUPON_RATE / VFREQUENCE));
            PARTB :=
                  (o_TRANS_RATE / 100)
                + (  (VSettlemnt_LastCoupon / VCouponInDays)
                   * (VCOUPON_RATE / VFREQUENCE));
            PARTC :=
                  (VFREQUENCE * VCouponInDays)
                / (VCouponInDays - VSettlemnt_LastCoupon);
            VYIELD_TO_MATURITY := (((PARTA - PARTB) / PARTB) * PARTC) * 100;
        ELSIF o_TRANS_RATE > 100
        THEN
            YTM := VCOUPON_RATE;

            -- :GROSS_PRICE := (:TRANS_RATE * VPARVALUE / 100) + NVL(:ACCRUED_INTEREST,0);
            --:CLEAN_PRICE := :TRANS_RATE * VPARVALUE / 100;
            WHILE E > .1
            LOOP
                YTM := YTM - 0.001;
                VCOUPON_LEFT :=
                    FLOOR (
                          MONTHS_BETWEEN (VMATURITY_DATE, o_SETTLEMENT_DATE)
                        / 12
                        * VFREQUENCE);
                VRATE_PER_PERIOD := VCOUPON_RATE / VFREQUENCE;
                PartA := POWER ((1 / (1 + (YTM / VFREQUENCE))), VCOUPON_LEFT);
                PartB := 1 - PartA;
                PartC :=
                    vrate_per_period * (1 + (PARTB / (YTM / VFREQUENCE)));
                PartD :=
                    POWER (
                        (1 + (YTM / VFREQUENCE)),
                        (  (VNEXT_COUPON_PAYMENT - o_SETTLEMENT_DATE)
                         / (VNEXT_COUPON_PAYMENT - VLAST_COUPON_PAYMENT)));
                E :=
                      (  (o_TRANS_RATE * VPARVALUE / 100)
                       + NVL (VACCRUED_INTEREST, 0))
                    - ((PARTA + PARTC) / PARTD * VPARVALUE);
                VYIELD_TO_MATURITY := YTM * 100;
            END LOOP;

            E := 1;

            WHILE E > .00001
            LOOP
                YTM := YTM + 0.0000001;
                VCOUPON_LEFT :=
                    FLOOR (
                          MONTHS_BETWEEN (VMATURITY_DATE, o_SETTLEMENT_DATE)
                        / 12
                        * VFREQUENCE);
                VRATE_PER_PERIOD := VCOUPON_RATE / VFREQUENCE;
                PartA := POWER ((1 / (1 + (YTM / VFREQUENCE))), VCOUPON_LEFT);
                PartB := 1 - PartA;
                PartC :=
                    vrate_per_period * (1 + (PARTB / (YTM / VFREQUENCE)));
                PartD :=
                    POWER (
                        (1 + (YTM / VFREQUENCE)),
                        (  (VNEXT_COUPON_PAYMENT - o_SETTLEMENT_DATE)
                         / (VNEXT_COUPON_PAYMENT - VLAST_COUPON_PAYMENT)));
                E :=
                      ((PARTA + PARTC) / PARTD * VPARVALUE)
                    - (  (o_TRANS_RATE * VPARVALUE / 100)
                       + NVL (VACCRUED_INTEREST, 0));
                VYIELD_TO_MATURITY := YTM * 100;
            END LOOP;

            VYIELD_TO_MATURITY := YTM * 100;
        --
        ELSE
            YTM := VCOUPON_RATE;

            WHILE E > .01
            LOOP
                YTM := YTM + 0.001;
                VCOUPON_LEFT :=
                    FLOOR (
                          MONTHS_BETWEEN (VMATURITY_DATE, o_SETTLEMENT_DATE)
                        / 12
                        * VFREQUENCE);
                VRATE_PER_PERIOD := VCOUPON_RATE / VFREQUENCE;
                PartA := POWER ((1 / (1 + (YTM / VFREQUENCE))), VCOUPON_LEFT);
                PartB := 1 - PartA;
                PartC :=
                    vrate_per_period * (1 + (PARTB / (YTM / VFREQUENCE)));
                PartD :=
                    POWER (
                        (1 + (YTM / VFREQUENCE)),
                        (  (VNEXT_COUPON_PAYMENT - o_SETTLEMENT_DATE)
                         / (VNEXT_COUPON_PAYMENT - VLAST_COUPON_PAYMENT)));
                E :=
                      ((PARTA + PARTC) / PARTD * VPARVALUE)
                    - (  (o_TRANS_RATE * VPARVALUE / 100)
                       + NVL (VACCRUED_INTEREST, 0));
                vYIELD_TO_MATURITY := YTM * 100;
            END LOOP;

            E := 1;

            WHILE E > .00001
            LOOP
                YTM := YTM - 0.0000001;
                VCOUPON_LEFT :=
                    FLOOR (
                          MONTHS_BETWEEN (VMATURITY_DATE, o_SETTLEMENT_DATE)
                        / 12
                        * VFREQUENCE);
                VRATE_PER_PERIOD := VCOUPON_RATE / VFREQUENCE;
                PartA := POWER ((1 / (1 + (YTM / VFREQUENCE))), VCOUPON_LEFT);
                PartB := 1 - PartA;
                PartC :=
                    vrate_per_period * (1 + (PARTB / (YTM / VFREQUENCE)));
                PartD :=
                    POWER (
                        (1 + (YTM / VFREQUENCE)),
                        (  (VNEXT_COUPON_PAYMENT - o_SETTLEMENT_DATE)
                         / (VNEXT_COUPON_PAYMENT - VLAST_COUPON_PAYMENT)));
                E :=
                      (  (o_TRANS_RATE * VPARVALUE / 100)
                       + NVL (VACCRUED_INTEREST, 0))
                    - ((PARTA + PARTC) / PARTD * VPARVALUE);
                VYIELD_TO_MATURITY := YTM * 100;
            END LOOP;

            IF VCOUPON_RATE = 0
            THEN                                            -- for zero coupon
                VYIELD_TO_MATURITY := 0;
            END IF;
        --

        --
        END IF;
    END IF;

    vYTM := VYIELD_TO_MATURITY;
    RETURN vYTM;
END;
/

