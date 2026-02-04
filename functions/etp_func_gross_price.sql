create FUNCTION etp_func_gross_price (o_ISIN CHAR,o_TRANS_RATE number,o_SETTLEMENT_DATE date)
    RETURN NUMBER   AS
    
    
       vgross_price  number;
    
    
    begin  
    
 
      vgross_price := etp_func_ACCRUED_INTEREST(o_isin,o_SETTLEMENT_DATE)   +etp_func_clean_price(o_isin,o_TRANS_RATE);
      
        return vgross_price;
       
        
     end;
/

