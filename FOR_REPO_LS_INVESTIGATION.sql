--George Investigate "For Repo" LS
with for_repo as ( -- cases that have for repo ls in winback ... this should be a pre-requisite FOR THOSE ACCOUNTS THAT WERE IN LAST CALL SINCE WIN BACK WAS IMPLEMENTED (aged accounts - mostly offline - may not meet this criterion)
  select   
    af_id
    ,date_added
    ,tc.Legal_Status as teams_legal_status
    ,tc.Timestamp
  from `dwoperation.winback_ke.teams_combined` tc
  where 1=1
    and tc.Legal_Status = "For Repo"
    and cast(Timestamp AS date) <= current_date() - 2
  )

,loan as ( --mifos for repo ls  ... why only active loans?
  select
    registration_no
    ,account_no
    ,asset_type
    ,legal_status as loan_legal_status
    ,connection_status  
  from `dwanalytics.core.vw_loan` loan
  where 1=1
    and legal_status = "For Repo"
    and country = "KE"
)

,repo_loan as ( -- left join of winback and mifos/loan to be used later ... shouldn't be a total whitelist (we still want to investigate accounts on repo list if they meet the criteria)
  select
    for_repo.*
    ,loan.*
  from for_repo 
  left join loan 
    on for_repo.af_id = loan.account_no
)

,whitelist as ( --whitelisted accounts to continue with investigation later
  select 
    * 
  from repo_loan
  where
    account_no is not null
)

,not_whitelist as ( --ls to be investigated because they're mixed up and not consistent with for repo returned in the spreadsheet
  select 
    af_id 
    ,"INVESTIGATE WINBACK LS" as issue 
  from repo_loan
  where
    account_no is null
  group by 1
)
,wh as ( --warehouse to be used later to filter out for repo accounts that aren't in the wh since going into winback and for repo decision ... these should be investigated, but why aren't we specifying that relesed_date is after date assigned for repo?
  select
    LS
    ,date
    ,plate
    ,relesed_date
  from `dwoperation.inventory_repo_ke.in_combined`
  where 1=1
)

,check_wh as ( -- whitelisted accounts left joined with loan for later use ... not clear what the purpose of this is. you're returning everything from repo_loan, joined to everything from wh that entered the warehouse BEFORE the repo_loan timestamp and where it was added to repo list AFTER it came into warehouse
  select
    wl.*
    ,wh.*
  from whitelist as wl
  left join wh 
    on wl.registration_no = wh.plate
    and wl.timestamp < wh.date 
    and date_added < cast(wh.date as date)
  where 1=1
)

-- accounts with for repo ls that aren't in the warehouse unioned with accounts with ls not consistent with for repo criteria ... that's not really waht the check_wh CTE is doing
,not_in_wh as (
  select
    ch_wh.af_id 
    ,ch_wh.asset_type
    ,ch_wh.registration_no
    ,ch_wh.connection_status
    ,ch_wh.loan_legal_status
    ,"NOT IN WAREHOUSE WITH 'FOR REPO' LS" as issue --why is issue same as above when where condition is opposite?
  from check_wh as ch_wh 
  where 1=1
    and ch_wh.plate is null
)

,investigate as (
  select 
    wh.af_id
    ,wh.registration_no
    ,wh.connection_status
    ,wh.asset_type
    ,wh.loan_legal_status
    ,ls.duration_day
    ,listx.r_score
    ,listx.score_14
    ,case
        when (duration_day >= 30 and duration_day <= 60 and connection_status = "Online") then "REPOSSESS" 
        when (r_score > 80 or score_14 > 50) then "NOT FOR REPO"
        else wh.issue
      end as issue
  from not_in_wh as wh 
  inner join dwanalytics.analytics.legal_status_change as ls
    on wh.af_id = ls.account_no
    and ls.country = "KE"
    and ls.legal_status = "For Repo"
    and is_current = 1
  inner join dwanalytics.analytics.list_x as listx
    on ls.account_no = listx.account_no
    and listx.country = "KE"
  where 1=1
  group by 1, 2,3,4,5,6,7,8,9
)

select count(distinct af_id) from not_whitelist
