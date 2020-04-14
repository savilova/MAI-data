drop table watch_records;


create table watch_records (
watch_id varchar(50) primary key,
show_date timestamp,
show_duration int,
platform int,
user_id varchar(50),
paid_type varchar(10),
campaign varchar(30) 
);

insert into watch_records (watch_id, show_date, show_duration, platform, user_id, paid_type, campaign)
values
(10971121570,	'07.01.2018 14:37',	1340,	583,	1553139, 'AVOD',	'organic'),
(4458319751,	'12.01.2018 15:00',	12432,	353,	1554866, 'AVOD',	'organic'),
(31382550,	    '08.02.2018 14:39',	1800,	10,	    5255577, 'SVOD',	'organic'),
(11254336994,	'07.07.2017 17:56',	210,	11,	    1262419, 'AVOD',	'organic'),
(1231646730,	'01.01.2016 12:48',	4685,	11,	    597306,	 'SVOD',	'organic'),
(4212172051,	'12.08.2018 10:52',	472,	11,	    2852753, 'AVOD',	'organic'),
(8909218338,	'09.05.2017 0:55',	297,	583,	9462609, 'AVOD',	'direct'),
(1904761857,	'24.09.2018 19:31',	1635,	9,	    320756,	 'TVOD',	'organic'),
(17947987,	    '30.10.2018 4:45',	854,	353,	1547421, 'AVOD',	'referral'),
(6077839073,	'07.12.2017 23:58', 4571,	353,	4066590, 'AVOD',	'organic');



insert into watch_records (watch_id, show_date, show_duration, platform, user_id, paid_type, campaign)
values
(6077839075,	'2020-04-14 10:55:51', 4571,	353,	4066590, 'AVOD',	'organic'),
(6077839083,	'2020-04-14 15:55:51', 4571,	353,	4066590, 'AVOD',	'direct');

insert into watch_records (watch_id, show_date, show_duration, platform, user_id, paid_type, campaign)
values
(6077839900,	'2020-04-04 15:55:51', 4571,	353,	4066590, 'SVOD',	'direct');

