WITH loan AS (
  SELECT
    loan_id,
    registration_no,
    disbursed_on_date,
    legal_status,
    closed_on_date,
    account_no,
    loan_status,
    principal_written_off_derived,
    ROW_NUMBER() OVER (PARTITION BY registration_no ORDER BY disbursed_on_date ASC) AS loan_rn
  FROM
    `dwanalytics.core.vw_loan`
  WHERE
    country = "UG" AND 
    legal_status LIKE ("Sold On%") AND 
    asset_type IN ("Motor cycle",
      "Electric bike") AND 
    closed_on_date IS NOT NULL 
),

warehouse AS (
  SELECT
    repo_out.registration_no,
    repo_out.released_date,
    repo_out_type,
    repo_in.loan_id,
    ROW_NUMBER() OVER (PARTITION BY repo_out.registration_no ORDER BY repo_out.released_date) AS warehouse_rn
  FROM
    `dwanalytics.core.repo_out` AS repo_out
  INNER JOIN
     `dwanalytics.core.repo_in` AS repo_in 
  ON repo_out.repo_in_id=repo_in.repo_in_id AND 
    repo_out.country=repo_in.country   
  WHERE
    repo_out_type IN ("sold as loan","sold in cash") AND 
    repo_out.registration_no IS NOT NULL AND 
    repo_out.released_date IS NOT NULL AND 
    repo_out.country = "UG"
),

loan_warehouse AS (
  SELECT
    loan.*,
    warehouse.*,
    CASE
      WHEN loan_rn = 1 AND warehouse.registration_no IS NULL 
      THEN "missing in warehouse"
      WHEN warehouse_rn = 1 AND loan.registration_no IS NULL 
      THEN "missing in mifos"
      WHEN loan.registration_no IS NOT NULL AND warehouse.registration_no IS NOT NULL 
      THEN "in_mifos_warehouse"
    END
        AS record_status
  FROM
    loan
  FULL OUTER JOIN
    warehouse
  ON
    loan.registration_no = warehouse.registration_no AND 
    loan_rn = warehouse_rn AND 
    loan.loan_id = warehouse.loan_id
  ORDER BY
    loan.disbursed_on_date DESC 
)

SELECT
    DATE_TRUNC(released_date, MONTH) AS month,
    SUM(principal_written_off_derived) AS total_write_off,
  FROM
    loan_warehouse
  WHERE
    record_status="in_mifos_warehouse"
  GROUP BY
    month
  ORDER BY
    month asc