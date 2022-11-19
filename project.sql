

/*Q1 */
/* Topic: CASE + GROUP BY
Task: Write a query that gives an overview of how many films have replacements costs in the following cost ranges
low: 9.99 - 19.99,medium: 20.00 - 24.99,high: 25.00 - 29.99.
Question: How many films have a replacement cost in the "low" group?*/

 SELECT COUNT(*) ,
 CASE 
 WHEN replacement_cost >= 9.99 AND replacement_cost <= 19.99 THEN 'LOW'
 WHEN replacement_cost >= 20.00 AND replacement_cost <=24.99 THEN 'MEDIUM'
 WHEN replacement_cost >= 25.00 AND replacement_cost <= 29.99 THEN 'HIGH'
 END AS cost_category
 FROM film
 GROUP BY cost_category;
 
 /*Q2 */
 /*
Topic: JOIN
Task: Create a list of the film titles including their title, length and category name ordered descendingly by the length. Filter the results to only the movies in the category 'Drama' or 'Sports'.
Question: In which category is the longest film and how long is it?*/

 SELECT title, length,name FROM film f
INNER JOIN film_category fc -- film-->film_category-->category
ON f.film_id = fc.film_id
INNER JOIN category c
ON c.category_id = fc.category_id
WHERE name =  'Drama' OR name = 'Sports'
ORDER BY length DESC;

/*Q3*/
/*
Topic: JOIN & GROUP BY
Task: Create an overview of how many movies (titles) there are in each category (name).
Question: Which category (name) is the most common among the films?
Answer: Sports with 74 titles */

 SELECT name,COUNT(*) FROM film f
INNER JOIN film_category fc -- film-->film_category-->category
ON f.film_id = fc.film_id
INNER JOIN category c
ON c.category_id = fc.category_id
GROUP BY name
ORDER BY COUNT(*) DESC;

/*Q4*/
/* 
Topic: JOIN & GROUP BY
Task: Create an overview of the actors first and last names and in  how many movies they appear.
Question: Which actor is part of most movies?
Answer: Susan Davis with 54 movies*/

SELECT first_name,last_name,COUNT(*) AS appear_in_movies FROM actor a
INNER JOIN film_actor fa
ON fa.actor_id = a.actor_id
INNER JOIN film f
ON f.film_id = fa.film_id
GROUP BY first_name,last_name
ORDER BY COUNT(*) DESC;

/*Q5*/
/*

Topic: JOINS & FILTERING
Task: Create an overview of the addresses that are not associated to any customer.
Question: How many addresses are that?
Answer: 4*/

SELECT * FROM customer c 
FULL OUTER JOIN  address a
ON a.address_id = c.address_id
WHERE c.address_id IS NULL;


/*Q6*/
/*
Topic: JOIN & GROUP BY
Task: Create an overview of the revenue (sum of amount) grouped by a column in the format "country, city".
Question: Which country, city has the least sales?
Answer: United States, Tallahassee with a total amount of 50.85.*/

SELECT city,SUM(amount),country FROM payment p
INNER JOIN customer c
ON p.customer_id = c.customer_id
INNER JOIN address a
ON a.address_id = c.address_id
INNER JOIN city ci
ON a.city_id = ci.city_id
INNER JOIN country cu
ON ci.country_id = cu.country_id
GROUP BY city,country
ORDER BY sum(amount) ;

/*Q7*/
/*
Topic: Uncorrelated subquery
Task: Create a list with the average of the sales amount each staff_id has per customer.
Question: Which staff_id makes in average more revenue per customer?
Answer: staff_id 2 with an average revenue of 56.64 per customer.*/
 
SELECT staff_id,ROUND(AVG(totall),2) FROM
(SELECT staff_id,customer_id,sum(amount) AS totall FROM payment
GROUP BY staff_id,customer_id) SUB
GROUP BY staff_id;
 
/*Q8*/
/*
Level: Difficult to very difficult
Topic: EXTRACT + Uncorrelated subquery
Task: Create a query that shows average daily revenue of all Sundays.
Question: What is the daily average revenue of all Sundays?
Answer: 1536.02 */

SELECT ROUND(AVG(totall),2)
FROM (SELECT DATE(payment_date),sum(amount) AS totall,
EXTRACT (dow from payment_date) 
FROM payment
WHERE EXTRACT (dow from payment_date)  = 0
GROUP BY DATE(payment_date),EXTRACT (dow from payment_date)) sub;

/*Q9*/
/*

Topic: Correlated subquery
Task: Create a list of movies - with their length and their replacement cost - 
that are longer than the average length in each replacement cost group.
Question: Which two movies are the shortest in that list and how long are they?
Answer: CELEBRITY HORN and SEATTLE EXPECATIONS with 110 minutes.
*/
SELECT title,length,replacement_cost
FROM film f1
WHERE length  >
(SELECT AVG(length)
FROM film f2
WHERE f1.replacement_cost = f2.replacement_cost) 
ORDER BY length;

/* Q10*/
/*Level: Very difficult
Task: Create a list that shows how much the average customer spent in total (customer life-time value)
grouped by the different districts.
Question: Which district has the highest average customer life-time value?
Answer: Saint-Denis with an average customer life-time value of 216.54.
*/
SELECT district,ROUND(AVG(totall),2) AS totall FROM
(SELECT p.customer_id,sum(amount) AS totall,a.district FROM payment P
INNER JOIN customer c 
ON P.customer_id = c.customer_id
INNER JOIN address a
ON a.address_id = c.address_id
GROUP BY  p.customer_id,a.district) SUB
GROUP BY district
ORDER BY totall DESC;

/*Q11*/
/*Level: Very difficult
Task: Create a list that shows all payments including the payment_id,
amount and the film category (name) plus the total amount that was made in this category.
Order the results ascendingly by the category (name) and as second order criterion by the payment_id ascendingly.
Question: What is the total revenue of the category 'Action' and what is the lowest payment_id in that category 'Action'?
Answer: Total revenue in the category 'Action' is 4375.85 and the lowest payment_id in that category is 16055.*/

SELECT name,payment_id,amount,title,
/* sum of the amount that made in each of the category */
(SELECT SUM(amount) FROM payment p
INNER JOIN rental r 
ON p.rental_id=r.rental_id
INNER JOIN inventory i
ON r.inventory_id = i.inventory_id
INNER JOIN film f
ON f.film_id = i.film_id
INNER JOIN film_category fc
ON fc.film_id = f.film_id
INNER JOIN category c
ON c.category_id = fc.category_id 
WHERE c.name = ca.name) -- correlated subqueries end
FROM payment p
INNER JOIN rental r --rental-->inventory-->film-->film_category-->category
ON p.rental_id=r.rental_id
INNER JOIN inventory i
ON r.inventory_id = i.inventory_id
INNER JOIN film f
ON f.film_id = i.film_id
INNER JOIN film_category fc
ON fc.film_id = f.film_id
INNER JOIN category ca
ON ca.category_id = fc.category_id 
ORDER BY name ASC,payment_id ASC