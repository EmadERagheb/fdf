create table ETPORD.ETP_ORDER_STATUS
(
    ORDER_STATUS          VARCHAR2(3),
    ORDER_STATUS_DESC_ARB VARCHAR2(40),
    ORDER_STATUS_DESC_ENG VARCHAR2(40)
)
/

| ORDER\_STATUS | ORDER\_STATUS\_DESC\_ARB | ORDER\_STATUS\_DESC\_ENG |
| :--- | :--- | :--- |
| 772 | Queued - OPEN | Queued -OPEN |
| 775 | Changed | Changed |
| 776 | Canceled | Canceled |
| 779 | Filled - OPEN | Filled - OPEN |
| 786 | Complete Fill | Complete Fill |
| 789 | Suspended | Suspended |
| 790 | Resumed - OPEN | Resumed - OPEN |
CODE	DESC
772	Queued        
773	Reject AtLoad 
774	Global CXL    
775	Changed       
776	Canceled      
777	FOK           
778	Expired       
779	Filled        
780	Trade CXL     
782	Spot CXL      
783	Accepted      
784	Rej on Activate
785	Activated     
786	Complete Fill 
787	Family Changed
788	Price Adjusted
789	Suspended     
790	Resumed       
791	Global Suspend
792	Global Resume 
793	Rej on Resume 
794	CFO From      
795	CFO To        
796	Reinstated    
797	Move From     
798	Move To       
800	ErrorCorrection
804	Corp Act Susp
