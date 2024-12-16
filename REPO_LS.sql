with base_pop as (
  select
    account_no
    ,registration_no
    ,loan.legal_status as loan_ls
    ,asset_type
  from `dwanalytics.core.vw_loan` loan
  inner join `dwanalytics.analytics.legal_status_change` ls
    using (account_no)
  where 1=1
    and loan.legal_status = "Repossessed"
    and ls.legal_status = "Repossessed"
    and loan.country = "KE"
    and loan.country = ls.country
    and ls.is_current = 1
    and ls.legal_status_start_date < current_date() - 3
)