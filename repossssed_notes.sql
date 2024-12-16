with base_pop as (
  all Kenya loans that currently have "repossessed" legal status where legal status start date < current date - 3
)
, for_repo as (
  select base_pop.*
  , 'Currently' ||repo_list.status|| ' according to repo list' as issue 
  from base_pop
  inner join repo list --this should be partitioned by plate and ordered by date added, taking only most recent record
    on account
    and coalesce(status,'Repossessed') <> 'Repossesed'
)
, never_lastcall as (
  select base_pop.*
    , 'Never in Win Back' as issue
  left join win_back
    on account
    and win_back.date_added >= legal_status_start_date - 3
  where win_back.account is null
  
  UNION ALL

  select base_pop.*
    , 'Never had Last Call legal status' as issue
  left join legal_status_change as ls -- this should be partitioned on plate and ordered by start date desc
    on account
    and ls.legal_status = 'Last Call'
    and (ls.rn = 2 or ls.rn = 3 or ls.rn = 4) --was in last call legal status recently before repossession
  where ls.account is null 

  UNION ALL 

  select base_pop.*
    , 'Never had For Repo legal status' as issue
  left join legal_status_change as ls -- this should be partitioned on plate and ordered by start date desc
    on account
    and ls.legal_status = 'For Repo'
    and (ls.rn = 2 or ls.rn = 3) --had for repo legal status recently before repossession
  where ls.account is null 
)
, never_prc as (
  select base_pop.*
    , 'Hasnt gone to PRC since repossessed'
  left join prc
    on account
    and prc.date_added >= legal_status_start_date-3 -- minus 28 in case satellite but there's a more accurate way to do this
  where prc.account is null 
)