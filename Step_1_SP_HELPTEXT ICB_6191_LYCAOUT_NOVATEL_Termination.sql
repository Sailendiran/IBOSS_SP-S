    
          
          
          
          
          
          
--SP_HELPTEXT ICB_6191_LYCAOUT_NOVATEL_Termination            
            
            
            
                                
                             
CREATE  PROCEDURE [dbo].[ICB_6191_LYCAOUT_NOVATEL_Termination]                                                                                                                      
-- PRINT ICB_6191_LYCAOUT_NOVATEL_Termination '2016','02','26'                                                                                                                      
@yyyy varchar(4)='',                                                                                                                          
@mm  varchar(2)='',                                                                                                                          
@dd varchar(2) =''                                                                                                                         
                                
as                                                                                                                        
begin                                                                                                                          
                                
set QUOTED_IDENTIFIER OFF                                                                                                                          
                                
                                
declare @sql varchar(4000)                                                                                                                          
declare @lycafile varchar(100)                                                                                                                          
declare @lycafile1 varchar(100)                                                                                   
declare @FNGN_xcds varchar(50)                                                                                                                         
declare @FNGN_xcdX varchar(50)                                                                                     
declare @date varchar(10)                                                            
declare @mm_1 varchar(2)                                                    
declare @yyyy_1 varchar(10)                                                         
                                
                                
--declare @mm varchar(2)                                                                                  
--declare @yyyy varchar(4)                                                                                  
--declare @dd varchar(2)                                                                                  
--set @yyyy='2025'                                                                                  
--set @mm='07'                                                                                  
--set @dd='26'                                                                                  
                                
set @dd =isnull(@dd,right(convert(varchar(8),GETDATE()-1,112 ),2))                                                                                                                         
set @mm =isnull(@mm,substring(convert(varchar(8),GETDATE()-1,112 ),5,2))                                                                                  
set @YYyy=isnull(@yyyy,substring(convert(varchar(8),GETDATE()-1,112 ),1,4)  )                                                                                 
--------set @mm_1 =right(((isnull(@mm,substring(convert(varchar(8),GETDATE()-1,112 ),5,2)))-1)+100,2)                                                    
set  @mm_1 =(case when @mm='01'  then  '12'                                                     
else                                                    
right(((isnull(@mm,substring(convert(varchar(8),GETDATE()-1,112 ),5,2)))-1)+100,2)     
end )                                                     
set @yyyy_1=(case when @mm='01' then (@yyyy -1)                                                     
else           
isnull(@yyyy,substring(convert(varchar(8),GETDATE()-1,112 ),1,4))                       
end)                                                    
                                
                                
Set @date=@yyyy+'-'+ @mm+'-'+@dd                                                                            
                                
Print 'Data Date_'+@date                      
          
declare @datesum varchar(10)          
declare @datewin varchar(10)          
declare @timediff varchar(50)          
          
Set @datesum = DATEADD(DAY, -(DATEPART(WEEKDAY,DATEFROMPARTS(@yyyy,3,31)) % 7)+1, DATEFROMPARTS(@yyyy,3,31))          
          
set @datewin = DATEADD(DAY, -(DATEPART(WEEKDAY,DATEFROMPARTS(@yyyy,10,31)) % 7)+1, DATEFROMPARTS(@yyyy,10,31))          
          
                                
set @lycafile ='IBOSS_148.carrier.dbo.lycaout'+ right(100+ltrim(rtrim(@mm)),2)+@yyyy                                                 
set @lycafile1 ='IBOSS_148.carrier.dbo.lycaout'+ right(100+ltrim(rtrim(@mm)),2)+@yyyy+'_Timecls'                                                         
   IF ( @date between @datesum and DATEADD(dd,-1,@datewin))          
begin           
set @timediff = 'timediff_summer_mins'          
end          
else           
begin          
set @timediff = 'timediff_winter_mins'          
end          
                             
                                
----------------------------------------------------------------------------------------------------------------------                                                                              
                                
set @sql='                                                                       
                                
delete from '+@lycafile+' where callyy='+@yyyy+' and callmm='+@mm+' and calldd='+@dd+'                                                                                                  
and DataType = ''NOVA_Term''                                                            
                                
delete from '+@lycafile1+' where callyy_act='+@yyyy+' and callmm_act='+@mm+' and calldd_act='+@dd+'                                                 
and DataType = ''NOVA_Term''                                                                                       
                                
truncate table ICB_6191_Lycaout_Temp_Novatel                                                                                       
truncate table ICB_6191_Lycaout_Temp_Novatel_timeclass                                                                                     
'                                                                                          
EXEC (@sql)                                                                                  
                                                                      
                      
                                 
set @sql='                                                               
                                
insert into ICB_6191_Lycaout_Temp_Novatel                                                                                            
select convert(varchar(10),Actual_call_date,120)Actual_Call_Date,YEAR(Actual_call_date)YYYY,                                                        
right(((MONTH(Actual_call_date))+100),2)MM,right(((DAY(Actual_call_date))+100),2)DD,                                                                            
Supplier OperatorOut,Sum(Cast(Supplier_rounded_duration as float)/60.) Dura,sum(Cast(Expense_EUR as float)) Cost,''NOVA_Term'' DataType,''0.0'' bcost_lcr,                                                                            
count(*) Calls,''0.0'' SetupCost                             
from                                                         
(                        
select * from icb_reports_novatel.dbo.ICB_6289_Novatel_temp A(nolock)                     
                                
------select *  from ESP_RRBS.NOVATEL_'+@yyyy+@mm+'.dbo.NOVATEL_'+@yyyy+''+@mm+' A(nolock)                                                        
----union all                                     
----select *  from Novatel.dbo.NOVATEL_RATED_'+@yyyy_1+''+@mm_1+' (nolock)                
)A                                                           
where filename  not like ''%rerated%''                                                                   
and  Supplier_rounded_duration > ''0.0''                                                             
--- and   Incoming_trunk   in (''30101'',''12004'',''22082'')                                                               
--and customer in (''ws_119'',''ws_quat'')                                                                   
and convert(varchar(10),Actual_call_date,120)='''+@date+'''                                                                                                                        
group by convert(varchar(10),Actual_call_date,120),YEAR(Actual_call_date),right(((MONTH(Actual_call_date))+100),2)                                                                            
,right(((DAY(Actual_call_date))+100),2),Supplier                                                                   
                                
                                
'                                                             
                                
EXEC (@sql)                                                                                  
                 
                          
                               
                                
set @sql='                                                                                  
                                
insert into ICB_6191_Lycaout_Temp_Novatel_timeclass                                                                                    
select YEAR(Actual_Calldate_timecls)YYYY,right(((MONTH(Actual_Calldate_timecls))+100),2)MM,                             
right(((DAY(Actual_Calldate_timecls))+100),2)DD,OperatorOut,sum(cast(Dura as float)/60.) Dura,sum(cast(Cost as float)) Cost,                                                                            
DataType, bcost_lcr,count(*) Calls, SetupCost,'+@timediff+' ,YEAR(Actual_call_date)Act_YYYY,right(((MONTH(Actual_call_date))+100),2)Act_MM,                                                                            
right(((DAY(Actual_call_date))+100),2)Act_DD                              
From                                                                             
(                                                                            
select convert(varchar(10),Actual_call_date,120)Actual_Call_Date,YEAR(Actual_call_date)YYYY,right(((MONTH(Actual_call_date))+100),2)MM,                                                                            
right(((DAY(Actual_call_date))+100),2)DD,   Supplier OperatorOut,Supplier_rounded_duration Dura,Expense_EUR Cost, a.filename ,a.customer,                                                                          
''NOVA_Term'' DataType,''0.0'' bcost_lcr,''0.0'' SetupCost,b.'+@timediff+'                                                                              
,isnull((DATEADD(minute,((-1)*(isnull('+@timediff+',0))),Actual_call_date) ),Actual_call_date)Actual_Calldate_timecls,Incoming_trunk                                                                                  
from   (                         
select * from icb_reports_novatel.dbo.ICB_6289_Novatel_temp A(nolock)                 
where Expense_EUR not like ''%,%''                       
----select *  from ESP_RRBS.NOVATEL_'+@yyyy+@mm+'.dbo.NOVATEL_'+@yyyy+''+@mm+' A(nolock)                                                        
----union all                                                        
----select *  from NOVATEL_202310.dbo.NOVATEL_RATED_'+@yyyy_1+''+@mm_1+' (nolock)                                                        
)A                           
left outer join  ICB_Carrier_report.dbo.ICB_6418_carriers b                                                                                        
on  ltrim(rtrim(a.supplier))=ltrim(rtrim(b.systemname  ))                                                                            
) a                                                              
where convert(varchar(10),Actual_call_date,120)='''+@date+'''                    
and  dura > ''0.0''     and   a.filename  not like ''%rerated%''      ----and   Incoming_trunk   in (''30101'',''12004'',''22082'')                                                             
---and customer in (''ws_119'',''ws_quat'')                                                                         
group by    YEAR(Actual_Calldate_timecls),right(((MONTH(Actual_Calldate_timecls))+100),2) ,                                                       
right(((DAY(Actual_Calldate_timecls))+100),2),OperatorOut, SetupCost,'+@timediff+' ,YEAR(Actual_call_date),                                                                            
right(((MONTH(Actual_call_date))+100),2),                                                                            
right(((DAY(Actual_call_date))+100),2) ,DataType, bcost_lcr                                                                                                          
                                
                                
'                                                                                 
                                
                                
EXEC (@sql)                                                       
                                
set @sql='                                                                                          
                                
insert into '+@lycafile+'                                                 
select MM,DD,operatorout,dura,((Cost)+(calls*(CAST(SETUPCOST AS FLOAT)))),                                                                                          
datatype,YYYY,bcost_lcr,calls,SETUPCOST,cost                                           
from ICB_6191_Lycaout_Temp_Novatel (nolock)                                                                                          
                                
                                
insert into '+@lycafile1+'                                                  
select MM,DD,operatorout,dura,((Cost)+(calls*(CAST(SETUPCOST AS FLOAT)))),                                                                                          
datatype,YYYY,bcost_lcr,calls,SETUPCOST,cost,timediff ,Act_mm,Act_dd,Act_yyyy                                                  
from ICB_6191_Lycaout_Temp_Novatel_timeclass (nolock)                                                                                       
                                
'                                                                                          
                                
EXEC (@sql)                                                                              
                                
PRINT  'Novatel Termination Traffic Uploaded'                                                                                    
                                
end                                 
                                
                                
                                
                            
                                
                                
                               
                                
                                
                                
                                
                                
                                
                                
                                
                          