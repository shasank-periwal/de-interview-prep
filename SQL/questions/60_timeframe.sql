--timeframe sql
with todays_data as 
(
select * from calender_dim where cal_date=datetrunc(day,getdate())
),
cal as (
select c.*, t.cal_year as current_year,t.cal_date as todays_date,t.cal_year_day as current_cal_year_day
,t.cal_quarter as current_quarter,t.cal_month as current_month, t.cal_month_day as current_cal_month_day
from calender_dim c
cross join todays_data t
where c.cal_year between t.cal_year -2 and t.cal_year)
, cte as (
select 'FY' as timeframe 
,'FY' as timeframe_id
,min(case when cal_year=current_year then cal_date end) as start_date_ty
,max(case when cal_year=current_year then cal_date end) as end_date_ty
,min(case when cal_year=current_year-1 then cal_date end) as start_date_ly
,max(case when cal_year=current_year-1 then cal_date end) as end_date_ly
,min(case when cal_year=current_year-2 then cal_date end) as start_date_lly
,max(case when cal_year=current_year-2 then cal_date end) as end_date_lly
from cal c
union all
select 'QUARTER' as timeframe 
,cast(cal_quarter as varchar(3)) as timeframe_id
,min(case when cal_year=current_year then cal_date end) as start_date_ty
,max(case when cal_year=current_year then cal_date end) as end_date_ty
,min(case when cal_year=current_year-1 then cal_date end) as start_date_ly
,max(case when cal_year=current_year-1 then cal_date end) as end_date_ly
,min(case when cal_year=current_year-2 then cal_date end) as start_date_lly
,max(case when cal_year=current_year-2 then cal_date end) as end_date_lly
from cal c
group by cal_quarter
union all
select 'YTD' as timeframe 
,'YTD' as timeframe_id
,min(case when cal_year=current_year then cal_date end) as start_date_ty
,max(case when cal_year=current_year then cal_date end) as end_date_ty
,min(case when cal_year=current_year-1 then cal_date end) as start_date_ly
,max(case when cal_year=current_year-1 then cal_date end) as end_date_ly
,min(case when cal_year=current_year-2 then cal_date end) as start_date_lly
,max(case when cal_year=current_year-2 then cal_date end) as end_date_lly
from cal c
where cal_year_day <= current_cal_year_day
union all
select 'QTD' as timeframe 
,'QTD' as timeframe_id
,min(case when cal_year=current_year then cal_date end) as start_date_ty
,max(case when cal_year=current_year then cal_date end) as end_date_ty
,min(case when cal_year=current_year-1 then cal_date end) as start_date_ly
,max(case when cal_year=current_year-1 then cal_date end) as end_date_ly
,min(case when cal_year=current_year-2 then cal_date end) as start_date_lly
,max(case when cal_year=current_year-2 then cal_date end) as end_date_lly
from cal c
where cal_quarter = current_quarter and cal_year_day <= current_cal_year_day
union all
select 'MTD' as timeframe 
,'MTD' as timeframe_id
,min(case when cal_year=current_year then cal_date end) as start_date_ty
,max(case when cal_year=current_year then cal_date end) as end_date_ty
,min(case when cal_year=current_year-1 then cal_date end) as start_date_ly
,max(case when cal_year=current_year-1 then cal_date end) as end_date_ly
,min(case when cal_year=current_year-2 then cal_date end) as start_date_lly
,max(case when cal_year=current_year-2 then cal_date end) as end_date_lly
from cal c
where cal_month = current_month and cal_month_day <= current_cal_month_day
union all
select 'month' as timeframe 
,cast(cal_month as varchar(2)) as timeframe_id
,min(case when cal_year=current_year then cal_date end) as start_date_ty
,max(case when cal_year=current_year then cal_date end) as end_date_ty
,min(case when cal_year=current_year-1 then cal_date end) as start_date_ly
,max(case when cal_year=current_year-1 then cal_date end) as end_date_ly
,min(case when cal_year=current_year-2 then cal_date end) as start_date_lly
,max(case when cal_year=current_year-2 then cal_date end) as end_date_lly
from cal c
group by cal_month)
select * into timeframes from cte 