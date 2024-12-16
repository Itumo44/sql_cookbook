with ranked_acc AS 
( SELECT 
  account_no,
  client_id,
  source_client_id,
  registration_no,
  ROW_NUMBER() over(partition by registration_no order by disbursed_on_date ASC) AS rownum 
  FROM `dwanalytics.core.vw_loan`
)
select vw.account_no, vw.registration_no,c.source_id, cl.display_name,c.document_key 
 FROM  ranked_acc AS vw
INNER join `dwanalytics.core.client` CL on cl.source_id= vw.source_client_id and CL.is_current=1
INNER join `dwanalytics.core.client_identifier` c ON cl.source_id =c.source_client_id and c.document_type = 'National ID' 
WHERE rownum=3
AND registration_no='KMFS274F';