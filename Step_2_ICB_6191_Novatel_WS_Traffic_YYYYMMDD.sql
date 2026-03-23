  
                                                                                  
CREATE   PROCEDURE [dbo].[ICB_6191_Novatel_WS_Traffic_YYYYMMDD]                                                                                                                        
@date varchar(8) =''                                                                                                                        
as                                                                                                                       
                                                                                                                      
                                                                                                                                                                                                         
begin                                                                                                                                                                                                          
                                                                                              
                                                                                                                                                                                                        
declare @sql   varchar(8000)                                                                                                                                                                                                       
declare @dt    varchar(10)                                                                                                                                                                                                
declare @yyyy   varchar(4)                                                                                                        
declare @yyyy_1   varchar(4)                                                                                                                                                                                            
declare @mm    varchar(2)                                                                                                                                                                                              
declare @dd    varchar(2)                                                                                                       
declare @mm_1 varchar(2)                                                                                                                              
--declare @date    varchar(10)                                                                                                                          
                                                                                                                                                                                              
                                                                                                                           
 --select convert(varchar(8),getdate()-3,112)                                                                                                                       
                                                                                                                                                                        
 if isnull(@date,'')=''                                                                                                                                                                                                                           
 set @date=convert(varchar(8),getdate()-1,112)                                                                                                                                                             
                               
       
set @dd=right(ltrim(rtrim(@date)),2)                                      
                        
set @YYYY=LEFT(@date,4)                                           
set @mm=substring(@date,5,2)                                                                        
                                 
If substring(@date,5,2) ='01'                                                                         
begin                                                                                      
set @YYYY_1=LEFT(@date,4)-1                                                     
set @MM_1='12'                                                                   
end                                                               
else                                                          
If substring(@date,5,2) <> '01'                                                                         
begin                                                            
set @YYYY_1=LEFT(@date,4)                                                               
set @MM_1=right((substring(@date,5,2)-1)+100,2)                                                                                    
end                                                         
                                                                                                      
set @dt=@yyyy+'-'+@mm+'-'+@dd                                                                                                                     
                                                                            
print 'IBOS Uploading Date_' +@date                                                                                    
                                                                                                                      
                                                                                                           
set @sql='                                                                                
                                                                                                                      
truncate table ICB_6191_WS_N_IBOS_Temp                                                                                                            
                                                                                                        
insert into ICB_6191_WS_N_IBOS_Temp                                                                                                                      
select A_Number,B_Number,MDL_Dial_Code,MDL_Destination,C_Number,convert(datetime,[date],120)Call_date,Duration,                                                                                              
Customer_rounded_duration,Supplier_rounded_duration,                                                                                                                      
Customer,Supplier,Revenue_EUR,Expense_EUR                                                                                                       
----into ICB_6191_WS_N_IBOS_Temp                                                                                                                      
from    (                                                  
select * from icb_reports_novatel.dbo.ICB_6289_Novatel_temp A(nolock)                                                                                                                                            
----select *  from ESP_RRBS.NOVATEL_'+@yyyy+@mm+'.dbo.NOVATEL_'+@yyyy+''+@mm+' a (nolock)                                                                                                      
----union all                                                                                                      
----select *  from Novatel.dbo.NOVATEL_RATED_'+@yyyy_1+''+@mm_1+' (nolock)                                                                                                        
   )A                                                        
where convert(varchar(10),(CONVERT(datetime,[DATE],120)),120)='''+@dt+'''                             
and filename  not like ''%rerated%''                                                                                         
and Supplier_rounded_duration  > ''0.0''     --and  Incoming_trunk   in (''30101'',''12004'',''22082'')                                                       
---and customer in (''ws_119'',''ws_quat'')                                                                                           
order by date                                                       
                                                                                                   
'                                                                                       
                                      
EXEC (@SQL)                                 
                                                                                                                      
set @sql='                                                                                 
delete from ICB_6191_WS_N_IBOS_Final                                                                                                                      
where yyyy='''+@yyyy+''' and mm='''+@mm+'''  and dd='''+@dd+'''                                                                                                                       
 insert into ICB_6191_WS_N_IBOS_Final                                                                                                                      
select Call_date,YEAR(Call_date)YYYY,right(((MONTH(Call_date))+100),2)MM,right(((DAY(Call_date))+100),2)DD,                                                                              
right(((DATEPART(HOUR,call_date))+100),2)HH,                                                                                   
right(((DATEPART(MINUTE,call_date))+100),2)MI,                                                                                       
right(((DATEPART(SECOND,call_date))+100),2)SS,                                                                                              
''WS_N_''+(select top 1 shortname                                                    
from ICB_6289_wholesalemaster    b                                                                                                                         
where a.customer=b.ws_id order by ws_ID )WS_Carrier,                                                                                  
MDL_destination Dest_code,supplier Trunkout,((cast(expense as float))/(Cast(Supplier_rounded_duration as float)/60.))BuyPrice,                                                                                                                      
((cast(Revenue as float))/(Cast(Supplier_rounded_duration as float)/60.))Sell_price,(cast(Supplier_rounded_duration as float)/60.)Dura,                                                                                                                      
((cast(revenue as float)))Ws_cost,                                                                                                                      
((cast(expense as float)))Term_Cost,                                                             
((cast(expense as float)))bLCR_Cost                                                                                                                     
--into ICB_6191_WS_N_IBOS_Final                                                                                                      
from ICB_6191_WS_N_IBOS_Temp a (nolock)                                                                                                                      
'                                                                                                                      
EXEC (@SQL)   
                                                                     
set @sql='                                                                                                                      
                           
delete from  IBOSS_148.carrier.dbo.wholesaletrans    --wholesaletrans                                                                 
where carr_id like ''WS_N_%''                                                                                                    
and yyyy='''+@yyyy+''' and mm='''+@mm+'''  and dd='''+@dd+'''                     
                                                  
'                                                                                                                      
EXEC (@SQL)                                                                  
                                                                     
set @sql='                                                  
                                                                                      
insert into  [IBOSS_148].carrier.dbo.wholesaletrans                                                                                                                     
select yyyy,mm,dd,ws_Carrier,dest_code,trunkout,buyprice,                                                                          
sum(cast(dura as float))dura,sum(ws_Cost)ws_Cost,sum(term_cost)term_cost,sum(blcr_cost)blcr_cost                                       
from ICB_6191_WS_N_IBOS_Final (nolock)                                                                                           
where yyyy='''+@yyyy+''' and mm='''+@mm+'''  and dd='''+@dd+'''                                                                                                                          
group by yyyy,mm,dd,ws_Carrier,dest_code,trunkout,buyprice                                                                                                                      
order by yyyy,mm,dd,ws_Carrier,dest_code,trunkout,buyprice                                                                        
                                                                                                                      
'                                                                             
EXEC (@SQL)                                                            
                                                           
                                                                                                                   
set @sql='                                                             
                                                                                                       
delete  Other_Margin                                                                                               
where Sitecode=''W.Sale_NOVA''                                                                                              
and   left(dd,4)='''+@yyyy+'''                                                                                                                      
and substring(dd,5,2)='''+@mm+'''                                                                                                                       
and right(dd,2) = '''+@dd+'''                                                       
                                                                                                                                                                                            
                                                                                                                                                         
Print ''Duplicate data removed from Tariff_Op_'+@date+'''                                                                                                                      
       
----------------- Sumary update to da server -----------------------                                                             
                    
insert into Other_Margin                                                                                                                                                                
select                                                                     
 ''W.Sale_NOVA'' Sitecode                                                                                                                              
 ,(cast(yyyy as varchar(4)) + right(cast( mm +100 as varchar(3)),2)+right(cast(dd+100 as varchar(3)),2)) dd                                                                                                           
 ,0.0 cnt                                  
 ,0.0 Adura                   
 ,sum(Dura) B_dura                                                                                                                                                                          
 ,0.0 tlkchg                                                                                       
 ,sum(income) income                                                                                                    
 ,0.0 A_cost                                                                                                               
 ,0.0 B_cost                                                                          
 ,sum(cost) lcr                                                                                                                                              
 ,(sum(income)-sum(cost)) margin                                                                     
from [IBOSS_148].carrier.dbo.wholesaletrans                                                                                                 
where yyyy= '''+@yyyy+''' and mm= '''+@mm+''' and dd='''+@dd+'''                                                                                          
and  carr_id like ''WS_N_%''                                                                                    
group by  (cast(yyyy as varchar(4)) + right(cast( mm +100 as varchar(3)),2)+right(cast(dd+100 as varchar(3)),2))                                                                                                                       
                                                                                                                      
Print ''Summary updated to the Tariff_Op_'+@date+'''                                                                                                                      
                                               
'                                                                                                                                                            
                                                                           
EXEC (@SQL)                                                                                                                       
                                                                                                   
end   