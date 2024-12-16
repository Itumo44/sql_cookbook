with A as
(
  SELECT 
  account_no, 
  ROW_NUMBER() over(partition by registration_no order by disbursed_on_date ASC) AS rownum 
  FROM `dwanalytics.core.vw_loan` where registration_no='KMFS274F'
  qualify rownum=2
) 
select account_no from A; 