               
CREATE PROCEDURE [dbo].[ICB_6289_CCRPX]                                           
--exec [ICB_CCRPX] '2014','02','01'                                               
@yyyy varchar(4),                                                  
@mm  varchar(2),                                                  
@dd varchar(2)                                                 
                                                  
as                                                
begin                                                  
                                                  
set QUOTED_IDENTIFIER OFF                                                  
                                                  
declare @sql varchar(4000)                                                  
declare @notlike varchar(100)                                                  
declare @where varchar(3000)                                                  
declare @groupby varchar(2000)                                                  
declare @orderby varchar(2000)                                                  
declare @date   varchar(10)                                                  
declare @monthname varchar(50)                                                  
declare @rpxfile varchar(50)                                                  
declare @infile varchar(50)                                                  
declare @lycafile varchar(50)                                                  
declare @vecfile varchar(50)                                                  
declare @veccdb varchar(50)                                                  
declare @xcdr varchar(50)                                                  
declare @xcds varchar(50)                                                  
declare @mobxcdr varchar(50)                                                  
declare @lycxcdr varchar(50)                                                  
                                                  
                                                
--sp_tables 'Rpx%'                                                  
--select top 0 * into rpx102008 from rpx092008                                                
                                                
--select  calldd, count(*) from rpx092008                                                
--group by calldd                                                
--order by calldd                                                
                                                
set @date = @yyyy + '-' +right((@mm+100),2) + '-'+right((@dd+100),2)                                                   
                                                
set @rpxfile = 'IBOSS_148.carrier.dbo.rpx'+ replicate('0',2-len(ltrim(rtrim(@mm))))+cast(@mm  as varchar)+cast(@yyyy as varchar)                                         
                                        
truncate table RPX_cnt                          
                        
set @sql = '                                                  
                                                
delete from '+@rpxfile+' where callyy='+@yyyy+' and callmm='+@mm+' and calldd='+@dd+'                                                 
and producttype=''CARD''                                            
                                                
                                             
INSERT  INTO Rpx_cnt                                               
SELECT SITECODE,TARIFFZONE,ROUTEPFX,OPERATOROUT,dura,BCOST,COST,                                                  
INCOME,MARGIN,CALLYY,CALLMM,CALLDD,''CARD'',cnt FROM                                                   
(                                                  
SELECT  callyy,callmm ,calldd,                                                
SITECODE,TARIFFZONE,ROUTEPFX,                                                  
OPERATOROUT, SUM(CAST(TALKTIME AS FLOAT)/60.) AS DURA,                                                  
AVG(CAST(COSTLEGA AS FLOAT)*60.) AS BCOST, SUM(CAST(TALKTIME AS FLOAT)/60.* CAST(COSTLEGA AS FLOAT)) AS COST,                         
----SUM(CAST(TOTALINC AS FLOAT)) AS INCOME        
----,SUM(CAST(MARGIN AS FLOAT)) AS MARGIN,        
''0'' AS INCOME,''0'' AS MARGIN,        
count(*)cnt                                                    
-- FROM IS_MARGIN.MARGIN.[DBO].MARGIN112023                                                
FROM icb_reports_cc.dbo.ICB_6289_CC_DUMP a (nolock)                                               
-----from IS_MARGIN.workdb_icb.dbo.margin_temp                                              
WHERE sitecode <>''MIL'' and CALLYY='+@yyyy+' AND CALLMM='+@mm+' AND CALLDD between '+@dd+' and '+@dd+'        
AND ROUTEPFX IS NOT NULL AND  TALKTIME >0 AND OPERATOROUT NOT LIKE ''WS_%''                                                  
GROUP BY callyy,callmm ,calldd,SITECODE,TARIFFZONE,ROUTEPFX, OPERATOROUT) x                                                  
                                                    
'                                
                            
                          
exec(@sql)                                         
set @sql='                               
                            
  ----  truncate table routing_prefix_temp                        
                            
  ----  insert into routing_prefix_temp                        
  ----select * from openquery( IS_MARGIN,   ''select * from openquery(FNGN_NocUk,''''select * from Wholesale_FNGN_144.dbo.routing_prefix(nolock)'''')''  )                  
                       
                           
            
                         
update a set a.tariffzone=b.destcode                            
from RPX_cnt a(nolock),ICB_6289_Routing_prefix b (nolock)                         
where a.routepfx=b.prefixcode                            
--and a.operatorout=b.operatorout       
    
    
update A    
set a.tariffzone = (select top 1 destcode from icb_6289_routing_prefix where a.ROUTEPFX like PREFIXCODE+''%''              
order by prefixlen desc)     
from RPX_cnt a    
where a.tariffzone is null    
                         
                            
update a                                          
set a.tariffzone=c.destcode                                          
from RPX_cnt a(nolock),TZ_trunk_mapping b(nolock),TZ_Prefix_mapping c(nolock)                                          
where a.routepfx=c.prefix                                      
--and a.operatorout=b.trunkout                                          
and b.operator=c.operator                                          
                            
                                       
INSERT  INTO ' + @rpxfile + '                            
(SITECODE,TARIFFZONE,ROUTEPFX,OPERATOROUT,DURA,BCOST,COST,INCOME,MARGIN,CALLYY,CALLMM,CALLDD,producttype,Calls,setupcharge,actual_cost,country)                                       
select *,''0.0'',Cost,''Calling_card'' as country from  RPX_cnt(nolock)                                        
'                                        
                                            
exec(@sql)                                                  
--print @sql                                                
                                                
                                                
select '1' ErrCode,'Success' ErrMsg                                                  
end 