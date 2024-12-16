WITH loan AS (
  SELECT
    registration_no,
    disbursed_on_date,
    legal_status,
    closed_on_date,
    account_no,
    loan_status,
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
    out_sales.plate AS plate,
    out_sales.date AS release_date,
    out_sales.type AS out_type,
    out_sales.actual_price,
    ROW_NUMBER() OVER (PARTITION BY plate ORDER BY out_sales.date) AS warehouse_rn
  FROM
    `dwoperation.inventory_repo_ug.out_combined_bq` out_sales
  WHERE
    out_sales.type IN ("sold as loan","sold in cash") AND 
    Plate IS NOT NULL AND 
    out_sales.date IS NOT NULL 
),

loan_warehouse AS (
  SELECT
    loan.*,
    warehouse.*,
    CASE
      WHEN loan_rn = 1 AND warehouse.plate IS NULL 
      THEN "missing in warehouse"
      WHEN warehouse_rn = 1 AND loan.registration_no IS NULL 
      THEN "missing in mifos"
      WHEN loan.registration_no IS NOT NULL AND warehouse.plate IS NOT NULL 
      THEN "in_mifos_warehouse"
    END
        AS record_status
  FROM
    loan
  FULL OUTER JOIN
    warehouse
  ON
    loan.registration_no = warehouse.plate AND 
    loan_rn = warehouse_rn
  ORDER BY
    loan.disbursed_on_date DESC 
),

monthly_writeoff AS (
  SELECT
    DATE_TRUNC(CAST(prc_ug.timestamp AS date), MONTH) AS month,
    SUM(prc_ug.writeoff_amt) AS total_write_off,
  FROM
    loan_warehouse
  INNER JOIN
    `dwoperation.inventory_repo_ug.price_module` prc_ug
  ON
    loan_warehouse.registration_no = prc_ug.reg_no
  WHERE
    prc_ug.timestamp IS NOT NULL AND
    record_status="in_mifos_warehouse"
  GROUP BY
    month
  ORDER BY
    month asc
),

per_make_monthly_writeoff AS (
  SELECT
    DATE_TRUNC(CAST(prc_ug.timestamp AS date), MONTH) AS month,
    make,
    SUM(prc_ug.writeoff_amt) AS total_write_off
  FROM
    loan_warehouse
  INNER JOIN
    `dwoperation.inventory_repo_ug.price_module` prc_ug
  ON
    loan_warehouse.registration_no = prc_ug.reg_no
  WHERE
    prc_ug.timestamp IS NOT NULL and
    make IS NOT NULL
  GROUP BY
    month,
    make
  ORDER BY
    month asc,
    make
),

branch_monthly_writeoff AS (
  SELECT
    DATE_TRUNC(CAST(prc_ug.timestamp AS date), MONTH) AS month,
    branch,
    SUM(prc_ug.writeoff_amt) AS total_write_off
  FROM
    loan_warehouse
  INNER JOIN
    `dwoperation.inventory_repo_ug.price_module` prc_ug
  ON
    loan_warehouse.registration_no = prc_ug.reg_no
  WHERE
    prc_ug.timestamp IS NOT NULL and
    branch IS NOT NULL
  GROUP BY
    month,
    branch
  ORDER BY
    month asc,
    branch
)

select * from monthly_writeoff;