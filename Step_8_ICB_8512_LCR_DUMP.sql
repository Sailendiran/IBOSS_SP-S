  
  
                     
CREATE procedure [dbo].[ICB_8512_LCR_DUMP]                                                 
as                                               
begin                                                                                  
Declare @pastdate varchar(12)                                            
Declare @currdate varchar(12)                                            
Declare @pasttwoday varchar(12)                                            
Declare @sql varchar(max)                                       
Declare @pasttodayyy varchar(4)                                 
Declare @pasttodaymm varchar(2)                               
Declare @currdateyy varchar(4)                              
Declare @currdatemm varchar(2)                             
Declare @pastdateyy varchar(4)                            
Declare @pastdatemm varchar(2)                
Declare @pastdatedd  varchar(2)                  
Declare @pastdate1 Varchar (10)                       
set @pastdate1 = convert(varchar(10),getdate()-1,120)                                     
set @pastdate=convert(varchar(8),getdate()-1,112)                                             
set @currdate=convert(varchar(8),getdate(),112)                                             
set @pasttwoday=convert(varchar(8),getdate()-2,112)                                            
set @pasttodayyy=substring(@pasttwoday,1,4)                            
set @pasttodaymm=substring(@pasttwoday,5,2)                   
set @currdateyy=substring(@currdate,1,4)                            
set @currdatemm=substring(@currdate,5,2)                                         
set @pastdateyy=substring(@pastdate,1,4)                            
set @pastdatemm=substring(@pastdate,5,2)                
set @pastdatedd=substring(@pastdate,7,2)     
  
set @sql=  
'truncate table ICB_8512_LCR_Temp_S'    
  
EXEC(@sql)  
print (@sql)           
  
set @sql=  
'truncate table ICB_8512_LCR_Temp_X'    
  
EXEC(@sql)                                        
print (@sql)       
  
set @sql='                                              
insert into ICB_8512_LCR_Temp_S                     
select distinct sitecode,switchcode,calldate,sessionid_b,trunkin,trunkout,legAdev,SetupCharge,ani,did,dialednum,legAtime,talktime,status,cause,YYYY,MM,DD,HH,mn,prefixcode,destcode,connectflg,disconnectflg,oprsitecode,callcost,timecls,choicenb,cropr,      
crsitecode,CallAttempt,currcode,routecls,costprice ,RoundedUpCallTime,ActualCallDuration          
from                                          
(                                            
select sitecode,switchcode,calldate,sessionid_b,trunkin,trunkout,legAdev,SetupCharge,ani,did,dialednum,legAtime,  
talktime,status,cause,YYYY,MM,DD,HH,mn,prefixcode,destcode,connectflg,disconnectflg,oprsitecode,callcost,timecls,  
choicenb,cropr, crsitecode,CallAttempt,currcode,routecls,costprice,RoundedUpCallTime,ActualCallDuration     
from LCR_MONTH'+@pasttodaymm+'_'+@pasttodayyy+'.dbo.FNGN_XCDS_'+@pasttwoday+'(nolock)                                         
union all                                          
select sitecode,switchcode,calldate,sessionid_b,trunkin,trunkout,legAdev,SetupCharge,ani,did,dialednum,legAtime,  
talktime,status,cause,YYYY,MM,DD,HH,mn,prefixcode,destcode,connectflg,disconnectflg,oprsitecode,callcost,timecls,  
choicenb,cropr, crsitecode,CallAttempt,currcode,routecls,costprice,RoundedUpCallTime,ActualCallDuration    
from LCR_MONTH'+@pastdatemm+'_'+@pastdateyy+'.dbo.FNGN_XCDS_'+@pastdate+'(nolock)                                         
union all                                            
select sitecode,switchcode,calldate,sessionid_b,trunkin,trunkout,legAdev,SetupCharge,ani,did,dialednum,legAtime,  
talktime,status,cause,YYYY,MM,DD,HH,mn,prefixcode,destcode,connectflg,disconnectflg,oprsitecode,callcost,timecls,  
choicenb,cropr,crsitecode,CallAttempt,currcode,routecls,costprice,RoundedUpCallTime,ActualCallDuration  
from LCR_MONTH'+@currdatemm+'_'+@currdateyy+'.dbo.FNGN_XCDS_'+@currdate+'(nolock)                                         
)aa                  
Where yyyy ='''+@pastdateyy+''' and mm= '''+@pastdatemm+''' and dd= '''+@pastdatedd+'''                  
'    
EXEC (@sql)                  
print (@sql)                          
set @sql='                                              
insert into ICB_8512_LCR_Temp_X                     
select distinct site_code,switch_code,a_call_start,session_id,trunk_in,trunk_out,lega_name,legb_name,a_cli,a_did,prefix_code,callednb,legatime,legbtime,connect_start,duration,call_domain,call_cost,choice,connect_flag,stat,cause,disc_party,SetupCharge,Roun
dedUpCallTime,ActualCallDuration  from  
(              
 select site_code,switch_code,a_call_start,session_id,trunk_in,trunk_out,lega_name,legb_name,  
 a_cli,a_did,prefix_code,callednb,legatime,legbtime,connect_start,duration,call_domain,  
 call_cost,choice,connect_flag,stat,cause,disc_party,SetupCharge ,RoundedUpCallTime,  
 ActualCallDuration    
 from LCR_MONTH'+@pasttodaymm+'_'+@pasttodayyy+'.dbo.FNGN_XCDX_'+@pasttwoday+'(nolock)                                         
union all                                          
 select site_code,switch_code,a_call_start,session_id,trunk_in,trunk_out,lega_name,legb_name,  
 a_cli,a_did,prefix_code,callednb,legatime,legbtime,connect_start,duration,call_domain,  
 call_cost,choice,connect_flag,stat,cause,disc_party,SetupCharge,RoundedUpCallTime,  
 ActualCallDuration     
 from LCR_MONTH'+@pastdatemm+'_'+@pastdateyy+'.dbo.FNGN_XCDX_'+@pastdate+'(nolock)                                         
union all                                            
 select site_code,switch_code,a_call_start,session_id,trunk_in,trunk_out,lega_name,legb_name,  
 a_cli,a_did,prefix_code,callednb,legatime,legbtime,connect_start,duration,call_domain,  
 call_cost,choice,connect_flag,stat,cause,disc_party,SetupCharge,RoundedUpCallTime,  
 ActualCallDuration     
 from LCR_MONTH'+@currdatemm+'_'+@currdateyy+'.dbo.FNGN_XCDX_'+@currdate+'(nolock)                                         
)aa                  
Where convert(varchar(10),a_call_start,120) ='''+@pastdate1+'''                 
'    
EXEC (@sql)                                    
print (@sql)                                 
                                
end   