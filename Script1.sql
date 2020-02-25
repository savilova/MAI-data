-- PostgeSQL

-- ��� ������� ������� �������, � ������� ����������� ������ �� �������
create table content_watch ( watch_id varchar PRIMARY key,	show_date timestamp,	show_duration int,	platform varchar,	user_id varchar,	utm_medium varchar,	content_id varchar);
create table content_info ( content_id varchar PRIMARY key,	compilation_id varchar,	episode varchar,	paid_type char(4))

-- ������ 0: �� ������ ���� ���������� ���������� �������� �� ������������ SVOD � AVOD �� ���������� 10 � 11 �� ��������� 30 ����.

select DATE(show_date), paid_type, count(*)
from content_watch w left join content_info i on w.content_id=i.content_id 
where platform='10' or platform='11'
	and paid_type <>'TVOD'
group by date(show_date),paid_type
order by date(show_date), paid_type limit 60;


-- ������ 1: ����������� ���-5 �������� � ���-5 ���������� �������� �� ���������� ��������� �����

-- ��� ���-5 ��������
select  i.compilation_id, count(distinct user_id)
from content_watch w left join content_info i on w.content_id=i.content_id
where date_part('month', show_date)= date_part('month', now()) 
and date_part('year', show_date)= date_part('year', now()) 
and compilation_id is not null
group by i.compilation_id
order by count(distinct user_id) desc limit 5;

-- ��� ���-5 ���������� ��������
select  count(distinct user_id),i.content_id
from content_watch w left join content_info i on w.content_id=i.content_id
where date_part('month', show_date)= date_part('month', now()) 
	and date_part('year', show_date)= date_part('year', now())
	and compilation_id is null
group by i.content_id
order by count(distinct user_id) desc limit 5;

-- ������ 2: 2.	������ �������������, � ������� ����� ��� ������� �������� � organic, � ����� ������ �� ��� - �������� � referral

-- ���� ��� ���������� �������������, � ������� 1-� �������� organic, � 2-� referral

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
