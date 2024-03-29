-- Team 8 
-- uta ids:1001933530, 1001945949
-- name:adit shah, jaykumar patel
-- Finding age 
--select round(((sysdate-DOB)/365)) as age from F21_S001_8_PERSON;


--having/group by
--1)for how many hours does a member plays the sports.could be found out on the basis of the time duration between the equipment check in and equipment 
--checkout.Then taking sum of all the such hours for a particular member
select fname, lname,email_id, hours from F21_S001_8_PERSON p join 
(
	Select mac.member_id,(mac.EQUIPMENT_CHECKOUT-mac.EQUIPMENT_CHECKIN) as hours,m.email_id as email
	from F21_S001_8_MEMBER_ACTIVITY mac, F21_S001_8_MEMBER m
	where mac.member_id=m.member_id
)on email=p.email_id
group by fname, lname, email_id,hours;
--2)retrives the employees whoes salarys is greater than average salary
select SALARY, EMPLOYEE_ID from F21_S001_8_EMPLOYEE
group by EMPLOYEE_ID,SALARY
having salary>=
(select avg(salary) from F21_S001_8_EMPLOYEE);
--3)retrives out all the details about employee whoes salary is more than 20 and sex is female i.e f
SELECT FNAME, LNAME, SALARY 
FROM F21_S001_8_EMPLOYEE E, F21_S001_8_PERSON P
where SEX='F' AND P.EMAIL_ID=E.EMAIL_ID AND E.EMAIL_ID IN 
(
	SELECT EMAIL_ID FROM F21_S001_8_EMPLOYEE WHERE SALARY>20
)
GROUP BY FNAME,LNAME,SALARY;

--rollup/cube
--1)gives us different combination of statistic of different attributes
Select ts.event_id,(ts.sales*ts.price) as revenue,ts.price as sells 
from F21_S001_8_SPORTS_SCHEDULE ss join F21_S001_8_EVENT_TICKET_SALES ts on ss.event_id=ts.event_id  
group by rollup(ts.SALES ,ts.PRICE,ts.event_id);
--2)means: gives us analysis about each gender, plan and cost seperately and cumilatively as well
select sex, m.plan_id,cost
from F21_S001_8_PERSON p, F21_S001_8_MEMBER m ,F21_S001_8_MEMBERSHIP_PLAN mp
where p.email_id=m.email_id AND m.plan_id=mp.plan_id
GROUP by cube(sex,m.plan_id,cost);

--over
--1)
--mean:gives us the total amount of revenue generated by each sport from the ticket sells of those events
Select sd.sport_id,sum(ts.sales)  
over (order by sd.event_id) as sells 
from F21_S001_8_SPORTS_SCHEDULE sd join F21_S001_8_EVENT_TICKET_SALES ts 
on sd.event_id=ts.event_id;
--2)
--mean:statistics of popular membership plan, how popluar each membership plan is, how many people has taken the plans
Select DESCRIPTION,count(mp.plan_id) 
over(order by DESCRIPTION ) as TOTAL_MEMBERS  
from F21_S001_8_MEMBER m join F21_S001_8_MEMBERSHIP_PLAN mp  
On m.plan_id=mp.plan_id 
group by mp.plan_id,DESCRIPTION  ORDER BY TOTAL_MEMBERS DESC;

--few other complex queries that we tired in order to implement all 
--query:taking out the information about employee who has his salary greater than 40 and is sex is female, and fetcing information from other table
SELECT FNAME, LNAME, SALARY ,(
		select round(((sysdate-DOB)/365))  from  F21_S001_8_PERSON  where email_id=e.email_id
	) as Age 
FROM F21_S001_8_EMPLOYEE E, F21_S001_8_PERSON P
WHERE SEX='F' AND P.EMAIL_ID=E.EMAIL_ID AND E.EMAIL_ID IN 
(SELECT EMAIL_ID FROM F21_S001_8_EMPLOYEE WHERE SALARY>20) ;

--query:taking out the information about the employee who is a manager, who has handled the events organized
SELECT distinct e.employee_id,p.fname,p.lname,p.apartment_number,p.street,p.city,p.state,p.zip,p.dob,p.sex, round(((sysdate-p.DOB)/365)) as age, SALARY from 
(select event_manager_id as emi from F21_S001_8_SPORTS_SCHEDULE)  , F21_S001_8_EMPLOYEE e, F21_S001_8_PERSON p
WHERE e.employee_id=emi and p.email_id=e.email_id;
