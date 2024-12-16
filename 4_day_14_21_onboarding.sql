WITH prc_main AS(
  SELECT 
    id,
    account_number,
    date_added , 
    cast(timestamp as date) as date_out , 
    date_diff(cast(timestamp as date),date_added,day) as days_in_prc  
  FROM `dwoperation.prc_ug.prc_master`
)
,totals AS (
  SELECT
    DATE_TRUNC(date_added, month) as month,
    COUNT(*) AS total_customers,
    COUNTIF(prc_main.days_in_prc > 14) AS cust_greater_14,
    COUNTIF(prc_main.days_in_prc > 21) AS cust_greater_21
  FROM prc_main
  GROUP BY 1
)
,percentages AS (
  SELECT
  month,
  round((cust_greater_14/total_customers)*100,2) AS percent_14
  ,ROUND((cust_greater_21/total_customers)*100,2) AS percent_21
  
  FROM totals
  WHERE month is not null
)

SELECT * FROM percentages
-- SELECT * FROM totals