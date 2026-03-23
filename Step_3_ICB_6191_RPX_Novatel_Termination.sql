  
                           
----EXEC [ICB_6191_RPX_Novatel_Termination]   '2023','10','09'                            
                            
CREATE PROCEDURE [dbo].[ICB_6191_RPX_Novatel_Termination]                                                                          
                                                    
@yyyy varchar(4),                                                                                                                        
@mm  varchar(2),                                                                                                                        
@dd varchar(2)                                                                                                                
                                                                                                                  
as                                                                                                                      
begin                                                                                                                      
                                                                                                                      
                                                                                                                
declare @rpxfile varchar(50)                                                                                                                       
declare @sql varchar(8000)                                                                                                                       
declare @DATE varchar (10)                                       
declare @mm_1 varchar(2)                                     
declare @yyyy_1 varchar(10)                                                                                                                     
                                                                      
------declare @yyyy varchar(10)                                                            
------declare @mm varchar(10)                                                       
------declare @dd varchar(10)                                                       
                                                                                                       
                                                                            
set @dd =isnull(@dd,right(convert(varchar(8),GETDATE()-1,112 ),2))                                                                                                 
set @mm =isnull(@mm,substring(convert(varchar(8),GETDATE()-1,112 ),5,2))                                                          
set @YYyy=isnull(@yyyy,substring(convert(varchar(8),GETDATE()-1,112 ),1,4)  )                                       
------set @mm_1 =right(((isnull(@mm,substring(convert(varchar(8),GETDATE()-1,112 ),5,2)))-1)+100,2)                                                        
 set  @mm_1 =(case when @mm='01'  then  '12'                                       
 else                                      
  right(((isnull(@mm,substring(convert(varchar(8),GETDATE()-1,112 ),5,2)))-1)+100,2)                                      
  end )                                       
set @yyyy_1=(case when @mm='01' then (@yyyy -1)                                       
else                                      
isnull(@yyyy,substring(convert(varchar(8),GETDATE()-1,112 ),1,4))                                         
end)                                     
                                                    
Set @date=@yyyy+'-'+ @mm+'-'+@dd                                                    
                                                                                                                    
set @rpxfile = 'IBOSS_148.carrier.dbo.Rpx'+ right(ltrim(rtrim(@mm)),2)+ltrim(rtrim(@yyyy))                                                                                                                    
       
print 'RPX Data for Date - '+@DATE                                                    
                                                   
set @sql='                                              
                                 
----truncate table  icb_6191_routing_prefix                                                             
                                                    
----insert into icb_6191_routing_prefix                                                                              
----select * from routing_prefix                                                    
                                                    
                                             
'                                                                                        
                            
                                                                                          
exec (@SQL)                                                           
                              
                                                                                                                      
SET @SQL=                                                                                                              
'                                                  
delete from '+@rpxfile+'                                                     
where callyy='+@yyyy+'                                  
and callmm='+@mm+'                                                     
and calldd= '+@dd+'                                                     
and producttype=''NOVA_Term''                                                                                                                 
                                                                                           
truncate table ICB_6191_NOVA_Term_RPX_TEMP                                                          
                                                                      
insert into ICB_6191_NOVA_Term_RPX_TEMP                                                                          
select   ''Nova'' SITECODE,                                                                                                                      
(select top 1 destcode from icb_6289_routing_prefix (nolock)  where B.Prefix like PREFIXCODE+''%''                                                                                                   
order by prefixlen desc) as tariffzone,                                                                                                                 
Prefix ,OPERATOROUT,COUNT(*)Calls   ,                                                                                                                      
SUM(CAST(Supplier_rounded_duration AS FLOAT)/60.) AS DURA,                                                                                                 
avg(cast(isnull(BCost,0.0) as float))bcost,sum(cast(COST as float))Cost,''0.0'' Income,''0.0'' margin,                                                                                                                      
datepart( yyyy, Actual_Call_date) YYYY,right((cast((datepart(mm, Actual_Call_date)) as float)+100),2) MM ,                                                    
right((cast((datepart(dd, Actual_Call_date)) as float)+100),2) DD,                                                                                    
''NOVA_TERM'' producttype,count(*)cnt,setupCharge                                                      
from                                                       
(                                                                                                                    
select  RAting_status,A_number,B_number,MDL_Dial_code Prefix,MDL_Destination DestCode,Date,Supplier_rounded_duration,Customer legaDev,Supplier Operatorout                                                    
,((cast(expense as float))/(((cast(Supplier_rounded_duration as float))/60.)))BCost,Revenue_EUR,Expense_EUR Cost,Actual_Call_date,                                                   
datepart( yyyy, Actual_Call_date) YYYY,right((cast((datepart(mm, Actual_Call_date)) as float)+100),2) MM ,  filename,customer,                                                  
datepart(dd,Actual_Call_date) DD,''0.0'' setupCharge,Incoming_trunk                                                   
from  (               
select * from icb_reports_novatel.dbo.ICB_6289_Novatel_temp A(nolock)                                            
------select *  from ESP_RRBS.NOVATEL_'+@yyyy+@mm+'.dbo.NOVATEL_'+@yyyy+''+@mm+' a(nolock)                                      
----union all              
----select *  from Novatel.dbo.NOVATEL_RATED_'+@yyyy_1+''+@mm_1+' (nolock)                                       
   )A                                                    
where convert(varchar(10),Actual_call_date,120)='''+@DATE+'''                                                    
and Supplier_rounded_duration > ''0.0''                                                    
and   filename  not like ''%rerated%''                   
) B                                                    
WHERE convert( varchar(10),Actual_call_date, 120) ='''+@Date+'''                                                     
and Supplier_rounded_duration > ''0.0''     and    filename  not like ''%rerated%''                                                                                                               
----and   Incoming_trunk  in (''30101'',''12004'',''22082'')                                           
---and customer in (''ws_119'',''ws_quat'')                                                
group by Prefix ,OPERATOROUT,datepart( yyyy, Actual_Call_date),right((cast((datepart(mm, Actual_Call_date)) as float)+100),2)  ,                                                    
right((cast((datepart(dd, Actual_Call_date)) as float)+100),2),setupCharge                                      
                                                                                                                       
'                                                                   
exec (@SQL)                                                                           
                                                                          
--exec (@SQL)                                        
                    
                                                  
                                                                                                              
set @sql='                                     
insert into '+@rpxfile+'                                                                            
(SITECODE,TARIFFZONE,ROUTEPFX,OPERATOROUT,DURA,BCOST,COST,INCOME,MARGIN,CALLYY,CALLMM,CALLDD,producttype,Calls,SetupCharge,actual_cost,country)                                                                                                           
select SITECODE,TARIFFZONE,Prefix,OPERATOROUT,DURA,                                                                          
BCOST,(COST+(Calls*(cast(setupCharge as float)))),                                                    
INCOME,MARGIN,YYYY,MM,DD,producttype,Calls,setupCharge,cost , ''Nova'' as country                                                    
from ICB_6191_NOVA_Term_RPX_TEMP (nolock)                                                                                                            
'                                                                                                              
exec (@SQL)                                                                                                               
                                                                            
--update a                                                                                                              
--set a.tariffzone=c.destcode                                                                                                              
--from RPX_TEMP_2 a(nolock),TZ_trunk_mapping b(nolock),TZ_Prefix_mapping c(nolock)                                                                                                              
--where a.routepfx=c.prefix                                                                                     
--and a.operatorout=b.trunkout                                                                           
--and b.operator=c.operator                                                                                     
                                                                    
                     
print 'NOVATEL Termination RPX TRAFFIC INCLUDED'                                                                                                                      
                                    
END   