SELECT
  officers_combined.account_no,
  REGEXP_REPLACE(STRING_AGG(CAST(timestamp as STRING) ORDER BY timestamp desc),',', '\n') AS last_contact_date,
  REGEXP_REPLACE(STRING_AGG(CONCAT(CAST(timestamp AS DATE)," - ",contacted)
    ORDER BY
      timestamp DESC),',', '\n') AS contacted,
  REGEXP_REPLACE(STRING_AGG(CONCAT(CAST(timestamp AS DATE)," - ",call_status)
    ORDER BY
      timestamp DESC),',', '\n') AS call_status,
  REGEXP_REPLACE(STRING_AGG(CONCAT(CAST(timestamp AS DATE)," - ",Comments)
    ORDER BY
      timestamp DESC),',', '\n') AS Comments,
  REGEXP_REPLACE(STRING_AGG(CONCAT(CAST(timestamp AS DATE)," - ",Conclusion)
    ORDER BY
      timestamp DESC),',', '\n') AS Conclusions,
  REGEXP_REPLACE(STRING_AGG(CONCAT(CAST(timestamp AS DATE)," - ",'Client:',is_client_details,",",'Guarantor:',has_guarantor,",",'Referees:',has_referees,",",'Chairman:',has_chairman,",",'Loan:',is_loan_details,",",'NextofKin:',has_next_of_kin)),',', '\n') AS confirmations,
  loan.last_connection_date AS connection_date,
  CASE
    WHEN 
      loan.last_connection_date = CURRENT_DATE() 
    THEN "online"
    WHEN 
      loan.last_connection_date < loan.disbursed_on_date 
    THEN "offline before sale"
    WHEN 
      loan.disbursed_on_date < loan.last_connection_date AND loan.last_connection_date < CURRENT_DATE() 
    THEN "offline after sale"
  END AS connection_status
FROM `dwoperation.collections_ke.welcome_call_officer_combined` AS officers_combined
left JOIN `dwanalytics.core.vw_loan` AS loan ON
  officers_combined.account_no = loan.account_no
WHERE
  loan.country='KE'
GROUP BY
  account_no,
  connection_date,
  connection_status
;