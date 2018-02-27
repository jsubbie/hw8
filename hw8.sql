
SELECT * FROM actor; 

-- 1a Display the first and last names of all actors from the table `actor`. 
SELECT first_name, last_name FROM actor;

-- 1b Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`. 
SELECT concat(first_name, ' ', last_name) 
AS Full_Name
From actor;

-- 2a You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
SELECT actor_id, first_name, last_name 
FROM actor
WHERE 
first_name = 'joe';

-- 2b Find all actors whose last name contain the letters `GEN`:
SELECT actor_id, first_name, last_name 
FROM actor
WHERE 
last_name LIKE '%GEN%';

-- 2c Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:
SELECT first_name, last_name
FROM actor
WHERE first_name LIKE '%LI%'
GROUP BY last_name, first_name;

-- 2d Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id, country FROM country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

-- 3a Add a `middle_name` column to the table `actor`. Position it between `first_name` and `last_name`. Hint: you will need to specify the data type.
ALTER TABLE actor
ADD middle_name VARCHAR(50); 
  -- there doesn't seem to be a specific way to specify the location upon insertion, however, the table can still be called in the correct order with a standard query 
SELECT first_name, middle_name, last_name FROM actor; 

-- 3b You realize that some of these actors have tremendously long last names. Change the data type of the `middle_name` column to `blobs`.
ALTER TABLE actor 
MODIFY COLUMN middle_name BLOB;

-- 3c Now delete the `middle_name` column.
ALTER TABLE actor DROP COLUMN middle_name;

-- 4a List the last names of actors, as well as how many actors have that last name.
SELECT last_name, count(*)
FROM actor
WHERE last_name = last_name
GROUP BY last_name; 

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name, count(*)
FROM actor
WHERE last_name is not null
GROUP BY last_name = '%_%_'; 

-- 4c. Oh, no! The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`, the name of Harpo's second cousin's husband's yoga teacher. Write a query to fix the record.
SELECT actor_id, first_name, last_name FROM actor 
WHERE first_name='Groucho'; 

UPDATE actor
SET first_name = 'Harpo'
WHERE actor_id = 172;
  	
-- 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`. Otherwise, change the first name to `MUCHO GROUCHO`, as that is exactly what the actor will be with the grievous error. BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO `MUCHO GROUCHO`, HOWEVER! (Hint: update the record using a unique identifier.)
-- UPDATE actor
-- 	IF first_name FROM actor WHERE first_name = 'harpo' and last_name = 'williams'
-- 		SET first_name = 'Groucho' 
-- 	ELSE IF SET first_name =  'Mucho Groucho'; 
    
-- 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?

-- start by confirming that the table is gone.   
SELECT * FROM address; 
 
-- if no table, then create address table 
CREATE TABLE address(
	first_name VARCHAR(255), 
    last_name VARCHAR(255), 
    street VARCHAR (255), 
    city VARCHAR(255), 
    state VARCHAR(255), 
    zip_code INT(15)
);
    
-- 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:

SELECT staff.address_id, staff.first_name, staff.last_name, address.address
FROM staff
LEFT JOIN address
ON staff.address_id=address.address_id
ORDER BY staff.address_id; 


-- 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`. 

SELECT staff.staff_id, staff.first_name, staff.last_name, SUM(payment.amount) AS amount_rung_up
FROM staff
INNER JOIN payment 
ON staff.staff_id = payment.staff_id
WHERE payment_date >= '2005-08-01' and payment_date <= '2005-08-31'
GROUP BY staff_id; 
		
-- 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.

SELECT film_actor.film_id , film.title, COUNT(film_actor.actor_id) AS number_of_actors
FROM film
JOIN film_actor 
ON film.film_id = film_actor.film_id
GROUP BY film_id;  	

-- 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?

select * from inventory; 
select * from rental; 

SELECT COUNT(*)
FROM inventory
WHERE film_id IN
	(SELECT film_id
	FROM film
	WHERE title = 'Hunchback Impossible');

-- 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name:

SELECT customer.customer_id, customer.first_name, customer.last_name, SUM(payment.amount) AS payment_amount
FROM customer
JOIN payment 
ON customer.customer_id = payment.customer_id
GROUP BY customer_id
ORDER BY last_name ASC;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English. 

-- SELECT * FROM film;
-- SELECT * FROM language;

SELECT film_id, title, language_id 
FROM film
WHERE
	(title LIKE 'Q%'
	OR
	title LIKE 'K%')
AND
language_id IN (
	SELECT language_id
	FROM language
	WHERE name = 'English'
	);

-- 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
SELECT actor_id, first_name, last_name
FROM actor
WHERE actor_id IN (
	SELECT actor_id
	FROM film_actor
	WHERE film_id IN (
		SELECT film_id
		FROM film
		WHERE title = 'Alone Trip'
		)
	);
    
-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.

SELECT customer.first_name, customer.last_name, customer.email
FROM customer
JOIN address ON
customer.address_id = address.address_id
JOIN city ON
address.city_id = city.city_id
JOIN country ON
city.country_id = country.country_id
WHERE country.country = 'Canada';


-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as famiy films.

SELECT film_id, title
FROM film
WHERE film_id IN (
	SELECT film_id
	FROM film_category
	WHERE category_id IN (
		SELECT category_id
		FROM category
		WHERE name = 'Family'
		)
	);

-- 7e. Display the most frequently rented movies in descending order.

SELECT inventory.film_id, film.title, COUNT(rental.inventory_id) AS rental_count
FROM inventory
JOIN rental ON
inventory.inventory_id = rental.inventory_id
JOIN film ON 
film.film_id = inventory.film_id
GROUP BY film_id
ORDER BY rental_count DESC;
  	
-- 7f. Write a query to display how much business, in dollars, each store brought in.

SELECT customer.store_id, SUM(payment.amount) AS total_payment
FROM customer
JOIN payment ON
customer.customer_id = payment.customer_id
GROUP BY store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.

SELECT store.store_id, city.city, country.country
FROM store
JOIN address 
ON store.address_id = address.address_id
JOIN city 
ON address.city_id = city.city_id
JOIN country 
ON city.country_id = country.country_id;
  	
-- 7h. List the top five genres in gross revenue in descending order. (**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
 
SELECT category.name AS Film_Category, SUM(payment.amount) as gross_sum
FROM category
JOIN film_category 
ON category.category_id = film_category.category_id
JOIN inventory 
ON film_category.film_id = inventory.film_id
JOIN rental 
ON inventory.inventory_id = rental.inventory_id
JOIN payment 
ON rental.rental_id = payment.rental_id
GROUP BY name
ORDER BY gross_sum DESC
LIMIT 5;

 
-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.

CREATE VIEW gross_sum_by_category
AS
SELECT category.name AS Film_Category, SUM(payment.amount) as gross_sum
FROM category
JOIN film_category 
ON category.category_id = film_category.category_id
JOIN inventory 
ON film_category.film_id = inventory.film_id
JOIN rental 
ON inventory.inventory_id = rental.inventory_id
JOIN payment 
ON rental.rental_id = payment.rental_id
GROUP BY name
ORDER BY gross_sum DESC
LIMIT 5;

  	
-- 8b. How would you display the view that you created in 8a?

SELECT * FROM gross_sum_by_category;

-- 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it. 
  
DROP VIEW gross_sum_by_category;






