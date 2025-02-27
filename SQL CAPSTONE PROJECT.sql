
--1)Display the customer names that shares the same address (e.g. husband and wife)
SELECT cs.first_name, cs.last_name, ad.address, COUNT(ad.address_id) AS id
FROM customer cs
INNER JOIN address ad
ON cs.address_id = ad.address_id
GROUP BY cs.first_name, cs.last_name, ad.address
HAVING COUNT(ad.address_id)>1;
-- None of the customers share the same address--


--2)What is the name customer who made the highest total payments.
SELECT cs.first_name, cs.last_name,
SUM(py.amount) AS total
FROM customer AS cs
INNER JOIN payment AS py
ON cs.customer_id = py.customer_id
GROUP BY cs.first_name, cs.last_name
ORDER BY total DESC
LIMIT 1;



--3)What is the movie(s) that was rented the most
--Created a view
CREATE VIEW movie_rented AS
SELECT f.title, i.film_id, r.inventory_id, r.rental_id
FROM film f
INNER JOIN inventory i ON f.film_id = i.film_id
INNER JOIN rental r ON i.inventory_id = r.inventory_id;
--querying 
SELECT title, COUNT(rental_id) AS no_times_rented
FROM movie_rented
GROUP BY title
ORDER BY no_times_rented DESC
LIMIT 1;

--4)Which movie(s) have been rented so far.
SELECT title 
FROM film 
WHERE film_id IN
	(SELECT DISTINCT film_id 
	FROM rental r INNER JOIN inventory i
	 ON r.inventory_id = i.inventory_id);


--5)Which movie(s) have not been rented so far.
SELECT title 
FROM film 
WHERE film_id NOT IN
	(SELECT DISTINCT film_id 
	FROM rental r INNER JOIN inventory i
	 ON r.inventory_id = i.inventory_id);


--6)Which customer have not rented any movies so far.
SELECT c.first_name, c.last_name
FROM customer c 
LEFT JOIN rental r
ON c.customer_id = r.customer_id
WHERE rental_id IS null;


--7)Display each movie and the number of time it got rented.
SELECT f.title, COUNT(*) AS times_rented
FROM film f
INNER JOIN inventory i
ON f.film_id = i.film_id 
LEFT JOIN rental r
ON i.inventory_id = r.inventory_id
GROUP BY f.title
ORDER BY times_rented DESC;


--8)Show the first name and last name and the number of films each actor acted in.
SELECT a.first_name, a.last_name, COUNT(*) AS no_of_films_acted
FROM film f
INNER JOIN film_actor fa
ON f.film_id = fa.film_id
INNER JOIN actor a
ON fa.actor_id = a.actor_id
GROUP BY a.first_name, a.last_name
ORDER BY no_of_films_acted DESC;


--9)Display the names of the actors that acted in more than 20 movies.
SELECT a.first_name, a.last_name, COUNT(*) AS no_of_films
FROM film f
INNER JOIN film_actor fa
ON f.film_id = fa.film_id
INNER JOIN actor a
ON fa.actor_id = a.actor_id
GROUP BY a.first_name, a.last_name
HAVING COUNT(*) > 20
ORDER BY no_of_films ASC;


--10)For all the movies rated PG show me the movies and the number of times it got rented
SELECT f.title, COUNT(*) AS PG_Movies_rental_frequency
FROM film f
INNER JOIN inventory i
ON f.film_id = i.film_id 
LEFT JOIN rental r
ON i.inventory_id = r.inventory_id
WHERE f.rating ='PG'
GROUP BY f.title
ORDER BY PG_Movies_rental_frequency DESC;


--11)Display the movies offered for rent in store_id 1 and not offered in store_id 2.
SELECT DISTINCT(f.film_id), f.title
FROM film f
INNER JOIN inventory i
ON f.film_id = i.film_id
WHERE i.store_id = 1 AND i.film_id NOT IN (SELECT DISTINCT(f.film_id) FROM film f
INNER JOIN inventory i ON f.film_id = i.film_id WHERE i.store_id = 2)
ORDER BY f.film_id ASC;


--12)Display the movies offered for rent in any of the stores 1 and 2.
SELECT film_id, title
FROM film
WHERE film_id in
((SELECT film_id
FROM public.inventory
WHERE store_id=1) 
UNION
(SELECT film_id
FROM public.inventory
WHERE store_id=2))
ORDER BY film_id ASC;


--13)Display the movie titles of those movies offered in both stores at the same time.
SELECT title
FROM film 
WHERE film_id IN
(SELECT film_id
	FROM inventory
	WHERE store_id =1 AND film_id IN
	(SELECT film_id
	FROM inventory
	WHERE store_id =2));
	
	
--14)Display the movie title for the most rented movie in the store with store_id 1.
SELECT f.title,COUNT(f.film_id) AS times_rented
FROM film f
INNER JOIN inventory i
ON f.film_id = i.film_id
INNER JOIN rental r
ON r.inventory_id = i.inventory_id
WHERE store_id = 1
GROUP BY f.title
ORDER BY times_rented DESC
LIMIT 1;


--15)How many movies are not offered for rent in the stores yet. There are two stores only 1 and 2.
SELECT title 
FROM film 
WHERE film_id NOT IN
	((SELECT film_id 
	FROM inventory
	WHERE store_id = 1)
	UNION
	 	(SELECT film_id
		FROM inventory
		WHERE store_id =2));
		
		
--16)Show the number of rented movies under each rating.
SELECT f.rating, COUNT(f.rating) AS rented_Movies
FROM film f
INNER JOIN inventory i
ON f.film_id = i.film_id 
LEFT JOIN rental r
ON i.inventory_id = r.inventory_id
GROUP BY f.rating
ORDER BY rented_Movies DESC;


--17)Show the profit of each of the stores 1 and 2.
SELECT store_id, SUM(amount) AS profit
FROM payment p
INNER JOIN rental r
ON p.rental_id = r.rental_id
INNER JOIN inventory i
ON r.inventory_id = i.inventory_id
GROUP BY store_id;
