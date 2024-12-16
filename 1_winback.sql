WITH winback_accounts AS 
(
  SELECT 
  COUNT( DISTINCT date_added) cases, 
  account_no 
  FROM `dwanalytics.core.win_back_loan` 
  GROUP BY account_no
  having COUNT( DISTINCT date_added) > 4
)

SELECT COUNT(account_no) as winback_over_4 from winback_accounts;