   
CREATE procedure [dbo].[ICB_8512_UKRPX_LCR]        
as        
begin        
        
                                                                                       
declare @rpxfile varchar(50)                                                                                         
declare @sql varchar(8000)                                                                                                              
declare @dd varchar (2)                                                                                                                         
declare @yyyy varchar(4)         
declare @mm varchar (2)        
declare @date varchar(10)        
declare @routing varchar(100)        
        
        
        
set @date =  CONVERT(varchar(10),getdate()-1,120)        
        
set @yyyy = SUBSTRING(@date,1,4)        
set @mm =SUBSTRING(@date,6,2)        
set @dd = SUBSTRING(@date,9,2)        
set @routing = 'icb_6289_routing_prefix'        
        
        
        
        
        
set @rpxfile = 'IBOSS_148.carrier.dbo.Rpx'+ right(ltrim(rtrim(@mm)),2)+ltrim(rtrim(@yyyy))         
        
        
        
                                                                                   
SET @SQL=                                               
'                                
delete from '+@rpxfile+' where callyy='+@yyyy+' and callmm='+@mm+' and calldd = '+@dd+'                                                               
and producttype=''RES_FNGN''                         
                                                                                
truncate table RPX_TEMP_LCR                                         
                                        
                                          
insert into RPX_TEMP_LCR                                
(SITECODE,TARIFFZONE,ROUTEPFX,OPERATOROUT,DURA,BCOST,COST,INCOME,MARGIN,CALLYY,CALLMM,CALLDD,producttype,cnt,SetupCost,country,lega_name,trunk_in,a_cli)                                                                                   
select   (case when  lega_name = ''ws_mob'' and left(a_cli,2) = ''44'' then ''UK''                                                                                         
         when  lega_name = ''ws_mob'' and left(a_cli,2) = ''41'' then ''SWI''                                                                                         
                         when  lega_name = ''ws_mob'' and left(a_cli,2) = ''45'' then ''DEN''                                              
                                 when  lega_name = ''ws_mob'' and left(a_cli,2) = ''31'' then ''HOL''                                                                                         
           when  lega_name = ''ws_mob'' and left(a_cli,2) = ''46'' then ''SWE''                                                    
           when  lega_name = ''ws_mob'' and left(a_cli,2) = ''32'' then ''BEL''                                                                      
           when  lega_name = ''ws_mob'' and left(a_cli,2) = ''47'' then ''NOR''                                                                                    
 when  lega_name = ''ws_mob'' and left(a_cli,2) = ''49'' then ''GER''                                                                                  
 when  lega_name = ''ws_mob'' and left(a_cli,2) = ''34'' then ''ESP''                        
                         
 when  lega_name = ''ws_mob'' and left(a_cli,2) = ''43'' then ''AUT''                       
 when  lega_name = ''ws_mob'' and left(a_cli,2) = ''33'' then ''FRA''                      
 when  lega_name = ''ws_mob'' and left(a_cli,3) = ''852'' then ''HKG''                      
 when  lega_name = ''ws_mob'' and left(a_cli,3) = ''353'' then ''IRL''                      
 when  lega_name = ''ws_mob'' and left(a_cli,2) = ''39'' then ''ITA''                      
 when  lega_name = ''ws_mob'' and left(a_cli,3) = ''389'' then ''MKD''                      
 when  lega_name = ''ws_mob'' and left(a_cli,2) = ''31'' then ''NLD''                      
 when  lega_name = ''ws_mob'' and left(a_cli,2) = ''48'' then ''POL''                      
 when  lega_name = ''ws_mob'' and left(a_cli,3) = ''351'' then ''PRT''                      
 when  lega_name = ''ws_mob'' and left(a_cli,2) = ''40'' then ''ROU''                        
 when  lega_name = ''ws_mob'' and left(a_cli,3) = ''216'' then ''TUN''                      
 when  lega_name = ''ws_mob'' and left(a_cli,3) = ''256'' then ''UGA''                      
 when  lega_name = ''ws_mob'' and left(a_cli,3) = ''380'' then ''UKR''                       
 when  lega_name = ''ws_mob'' and left(a_cli,2) = ''27'' then ''ZAF''                                                    
 when  lega_name <> ''ws_mob''  then ''RES''                                                                                         
END                                                                                                                   
) SITECODE,                                                                                   
(select top 1 destcode from '+@routing+'   where B.PREFIX_CODE like PREFIXCODE+''%''                                                         
order by prefixlen desc) as tariffzone,                                                                                        
PREFIX_CODE ROUTEPFX , ISNULL ( LEGB_NAME , left(call_domain,charindex(''@'',call_domain,1)-1))  OPERATOROUT,                                      
SUM(CAST(RoundedUpCallTime AS FLOAT)/60.) AS DURA,                                                                        
avg(cast(isnull(call_cost,0.0) as float))bcost,                                                                    
SUM(CAST(RoundedUpCallTime AS FLOAT)/60.*(CAST(call_cost AS FLOAT)+CAST(stat as float)))  AS COST,''0.0'' Income,''0.0'' margin,                                                                                        
datepart( yyyy, a_call_start) YYYY,datepart(mm, a_call_start) MM ,datepart(dd,a_call_start) DD,                                                      
''RES_FNGN'' producttype,count(*)cnt,setupCharge,null as country ,lega_name,trunk_in ,left(a_cli,4) as a_cli                                                                         
from    ICB_REPORTS_UGC.dbo.ICB_8512_LCR_Temp_X  B (nolock)                                                                                        
WHERE convert( varchar(10),a_call_start, 120)  between '''+@date+''' and '''+@date+'''                                                                                        
AND CONNECT_FLAG = ''1''                                                                                         
AND call_cost > ''0'' AND RoundedUpCallTime > ''0''                                                                                         
and left(call_domain,charindex(''@'',call_domain,1)-1) not in(''BARA1628'',''CISCO'',''IPG'',''IVR'',''PIPEWA_V'',''WA_LYC_2'',''WA_LYC_1'',                                                                                        
''WA_LYC_3'',''WA_LYC_G'',''WA_LYC_U'',''WA_VIGRA'',''WS_IRE'',''WS_PLI'',''WS_SLAB'',''WS_VECTO'',                                                                                        
''7IND'',''vt366'',''VT400'',''vt407'',''vt482'',''nomi_out'')and trunk_in <> ''lyc_in''                                                                       
GROUP BY datepart( yyyy, a_call_start),datepart(mm, a_call_start),datepart(dd,a_call_start),                                                       
ISNULL ( LEGB_NAME , left(call_domain,charindex(''@'',call_domain,1)-1)),B.lega_name,left(a_cli,2),left(a_cli,3),B.prefix_code ,setupCharge    ,lega_name,trunk_in ,left(a_cli,4)                                                                              
  
    
     
ORDER BY datepart( yyyy, a_call_start),datepart(mm, a_call_start),datepart(dd,a_call_start),                                                                                        
ISNULL ( LEGB_NAME , left(call_domain,charindex(''@'',call_domain,1)-1)),B.lega_name,left(a_cli,2),left(a_cli,3),B.prefix_code  ,setupCharge                                                              
                                                                                         
'                                               
EXEC(@SQL)         
        
                 
  set @sql ='                  
  update a                
set a.sitecode=b.TADIQ_code                
from RPX_TEMP_LCR a inner join ICB_8286_TADIQ_CODE_DETAILS b                
on left(a.a_cli,4)=b.code                
where a.sitecode is null and a.lega_name = ''ws_mob''                        
  '                
  EXEC(@SQL)                             
                             
  set @sql ='                           
                             
     update a                
set a.sitecode=b.TADIQ_code                
from RPX_TEMP_LCR a inner join ICB_8286_TADIQ_CODE_DETAILS b                
on left(a.a_cli,3)=b.code                
where a.sitecode is null and   a.lega_name = ''ws_mob''                
'                
EXEC(@sql)                
               
    set @sql ='                           
                             
     update a                
set a.sitecode=b.TADIQ_code                
from RPX_TEMP_LCR a inner join ICB_8286_TADIQ_CODE_DETAILS b                
on left(a.a_cli,2)=b.code                
where a.sitecode is null and   a.lega_name = ''ws_mob''                
'                
EXEC(@sql)                           
                     
       set @sql ='                           
                             
     update a                
set a.sitecode=b.TADIQ_code                
from RPX_TEMP_LCR a inner join ICB_8286_TADIQ_CODE_DETAILS b                
on left(a.a_cli,1)=b.code                
where a.sitecode is null and   a.lega_name = ''ws_mob''                
'                
EXEC(@sql)                       
                    
                    
    set @sql ='                
    update A                
set a.country = b.country                 
from RPX_TEMP_LCR a inner join  ICB_REPORTS_UGC.DBO.icb_6235_trunk_master b                 
on a.trunk_in = b.trunk                 
where a.country is null                 
'                
EXEC(@sql)                 
  set @sql ='                
  update a                
set a.country =''CC/LT''                
from RPX_TEMP_LCR a inner join icb_6191_LT_Trunks b                
on a.trunk_in = b.trunk                 
where a.country is null                
'                
EXEC(@sql)                  
------      set @sql ='                
------  update a                
------set a.country =''CC''                
------from RPX_TEMP_LCR a inner join icb_6134_proj_trunks b                
------on a.trunk_in = b.trunk                 
------where a.country is null                
------'                
------EXEC(@sql)                  
                    
    set @sql='update a                
set a.country =b.product                
from RPX_TEMP_LCR a inner join icb_6191_MNO_TRUNKS b                
on a.trunk_in = b.trunk                 
where a.country is null                
'                
  EXEC(@sql)                                         
                                                                                                                  
                                                                                
set @sql='                                                  
insert into '+@rpxfile+'                                              
(SITECODE,TARIFFZONE,ROUTEPFX,OPERATOROUT,DURA,BCOST,COST,INCOME,MARGIN,CALLYY,CALLMM,CALLDD,producttype,Calls,SetupCharge,actual_cost,country )                                                                             
select SITECODE,TARIFFZONE,ROUTEPFX,OPERATOROUT,DURA,                                            
BCOST,(COST+(cnt*Setupcost)),INCOME,MARGIN,CALLYY,CALLMM,CALLDD,producttype,cnt,SetupCost,cost,country from RPX_TEMP_LCR (nolock)                                                                              
'                                                                                
EXEC(@SQL)                                                                                
        
        
        
END        