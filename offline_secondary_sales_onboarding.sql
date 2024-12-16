WITH out as(
  SELECT *, ROW_NUMBER() OVER(PARTITION BY plate ORDER BY released_date DESC ) AS rn FROM `dwoperation.inventory_repo_ke.out_combined` 
)
,loan AS(
  
  SELECT account_no, registration_no, tracking_status,connection_status,last_connection_date
  , ROW_NUMBER() OVER(PARTITION BY registration_no ORDER BY disbursed_on_date DESC ) AS rn FROM `dwanalytics.core.vw_loan` 
  WHERE country ='KE'
  AND asset_type ='Motor cycle'
)

SELECT out.plate,released_date as sale_date, loan.* FROM out   
INNER JOIN loan ON loan.registration_no =out.plate And loan.rn=1 AND loan.connection_status ='Offline'
WHERE out.rn=1
AND type ='sold as loan'
AND out.released_date =current_date()-1