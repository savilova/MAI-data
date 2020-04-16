-- Диалект ClickHouse
-- Таблица из задания здесь называется watch_records

--1.	Кол-во просмотров по дням суммарно на двух платформах - 10 и 11
select toDate(show_date) as watch_date, count(watch_id) as watch_count from watch_records
where platform in (10,11)
group by watch_date;

--2.	Кол-во пользователей, смотревших контент в двух разных paid_type за месяц по всем платформам
select  count(user_id) from (select user_id from watch_records 
					  -- за прошедшие 30 дней:
					  -- where toDate(show_date) between today() - interval '30' day and yesterday()
					  
					  -- за текущий месяц:
					  where toStartOfMonth(show_date) = toStartOfMonth(today())
					  group by user_id
					  having count(distinct paid_type)=2) users;

--3.	Доля просмотров более 5 минут от всех просмотров за месяц  
select toDecimal32(countIf(watch_id , 
						   show_duration >300 -- просмотры по 5 минут
						   and toStartOfMonth(show_date) = toStartOfMonth(today()) ) -- за текущий месяц
					/
					(select countIf(watch_id,
						   			toStartOfMonth(show_date) = toStartOfMonth(today()) ) 
						   			from watch_records), -- общее число просмотров за текущий месяц
					2) -- округление в toDecimal
					as ratio
from watch_records;

--4.	Суммарная длительность смотрения с разбиением по всем типам кампаний на платформе 583 за последние 30 дней
select campagin,
	   sumIf(show_duration, 
			 platform=583 
			 and toDate(show_date) between today() - interval '30' day and yesterday()) -- прошедшие 30 дней
			 -- за последние 30 дней включая сегодня: toDate(show_date) > today() - interval '30'
from watch_records
group by campaign;

--5.	Список пользователей, просматривавших paid_type = SVOD более одного раза за сегодня
select user_id from watch_records
where paid_type = 'SVOD' 
and toDate(show_date) = today()
group by user_id
having count(user_id)>1;

--6.       Список пользователей, у которых за сегодня был сначала просмотр с органики, а потом с директа

-- первый вариант: по документации должен работатть, а по факту neighbor() залезает и в фильтрацию и во внешнем запросе тоже 
select distinct user_id from (select user_id, 
							neighbor(user_id, 1)  as lead_user_id,
						    campaign,
						    neighbor(campaign, 1) as lead_campaign 
						    from (select user_id, campaign from watch_records
						    	  where toDate(show_date) = today()
						    	  order by user_id, show_date 
						    	  ) ordered_records
						    ) campaigns
where user_id = lead_user_id -- замена partition
and campaign='organic' and lead_campaign='direct';

-- второй вариант: дополнительные костыли, но вроде выдает что надо
select distinct user_id -- финальный список пользователей
from (select user_id, campaign x, lead_campaign y -- по x и y будем делать фильтрацию результатов
	  from (select user_id, 
				neighbor(user_id, 1, null)  as lead_user_id, -- для partition
				campaign,
				neighbor(user_id, 1, null) as lead_campaign -- следующий просмотр
			from (select user_id, campaign from watch_records
					order by user_id , show_date) ordered_records -- упорядоченная таблица для neighbor()
					) leads 
				where user_id = lead_user_id ) super_table -- замена partition
where toString(tuple(x,y)) = '(\'organic\',\'direct\')'; -- конечная фильтрация