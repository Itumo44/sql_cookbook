WITH bikes_4_sale AS (SELECT
  in_comb.loan_id,
  in_comb.date as date,
  in_comb.plate,
  in_comb.type,
  in_comb.make,
  in_comb.model,
  in_comb.decision,
  in_comb.days_in_warehouse,
  in_comb.relesed_date,
  ROW_NUMBER() OVER (PARTITION BY in_comb.plate ORDER BY in_comb.date ASC) as rn,
  DATE_DIFF(current_date(), cast(in_comb.date AS date), day) AS day_diff,
FROM `dwoperation.inventory_repo_ke.in_combined` in_comb where plate in (
SELECT DISTINCT registration_no
FROM `dwanalytics.analytics.list_x`
WHERE legal_status = "On Sale" AND country = "KE") 
qualify rn=1
),

in_inspection as (select 
  b4s.*,
  inspection.plate,
  inspection.make,
  type_of_asset,
  vehicle_grading 
from bikes_4_sale as b4s
left join 
  `dwoperation.inventory_repo_ke.inspection_v2` as inspection
on 
  b4s.plate=inspection.plate and 
  b4s.make=inspection.make
where inspection.plate is not null
),

discount as (
  select
    b4s.days_diff,
    inspection.plate,
    inspection_make,
    vehicle_grading,
    plate_number,
    current_price,
    price_module.make,
    CASE 
      WHEN b4s.days_diff >= 186
      THEN current_price * 0.10
      WHEN  b4s.days_diff >= 248
      THEN current_price * 0.15
      WHEN  b4s.days_diff >= 365
      THEN current_price * 0.20 
  from in_inspection
  inner join `dwoperation.inventory_repo_ke.price_module_bqt` price_module 
  on in_inspection.plate= price_module.plate_number
)