create FUNCTION etp_func_clean_price (o_ISIN CHAR,o_TRANS_RATE number) 
    RETURN NUMBER   AS
    
      VCOUPON_RATE                  NUMBER;
      VPARVALUE                     NUMBER;
      VYEARS                        NUMBER;
      FREQUENCY                     NUMBER;
      VLAST_COUPON_PAYMENT    DATE;
      VNEXT_COUPON_PAYMENT    DATE;
      VCouponInDays            NUMBER;
      VIsSpecialIsin    NUMBER ;
      VMATURITY_DATE                DATE;
       VYearInDays            NUMBER;
     VPERIOD                       NUMBER;
       VACCRUED_INTEREST       NUMBER;
       vCLEAN_PRICE  number;
    
    
    begin  
    
        SELECT      PARVALUE, COUPON_INTER_RATE/100, NUMBER_OF_COUPONS, LAST_COUPON_PAYMENT,
                  NEXT_COUPON_PAYMENT, MATURITY_DATE,
          --  to_number (DECODE(TO_CHAR(TO_DATE('31/12'|| to_char(o_SETTLEMENT_DATE, 'YYYY') ,'DD/MM/YYYY'),'DDD'), '366','366', '365'))
             NVL(bond_type,0)
        INTO      VPARVALUE, VCOUPON_RATE, FREQUENCY, VLAST_COUPON_PAYMENT,
                  VNEXT_COUPON_PAYMENT, VMATURITY_DATE,
            --VYearInDays ,
            VIsSpecialIsin
        FROM      ETP_SECURITIES
       WHERE      SEC_ISIN_CODE = o_ISIN;
       
       
        vCLEAN_PRICE := o_TRANS_RATE * VPARVALUE / 100;    
       
        return vCLEAN_PRICE;
       
        
     end;
/

