create FUNCTION etp_func_bill_price (
    P_yield              NUMBER,
    P_Days_to_Maturity   NUMBER,
    p_DayCount           NUMBER DEFAULT 365)
    RETURN NUMBER
AS
BEGIN
    --return round(1/(( (P_yield/100)*P_Days_to_Maturity/365)+1),5);
    RETURN ROUND (
               1 / (((P_yield / 100) * P_Days_to_Maturity / p_DayCount) + 1),
               5);
END;
/

