        
CREATE procedure [dbo].[ICB_8512_LycaOut_Carrier_TimeClass_LCR]             
@date varchar(10)=NULL        
as               
begin               
--declare @date varchar(10)               
--set @date  ='2025-04-22'        
declare @sql varchar(8000)                                                                                                
declare @lycafile varchar(100)                                                                                                
declare @lycafile1 varchar(100)                                                                                                      
declare @yyyy varchar (4)              
declare @mm varchar (2)              
declare @dd varchar (2)          
        
declare @datesum varchar(10)        
declare @datewin varchar(10)        
        
declare @timediff varchar(50)        
              
set @date = isnull(@date,convert(varchar(10),GETDATE()-1,120))              
              
set  @yyyy = SUBSTRING(@date,1,4)              
set @mm = SUBSTRING(@date,6,2)              
set @dd = SUBSTRING(@date,9,2)                    
              
set @lycafile ='IBOSS_148.carrier.dbo.lycaout'+ right(100+ltrim(rtrim(@mm)),2)+@yyyy                                                           
set @lycafile1 ='IBOSS_148.carrier.dbo.lycaout'+ right(100+ltrim(rtrim(@mm)),2)+@yyyy+'_Timecls'            
        
Set @datesum = DATEADD(DAY, -(DATEPART(WEEKDAY,DATEFROMPARTS(@yyyy,3,31)) % 7)+1, DATEFROMPARTS(@yyyy,3,31))        
        
set @datewin = DATEADD(DAY, -(DATEPART(WEEKDAY,DATEFROMPARTS(@yyyy,10,31)) % 7)+1, DATEFROMPARTS(@yyyy,10,31))        
        
        
        
IF ( @date between @datesum and DATEADD(dd,-1,@datewin))        
begin         
set @timediff = 'timediff_summer_mins'        
end        
else         
begin        
set @timediff = 'timediff_winter_mins'        
end        
        
        
        
        
              
set @sql='                                                          
                                                        
delete from '+@lycafile+' where callyy='+@yyyy+' and callmm='+@mm+' and calldd='+@dd+'                                                                                              
      and DataType = ''NGDS''                                                            
                                                              
      delete from '+@lycafile1+' where callyy_act='+@yyyy+' and callmm_act='+@mm+' and calldd_act='+@dd+'                                                                                              
      and DataType = ''NGDS''                                         
                                                                      
      truncate table ICB_8512_lycaout_temp                                                             
      truncate table icb_8512_Lycaout_temp_timeclass                                                           
'                         
EXEC (@sql)                
              
                                           
                                           
 set @sql='                                                                    
   insert into ICB_8512_lycaout_temp                                                                  
   (callyy,callmm,calldd,operatorout,dura,cost,datatype,bcost_lcr,calls,setupcharge )                               
   select yyyy,mm,dd,trunkout,sum(cast(RoundedUpCallTime as float )/60.) as dura,                                                                
  (sum(cast(RoundedUpCallTime as float)/60.*(cast(callcost as float)+status))) as cost,''NGDS'' DataType , ''0.0'' bcost_lcr ,count(*) ,setupcharge                                                         
    from ICB_REPORTS_UGC.dbo.ICB_8512_LCR_Temp_S a (nolock)                                                                                          
   where yyyy='+@yyyy+' and mm='+@mm+' and dd='+@dd+'   and  RoundedUpCallTime > 0                                                     
   and  callcost is not null                                                                          
   and  callcost> ''0.0''                                                       
   and trunkout<>''nomi_out''                                                               
   --and  cause <> 120                   
   and  connectflg=1                                                                                          
   group by yyyy,mm,dd,trunkout ,SetupCharge '                                                        
                                                                                 
EXEC (@sql)                
                                               
                                                         
set @sql='                                                        
                                                                          
   insert into icb_8512_Lycaout_temp_timeclass                                                                  
   (callyy,callmm,calldd,operatorout,dura,cost,datatype,bcost_lcr,calls,setupcharge,timediff,callmm_act,calldd_act,callyy_act )                            
   select datepart(yyyy,Calldate_timecls),datepart(mm,Calldate_timecls),                      
   datepart(dd,Calldate_timecls),trunkout,sum(cast(RoundedUpCallTime as float)/60.) as dura,                                                                
 (sum(cast(RoundedUpCallTime as float)/60.*(cast(callcost as float)+status))) as cost,''NGDS'' DataType , ''0.0'' bcost_lcr ,                                                        
   count(*) , setupcharge ,'+@timediff+',mm,dd,yyyy                                                        
   from                                                         
    (select a.yyyy,a.mm,a.dd,a.calldate,a.trunkin,a.trunkout,setupcharge, RoundedUpCallTime,                                 
 legAdev,talktime,prefixcode,destcode,callcost,status,b.'+@timediff+'                                                      
 ,isnull((DATEADD(minute,((-1)*(isnull('+@timediff+',0))),calldate) ),calldate)Calldate_timecls                                                         
 from ICB_REPORTS_UGC.dbo.ICB_8512_LCR_Temp_S a(nolock)                                                         
    left outer join  ICB_Carrier_report.dbo.ICB_6418_carriers b                                                              
   on  ltrim(rtrim(a.trunkout))=ltrim(rtrim(b.systemname))                                                        
   where a.connectflg=''1''                                                        
    ) a                                                                               
   where a.yyyy='+@yyyy+' and a.mm='+@mm+' and a.dd='+@dd+'                                                                                                
   and  a.RoundedUpCallTime > 0                                                                                               
   and  a.callcost is not null                                                                                               
   and  a.callcost> ''0.0''                     
   and a.trunkout<>''nomi_out''                                                          
   group by datepart(yyyy,Calldate_timecls),datepart(mm,Calldate_timecls), datepart(dd,Calldate_timecls),trunkout ,        
   SetupCharge  ,'+@timediff+',mm,dd,yyyy                       
'                                                                        
                                                                
EXEC (@sql)               
                                                             
set @sql='                                                     
                                                                
insert into '+@lycafile+'                                                                
select callmm,calldd,operatorout,dura,((cast(Cost as float))+(cast(calls as float)*cast(setupcharge as float))),                                                                
datatype,callyy,bcost_lcr,calls,setupcharge,cost                                                                
from ICB_8512_lycaout_temp (nolock)                                                                
                              
                                                                
insert into '+@lycafile1+'                
select callmm,calldd,operatorout,dura,((cast (Cost as float))+(cast(calls as float)*cast(setupcharge as float))),                                                                
datatype,callyy,bcost_lcr,calls,setupcharge,cost,timediff,callmm_act,calldd_act,callyy_act                                                               
from icb_8512_Lycaout_temp_timeclass (nolock)                                                             
                                                        
'                                                                
                                                                                          
EXEC (@sql)                  
                   
end 