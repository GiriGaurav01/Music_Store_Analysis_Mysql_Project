CREATE DATABASE music_db;
use music_db;
Select * FROM album2;
-- who is the senior most employee based on job title?

select * from employee
order by levels desc
limit 1;

-- which countries have the most Invoices?

Select count(*) as c,billing_country 
from invoice
group by billing_country
order by c desc;

-- What are  top 3 values of total invoices 
select * from invoice
order by total desc
limit 3;

-- 4) Which city has the best customers? we would like to throw a promotional music festival in the city 
-- we made the most money.Write a query that returns one city that has the highest sum of invoice totals.
-- Return both the city name & sum of all the invoice totals 

Select sum(total) as c,billing_city 
from invoice
group by billing_city
order by c desc
limit 1;

-- 5) WHO IS THE BEST CUSTOMER ?THE CUSTOmER WHo HAS spent the most money will be declared the best customer
-- write a query that returns the person who has spent the most money.

Select customer.customer_id, customer.first_name, customer.last_name , sum(invoice.total) as total
from customer 
join invoice on
customer.customer_id = invoice.customer_id
group by customer.customer_id
order by total desc
limit 1;

-- 6)Write a query to return the email,firstname,lastname & genre of all rock music listeners.
-- Return your list ordered alphabetically by email starting with A;

SELECT DISTINCT email,first_name,last_name
from customer
JOIN invoice on customer.customer_id = invoice.customer_id
join invoice_line on 
invoice.invoice_id = invoice_line.invoice_id
where track_id IN(
    SELECT track_id from track
    join genre on track.genre_id = genre.genre_id
    where genre.name LIKE 'ROCK'
)
order by email;

-- 7) Lets invite the artists who have written the most rock music in our dataset. Write a query that returns 
-- the Artist name and total track count of the top 10 rock bands.

SELECT artist.artist_id,artist.name,count(artist.artist_id) as number_of_songs
from track
join album2 on album2.album_id = track.album_id
join artist on artist.artist_id = album2.artist_id
join genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
GROUP BY artist.artist_id
-- HAVING genre.name LIKE 'Rock'
ORDER by number_of_songs DESC
LIMIT 10;

SELECT DISTINCT email,first_name,last_name
from customer
join invoice on customer.customer_id = invoice.customer_id
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
where track_id IN(
   SELECT track_id from track
   join genre on track.genre_id=genre.genre_id
   where genre.name LIKE "Rock"
)
order by email;
-- 8) Return all the track name that have a song length longer than the average song length.
-- Return th name and milliseconds for each track. Order by the song lenght with the longest songs listed first.

SELECT name,milliseconds
from track
where milliseconds >
 (
  SELECT AVG(milliseconds) as avg_track_length
  from track
 )
 order by milliseconds DESC;

-- 9)Find how much amount spent by each customer on artists? Write a query toreturn customer name, artist name
-- and total spent

with best_selling_artist as
(
 select artist.artist_id as artist_id, artist.name as artist_name,
 sum(invoice_line.unit_price * invoice_line.quantity) as total_sales
 from invoice_line
 join track on track.track_id = invoice_line.track_id
 join album2 on album2.album_id = track.album_id
 join artist on artist.artist_id = album2.artist_id
 group by 1
 order by 3 desc
 limit 1
 )
SELECT c.customer_id,c.first_name,c.last_name,bsa.artist_name,
sum(invoice_line.unit_price * invoice_line.quantity) as amount_spent
from invoice i
join customer c on
c.customer_id = i.customer_id
join invoice_line  on invoice_line.invoice_id = i.invoice_id
join track t on t.track_id = invoice_line.track_id
join album2 alb on alb.album_id = t.album_id
join best_selling_artist bsa on bsa.artist_id = alb.artist_id
group by 1,2,3,4
order by 5 desc;

-- 10)we want to find out the most popular music genre for each country.
-- We determine thee most popular genree asth genre with the highest amount of purchases

with popular_genre as
(
 select count(invoice_line.quantity) as purchase, customer.country,genre.name,genre.genre_id,
 row_number() over(partition by customer.country order by count(invoice_line.quantity) DESC) as RowNo
 from invoice_line
 join invoice on invoice.invoice_id = invoice_line.invoice_id
 join customer on customer.customer_id = invoice.customer_id
 join track on track.track_id = invoice_line.track_id
 join genre on genre.genre_id = track.genre_id
 group by 2,3,4
 order by 2 asc,1 desc
)
Select * from popular_genre where RowNo <= 1;

-- 11) Write a query that deteermines the customer that has spent thee most on music for each country. 
-- Write a query that reeturns th country along with the top customer and how much they spent.
-- for countries where the top amount spent us shared,provie all customers who has spent this amount

with RECURSIVE 
	customer_with_country as(
    SELECT customer.customer_id,first_name,last_name,billing_country,sum(total) as total_spending from invoice 
    join customer on customer.customer_id = invoice.customer_id
    group by 1,2,3,4
    order by 2,3 desc),
    
    country_max_spending as
    (
    select billing_country,max(total_spending) as max_spending
    from customer_with_country
    group by billing_country)
    
    select cc.billing_country,cc.total_spending,cc.first_name,cc.last_name,cc.customer_id
    from customer_with_country cc
    join country_max_spending ms
    on cc.billing_country = ms.billing_country
    where cc.total_spending = ms.max_spending
    order by 1;