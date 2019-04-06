-- Initiate sakila db
use sakila;

-- 1a. Display the first and last names of all actors from the table actor.
select * from actor;
select first_name, last_name from actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
-- add column Actor_name
alter table actor
add column Actor_name varchar(100) after actor_id;

-- Concat first and last name column into Actor Name column
update actor
set Actor_name = upper(concat(first_name,' ', last_name));


-- 2a. Find joe the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe".
select actor_id, first_name, last_name from actor
where first_name = "Joe";

-- 2b. Find actors with last name containing "GEN"
select actor_id, Actor_name from actor
where last_name like "%GEN%";

-- 2c. Find actors with last name containing "LI" order by last and first name
select * from actor
where last_name like "%LI%"
order by last_name, first_name;

-- 2d. Using IN, display country_id and country of 3 countries
select country_id, country from country
where country in ("Afghanistan", "Bangladesh" , "China");

-- 3a. Create column called description and use type blob
alter table actor
add column description blob after Actor_name;

-- 3b. Delete description column
alter table actor
drop column description;

-- 4a. List last name and count
select last_name, count(last_name) as Count_lastname from actor
group by last_name;

-- 4b. List last name and count with at least 2 per name
select last_name, count(last_name) as Count_lastname from actor
group by last_name
having count(last_name)>1;

-- 4c. Harpo williams entered wrongly as groucho williams. fix it
update actor
set first_name = "HARPO"
where Actor_name = "GROUCHO WILLIAMS";

-- 4d. Change it back with single query
update actor
set first_name = "GROUCHO"
where first_name = "HARPO";

-- 5a. Re-create the address table
show create table address;

-- 6a. Join to display the first and last names, as well as address of staff & address
-- note that address_id is common between two tables, so we can use "using()"
select a.address, s.first_name, s.last_name
from staff as s
inner join address as a
using (address_id);

-- 6b. Join to display total amount rung up by each staff in August 2005, staff & payment
select s.username, sum(p.amount) as "Total amount in August-2005"
from payment as p
inner join staff as s
using(staff_id)
where payment_date like "2005-08%"
group by p.staff_id;

-- 6c. Use tables film_actor and film inner join, list each film and number of actors 
select f.title, count(fa.actor_id) as "Number of Actors"
from film as f
inner join film_actor as fa
using(film_id)
group by fa.film_id;

-- 6d.  How many copies of the film Hunchback Impossible exist in the inventory system?
select count(film_id) as "Count of Hunchback Impossible copies"
from inventory 
where film_id in 
(select film_id from film where title="Hunchback Impossible");

-- 6e. Join payment and customer, list total paid by each customer, list alphabetially
select c.first_name, c.last_name, sum(p.amount) as "Total Amount Paid"
from payment as p
join customer as c
using (customer_id)
group by p.customer_id
order by c.last_name;

-- 7a. Use subqueries to display titles of movies starting with K and Q and language =English
-- Here all these films have language_id = 1 is English.
select film.title from film
where language_id in (select language_id from language where name = "English")
and title like "K%"
or title like "Q%"; 

-- 7b. Display all actors appeared in film Alone Trip
select first_name, last_name from actor
where actor_id in 
(select actor_id from film_actor
where film_id in 
(select film_id from film
where title = "Alone Trip")
);

-- 7c. For Email marketing campaign in Canada, names and email of all Canadian customers arec needed. Using join to retrieve
select c.first_name, c.last_name, c.email 
from customer as c
inner join address as a on c.address_id = a.address_id
inner join city on a.city_id = city.city_id
inner join country on city.country_id = country.country_id
where country.country = "Canada";

-- 7d. Identify all movies categorized as family films
select f.title from film as f
where film_id in 
(select film_id from film_category
where category_id in 
(select category_id from category 
where name = "Family"));

-- 7e. Display the most frequently rented movies in descending order.
select f.title, count(r.inventory_id) as "Rental Count" from film as f
inner join inventory as i using(film_id)
inner join rental as r using (inventory_id)
group by f.film_id
order by count(r.inventory_id) desc;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
select c.store_id , sum(p.amount) as "Business in Dollar"
from payment as p
inner join customer as c using(customer_id)
group by c. store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
select s.store_id,  city.city, country.country from store as s
inner join address as a using(address_id)
inner join city using (city_id)
inner join country using (country_id);

-- 7h. List the top five genres in gross revenue in descending order. 
-- (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
select category.name as "Genre", sum(p.amount) as "Gross Revenue"
from category 
inner join film_category as fc using (category_id)
inner join inventory as i using (film_id)
inner join rental as r using (inventory_id)
inner join payment as p using (rental_id)
group by category.name
order by sum(p.amount) desc
limit 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing 
-- the Top five genres by gross revenue. Use the solution from the problem above to create a view. 
-- If you haven't solved 7h, you can substitute another query to create a view.
create view `Top 5 Gross Revenue Genres` as
select category.name as "Genre", sum(p.amount) as "Gross Revenue"
from category 
inner join film_category as fc using (category_id)
inner join inventory as i using (film_id)
inner join rental as r using (inventory_id)
inner join payment as p using (rental_id)
group by category.name
order by sum(p.amount) desc
limit 5;

-- 8b. Display the view that was created in 8a?
select * from  `Top 5 Gross Revenue Genres`;

-- 8c. If you find that you no longer need the view top_five_genres. Write a query to delete it.
drop view `Top 5 Gross Revenue Genres`;
