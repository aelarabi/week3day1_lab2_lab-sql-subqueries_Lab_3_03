use sakila;
/*Instructions
How many copies of the film Hunchback Impossible exist in the inventory system?
List all films whose length is longer than the average of all the films.
Use subqueries to display all actors who appear in the film Alone Trip.
Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
Identify all movies categorized as family films.
Get name and email from customers from Canada using subqueries. Do the same with joins. 
Note that to create a join, you will have to identify the correct tables with their primary keys and foreign keys, 
that will help you get the relevant information.
Which are films starred by the most prolific actor? 
Most prolific actor is defined as the actor that has acted in the most number of films.
First you will have to find the most prolific actor and then use that actor_id to find the different films that he/she starred.
Films rented by most profitable customer. 
You can use the customer table and payment table to find the most profitable customer 
ie the customer that has made the largest sum of payments
Customers who spent more than the average payments.*/

-- 1) How many copies of the film Hunchback Impossible exist in the inventory system?
select * from film;
select * from inventory;

select count(film_id) as total_copies from (select fi.title, fi.film_id 
from film as fi
join inventory as inv
on fi.film_id=inv.film_id
having title='Hunchback Impossible') as sub;

-- 2) List all films whose length is longer than the average of all the films.	
select title from film
where length>(select avg(length) as 'average runtime'from film);


-- 3) Use subqueries to display all actors who appear in the film Alone Trip.
select first_name,last_name from 
(select fi.title, ac.first_name,ac.last_name
from film as fi
join film_actor as fiac
on fi.film_id = fiac.film_id
join actor as ac
on fiac.actor_id=ac.actor_id 
where title='alone trip') as sub;

-- 4) Identify all movies categorized as family films.

SELECT name as cat_name , fi.title
FROM sakila.category as cat
right JOIN sakila.film_category as f
ON cat.category_id = f.category_id
join film as fi 
on f.film_id=fi.film_id
GROUP BY fi.title
having cat_name='family';

-- 5)Get name and email from customers from Canada using subqueries. Do the same with joins.
-- with joins:
select cus.first_name,cus.last_name,cus.email,co.country
from customer as cus
join address as ad
on cus.address_id=ad.address_id
left join city as ci
on ad.city_id=ci.city_id
left join country as co
on ci.country_id=co.country_id
where co.country='canada'
group by cus.first_name;
-- having country="canada";

-- using sub quieries 

select first_name,last_name,email from customer
where address_id in (select address_id from address
where city_id in(select city_id from city 
where country_id =(
select country_id from country 
where country='canada')));

-- 6) Which are films starred by the most prolific actor?

--  could not figure out how to put these 2 in one query.. error message this version of mysql does not yet support limit & in IN/All/ANY SOME

select * from (select actor_id, count(actor_id) from film_actor
group by actor_id
having count(actor_id)
order by count(actor_id) desc) as sub
limit 1;

--  actor id 107
select title from film where film_id in ((select film_id from film_actor
where actor_id=107));
--  could not figure out how to put these 2 in one query.. error message this version of mysql does not yet support limit & in IN/All/ANY SOME

-- 7) Films rented by most profitable customer.

select customer_id , sum(amount) from payment
group by customer_id
having sum(amount)
order by sum(amount) desc
limit 1;

-- customer 526
select title from film where film_id in (select film_id from (select film_id 
from inventory as inv
join rental as rent
on inv.inventory_id=rent.inventory_id
where rent.customer_id=526) as sub);


-- 8) Customers who spent more than the average payments

select first_name, last_name from customer where customer_id in(select customer_id from 
(select customer_id, amount,avg(amount) as avg_payment from payment
group by customer_id
having amount>avg(amount))as sub);
