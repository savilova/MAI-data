--1.	���-�� ���������� �� ���� �������� �� ���� ���������� - 10 � 11
select count(*) from watch_records
where platform in (10,11)
group by date_trunc('day', show_date);

--2.	���-�� �������������, ���������� ������� � ���� ������ paid_type �� ����� �� ���� ����������
select count(distinct user_id) from watch_records
where date_trunc('day', show_date) >= now() - interval '30' day
group by user_id
having count(distinct paid_type)=2;

--3.	���� ���������� ����� 5 ����� �� ���� ���������� �� �����  
select count(*), 
	   concat(100*count(*)/(select count(*) 
	   from watch_records 
	   where date_trunc('day', show_date) >= now() - interval '30' day), ' %') as ratio
	   from watch_records
where show_duration>600 and date_trunc('day', show_date) >= now() - interval '30' day;

--4.	��������� ������������ ��������� � ���������� �� ���� ����� �������� �� ��������� 583 �� ��������� 30 ����
select sum(show_duration) from watch_records
where platform = 583 and date_trunc('day', show_date) > now() - interval '30' day
group by campaign;

--5.	������ �������������, ��������������� paid_type = SVOD ����� ������ ���� �� �������
select user_id  from watch_records
where paid_type = 'SVOD' and date_trunc('day', show_date) = date_trunc('day', now()) 
group by user_id
having count(*)>1;

--6.       ������ �������������, � ������� �� ������� ��� ������� �������� � ��������, � ����� � �������

with t as (select user_id, campaign, lead(campaign, 1) over(partition by user_id order by show_date) as lead_campaign from watch_records
where date_trunc('day', show_date)= date_trunc('day', now()))
select user_id from t
where campaign='organic' and lead_campaign='direct';
