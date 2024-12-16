with core as (
  select ls.account_no --ls.asset_type
    , vw.asset_type, vw.closed_on_date
    , case when ls.duration_day > 22 then 'LC LEGAL STATUS FOR '||cast(duration_day as string)||' DAYS'
           when wb.af_id is null then 'NOT IN WIN BACK'
           else 'code error'
      end as issue
  from `dwanalytics.analytics.legal_status_change` as ls --accounts on last call LS
  inner join `dwanalytics.core.vw_loan` as vw
    using(account_no, country)
  left join `dwoperation.winback_ke.teams_combined` as wb --currently in win back, to be excluded
    on ls.account_no = trim(upper(wb.af_id))
    and (
         wb.final_decision is null 
        OR
         cast(wb.timestamp as date) >= current_date-2
        )
  where (wb.af_id is null 
        OR
        ls.duration_day > 22
        )
    and ls.country = 'KE'
    and is_current = 1
    and ls.legal_status = 'Last Call'
with core as (
  select ls.account_no --ls.asset_type
    , vw.asset_type, vw.closed_on_date
    , case when ls.duration_day > 22 then 'LC LEGAL STATUS FOR '||cast(duration_day as string)||' DAYS'
           when wb.af_id is null then 'NOT IN WIN BACK'
           else 'code error'
      end as issue
  from `dwanalytics.analytics.legal_status_change` as ls --accounts on last call LS
  inner join `dwanalytics.core.vw_loan` as vw
    using(account_no, country)
  left join `dwoperation.winback_ke.teams_combined` as wb --currently in win back, to be excluded
    on ls.account_no = trim(upper(wb.af_id))
    and (
         wb.final_decision is null 
        OR
         cast(wb.timestamp as date) >= current_date-2
        )
  where (wb.af_id is null 
        OR
        ls.duration_day > 22
        )
    and ls.country = 'KE'
    and is_current = 1
    and ls.legal_status = 'Last Call'
)

select * from core;