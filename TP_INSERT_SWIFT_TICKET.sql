create PROCEDURE     ETP_INSERT_SWIFT_TICKET (  -- NEED UPDATE ( REPO TYPE WITH TAX)
    pTicket_Number    NUMBER)
AS
o_repo_type varchar2(10);

BEGIN
    
    begin
    select  repo_type into o_repo_type
    from  ETP_TRADE_REPORT
    where TRANS_CODE=pTicket_Number;
    exception 
    when no_data_found then
    null;
    end ;
    
    if   SUBSTR(nvl(o_repo_type,''),1,3) ='FOP' and nvl(SUBSTR(nvl(o_repo_type,''),5,3),'NO') <> 'TAX'  then
    
    INSERT INTO etp_swift_track (Ticket_Number,
                                 M_540_BUY_SEND,
                                 M_542_SELL_SEND)
    VALUES (pTicket_Number, 'N', 'N');
   
    
    else
       
    INSERT INTO etp_swift_track (Ticket_Number,
                                 M_541_BUY_SEND,
                                 M_543_SELL_SEND)
         VALUES (pTicket_Number, 'N', 'N');
         
    end if;     

    COMMIT;
END;
/

