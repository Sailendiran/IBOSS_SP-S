    
CREATE PROCEDURE [dbo].[ICB_6289_LYCAOUT_Timecls]                                                                               
@yyyy varchar(4),                                                                              
@mm  varchar(2),                                                                              
@dd varchar(2)                                                                              
                                                                 
---------exec [ICB_6184_LYCAOUT_Timecls] '2023','10','01'                                        
as                                                                            
begin                                                                              
                                                                              
set QUOTED_IDENTIFIER OFF                                                                              
                                                                              
declare @sql varchar(8000)                                                                              
declare @date   varchar(10)                                                                              
declare @monthname varchar(25)                                                                              
declare @lycafile varchar(50)                                                         
declare @lycafile1 varchar(50)                                                                 
declare @xcdr varchar(75)                                                                              
declare @xcds varchar(50)                                                                              
declare @FNGN_xcds varchar(50)                                                                             
declare @FNGN_xcdX varchar(50)                                                                             
declare @mobxcdr varchar(50)                                                                              
declare @lycxcdr varchar(50)                                          
                                        
----declare @mm varchar(2)                                        
----declare @yyyy varchar(4)                                        
----declare @dd varchar(2)                                        
----set @yyyy='2023'                                        
----set @mm='10'                                        
----set @dd='01'                                                                           
                                                                           
                                                                           
                                                                           
set @date = @yyyy + '-' +right((@mm+100),2) + '-'+right((@dd+100),2)                                                                              
set @lycafile = 'IBOSS_148.CARRIER.DBO.lycaout'+ replicate('0',2-len(ltrim(rtrim(@mm))))+cast(@mm  as varchar)+cast(@yyyy as varchar)                                        
set @lycafile1 ='IBOSS_148.CARRIER.DBO.lycaout'+ right(100+ltrim(rtrim(@mm)),2)+@yyyy+'_Timecls'                                                                                
set @xcdr    = 'LON_SRV21.MONTH'+ right((@mm+100),2)+'.DBO.XCDR'                                                                              
set @xcds    = 'Lon_SRV21.Month'+ right((@mm+100),2)+'.[dbo].XCDS'                                                                              
set @mobxcdr = 'LYC_MOB6.MONTH'+  right((@mm+100),2)+'.DBO.XCDR'                                                                              
set @lycxcdr = 'LON_SRV21.MONTH'+ right((@mm+100),2)+'.DBO.LYCA_XCDR'                                                                              
-- set @FNGN_xcds = 'TC2_NGN.wholesale.dbo.FNGN_XCDS_'+@yyyy+@mm+@dd+''                                                                           
-- set @FNGN_xcdX = 'TC2_NGN.wholesale.dbo.FNGN_XCDX_'+@yyyy+@mm+@dd+''                                           
set @FNGN_XCDS ='FNGN_XCDS'+right((@mm+100),2)+right((@yyyy+1000),2)                                                                    
set @FNGN_XCDX ='FNGN_XCDX'+right((@mm+100),2)+right((@yyyy+1000),2)                 
        
 declare @datesum varchar(10)        
declare @datewin varchar(10)        
declare @timediff varchar(50)        
        
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
and DataType = ''LFCDB''                                            
                                        
delete from '+@lycafile1+' where callyy_act='+@yyyy+' and callmm_act='+@mm+' and calldd_act='+@dd+'                         
and DataType = ''LFCDB''                                                                      
                                                                            
insert into '+@lycafile+'                                         
(callyy,callmm,calldd,operatorout,dura,cost,datatype, bcost_lcr,Calls,setup_cost,Actual_cost)                                                                               
SELECT callyy,CALLMM,CALLDD,OPERATOROUT, SUM(CAST(TALKTIME AS FLOAT)/60.) AS DURA,                                                                             
SUM(CAST(TALKTIME AS FLOAT)/60.*CAST(COSTLEGA AS FLOAT)) AS COST,''LFCDB'' as DATATYPE                                                         
,'''' AS bcost_lcr,count(*)Calls,''0.0'',SUM(CAST(TALKTIME AS FLOAT)/60.*CAST(COSTLEGA AS FLOAT)) AS COST2                                              
FROM icb_reports_cc.dbo.ICB_6289_CC_DUMP a (nolock)                                                                    
----FROM IS_MARGIN.workdb_icb.dbo.Icb_8283_view_CCCDB                                           
Where callyy = '+@yyyy+' and callmm='+@mm+' and calldd='+@dd+'                                                                            
AND COSTLEGA > ''0.0''                                                                            
AND CONNECTFLAG = ''1''                                                                             
AND TALKTIME>0                                                  
and operatorout not like ''ws_%'' AND OPERATOROUT NOT LIKE ''%VT%''                                                                             
and operatorout not in (''flg_out1'',''lyc_ger'',''lyc_ita'',''LYC_OUT'',                                                                            
''lyc_spa'',''walb_out'',''che_f'',''che_r'',''che_s'')                                                                 
GROUP BY callyy,CALLMM,CALLDD,OPERATOROUT                                                                              
ORDER BY callyy,CALLMM,CALLDD,OPERATOROUT                                                           
                                        
                                        
insert into '+@lycafile1+'                                         
(callyy,callmm,calldd,operatorout,dura,cost,datatype, bcost_lcr,Calls,setup_cost,Actual_cost,timecls,callmm_act,calldd_act,callyy_act)                                                                               
SELECT datepart(yyyy,Calldate_timecls),datepart(mm,Calldate_timecls),                                        
datepart(dd,Calldate_timecls),OPERATOROUT, SUM(CAST(TALKTIME AS FLOAT)/60.) AS DURA,                                                                             
SUM(CAST(TALKTIME AS FLOAT)/60.*CAST(COSTLEGA AS FLOAT)) AS COST,''LFCDB'' as DATATYPE                                                                               
,'''' AS bcost_lcr,count(*)Calls,''0.0'',SUM(CAST(TALKTIME AS FLOAT)/60.*CAST(COSTLEGA AS FLOAT)) AS COST2 ,        
'+@timediff+',callmm,calldd,callyy                                        
from                                         
(                                        
select a.*,dateadd(minute,((-1)*(isnull('+@timediff+',0))),Call_date) Calldate_timecls,b.'+@timediff+'                                         
FROM icb_reports_cc.dbo.ICB_6289_CC_DUMP a(nolock) left outer join ICB_Carrier_report.dbo.ICB_6418_carriers b                                        
on  ltrim(rtrim(a.operatorout))=ltrim(rtrim(b.systemname))                                        
Where callyy = '+@yyyy+' and callmm='+@mm+' and calldd='+@dd+'                                                          
AND COSTLEGA > ''0.0''                                                                            
AND CONNECTFLAG = ''1''                                                        
AND TALKTIME>0                                                  
and operatorout not like ''ws_%'' AND OPERATOROUT NOT LIKE ''%VT%''                                                                             
and operatorout not in (''flg_out1'',''lyc_ger'',''lyc_ita'',''LYC_OUT'',                                                                            
''lyc_spa'',''walb_out'',''che_f'',''che_r'',''che_s'')                                          
)a                                                               
GROUP BY datepart(yyyy,Calldate_timecls),datepart(mm,Calldate_timecls),                                        
datepart(dd,Calldate_timecls),OPERATOROUT ,'+@timediff+' ,calldd,callmm,callyy                          
ORDER BY datepart(yyyy,Calldate_timecls),datepart(mm,Calldate_timecls),                                        
datepart(dd,Calldate_timecls),OPERATOROUT ,'+@timediff+'   ,calldd,callmm,callyy                                      
                                        
'                                                                
                                                          
                                     
                                                                     
                                                                    
---print (@sql)                                                    
exec(@sql)                                                                                
                                                   
PRINT  'LFCDB -  CCCDB DATA UPLOADED'                                                                            
                                              
end          
          
--SELECT * FROM Carriers 