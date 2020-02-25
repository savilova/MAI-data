-- PostgeSQL

-- Для отладки создаем таблицы, в которые импортируем данные из задания
create table content_watch ( watch_id varchar PRIMARY key,	show_date timestamp,	show_duration int,	platform varchar,	user_id varchar,	utm_medium varchar,	content_id varchar);
create table content_info ( content_id varchar PRIMARY key,	compilation_id varchar,	episode varchar,	paid_type char(4))

-- Запрос 0: На каждый день количество просмотров отдельно по монетизациям SVOD и AVOD на платформах 10 и 11 за последние 30 дней.

select DATE(show_date), paid_type, count(*)
from content_watch w left join content_info i on w.content_id=i.content_id 
where platform='10' or platform='11'
	and paid_type <>'TVOD'
group by date(show_date),paid_type
order by date(show_date), paid_type limit 60;


-- Запрос 1: Ежемесячный ТОП-5 сериалов и ТОП-5 единичного контента по количеству смотрящих людей

-- для топ-5 сериалов
select  i.compilation_id, count(distinct user_id)
from content_watch w left join content_info i on w.content_id=i.content_id
where date_part('month', show_date)= date_part('month', now()) 
and date_part('year', show_date)= date_part('year', now()) 
and compilation_id is not null
group by i.compilation_id
order by count(distinct user_id) desc limit 5;

-- для топ-5 единичного контента
select  count(distinct user_id),i.content_id
from content_watch w left join content_info i on w.content_id=i.content_id
where date_part('month', show_date)= date_part('month', now()) 
	and date_part('year', show_date)= date_part('year', now())
	and compilation_id is null
group by i.content_id
order by count(distinct user_id) desc limit 5;

-- Запрос 2: 2.	Список пользователей, у которых вчера был сначала просмотр с organic, а сразу следом за ним - просмотр с referral

-- пока что показывает пользователей, у который 1-й просмотр organic, а 2-й referral

with org_ref_table as (
select user_id, utm_medium, ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY show_date) as show_order
from content_watch
--where date(show_date) = date(timestamp 'yesterday')
)
select user_id
from org_ref_table
where concat(utm_medium, show_order) = 'organic1'
	or concat(utm_medium, show_order) = 'referral2'
group by user_id
having count(*)>1
order by user_id;
