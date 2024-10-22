--senior most employee based on job title

select * from employee
ORDER BY levels desc
limit 1

--which country have the most invoices

select COUNT(*) as c, billing_country
from invoice
group by billing_country
order by c desc

--what are the top 3 values of total invoice

SELECT total FROM invoice 
order by total desc
limit 3

--which city has the best customers? we would like to throw a we made the most money.
--write a query that returns onbe city that return both the city name & sum of all invoice totals

select SUM(total) as invoice_total , billing_city
from invoice
group by billing_city
order by invoice_total desc

-- who is the best customer? the customer who has spend the most money will be declared the best customer.


select customer.customer_id, customer.first_name, customer.last_name, SUM(invoice.total) as total
from customer
JOIN invoice ON customer.customer_id = invoice.customer_id
GROUP BY customer.customer_id
ORDER BY total DESC 
limit 1

-- write query to return the email, first name, last name, & genere of all rock music listeners.
--return your list ordered alphabetically by email starting with A

select distinct email,first_name, last_name
from customer
JOIN invoice ON customer.customer_id = invoice.customer_id
JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id
WHERE track_id IN(
    SELECT track_id FROM track
    JOIN genre ON track.genre_id = genre.genre_id
	WHERE genre.name LIKE 'Rock'
)
ORDER BY email;

-- lets invite the artist who have written the most rock music in our dataset. write a query 
--that returns the artist name and total track count of the top 10 rock bands
	
SELECT artist.artist_id, artist.name,COUNT(artist.artist_id) AS number_of_songs
FROM track
JOIN album ON album.album_id = track.album_id
JOIN artist ON artist.artist_id = album.artist_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
GROUP BY artist.artist_id
ORDER BY number_of_songS DESC
LIMIT 10;

--Return all the track names that have a song lenght longer than the average song lengh.
--return the name and milliseconds for each track. order by the song length with the
--longest songs listed first

SELECT name,milliseconds
FROM track
WHERE milliseconds > (
    SELECT AVG(milliseconds) AS avg_track_lengh
	FROM track)
ORDER BY milliseconds DESC
	
--find how much amount spent by each cusrtomer on artists? write a query to return customer 
--name, artist name and total spent
	
WITH best_selling_artist AS (
    SELECT artist.artist_id AS artist_id, artist.name AS artist_name,
	SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
    FROM invoice_line
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN album ON album.album_id = track.album_id
	JOIN artist ON artist.artist_id = album.artist_id
	GROUP BY 1
	ORDER BY 3 DESC
	LIMIT 1
)
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name,
SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;

-- We want to find out the most popular music genre for each country we determine 
--the most popular genre as the genre with the highest amount of purchase. write a query
--that returns each country along with the top genre. for countries where the maximum 
--number of purchase is shared return all genre.
	
WITH popular_genre AS
( 
    SELECT COUNT(invoice_line.quantity)AS purchases, customer.country, genre.name, genre.genre_id,
    ROW_NUMBER()   OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo
    FROM invoice_line
    JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
    JOIN customer ON customer.customer_id = invoice.customer_id
    JOIN track ON track.track_id = invoice_line.track_id
    JOIN genre ON genre.genre_id = track.genre_id
    GROUP BY 2,3,4
    ORDER BY 2 ASC, 1 DESC
)
SELECT * FROM popular_genre WHERE RowNo <= 1

--write a quary that detemine the customer that has spent the most on music for each 
 --country. write a query that returns the country along with the top customer and how much they spent. for countries where the top customer and how much they spent. for 
 --countries where the top amount spent is shared, provide all customer who spent this 
--amount
	
WITH RECURSIVE
   customer_with_country AS (
       SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending
       FROM invoice
       JOIN customer ON customer.customer_id = invoice.customer_id
       GROUP BY 1,2,3,4
       ORDER BY 2,3 DESC),
   
   country_max_spending AS(
       SELECT billing_country,MAX(total_spending) AS max_spending
	   FROM customer_with_country 
	   GROUP BY billing_country)
	  
SELECT cc.billing_country, cc.total_spending, cc.first_name, cc.last_name
FROM customer_with_country cc
JOIN country_max_spending ms
ON cc.billing_country = ms.billing_country
WHERE cc.total_spending = ms.max_spending
ORDER BY 1;