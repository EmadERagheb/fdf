create PROCEDURE     etp_check_all_status (
    VTRADER_SERIAL_ID    IN     NUMBER,
    VFIRM_SERIAL_ID      IN     NUMBER,
    vMARKET_CODE        IN     NUMBER,
    VSEC_SERIAL_ID       IN     NUMBER,
    VMM                  IN     NUMBER,
    RVALDESC                OUT varchar,
    RVAL                    OUT NUMBER,
    IERRORCODE_OUT          OUT NUMBER)

is

temp_FIRM_STATUS_ID  number; 
temp_ISTR number;
temp_ISRFQ number;
temp_ISORDER number;
temp_ISMM number;
temp_MARKET_SECURITIES_status number; 
temp_ETP_FIRMS_SECURITIES_stat number;
temp_BOND_STATUS number;
TEMP_TRADER_STATUS number;

begin 
        RVAL := 1;
        IERRORCODE_OUT := 0;
        select FIRM_STATUS_ID,decode(ISTR,1,2,0), decode(ISRFQ,1,1,0), decode(ISORDER,1,3,0) , ISMM
        into temp_FIRM_STATUS_ID, temp_ISTR, temp_ISRFQ, temp_ISORDER, temp_ISMM
        from etp_firm  where FIRM_SERIAL_ID=VFIRM_SERIAL_ID;
 
    -------------***************************************** 
        IF temp_FIRM_STATUS_ID !=0
        THEN
            RVAL := 0;
            RVALDESC :='Firm Is Suspended/Delisted';                             
            RETURN;
        END IF;
 
        if  VMM=0 and vMARKET_CODE <> (case when vMARKET_CODE=1 then temp_ISRFQ  else case when  vMARKET_CODE=2 then temp_ISTR   else case when  vMARKET_CODE=3 then temp_ISORDER  end end   end) 
         then
            RVAL := 0;
            RVALDESC :='Firm Is Suspended in this Market';                             
            RETURN;
         
         end if; 
 
        
        if  VMM=1 and VMM <> temp_ISMM then 
            RVAL := 0;
            RVALDESC :='Firm Is Suspended as Market Maker';                             
            RETURN;
        
        end if;
        
 
 
    select STATUS into temp_MARKET_SECURITIES_status 
    from  ETP_MARKET_SECURITIES
    where SEC_SERIAL_ID = VSEC_SERIAL_ID 
    and MARKET_CODE= vMARKET_CODE;
   -------------***************************************** 
     IF temp_MARKET_SECURITIES_status !=0
        THEN
            RVAL := 0;
            RVALDESC :='ISIN is Suspended/Delisted in this Market';                             
            RETURN;
        END IF;
    
 
 
 select  A.STATUS into temp_ETP_FIRMS_SECURITIES_stat
  from ETP_FIRMS_SECURITIES  a , ETP_MARKET_SECURITIES b
 where A.UNQ_ID=B.UNQ_ID
 and A.FIRM_SERIAL_ID =VFIRM_SERIAL_ID
 and B.SEC_SERIAL_ID=VSEC_SERIAL_ID
 and  B.MARKET_CODE=vMARKET_CODE;
    -------------***************************************** 
      IF temp_ETP_FIRMS_SECURITIES_stat != 0
        THEN
            RVAL := 0;
            RVALDESC :='ISIN is Suspended/Delisted in this Market with Firm';                             
            RETURN;
        END IF;
    
 

select BOND_STATUS into temp_BOND_STATUS
 from ETP_SECURITIES
 where SEC_SERIAL_ID=VSEC_SERIAL_ID;
 
 
       IF temp_BOND_STATUS = 1
        THEN
            RVAL := 0;
            RVALDESC :='ISIN is Suspended ';                             
            RETURN;
        END IF;


 
    if VTRADER_SERIAL_ID is not null then
      SELECT TRADER_STATUS
          INTO TEMP_TRADER_STATUS
          FROM ETP_TRADER
         WHERE TRADER_SERIAL_ID = VTRADER_SERIAL_ID;


    -------------***************************************** 
       IF TEMP_TRADER_STATUS != 0
        THEN
            RVAL := 0;
            RVALDESC :='Trader is Not Active ';                             
            RETURN;
        END IF;
   end if;


end;
/

