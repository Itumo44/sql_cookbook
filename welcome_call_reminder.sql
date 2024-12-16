WITH latest_case AS (
  SELECT *,
  ROW_NUMBER() OVER(PARTITION BY Account_no ORDER BY Timestamp DESC) AS row_num
  FROM(
    SELECT
      *,
    FROM dwoperation.collections_ke.welcome_call_officer1 

    UNION ALL 

    SELECT
      *,
    FROM dwoperation.collections_ke.welcome_call_officer2 

    UNION ALL 

    SELECT
      *,
    FROM dwoperation.collections_ke.welcome_call_officer3 
  )
WHERE account_no IS NOT NULL
)

SELECT 
  account_no,
  timestamp,
  reminder_date,
  conclusion,
  officer 
FROM latest_case
WHERE row_num =1
  AND Conclusion='Follow-Up' AND 
  reminder_date IS NOT NULL
;