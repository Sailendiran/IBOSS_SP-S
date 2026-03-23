  
            
            
            
            
CREATE procedure [dbo].[ICB_6289_NOVATEL_DUMP_new]                                    
as                               
                            
begin                            
                          
Declare @pastdate varchar(12)                            
Declare @currdate varchar(12)                            
Declare @pasttwoday varchar(12)                            
Declare @sql varchar(max)                       
Declare @pasttodayyy varchar(4)                 
Declare @pasttodaymm varchar(6)               
Declare @currdateyy varchar(4)              
Declare @currdatemm varchar(6)             
Declare @pastdateyy varchar(4)            
Declare @pastdatemm varchar(6)            
                
                          
set @pastdate=convert(varchar(8),getdate()-1,112)                             
set @currdate=convert(varchar(8),getdate(),112)                             
set @pasttwoday=convert(varchar(8),getdate()-2,112)                            
            
set @pasttodayyy=substring(@pasttwoday,1,4)            
set @pasttodaymm=substring(@pasttwoday,1,6)            
            
set @currdateyy=substring(@currdate,1,4)            
set @currdatemm=substring(@currdate,1,6)            
            
set @pastdateyy=substring(@pastdate,1,4)            
set @pastdatemm=substring(@pastdate,1,6)            
                    
set @sql='truncate table ICB_6289_Novatel_temp                
'                            
exec(@sql)                        
                           
                    
--print(@sql)          
    
                            
set @sql='                              
insert into ICB_6289_Novatel_temp     
select * from                          
(                            
select Rating_status,A_Number,B_Number,MDL_Dial_Code,MDL_Destination,C_Number,Date,Duration,Customer_rounded_duration,Supplier_rounded_duration,Switch,  
Incoming_trunk,Outgoing_trunk,Completion_flag,Completion_description,Unanswered_time,Customer,Supplier,Revenue,Expense,Expense_per_minute,Revenue_EUR,  
Expense_EUR,Expense_per_minute_EUR,null as Customer_Dial_Code, null as Customer_Rounding_Rule,null as Supplier_Dial_Code,null as Supplier_Rounding_Rule,Actual_call_date,filename,created_date   
from NOVATEL_'+@pasttodaymm+'.dbo.NOVATEL_'+@pasttwoday+'(nolock)                         
union all                          
select Rating_status,A_Number,B_Number,MDL_Dial_Code,MDL_Destination,C_Number,Date,Duration,Customer_rounded_duration,Supplier_rounded_duration,Switch,  
Incoming_trunk,Outgoing_trunk,Completion_flag,Completion_description,Unanswered_time,Customer,Supplier,Revenue,Expense,Expense_per_minute,Revenue_EUR,  
Expense_EUR,Expense_per_minute_EUR,Customer_Dial_Code,Customer_Rounding_Rule,Supplier_Dial_Code,Supplier_Rounding_Rule,Actual_call_date,filename,created_date   
from NOVATEL_'+@pastdatemm+'.dbo.NOVATEL_'+@pastdate+'(nolock)                         
union all                            
select Rating_status,A_Number,B_Number,MDL_Dial_Code,MDL_Destination,C_Number,Date,Duration,Customer_rounded_duration,Supplier_rounded_duration,Switch,  
Incoming_trunk,Outgoing_trunk,Completion_flag,Completion_description,Unanswered_time,Customer,Supplier,Revenue,Expense,Expense_per_minute,Revenue_EUR,  
Expense_EUR,Expense_per_minute_EUR,Customer_Dial_Code,Customer_Rounding_Rule,Supplier_Dial_Code,Supplier_Rounding_Rule,Actual_call_date,filename,created_date   
from NOVATEL_'+@currdatemm+'.dbo.NOVATEL_'+@currdate+'(nolock)                         
)aa    
WHERE Revenue_EUR NOT  like ''%[a-z]%''    
AND  Expense_EUR NOT like ''%[a-z]%'' AND  cast(duration  as float)>0  
'                            
                    
exec (@sql)                  
                
                    
end                