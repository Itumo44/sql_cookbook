with loan AS (SELECT registration_no, account_no, disbursed_on_date, closed_on_date
    , legal_status, principal_overdue_derived, principal_written_off_derived, principal_outstanding_derived, asset_type  
 FROM `dwanalytics.core.vw_loan` loan  where loan_status = "Active" and legal_status = "Sold On Other Loan" and country = "KE" and asset_type = 'Motor cycle' 
),

wh AS (
  select plate AS plate,
    released_date,
    type AS out_type,
    sales_price,
    ROW_NUMBER() OVER (PARTITION BY plate ORDER BY plate) AS warehouse_rn from `dwoperation.inventory_repo_ke.out_combined` where
    type = "sold as loan" AND 
    Plate IS NOT NULL AND 
    released_date IS NOT NULL 
),

MaxRowNumber AS (
  SELECT
    plate as max_plate,
    MAX(warehouse_rn) as max_row_num
  FROM
    wh
  group by 1
),

out_combined AS (SELECT
  *
  EXCEPT(max_plate, max_row_num)
FROM
  wh
JOIN
  MaxRowNumber ON wh.warehouse_rn = MaxRowNumber.max_row_num AND  
  wh.plate = MaxRowNumber.max_plate
),

comparison as (
  select loan.*, out_combined.* from loan right join out_combined on loan.registration_no=out_combined.plate
),

investigate_ls as (select plate,loan.registration_no, loan.account_no, loan.disbursed_on_date, loan.closed_on_date
    ,loan.loan_status, loan.legal_status, loan.principal_overdue_derived, loan.principal_written_off_derived, loan.principal_outstanding_derived, loan.asset_type from comparison join  `dwanalytics.core.vw_loan` loan on comparison.plate = loan.registration_no where comparison.registration_no is null and loan.closed_on_date is null and loan.loan_status = "Active"
)

select * from loan;