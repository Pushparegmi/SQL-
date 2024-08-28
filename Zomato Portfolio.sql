drop table if exists goldusers_signup;
CREATE TABLE goldusers_signup(userid integer,gold_signup_date date); 

INSERT INTO goldusers_signup(userid,gold_signup_date) 
 VALUES (1,'09-22-2017'),
(3,'04-21-2017');

drop table if exists users;
CREATE TABLE users(userid integer,signup_date date); 

INSERT INTO users(userid,signup_date) 
 VALUES (1,'09-02-2014'),
(2,'01-15-2015'),
(3,'04-11-2014');

drop table if exists sales;
CREATE TABLE sales(userid integer,created_date date,product_id integer); 

INSERT INTO sales(userid,created_date,product_id) 
 VALUES (1,'04-19-2017',2),
(3,'12-18-2019',1),
(2,'07-20-2020',3),
(1,'10-23-2019',2),
(1,'03-19-2018',3),
(3,'12-20-2016',2),
(1,'11-09-2016',1),
(1,'05-20-2016',3),
(2,'09-24-2017',1),
(1,'03-11-2017',2),
(1,'03-11-2016',1),
(3,'11-10-2016',1),
(3,'12-07-2017',2),
(3,'12-15-2016',2),
(2,'11-08-2017',2),
(2,'09-10-2018',3);


drop table if exists product;
CREATE TABLE product(product_id integer,product_name text,price integer); 

INSERT INTO product(product_id,product_name,price) 
 VALUES
(1,'p1',980),
(2,'p2',870),
(3,'p3',330);


select * from sales;
select * from product;
select * from goldusers_signup;
select * from users;

--(1)What is the total amount each customer spent on zomato?

Select a.userid, b.product_id,b.price
From sales as a
inner join product as b
on a.product_id=b.product_id

Select a.userid,sum(b.price)as TotalSpent
from sales a
Inner join product as b 
on a.product_id=b.product_id
group by a.userid
order by TotalSpent desc

--(2)how many days each customer visited zomato

select a.userid,count(distinct(a.created_date))
from sales a
group by a.userid

--(3)What was the first product purchased by each customer

SElect * ,rank() over(partition by userid order by created_date)as Ranking
From sales 

--(4)for the first product purchased for all userid the ranking has to be 1

SElect * from
(SElect * ,rank() over(partition by userid order by created_date)as Ranking
From sales ) a
where Ranking=1

--(5)what is the most purchased item in the menu and how many times was i purchased by all customers
--1st part (the most purchased item on the menu)

SElect product_id, Count(product_id)as productcount
from sales
group by product_id
order by productcount desc

select top(1) product_id from sales group by product_id order by Count(product_id) desc

--2nd part(how many times it was purchased by all Customers)

select userid,count(product_id) cnt from sales where product_id= (select top(1) product_id from sales group by product_id order by Count(product_id) desc)
group by userid

--(6)which item was the most popular for each customer

SElect userid,product_id,Count(product_id)as CNT 
From sales  
group by userid,product_id

SElect * from 
(select *,rank() over(partition by userid order by CNT desc)as RNK 
from (SElect userid,product_id,Count(product_id)as CNT 
From sales  
group by userid,product_id)a)b
where RNK=1


--(7)which item was purchased first by the customer after they became a member?

select * from(select c.*, rank() over (partition by userid order by created_date) as Rnk
from (SElect s.userid,s.created_date,gm.gold_signup_date,s.product_id
from sales s
Inner Join goldusers_signup gm
on s.userid=gm.userid
and s.created_date>= gm.gold_signup_date)as c)as d
where Rnk=1

--(8) Which item was purchased just before the customer became a member?

SElect t.* from(SElect s.*,rank() over(partition by userid order by created_date desc) RNK
from (SElect s.userid,s.created_date,gm.gold_signup_date,s.product_id
from sales s
Inner Join goldusers_signup gm
on s.userid=gm.userid
and s.created_date<=gm.gold_signup_date) s)t where RNK =1

--(9)what is the total orders and amount spent for each member before they became a member?

Select userid,count(created_date) Totalorders,sum(price)Totalspent from(SElect c.*,p.price  from (SElect s.userid,s.created_date,gm.gold_signup_date,s.product_id
from sales s
Inner Join goldusers_signup gm
on s.userid=gm.userid
and s.created_date<=gm.gold_signup_date)c
inner join product p
on c.product_id=p.product_id)m
group by userid

--(10) If buying each product generates points for eg 5 Rs = 2 Zomato Pts and each product has different purchasing points 
--for eg for P1 5Rs=1 Zomato Pt, for P2 10 Rs=5 Zomato Pts and P3 5Rs=1 Zomato Pt, 
--Calculate points collected by each customer and  for which product most points have been given till now

SElect e.*, Cast(Sum*ZomatoPOints as int) as Totalpointsearned 
From 
(select d.*,case when d.product_id=1 then 0.2 when product_id=2 then  0.5  when product_id=3 then 0.2 else 0 end as ZomatoPoints
from(Select s.userid, s.product_id,sum(p.price)Sum
FRom sales s
Inner join product p
on s.product_id=p.product_id
group by s.userid,s.product_id)d)e

--Part 1 Calculate points collected by each customer

 SElect userid, sum(Totalpointsearned)Pointstotal
from(SElect e.*, Cast(Sum*ZomatoPOints as int) as Totalpointsearned 
From 
(select d.*,case when d.product_id=1 then 0.2 when product_id=2 then  0.5  when product_id=3 then 0.2 else 0 end as ZomatoPoints
from(Select s.userid, s.product_id,sum(p.price)Sum
FRom sales s
Inner join product p
on s.product_id=p.product_id
group by s.userid,s.product_id)d)e) f
group by userid

--Total earned by each customer as cashback for points

SElect product_id, sum(Totalpointsearned)Pointstotal
from(SElect e.*, Cast(Sum*ZomatoPOints as int) as Totalpointsearned 
From 
(select d.*,case when d.product_id=1 then 0.2 when product_id=2 then  0.5  when product_id=3 then 0.2 else 0 end as ZomatoPoints
from(Select s.userid, s.product_id,sum(p.price)Sum
FRom sales s
Inner join product p
on s.product_id=p.product_id
group by s.userid,s.product_id)d)e)f
group by product_id

--Part 2 For which product most poins have been given till now

select product_id 
from(SElect *,rank() over(order by Pointstotal desc) Rank
from(SElect product_id, sum(Totalpointsearned)Pointstotal
from(SElect e.*, Cast(Sum*ZomatoPOints as int) as Totalpointsearned 
From 
(select d.*,case when d.product_id=1 then 0.2 when product_id=2 then  0.5  when product_id=3 then 0.2 else 0 end as ZomatoPoints
from(Select s.userid, s.product_id,sum(p.price)Sum
FRom sales s
Inner join product p
on s.product_id=p.product_id
group by s.userid,s.product_id)d)e)f
group by product_id)g)h where Rank=1

--(10) In the first one year after customer joins the gold program (including their join date ),
--irrespective of what the customer has purchased they earn 5 Zomato points for every 10 Rs spent 
--who earned more 1 or 3 and what was their points earning in their First year?

select * from sales;
select * from goldusers_signup;
select * from users;

--Total spent by each customer within a year after becoming the gold member

SElect C.*,d.price
from(SElect a.userid,a.created_date,a.product_id,b.gold_signup_date
From sales a
Inner join goldusers_signup b
on a.userid=b.userid
where created_date between gold_signup_date and DATEADD(year,1,gold_signup_date))c
inner join product d
on c.product_id=d.product_id

--Total zomato points for each customer within a year after becoming the gold member


SElect  *, (price/2)as Zomatopoints
from(SElect C.*,d.price
from(SElect a.userid,a.created_date,a.product_id,b.gold_signup_date
From sales a
Inner join goldusers_signup b
on a.userid=b.userid
where created_date between gold_signup_date and DATEADD(year,1,gold_signup_date))c
inner join product d
on c.product_id=d.product_id)e
order by Zomatopoints desc

--User_id 3 earned more points after joining the gold membership within te first year

--(11) Rank all the transaction of the customer

Select *
from(SElect *,Dense_rank() over( order by price desc) Rank
from(SElect a.userid,a.created_date,a.product_id,b.price
From sales a 
Inner join product b
on a.product_id=b.product_id)c)d 
order by Rank


--12 Rank all the transactioms for each member whenever they are a Zomato gold member 
--for every non gold member transacton mark as N/A


SElect e.*,case when Rank=0 then 'na'else Rank end as RANK
 From (SElect c.*,cast((case when gold_signup_date is null  then 0 else rank() over(partition by userid order by  created_date desc )end)as varchar) as Rank
from(SElect a.userid,a.created_date,b.gold_signup_date,a.product_id
from Sales a
Left join goldusers_signup b
on a.userid=b.userid
and created_date>=gold_signup_date)c)e 
