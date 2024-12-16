WITH newcases as (
  SELECT
    loan.account_no AS account_no,
    'https://mx.watucredit.com/app/#/recovery/loan/list/'||client.source_id||'/'||loan.source_id||'/profile-loan-comments' AS pqm_link,
    loan.disbursed_on_date AS disbursal_date,
    CURRENT_DATE() AS date_added,
    client.display_name AS client_name,
    client.mobile_no AS client_phone,
    loan.weekly_installment AS weekly_installment,
    loan.expected_first_repayment_on_date AS pmt_date,
    loan.dealership AS dealership,
    loan.branch AS branch,
    loan.registration_no,
    loan.loan_officer AS loan_officer
  FROM `dwanalytics.core.vw_loan` AS loan
  INNER JOIN `dwanalytics.core.vw_client` AS client ON
    loan.source_client_id=client.source_id AND 
    loan.country = client.country
  LEFT JOIN dwoperation.collections_ke.welcome_call_allcases AS all_cases ON
    loan.account_no = all_cases.account_no
  WHERE
    CASE
      WHEN 
        EXTRACT(dayofweek FROM CURRENT_DATE()) = 2 
      THEN loan.disbursed_on_date = CURRENT_DATE()-2
      ELSE
      loan.disbursed_on_date = CURRENT_DATE()-1
    END AND loan.country='KE' AND 
    loan.loan_origin IN ('New',
      'Repossessed',
      'Transferred') AND 
    loan.asset_type IN ('Motor cycle',
      'Three wheeler',
      'Electric tuktuk',
      'Electric bike') AND 
    all_cases.account_no IS NULL AND
    loan.loan_status='Active'
),
sorted AS (
    SELECT 
      newcases.*,
      row_number() over(order by disbursal_date asc) as rn 
    FROM newcases
),
rn_max as (
  SELECT 
    MAX(rn) as rn
  FROM sorted
),
case_count AS (
  SELECT 
    sorted.*,
    rn_max.rn as cases
  FROM sorted
  CROSS JOIN rn_max
),
assignments AS (
  SELECT 
    case_count.*,
    CASE
      WHEN rn<=cases/3
      THEN "Gilbert Obura"
      WHEN rn<=(cases/3)*2
      THEN "Priscillah Mwende"
      WHEN rn<=(cases/3)*3
      THEN "Winnie Choni"
    END AS Officer
  FROM case_count
)
 
SELECT 
  *
EXCEPT (rn,cases)
FROM assignments;
