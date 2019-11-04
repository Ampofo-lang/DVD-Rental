/*1.Overdue DVD in the Sakila Database*/
SELECT CONCAT(c.last_name, ' ', c.first_name) AS customer,
        a.phone, f.title ,
        c.create_date,
        c.last_update
FROM rental r
        JOIN customer c
        ON r.customer_id = c.customer_id
        JOIN address a
        ON c.address_id = a.address_id
        JOIN inventory i
        ON r.inventory_id = i.inventory_id
        JOIN film f
        ON i.film_id = f.film_id
WHERE r.return_date IS NULL
        AND rental_date + INTERVAL f.rental_duration DAY < CURRENT_DATE()
LIMIT 10;


/*2.The sum of the first 7 highest customer’s Payment and average*/
WITH t1 AS (SELECT *, first_name || ' ' || last_name AS full_name
		    FROM customer)
SELECT first_name,
       last_name, email,
       address,
       phone,
       country,
       sum(amount) AS total_amt_currency,
       AVG(amount) AS avg_amount
FROM t1
      JOIN address
      USING(address_id)
      JOIN city
      USING (city_id)
      JOIN country
      USING (country_id)
      JOIN payment
      USING(customer_id)
      GROUP BY 1
      ORDER BY 7 DESC}
LIMIT 7;


/*3.The number of top 10 customers in each country, the total sales and the presence rent film */
SELECT country,
        COUNT(DISTINCT customer_id) AS country_customerBase
        SUM(amount) AS total_sales
FROM country
        INNER JOIN city
        USING (country_id)
        INNER JOIN address
        USING (city_id)
        INNER JOIN customer
        USING(address_id)
        INNER JOIN payment
        USING (customer_id)
        GROUP BY 1
        ORDER BY 3 DESC
        LIMIT 10;


  /*4.Which film title has the highest  the total rental duration as well as average film rate?*/
SELECT  f.title,
        f.rental_duration,
        AVG(f.rental_rate) AS avg_rental_rate,
        f.description,
        l.name,
  		  SUM(rental_duration)OVER(PARTITION BY l.name) AS total_duration
FROM film  f
        JOIN language l
        ON f.film_id = l.language_id
        GROUP BY 1,2
        ORDER BY rental_duration DESC;


/*What are the most requested genre and their total sales?*/
WITH t1 AS (SELECT c.name AS Type_of_Genre, COUNT(ct.customer_id) AS Total_rent_requested
        FROM category c
        JOIN film_category fc
        USING(category_id)
JOIN film f
        USING(film_id)
        JOIN inventory i
        USING(film_id)
        JOIN rental r
        USING(inventory_id)
        JOIN customer ct
        USING(customer_id)
        GROUP BY 1
        ORDER BY 2 DESC),
t2 AS (SELECT c.name AS Type_of_Genre, ROUND(SUM(p.amount)) AS Total_sales
        FROM category c
        JOIN film_category fc
        USING(category_id)
        JOIN film f
        USING(film_id)
        JOIN inventory i
        USING(film_id)
        JOIN rental r
        USING(inventory_id)
        JOIN payment p
        USING(rental_id)
        GROUP BY 1
        ORDER BY 2 DESC)
SELECT t1.Type_of_Genre, t1.Total_rent_requested, t2.Total_sales
        FROM t1
        JOIN t2
        ON t1.Type_of_Genre = t2.Type_of_Genre;
