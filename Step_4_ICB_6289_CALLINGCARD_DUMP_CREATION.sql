              
              
                        
CREATE procedure ICB_6289_CALLINGCARD_DUMP_CREATION                                     
as                                 
                              
begin                              
                            
Declare @pastdate varchar(12)                              
Declare @currdate varchar(12)                              
Declare @pasttwoday varchar(12)                              
Declare @sql varchar(1000)                         
Declare @pasttodayyy varchar(4)                   
Declare @pasttodaymm varchar(2)                 
Declare @currdateyy varchar(4)                
Declare @currdatemm varchar(2)               
Declare @pastdateyy varchar(4)              
Declare @pastdatemm varchar(2)              
                  
                            
set @pastdate=convert(varchar(8),getdate()-1,112)                               
set @currdate=convert(varchar(8),getdate(),112)                               
set @pasttwoday=convert(varchar(8),getdate()-2,112)                              
              
set @pasttodayyy=substring(@pasttwoday,1,4)              
set @pasttodaymm=substring(@pasttwoday,5,5)              
              
set @currdateyy=substring(@currdate,1,4)              
set @currdatemm=substring(@currdate,5,5)              
              
set @pastdateyy=substring(@pastdate,1,4)              
set @pastdatemm=substring(@pastdate,5,5)              
                      
set       
@sql='Drop TABLE ICB_6289_CC_DUMP'                              
Exec(@sql)                          
                      
--print(@sql)                              
                              
set @sql='                                
SELECT *,                        
(cast(callyy as varchar)+''-''+                        
right(100+ltrim(rtrim(cast(callmm as varchar))),2)+''-''+                        
right(100+ltrim(rtrim(cast(calldd as varchar))),2)+'' ''+                        
right(100+ltrim(rtrim(cast(callhh as varchar))),2)+'':''+                        
right(100+ltrim(rtrim(cast(callmi as varchar))),2)+'':''+                        
right(100+ltrim(rtrim(cast(calldd as varchar))),2)+''.000'')  Call_date          
INTO ICB_6289_CC_DUMP FROM                           
(                              
select * from CALLINGCARD_MONTH'+@pasttodaymm+''+@pasttodayyy+'.DBO.CCCDB_'+@pasttwoday+'(nolock)                           
union all                            
select * from CALLINGCARD_MONTH'+@pastdatemm+''+@pastdateyy+'.DBO.CCCDB_'+@pastdate+'(nolock)                           
union all                              
select * from CALLINGCARD_MONTH'+@currdatemm+''+@currdateyy+'.DBO.CCCDB_'+@currdate+'(nolock)                           
)a'                              
                      
Exec (@sql)                    
                  
                      
end           
      
         
              
              
              
              
              
              
              
              
              