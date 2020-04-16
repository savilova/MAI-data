--Диалект PostgreSQL
--Таблица из задания здесь называется watch_records

--1.	Кол-во просмотров по дням суммарно на двух платформах - 10 и 11
select date(show_date) as watch_date, count(*) watch_count from watch_records
where platform in (10,11)
group by watch_date;

--2.	Кол-во пользователей, смотревших контент в двух разных paid_type за месяц по всем платформам
select count(*) from (select user_id from watch_records
			   		  where date_trunc('month', show_date) = date_trunc('month', now()) -- текущий месяц
			   		  		and date_trunc('day', show_date) < date_trunc('day', now()) -- не включая сегодня (как вариант)
			   		  group by user_id
			   		  having count(distinct paid_type)=2) users;

--3.	Доля просмотров более 5 минут от всех просмотров за месяц  
select concat(100*count(*)/(select count(*) 
	   						from watch_records 
	   						where date_trunc('month', show_date) = date_trunc('month', now()) -- текущий месяц
	   						and date_trunc('day', show_date) < date_trunc('day', now())),     -- не включая сегодня 
	   		  ' %') -- доля в процентах
	   		  as ratio
from watch_records
where show_duration>300 
and date_trunc('month', show_date) = date_trunc('month', now()) 
and date_trunc('day', show_date) < date_trunc('day', now());

--4.	Суммарная длительность смотрения с разбиением по всем типам кампаний на платформе 583 за последние 30 дней
select sum(show_duration), campaign from watch_records
where platform = 583 
and date_trunc('day', show_date) >= now() - interval '30' day --прошедшие 30 дней
and date_trunc('day', show_date) < date_trunc('day', now()) -- не включая сегодня
group by campaign;

--5.	Список пользователей, просматривавших paid_type = SVOD более одного раза за сегодня
select user_id from watch_records
where paid_type = 'SVOD' 
and date_trunc('day', show_date) = date_trunc('day', now()) 
group by user_id
having count(*)>1;

--6.       Список пользователей, у которых за сегодня был сначала просмотр с органики, а потом с директа
select distinct user_id from (select user_id, 
						    campaign,
						    lead(campaign, 1) over(partition by user_id order by show_date) as lead_campaign 
						    from watch_records
						    where date_trunc('day', show_date)= date_trunc('day', now()) ) campaigns
where campaign='organic' and lead_campaign='direct';